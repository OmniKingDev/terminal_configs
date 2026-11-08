# Terminal Configurations

Personal **Fastfetch**, **Zsh**, and **Starship** configurations by O.K. Dev:

- **Fastfetch** displays hardware and system information.
- **Zsh** supplies aliases, plugins, history, and startup behavior. It launches Fastfetch on Linux pseudo-terminals and initializes Starship.
- **Starship** supplies three switchable prompt profiles.

Fastfetch and Starship can each be installed without this Zsh setup. Zsh can be used alone after disabling its Fastfetch and Starship calls, as described below.

## Prerequisites

These files originated on **Omarchy Linux**. The programs support Linux and macOS, but this configuration needs the platform adjustments below; it is not a ready-made macOS setup.

| Component | Requirements |
| --- | --- |
| All installations | Git; Bash or Zsh for the installation commands |
| Fastfetch | A recent [Fastfetch](https://github.com/fastfetch-cli/fastfetch#installation) release; the supplied configuration also calls Omarchy utilities |
| Zsh | Zsh, [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh#manual-installation) at `~/.oh-my-zsh`, and [fzf](https://github.com/junegunn/fzf#setting-up-shell-integration) with `fzf --zsh` support; Starship and Fastfetch unless their startup calls are removed |
| Starship | A recent [Starship](https://starship.rs/guide/) release and shell initialization; Git for repository information |

Install only the programs you need using your Linux distribution's package manager or the linked upstream instructions. On macOS, with Homebrew already installed, an all-components example is:

```sh
brew install git zsh fastfetch starship fzf eza
```

For Zsh, clone Oh My Zsh if it is not already installed (this does not replace your startup file):

```sh
git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
```

`20-customization` enables three plugins **not bundled with Oh My Zsh**: [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions), [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting), and [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting). Install them using their instructions, or remove their names from the installed module before starting Zsh. The other listed plugins are bundled; remove `archlinux` outside Arch-based Linux.

Optional tools used by aliases are `eza` (replaces `ls`, `ll`, `lt`), `tty-clock`, NetworkManager's `nmtui`, Hyprland's `hyprlock`, systemd's `systemctl`, and `grub-mkconfig`. Remove aliases for tools you do not use. Set `EDITOR` in `00-init` to an installed editor. Language runtimes are optional: `compact` displays versions when the corresponding tools/projects are available; its Bash version command uses `bash`, `head`, `awk`, and `cut`.

Select a Nerd Font in your terminal for the icons, and use a terminal with true-color support for the ASCII asset. The default image logo requires Kitty graphics support **and an image that is not included**.

**Path assumptions:** these instructions use `~/.config` and `~/.zshrc`. If you customize `XDG_CONFIG_HOME` or Zsh's `ZDOTDIR`, reconcile those paths first: `.zshrc` hardcodes `~/.config`, while `promptstyle` honors `XDG_CONFIG_HOME`. On macOS, ensure Homebrew programs are on `PATH` before Zsh loads this setup; no Homebrew initialization is supplied.

## Install the configurations

Run the following in Bash or Zsh. Choose an unused clone destination; if you already cloned the repository, set `repo` to that checkout and skip `git clone`.

```sh
repo="$HOME/terminal_configs"
git clone https://github.com/OmniKingDev/terminal_configs.git "$repo"
```

In the same terminal, choose **one or more** directory names in `components`: `fastfetch`, `starship`, or `zshrc` (for example, `components=(zshrc)` for Zsh alone). This block copies the selected configurations and moves any existing destinations, including symbolic links, to a new backup directory. Save the printed backup path. Stop if a command reports an error.

```sh
components=(fastfetch starship zshrc)
(
  set -e
  backup=$(mktemp -d "$HOME/terminal-configs-backup.XXXXXX")
  printf 'Backup: %s\n' "$backup"
  mkdir -p "$HOME/.config"
  for component in "${components[@]}"; do
    case "$component" in fastfetch|starship|zshrc) ;; *) exit 1 ;; esac
    test -d "$repo/$component"
    destination="$HOME/.config/$component"
    if [ -e "$destination" ] || [ -L "$destination" ]; then
      mv "$destination" "$backup/$component"
    fi
    cp -RP "$repo/$component" "$destination"
  done
)
```

These are independent copies, so edit the installed files under `~/.config`. `cp -RP` preserves Starship's symbolic link: a small filesystem pointer to another file. The tracked `starship/omni-os.toml` points to **`profiles/stack.toml`**, a relative target that works after cloning or copying the whole directory.

Complete the relevant sections below. For all three, prepare Fastfetch first, then activate Zsh; Zsh already initializes Starship.

## Fastfetch

`~/.config/fastfetch/config.jsonc` is the default configuration location (JSONC means JSON with comments). You can also select it explicitly with `--config`. See the [Fastfetch configuration reference](https://github.com/fastfetch-cli/fastfetch/wiki/Configuration).

Before using it on another machine, edit that installed file:

- The current `logo` uses `kitty-direct` and `~/Pictures/pictures/MAKIMA-PLAY-transparent.png`. That image is absent from this repository. To use the included colored ASCII art, replace the entire `logo` object with:

  ```json
  "logo": {
    "type": "file-raw",
    "source": "~/.config/fastfetch/ascii/eve-prime.txt"
  }
  ```

  Keep the comma after the object because `modules` follows it. `file-raw` preserves the asset's embedded ANSI colors; it does not need image-protocol support. See [logo options](https://github.com/fastfetch-cli/fastfetch/wiki/Logo-options).
- **Outside Omarchy:** remove the five `command` modules invoking `omarchy-version`, `omarchy-version-branch`, `omarchy-version-channel`, `omarchy-theme-current`, and `omarchy-version-pkgs`. You can insert `"os"` in the `modules` array for standard OS information.
- **macOS:** remove the OS Age `command` module; `stat -c %W /` uses GNU syntax unavailable in macOS's default `stat`. Even on Linux, root-directory birth time is not a reliable installation date. Remove the GPU's `"detectionMethod": "pci"` override to allow automatic detection. Window-manager, theme, and hardware fields may vary or be unavailable across systems.

Run it manually; no Zsh or Starship installation is needed:

```sh
fastfetch --config "$HOME/.config/fastfetch/config.jsonc"
```

The ASCII file is **not loaded by the original configuration**. To try it without changing the logo settings:

```sh
fastfetch --config "$HOME/.config/fastfetch/config.jsonc" \
  --file-raw "$HOME/.config/fastfetch/ascii/eve-prime.txt"
```

This overrides only the logo, not the Omarchy-specific modules.

## Zsh

Zsh reads `.zshrc` when starting an interactive shell. This repository's file loads non-directory, non-hidden entries from `~/.config/zshrc` in filename order:

| File | Responsibility |
| --- | --- |
| `00-init` | Editor, Oh My Zsh location, deduplicated `PATH`; adds Go, Cargo, and Odin paths |
| `20-customization` | Oh My Zsh plugins, fzf bindings (including Ctrl-R history search), 10,000-entry history |
| `25-aliases` | Navigation, file listings, Git, and desktop/system shortcuts |
| `30-autostart` | Runs Fastfetch only when `tty` contains `pts` |

For each file, `custom/<same-filename>` replaces the original when present. The actual expression also falls back to the original if sourcing the override returns failure. Directories are skipped, so **`user/functions` is not loaded automatically**. After the loop, `.zshrc` loads `~/.zshrc_custom` if present, initializes Starship, optionally sources `~/.config/envman/load.sh`, and enables vi-style editing with `bindkey -v`.

Before activation, edit the installed files:

- Review the plugins and editor from Prerequisites. Remove unused Go/Cargo/Odin paths in `00-init`; these directories are not supplied.
- Review Linux-specific `shutdown`, `wifi`, `lock`, and `update-grub` aliases, especially on macOS. Review any existing `~/.zshrc_custom`, which will still run.
- **Without Starship:** remove the `export STARSHIP_CONFIG=...` and `eval "$(starship init zsh)"` lines from `~/.config/zshrc/.zshrc`. To keep your own Starship configuration instead, change the export to its path.
- **Without Fastfetch:** empty `~/.config/zshrc/30-autostart` and remove `nf`, `pf`, and `ff` from `25-aliases`.
- **macOS startup display:** `/dev/ttys...` does not match `pts`. If desired, replace the condition in `30-autostart` with `if [[ -t 1 ]] && command -v fastfetch >/dev/null 2>&1; then`, retaining `fastfetch` and `fi` below it.

Activate your prepared startup file, preserving the old one in a separate backup:

```sh
(
  set -e
  test -f "$HOME/.config/zshrc/.zshrc"
  backup=$(mktemp -d "$HOME/terminal-configs-backup.XXXXXX")
  printf 'Startup backup: %s\n' "$backup"
  if [ -e "$HOME/.zshrc" ] || [ -L "$HOME/.zshrc" ]; then
    mv "$HOME/.zshrc" "$backup/.zshrc"
  fi
  cp "$HOME/.config/zshrc/.zshrc" "$HOME/.zshrc"
)
zsh
```

Keep the original terminal open while testing. `zsh` starts a child shell; `exit` returns to the previous one. This does not change your login shell. Future startup edits belong in `~/.zshrc`; the installed `zshrc/.zshrc` was only the activation source.

## Starship and profile switching

`omni-os.toml` is a link selecting one complete profile, not a file that merges the profiles:

| Profile | Appearance |
| --- | --- |
| `stack` (default) | One line: success/failure skull, current directory, Git branch/status, dirty-worktree marker |
| `compact` | Two lines: language/file-type indicators and Git information above the current directory |
| `kali` | Two-line framed prompt with directory, branch, commit/tag, Git state/status, and added/deleted line counts |

**Starship alone:** keep your existing shell setup. Before editing its startup file, make a backup; for Zsh:

```sh
backup=$(mktemp -d "$HOME/terminal-configs-backup.XXXXXX")
printf 'Startup backup: %s\n' "$backup"
if [ -e "$HOME/.zshrc" ] || [ -L "$HOME/.zshrc" ]; then
  cp -P "$HOME/.zshrc" "$backup/.zshrc"
fi
if [ -f "$HOME/.zshrc" ]; then
  cp -L "$HOME/.zshrc" "$backup/.zshrc.contents"
fi
```

This saves both the original file/link and its contents. Add these lines to `~/.zshrc`, replacing any existing Starship initialization to avoid duplicates:

```zsh
export STARSHIP_CONFIG="$HOME/.config/starship/omni-os.toml"
eval "$(starship init zsh)"
```

The supplied Zsh setup already contains these lines. For Bash, use the same export and `eval "$(starship init bash)"` in `~/.bashrc`, after backing it up. Other shells have their own [initialization instructions](https://starship.rs/guide/); `STARSHIP_CONFIG` selects this non-default path as described in the [configuration reference](https://starship.rs/config/#config-file-location).

**Enable `promptstyle` in Zsh:** after backing up `~/.zshrc`, add this line (adjust the clone path if needed). It works with either your existing Zsh setup or this repository's:

```zsh
source "$HOME/terminal_configs/zshrc/user/functions"
```

If you installed this repository's Zsh configuration, you can source `~/.config/zshrc/user/functions` instead to use the installed copy. Open a new Zsh shell; list the profiles, then select one:

```zsh
promptstyle
promptstyle compact
```

The function checks that the profile exists and replaces the active link with `profiles/<name>.toml`. The next prompt uses that profile; the choice persists across shells. The helper is Zsh-specific. In another shell, switch manually:

```sh
ln -sfn profiles/kali.toml "$HOME/.config/starship/omni-os.toml"
```

## Customize and maintain

- **Aliases/startup:** edit the installed numbered modules or their matching `custom/` overrides. Keep backup files outside `~/.config/zshrc`'s top level: the loader sources every non-hidden file there, not just numbered ones. Use `~/.zshrc_custom` for extra settings; it runs before Starship initialization and the final vi keybindings.
- **Prompts:** edit `~/.config/starship/profiles/*.toml`, or add another `.toml` profile and select it with `promptstyle`.
- **Fastfetch:** edit `config.jsonc` for modules, labels, colors, and logo settings; edit or replace `ascii/eve-prime.txt` for the artwork.

To update the checkout:

```sh
git -C "$HOME/terminal_configs" status --short
git -C "$HOME/terminal_configs" pull --ff-only
```

If status shows local changes, preserve/reconcile them before pulling. Installed copies do not update automatically: compare upstream files with your installed versions and merge desired changes. Re-running installation backs up the current copies but replaces their customizations; reinstalling Starship also resets its selection to the checkout's active profile.

The active Starship link is tracked by Git. With this copy-based setup, switching installed profiles does not dirty the checkout. If you instead link the entire installed directory to the checkout, `promptstyle` changes that tracked link; record your choice and reconcile that change before updating. Do not discard it blindly.

**Disable components:** empty `30-autostart` to stop startup Fastfetch while keeping manual use. Remove Starship initialization and its export from your shell startup file to disable the prompt. Start a fresh shell after changes. Use `zsh -f` for a shell that skips your `.zshrc` if startup breaks.

**Restore or uninstall:** first remove startup lines that refer to the component. Move its installed directory to a new holding directory, then move the original directory back from the printed backup path. For example, restoring Fastfetch (replace the backup path first):

```sh
backup="$HOME/terminal-configs-backup.REPLACE_ME"
(
  set -e
  test -e "$backup/fastfetch" || test -L "$backup/fastfetch"
  holding=$(mktemp -d "$HOME/terminal-configs-removed.XXXXXX")
  mv "$HOME/.config/fastfetch" "$holding/fastfetch"
  mv "$backup/fastfetch" "$HOME/.config/fastfetch"
)
```

Use the same move-and-restore approach for `starship`, `zshrc`, and the separately backed-up `~/.zshrc`. To remove this Zsh setup, restore `~/.zshrc` before moving its modules aside. If there was no original, just move the installed item aside. A backed-up symbolic link still needs its target; keep that target intact. Remove any function-source lines you added before deleting the checkout. Keep backups until a new terminal works; uninstalling these files does not require removing the programs themselves.

## Troubleshooting

- **Missing plugins or commands at startup:** check Oh My Zsh's location, installed plugins, `PATH`, and `fzf --zsh`. Remove unused integrations before starting another shell.
- **`ls` fails:** install `eza` or remove its aliases. **Squares instead of icons:** select a Nerd Font in the terminal settings.
- **No Fastfetch on macOS:** the original `pts` test excludes macOS terminal names. **Missing logo or Omarchy errors:** apply the Fastfetch adaptations above.
- **`promptstyle` is missing:** explicitly source `user/functions`. **Switching has no effect:** check `echo "$STARSHIP_CONFIG"` and `readlink "$HOME/.config/starship/omni-os.toml"`; the helper and Starship must use the same configuration directory, particularly when `XDG_CONFIG_HOME` is set.
- **Slow `stack` prompt in large repositories:** its custom dirty marker runs `git status --porcelain` with `ignore_timeout = true`. Remove `${custom.git_dirty}` from that profile's `format` to disable it.
