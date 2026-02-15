# Run `make` to see commands

.PHONY: help all stow dry-run unstow
.DEFAULT_GOAL := help

STOW := stow
STOW_FLAGS := -v --restow --target=$(HOME)

UNAME_S    := $(shell uname -s)

# OS-specific targets
ifeq ($(UNAME_S),Darwin)
    VSCODE_TARGET := $(HOME)/Library/Application Support/Code/User
else ifeq ($(UNAME_S),Linux)
    VSCODE_TARGET := $(HOME)/.config/Code/User
else
    $(error Unsupported OS: $(UNAME_S))
endif

PACKAGES := $(wildcard */)
PACKAGES := $(filter-out vscode/,$(PACKAGES))

help:
	@echo "Commands:"
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

all stow install: ## Stow all
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

unstow delete clean: ## Unstow all
	stow -v --target=$(HOME) -D $(PACKAGES)
	stow -v --target="$(VSCODE_TARGET)" -D vscode

unstow-%: ## Unstow single package
	@if [ "$*" = "vscode" ]; then \
	    $(STOW) -v --target="$(VSCODE_TARGET)" -D $*; \
	else \
	    $(STOW) -v --target=$(HOME) -D $*; \
	fi
