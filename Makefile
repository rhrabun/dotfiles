# Run `make` to see commands

.PHONY: help all stow dry-run unstow
.DEFAULT_GOAL := help

STOW_FLAGS := -v --restow --target=$(HOME)

UNAME_S    := $(shell uname -s)

PACKAGES := $(wildcard */)
PACKAGES := $(filter-out vscode/,$(PACKAGES))

# OS-specific packages
LINUX_PACKAGES=hyprland/
MACOS_PACKAGES=aerospace/

# OS-specific package lists and targets
ifeq ($(UNAME_S),Darwin)
	PACKAGES := $(filter-out $(LINUX_PACKAGES),$(PACKAGES))
	
	VSCODE_TARGET := $(HOME)/Library/Application Support/Code/User
else ifeq ($(UNAME_S),Linux)
	PACKAGES := $(filter-out $(MACOS_PACKAGES),$(PACKAGES))
	
	VSCODE_TARGET := $(HOME)/.config/Code/User
else
    $(error Unsupported OS: $(UNAME_S))
endif

help: ## Show commands
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[$$()% a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	
all stow: ## Stow all
	stow $(STOW_FLAGS) $(PACKAGES)
	stow -v --restow --target="$(VSCODE_TARGET)" vscode

stow-%: ## Stow any single package
	@if [ "$*" = "vscode" ]; then \
		stow -v --restow --target="$(VSCODE_TARGET)" $*; \
	else \
		stow $(STOW_FLAGS) $*; \
	fi

dry-run: ## Dry-run all
	stow -n $(STOW_FLAGS) $(PACKAGES)
	stow -n -v --restow --target="$(VSCODE_TARGET)" vscode

dry-stow-%: ## Dry-run single package
	@if [ "$*" = "vscode" ]; then \
		stow -n -v --restow --target="$(VSCODE_TARGET)" $*; \
	else \
		stow -n $(STOW_FLAGS) $*; \
	fi

unstow delete: ## Unstow all
	stow -v --target=$(HOME) -D $(PACKAGES)
	stow -v --target="$(VSCODE_TARGET)" -D vscode

unstow-%: ## Unstow single package
	@if [ "$*" = "vscode" ]; then \
	    stow -v --target="$(VSCODE_TARGET)" -D $*; \
	else \
	    stow -v --target=$(HOME) -D $*; \
	fi
