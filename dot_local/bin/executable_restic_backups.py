#!/usr/bin/env python3
# Makefile-style wrapper for day-to-day restic operations.
# Repos/paths/password live in ~/.config/restic/config.toml (chezmoi-managed, encrypted).

import argparse
import os
import subprocess
import sys
from pathlib import Path

CONFIG = Path("~/.config/restic/config.toml").expanduser()


def load_config():
    if not CONFIG.is_file():
        sys.exit(f"config not found: {CONFIG}")
    import tomllib

    with open(CONFIG, "rb") as f:
        return tomllib.load(f)


def expand(path):
    return Path(os.path.expandvars(os.path.expanduser(path)))


def run_repo(repo_name, repo_path, password_file, args, verbose):
    env = os.environ.copy()
    env["RESTIC_REPOSITORY"] = str(repo_path)
    env["RESTIC_PASSWORD_FILE"] = str(password_file)
    if verbose:
        print(f"\trestic {' '.join(args)}")
    return subprocess.run(["restic", *args], env=env, check=False).returncode


def main():
    parser = argparse.ArgumentParser(
        prog="restic_backups",
        description="Makefile-style wrapper for restic. First arg is the restic "
        "subcommand run against every repo: 'backup' backs up, 'all' runs "
        "backup+forget+check, 'check' defaults to reading a random 15% of data. "
        "Remaining args pass through to restic.",
    )
    parser.add_argument(
        "-r", "--repo", help="limit to one repo (name or path substring)"
    )
    parser.add_argument(
        "-v", "--verbose", action="store_true", help="print exact restic commands"
    )
    parser.add_argument(
        "command",
        help="restic subcommand to run per repo (e.g. backup, all, check, forget)",
    )
    parser.add_argument(
        "args", nargs=argparse.REMAINDER, help="arguments for the restic command"
    )
    opts = parser.parse_args()

    cfg = load_config()
    password_file = expand(cfg["password_file"])
    if not password_file.is_file():
        print(f"WARNING: password file missing: {password_file}", file=sys.stderr)

    repos = cfg.get("repos", [])
    if opts.repo:
        repos = [r for r in repos if opts.repo in r["name"] or opts.repo in r["repo"]]
        if not repos:
            sys.exit(f"no repo matches: {opts.repo}")

    def backup_args(extra):
        paths = [str(expand(p)) for p in (extra or cfg.get("paths", []))]
        excludes = [f"--exclude={p}" for p in cfg.get("excludes", [])]
        return [*excludes, *paths]

    def forget_args(extra):
        return extra or [*cfg.get("retention", []), "--prune"]

    def check_args(extra):
        return extra or ["--read-data-subset=15%"]

    if opts.command == "all":
        commands = [
            ("backup", backup_args(opts.args)),
            ("forget", forget_args(opts.args)),
            ("check", check_args([])),
        ]
    elif opts.command == "backup":
        commands = [("backup", backup_args(opts.args))]
    elif opts.command == "forget":
        commands = [("forget", forget_args(opts.args))]
    elif opts.command == "check":
        commands = [("check", check_args(opts.args))]
    else:
        commands = [(opts.command, opts.args)]

    failed = []
    for repo in repos:
        repo_path = expand(repo["repo"])
        name = repo["name"]
        print(f"== {name} ({repo_path}) ==")
        if not repo_path.is_dir() and opts.command != "init":
            print("\tWARNING: repo dir missing, skipping", file=sys.stderr)
            failed.append(name)
        else:
            for cmd, args in commands:
                rc = run_repo(name, repo_path, password_file, [cmd, *args], opts.verbose)
                if rc != 0:
                    print(f"\tFAILED: restic {cmd} rc={rc}", file=sys.stderr)
                    failed.append(name)
        print()

    if failed:
        sys.exit(f"failed repos: {', '.join(sorted(set(failed)))}")
    print("done")


if __name__ == "__main__":
    main()
