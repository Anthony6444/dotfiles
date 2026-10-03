#!/usr/bin/env bash
set -uo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
BIN_DIR="$HOME/.local/bin"

DOTS=(
	.bashrc
	.bash_aliases
	.bash_wrappers
)

if [ -t 1 ]; then
	RED=$'\e[31m'; GREEN=$'\e[32m'; YELLOW=$'\e[33m'; BLUE=$'\e[34m'; DIM=$'\e[2m'; RESET=$'\e[0m'
else
	RED=''; GREEN=''; YELLOW=''; BLUE=''; DIM=''; RESET=''
fi

info()  { printf '%s==>%s %s\n' "$BLUE" "$RESET" "$*"; }
ok()    { printf '  %s✓%s %s\n' "$GREEN" "$RESET" "$*"; }
skip()  { printf '  %s-%s %s%s%s\n' "$DIM" "$RESET" "$DIM" "$*" "$RESET"; }
warn()  { printf '  %s!%s %s\n' "$YELLOW" "$RESET" "$*"; }
fail()  { printf '  %s✗%s %s\n' "$RED" "$RESET" "$*"; errors=$((errors + 1)); }

errors=0
linked=0
backed_up=0

backup() {
	local target="$1"
	mkdir -p "$BACKUP_DIR" || return 1
	mv "$target" "$BACKUP_DIR/" || return 1
	warn "backed up existing $(basename "$target") -> $BACKUP_DIR/"
	backed_up=$((backed_up + 1))
}

link() {
	local src="$1" target="$2" name="${2#$HOME/}"

	if [ ! -e "$src" ]; then
		fail "missing source: ${src#$DOTFILES/}"
		return
	fi

	if [ -L "$target" ] && [ "$(readlink -f "$target")" = "$(readlink -f "$src")" ]; then
		skip "~/$name already linked"
		return
	fi

	if [ -e "$target" ] || [ -L "$target" ]; then
		backup "$target" || { fail "could not back up ~/$name"; return; }
	fi

	mkdir -p "$(dirname "$target")"
	if ln -s "$src" "$target"; then
		ok "~/$name -> ${src#$DOTFILES/}"
		linked=$((linked + 1))
	else
		fail "could not link ~/$name"
	fi
}

printf '%sInstalling dotfiles from%s %s\n\n' "$BLUE" "$RESET" "$DOTFILES"

info "Shell config"
for f in "${DOTS[@]}"; do
	link "$DOTFILES/$f" "$HOME/$f"
done

info "Scripts"
shopt -s nullglob
scripts=("$DOTFILES"/scripts/*)
if [ ${#scripts[@]} -eq 0 ]; then
	skip "no scripts to install"
else
	mkdir -p "$BIN_DIR"
	for s in "${scripts[@]}"; do
		[ -f "$s" ] || continue
		[ -x "$s" ] || chmod +x "$s"
		link "$s" "$BIN_DIR/$(basename "$s")"
	done
fi
shopt -u nullglob

info "Checking dependencies"
for cmd in nvim bat zoxide kitty go wl-copy; do
	if command -v "$cmd" >/dev/null 2>&1; then
		ok "$cmd"
	else
		warn "$cmd not found (referenced by these dotfiles)"
	fi
done

printf '\n'
if [ "$errors" -eq 0 ]; then
	printf '%sDone.%s %d link(s) created' "$GREEN" "$RESET" "$linked"
else
	printf '%sFinished with %d error(s).%s %d link(s) created' "$RED" "$errors" "$RESET" "$linked"
fi
[ "$backed_up" -gt 0 ] && printf ', %d file(s) backed up to %s' "$backed_up" "$BACKUP_DIR"
printf '.\n'
[ "$linked" -gt 0 ] && printf 'Run %ssource ~/.bashrc%s or open a new shell to pick up the changes.\n' "$DIM" "$RESET"

exit $(( errors > 0 ))
