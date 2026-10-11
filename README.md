# Tron: Ares Terminal

Four neon terminal themes with matching Bash Powerline prompts and a reusable,
four-pane tmux workspace. Built for GNOME Terminal on Ubuntu; the desktop GTK
theme is unchanged.

> This setup was AI-generated and works on my computer. It has been tested locally;
> other systems may need adjustments.

![Blue and green Powerline panes in work1](screenshots/work1.png)
![Red and yellow Powerline panes in work2](screenshots/work2.png)

Screenshots show a sample workspace captured on my computer with Hack Nerd Font
Mono and generic user/host labels. The shared profiles use the packaged Powerline font.

## Install

Start in a terminal in your Ubuntu GNOME desktop session.

1. Install Git and the required packages:

   ```bash
   sudo apt update
   sudo apt install git python3 gnome-terminal tmux powerline fonts-powerline fontconfig dconf-cli
   ```

2. Clone this repository and enter its folder:

   ```bash
   git clone https://github.com/bigg01/tron-ares-terminal.git
   cd tron-ares-terminal
   ```

3. Run the installer as your regular user:

   ```bash
   ./install.sh
   ```

Only the package installation needs `sudo`; do not run `install.sh` with `sudo`.
If you downloaded the repository as a ZIP instead, extract it, enter the extracted
folder, and run `bash install.sh` after installing the prerequisites.

Run this as your regular user in a graphical desktop session. The installer adds
**Tron: Ares — Green**, **Red**, **Blue**, and **Yellow** profiles, configures Bash,
and installs `~/.local/bin/tmux-work`. It keeps the default terminal profile.
Existing Bash, terminal, Powerline profile, and launcher settings are backed up
before replacement. Reinstalling updates the same four named terminal profiles.

Profiles use **DejaVu Sans Mono for Powerline**, supplied by `fonts-powerline`.
You can select Hack Nerd Font Mono in Terminal Preferences if installed.

Open a new terminal with the desired profile, or load the Bash aliases:

```bash
source ~/.bashrc
```

Try `tron-blue` to switch colors, then run `tmux-work` to launch the grouped
workspace. The installer adds `~/.local/bin` to Bash's PATH when the snippet is loaded.

## Change colors

```bash
tron-red
tron-green
tron-blue
tron-yellow
```

The aliases switch the current Powerline prompt, window title, foreground,
background, cursor, and ANSI palette. They do not change saved GNOME profiles.
In tmux, the current pane's prompt and foreground/background change; other panes
keep their colors. The terminal's shared palette and cursor stay unchanged.
The outer title bar and border follow GNOME's shared GTK theme.

## Grouped workspace

```bash
tmux-work                       # start in your home directory
tmux-work "$HOME/projects/app"  # use an existing project directory
```

| Window / group | Left pane | Right pane |
|---|---|---|
| `work1` | Blue | Green |
| `work2` | Red | Yellow |

Running the launcher again reattaches to `work`; from inside tmux, it switches
sessions. It leaves existing session layouts intact. Set `TMUX_WORK_DIR` for a
default directory or `TMUX_WORK_SESSION` for another session name.

Press **Ctrl+B**, release, then:

| Key | Action |
|---|---|
| `w` | Choose a window/group |
| Arrow | Choose a pane |
| `%` | Split side by side |
| `"` | Split top and bottom |
| `z` | Expand/restore a pane |
| `d` | Detach without closing shells |

Use `sync-on` to broadcast typing within the current window, and `sync-off` to
stop. Target panes should be at shell prompts when broadcasting shell commands.

## Files and customization

- `bashrc-profiles-snippet.sh`: color switching, Powerline setup, and sync aliases.
- `powerline-profiles/<color>/`: per-shell RGB colors and prompt segments.
- `terminal/`: four GNOME Terminal profile definitions.
- `tmux/tmux-work`: grouped session launcher.
- `screenshots/`: actual GNOME Terminal captures of both groups.

Powerline shows user, host, virtual environment, Git branch when available,
working directory, background jobs, and failed-command status. Each shell has
its own configuration under `${XDG_CONFIG_HOME:-$HOME/.config}/tron-ares/powerline/`,
so multiple colors can run simultaneously. Edit source files and rerun the
installer to apply changes; tmux layout changes apply to newly created sessions.

## Restore backups

The installer prints timestamped Bash and GNOME Terminal backup paths. Copy the
chosen `.bashrc.bak.tron-profiles.*` file back to `~/.bashrc`. Restore terminal
settings with `dconf load /org/gnome/terminal/legacy/ < BACKUP.dconf`.
Restore any previous launcher from `~/.local/bin/tmux-work.bak.*` and profile
configuration from the adjacent `powerline.bak.*` directory if needed.


## License and warranty

Licensed under the [MIT License](LICENSE). This setup is provided **AS IS,
without warranty of any kind**. There is no guarantee of compatibility,
reliability, or fitness for any purpose. Use it at your own risk; see the license
for the full warranty disclaimer and limitation of liability.

Third-party dependencies remain subject to their own licenses.
