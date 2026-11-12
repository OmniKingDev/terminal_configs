# Terminal Configurations

Personal **Fastfetch**, **Zsh**, and **Starship** configurations by O.K. Dev:

- **Fastfetch** displays hardware and system information.
- **Zsh** supplies aliases, plugins, history, and startup behavior. It launches Fastfetch in terminals on both operating systems and initializes Starship.
- **Starship** supplies three switchable prompt profiles.

One repository, one configuration structure, and one shared `main` branch serve **Omarchy Linux and macOS**. Platform checks select the behavior that differs; separate OS branches or configuration trees are not needed. Images and other machine-specific preferences stay local.

Fastfetch and Starship can each be installed without this Zsh setup. Zsh can be used alone after disabling its Starship initialization; Fastfetch startup is already conditional on the program being installed.

## Prerequisites

These files originated on Omarchy Linux and now share Linux/macOS support. Other Linux distributions need adaptation of the Omarchy-specific Fastfetch commands, which check for Linux rather than for Omarchy itself.

| Component | Requirements |
| --- | --- |
| All installations | Git; Bash or Zsh for the installation commands |
| Fastfetch | A recent [Fastfetch](https://github.com/fastfetch-cli/fastfetch#installation) release supporting module `condition.system` and logo-source shell expansion; Omarchy utilities on Linux |
| Zsh | Zsh, [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh#manual-installation) at `~/.oh-my-zsh`, its external plugins below, and [fzf](https://github.com/junegunn/fzf#setting-up-shell-integration) with `fzf --zsh` support; Starship unless its initialization is removed |
| Starship | A recent [Starship](https://starship.rs/guide/) release and shell initialization; Git for repository information |
| Image selector | Zsh, `fzf`, and either optional `fd` or the system's GNU/BSD `find`; `head` is used with `fd` |

Install only the programs you need. For all three components on **Omarchy/Arch Linux** (this also performs the normal system upgrade):

```sh
sudo pacman -Syu --needed git zsh fastfetch starship fzf eza
```

On **macOS**, with Homebrew already installed:

```sh
brew install git zsh fastfetch starship fzf eza
```

For Zsh, clone Oh My Zsh if it is not already installed (this does not replace your startup file):

```sh
git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
```

`20-customization` enables three plugins **not bundled with Oh My Zsh**: [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions), [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting), and [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting). Install them using their Oh My Zsh instructions, or remove their names from the installed module before starting Zsh. The other listed plugins are bundled; `archlinux` is added only when `/etc/arch-release` exists.

Optional tools used by aliases are `eza` (replaces `ls`, `ll`, `lt`), `tty-clock`, NetworkManager's `nmtui`, Hyprland's `hyprlock`, systemd's `systemctl`, and `grub-mkconfig`. Remove aliases for tools you do not use. Set `EDITOR` in `00-init` to an installed editor. Language runtimes are optional: `compact` displays versions when the corresponding tools/projects are available; its Bash version command uses `bash`, `head`, `awk`, and `cut`.

Select a Nerd Font in your terminal for Starship and other icons, and use a terminal with true-color support for the ASCII asset. The default `kitty-direct` image logo needs a compatible terminal and a locally selected image; the repository does not include a default image. See Fastfetch below for format limitations and the ASCII alternative.

**Path assumptions:** these instructions use `~/.config` and `~/.zshrc`. If you customize `XDG_CONFIG_HOME` or Zsh's `ZDOTDIR`, reconcile those paths first: `.zshrc`, `fflogo`, and the logo source use `~/.config`, while `promptstyle` honors `XDG_CONFIG_HOME`. On macOS, `.zshrc` initializes Homebrew from `/opt/homebrew/bin/brew` or `/usr/local/bin/brew`, using the first executable found; nonstandard Homebrew locations need your own initialization.

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

Complete the relevant sections below. For all three, activate Zsh, then run `fflogo` to choose this machine's image. Zsh already initializes Starship and loads the helper functions.

## Fastfetch

`~/.config/fastfetch/config.jsonc` is the default configuration location (JSONC means JSON with comments). You can also select it explicitly with `--config`. See the [Fastfetch configuration reference](https://github.com/fastfetch-cli/fastfetch/wiki/Configuration).

The shared layout includes host, CPU, GPU, display, disk, memory, swap, kernel, desktop/window manager, terminal, packages, terminal font, and uptime. GPU detection uses Fastfetch's default automatic behavior; no PCI-only override is set. Available fields vary with the OS, hardware, and desktop session.

- **Linux/Omarchy:** `condition.system = Linux` enables Omarchy version, branch, channel, theme, package-update time, and OS Age. These use `omarchy-version`, `omarchy-version-branch`, `omarchy-version-channel`, `omarchy-theme-current`, and `omarchy-version-pkgs`. OS Age uses GNU `stat -c %W /`; root-directory birth time is only an approximation, not a reliable installation date.
- **macOS:** its conditional built-in `os` module provides OS information. The Linux commands above are skipped automatically, including GNU `stat`.
- **Other Linux:** remove or adapt the Omarchy command modules in the installed copy and add a standard `"os"` module. The Linux condition does not check whether Omarchy utilities exist.

Run it manually; no Zsh or Starship installation is needed:

```sh
fastfetch --config "$HOME/.config/fastfetch/config.jsonc"
```

### Choose a local image with `fflogo`

The logo source reads the path saved in **`~/.config/fastfetch-logo`** through shell expansion. Each machine can select its own image without editing the Git-tracked JSONC. The path file is outside both the checkout and the installed `fastfetch/` directory, so reinstalling that directory preserves the choice.

With the supplied Zsh setup, `fflogo` is available automatically. For Fastfetch alone, run Zsh and load just the helper file from your checkout:

```zsh
source "$HOME/terminal_configs/zshrc/user/functions"
```

The selector finds the first directory directly under `$HOME` named `Pictures`, ignoring capitalization. It prefers `fd` when available; otherwise it uses `find` with options supported by GNU find on Linux and BSD find on macOS. It recursively lists `.png`, `.jpg`, `.jpeg`, and `.webp` files, ignoring extension case, then opens `fzf` for **you** to choose. It does not search for a particular image or choose one automatically. Cancelling leaves the existing selection unchanged.

Put your images in that Pictures directory, then run:

```zsh
fflogo
cat "$HOME/.config/fastfetch-logo"
fastfetch --config "$HOME/.config/fastfetch/config.jsonc" --show-errors
```

Use the picker to select an image and press Enter. The last command lets you visually verify the result in your terminal. Re-run `fflogo` whenever you want to change the image; moving or deleting the selected file requires selecting it again.

The selector filters filenames, not image validity or terminal support. `kitty-direct` requires compatible Kitty graphics handling; PNG is the safest choice, and Kitty/Ghostty support PNG for this mode even though the picker also lists JPEG/WebP. It does not automatically switch to iTerm graphics on macOS. See Fastfetch's [logo options](https://github.com/fastfetch-cli/fastfetch/wiki/Logo-options#kitty-direct) for terminal compatibility. No image is selected on a fresh install, so run `fflogo` before expecting a custom logo.

The bundled colored ASCII file is an alternative that needs no image protocol and is **not loaded by default**. Try it without changing the configuration:

```sh
fastfetch --config "$HOME/.config/fastfetch/config.jsonc" \
  --file-raw "$HOME/.config/fastfetch/ascii/eve-prime.txt"
```

To make the ASCII alternative permanent, set the installed configuration's `logo.type` to `file-raw` and `logo.source` to `~/.config/fastfetch/ascii/eve-prime.txt`. This bypasses the local image choice.

## Zsh

Zsh reads `.zshrc` when starting an interactive shell. This repository's file first initializes Homebrew on macOS, then loads non-directory, non-hidden entries from `~/.config/zshrc` in filename order:

| File | Responsibility |
| --- | --- |
| `00-init` | Editor, Oh My Zsh location, deduplicated `PATH`; adds Go, Cargo, and Odin paths |
| `20-customization` | Oh My Zsh plugins, conditional Arch integration, fzf bindings (including Ctrl-R history search), 10,000-entry history |
| `25-aliases` | Navigation, file listings, Git, and desktop/system shortcuts; Linux aliases are gated by `OSTYPE` |
| `30-autostart` | Runs Fastfetch when standard output is a terminal (`-t 1`) and the program is installed, on either OS |
| `user/functions` | Defines `promptstyle` and `fflogo`; explicitly sourced after the numbered modules |

For each top-level file, `custom/<same-filename>` replaces the original when present. The actual expression also falls back to the original if sourcing the override returns failure. The loop skips directories. After it, `.zshrc` loads `~/.zshrc_custom` if present, explicitly sources `user/functions` if present, initializes Starship with `~/.config/starship/omni-os.toml`, optionally sources `~/.config/envman/load.sh`, and enables vi-style editing with `bindkey -v`.

Before activation, edit the installed files:

- Review the plugins and editor from Prerequisites. Remove unused Go/Cargo/Odin paths in `00-init`; these directories are not supplied.
- On Linux, review `shutdown`, `wifi`, `lock`, and `update-grub`: they require systemd, NetworkManager, Hyprlock, and GRUB respectively. They are not defined on macOS. Review any existing `~/.zshrc_custom`, which will still run.
- **Without Starship:** remove the `export STARSHIP_CONFIG=...` and `eval "$(starship init zsh)"` lines from `~/.config/zshrc/.zshrc`. To keep your own Starship configuration instead, change the export to its path.
- **Without Fastfetch:** startup skips it automatically. Remove the unused `ff` alias from `25-aliases` if desired. To keep Fastfetch installed but stop startup output, empty `30-autostart`.

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

**`promptstyle` is loaded automatically by the supplied Zsh setup.** For Starship alone in an existing Zsh setup, back up `~/.zshrc` and add this line (adjust the clone path if needed):

```zsh
source "$HOME/terminal_configs/zshrc/user/functions"
```

Open a new Zsh shell; list the profiles, then select one:

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

### Synchronize Linux and macOS

The **Git checkout** holds the shared configuration. The **installed copies** under `~/.config` and `~/.zshrc` are what your shell uses. Keep changes intended for both platforms in the shared repository/main branch; keep these machine-specific settings local:

| Local setting | Location |
| --- | --- |
| Selected Fastfetch image path | `~/.config/fastfetch-logo` (the image itself also stays local) |
| Selected prompt profile | Installed `~/.config/starship/omni-os.toml` symlink |
| Personal shell settings/module overrides | `~/.zshrc_custom` and installed `~/.config/zshrc/custom/` |

On **each machine**, use this update workflow:

1. Check the checkout for local changes. Preserve/reconcile any changes before pulling; do not discard them blindly.

```sh
git -C "$HOME/terminal_configs" status --short
```

2. Pull updates into the checkout (adjust the path if you cloned elsewhere):

```sh
git -C "$HOME/terminal_configs" pull --ff-only
```

3. **`git pull` does not update installed configurations.** Record your current profile with `readlink "$HOME/.config/starship/omni-os.toml"` if Starship is installed. Re-run the configuration-copy block with `repo` pointing to the updated checkout and only the components you want to refresh. It backs up the old directories before copying. Review those backups and reapply local edits/`custom/` overrides rather than overwriting new shared files wholesale.
4. If updating Zsh, also re-run its activation block to back up and replace `~/.zshrc`; copying the module directory alone does not update this startup file. Reapply any local startup edits, open a new shell, and restore your chosen profile with `promptstyle`. Reinstalling Starship resets its selection to the checkout's profile. `~/.config/fastfetch-logo` and `~/.zshrc_custom` are outside the replaced directories and remain untouched.

Alternatively, back up the installed files and manually merge desired changes. Do not synchronize one machine's absolute image path to another; run `fflogo` there instead. The active Starship link is tracked by Git, but with this copy-based setup, switching installed profiles does not dirty the checkout. Linking the entire installed directory to the checkout would change that behavior: `promptstyle` would modify the tracked link.

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

Use the same move-and-restore approach for `starship`, `zshrc`, and the separately backed-up `~/.zshrc`. To remove this Zsh setup, restore `~/.zshrc` before moving its modules aside. If there was no original, just move the installed item aside. A backed-up symbolic link still needs its target; keep that target intact. Remove any function-source lines you added before deleting the checkout. The local `~/.config/fastfetch-logo` can also be moved aside when removing Fastfetch; this does not delete the image. Keep backups until a new terminal works; uninstalling these files does not require removing the programs themselves.

## Troubleshooting

- **Missing plugins or commands at startup:** check Oh My Zsh's location, installed plugins, `PATH`, and `fzf --zsh`. Remove unused integrations before starting another shell.
- **`ls` fails:** install `eza` or remove its aliases. **Squares instead of icons:** select a Nerd Font in the terminal settings.
- **No Fastfetch at startup:** verify it is on `PATH` and output is a terminal; redirected output is intentionally skipped. If upgrading from an older version, refresh both the modules and `~/.zshrc`.
- **No image:** run `fflogo`, check `cat "$HOME/.config/fastfetch-logo"`, and use `fastfetch --show-errors` in a compatible terminal. Choose PNG if JPEG/WebP fails. On macOS, allow terminal access to Pictures if prompted. The `fd` search skips hidden/ignored files by default, while `find` may list them.
- **`fflogo` cannot find Pictures:** it needs an actual directory directly under `$HOME` with that name (any capitalization); a symlink or a nested Pictures directory is not matched. Empty/cancelled selections do not update the path file.
- **Omarchy errors on other Linux distributions:** the Fastfetch conditions only distinguish operating systems; adapt the Omarchy command modules as described above.
- **`promptstyle` or `fflogo` is missing:** check the installed `user/functions` and refresh `~/.zshrc`; standalone users must source the helper explicitly. **Switching has no effect:** check `echo "$STARSHIP_CONFIG"` and `readlink "$HOME/.config/starship/omni-os.toml"`; the helper and Starship must use the same directory, particularly when `XDG_CONFIG_HOME` is set.
- **Slow `stack` prompt in large repositories:** its custom dirty marker runs `git status --porcelain` with `ignore_timeout = true`. Remove `${custom.git_dirty}` from that profile's `format` to disable it.
