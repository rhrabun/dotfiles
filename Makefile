# Run `make` to see commands

.PHONY: help all stow dry-run unstow
.DEFAULT_GOAL := help

STOW := stow -v --restow
UNSTOW := stow -D -v
STOW-DRY := stow -n -v --restow
UNAME_S := $(shell uname -s)

PACKAGES := $(wildcard */)

# Filter out packages that should not be stowed
PACKAGES := $(filter-out obsidian/,$(PACKAGES))

# OS-specific packages
LINUX_PACKAGES=hyprland/
MACOS_PACKAGES=aerospace/

ifeq ($(UNAME_S),Darwin)
	PACKAGES := $(filter-out $(LINUX_PACKAGES),$(PACKAGES))
else ifeq ($(UNAME_S),Linux)
	PACKAGES := $(filter-out $(MACOS_PACKAGES),$(PACKAGES))
else
    $(error Unsupported OS: $(UNAME_S))
endif


# Define target file for each package based on the OS
# If target file exists, read package target directory from it
# Otherwise, use default home directory
define stow_cmd
	target_file="$(2).target-$(UNAME_S)"; \
	if [ -f "$$target_file" ]; then \
		target=$$(cat "$$target_file" | xargs); \
		$(1) --target="$(HOME)/$$target" $(2); \
	else \
		$(1) --target=$(HOME) $(2); \
	fi
endef

help: ## Show commands
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[$$()% a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

all stow: ## Stow all
	for package in $(PACKAGES); do \
		$(call stow_cmd,$(STOW),$$package); \
	done

stow-%: ## Stow any single package
	$(call stow_cmd,$(STOW),"$*/")

dry-run: ## Dry-run all
	for package in $(PACKAGES); do \
		$(call stow_cmd,$(STOW-DRY),$$package); \
	done

dry-stow-%: ## Dry-run single package
	$(call stow_cmd,$(STOW-DRY),"$*/")

unstow delete: ## Unstow all
	for package in $(PACKAGES); do \
		$(call stow_cmd,$(UNSTOW),$$package); \
	done

unstow-%: ## Unstow single package
	$(call stow_cmd,$(UNSTOW),"$*/")
