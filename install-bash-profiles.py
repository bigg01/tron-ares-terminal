#!/usr/bin/env python3
"""Install matching green/red/blue/yellow Powerline Bash and GNOME Terminal profiles for this user."""
import ast
import os
from datetime import datetime
from pathlib import Path
import re
import shutil
import subprocess
import uuid

ROOT = Path(__file__).resolve().parent
SCHEMA = "org.gnome.Terminal.Legacy.Profile"
BASE = "/org/gnome/terminal/legacy/profiles:/"

def run(*args, **kwargs):
    return subprocess.run(args, check=True, text=True, capture_output=True, **kwargs).stdout.strip()

def install():
    required = ["bash", "tmux", "gsettings", "dconf", "powerline-render", "fc-match"]
    missing = [name for name in required if not shutil.which(name)]
    if missing or not Path("/usr/share/powerline/bindings/bash/powerline.sh").is_file():
        raise SystemExit("Install prerequisites first: sudo apt install gnome-terminal tmux powerline fonts-powerline fontconfig dconf-cli")
    schemas = run("gsettings", "list-schemas").splitlines()
    relocatable = run("gsettings", "list-relocatable-schemas").splitlines()
    if "org.gnome.Terminal.ProfilesList" not in schemas or SCHEMA not in relocatable:
        raise SystemExit("GNOME Terminal schemas are missing; install gnome-terminal.")
    rc = Path.home() / ".bashrc"
    original = rc.read_text() if rc.exists() else ""
    updated = re.sub(r"^# --- Tron: Ares selectable Bash profiles ---\n.*?^# --- end Tron: Ares selectable Bash profiles ---\n?", "", original, flags=re.M | re.S)
    # The selected profiles initialize their own Powerline after other settings.
    replacement = 'if [[ "${TRON_ARES_THEME:-}" != green && "${TRON_ARES_THEME:-}" != red && "${TRON_ARES_THEME:-}" != blue && "${TRON_ARES_THEME:-}" != yellow ]] && [ -f /usr/share/powerline/bindings/bash/powerline.sh ]; then'
    updated = re.sub(r'^if .*\[ -f /usr/share/powerline/bindings/bash/powerline\.sh \]; then$', lambda match: replacement, updated, flags=re.M)
    updated = updated.rstrip() + "\n\n" + (ROOT / "bashrc-profiles-snippet.sh").read_text()
    run("bash", "-n", input=updated)
    stamp = datetime.now().strftime("%Y%m%d-%H%M%S-%f")
    backup = rc.with_name(".bashrc.bak.tron-profiles." + stamp)
    if rc.exists():
        shutil.copy2(rc, backup)
    terminal_backup = rc.with_name(".gnome-terminal.bak.tron-profiles." + stamp + ".dconf")
    terminal_backup.write_text(run("dconf", "dump", "/org/gnome/terminal/legacy/") + "\n")
    config_dest = Path(os.environ.get("XDG_CONFIG_HOME", str(Path.home() / ".config"))) / "tron-ares" / "powerline"
    if config_dest.exists():
        shutil.copytree(config_dest, config_dest.with_name("powerline.bak." + stamp))
    shutil.copytree(ROOT / "powerline-profiles", config_dest, dirs_exist_ok=True)
    rc.write_text(updated)
    profiles = ast.literal_eval(run("gsettings", "get", "org.gnome.Terminal.ProfilesList", "list").removeprefix("@as "))
    for color in ("green", "red", "blue", "yellow"):
        name = "Tron: Ares — " + color.title()
        profile_id = next((pid for pid in profiles if run("gsettings", "get", SCHEMA + ":" + BASE + ":" + pid + "/", "visible-name") == "'" + name + "'"), None)
        if profile_id is None:
            profile_id = str(uuid.uuid4())
            profiles.append(profile_id)
        run("dconf", "load", BASE + ":" + profile_id + "/", input=(ROOT / "terminal" / ("tron-ares-" + color + "-profile.dconf")).read_text())
        target = SCHEMA + ":" + BASE + ":" + profile_id + "/"
        assert run("gsettings", "get", target, "custom-command") == "'env TRON_ARES_THEME=" + color + " bash'"
        print("Installed " + name)
    run("gsettings", "set", "org.gnome.Terminal.ProfilesList", "list", repr(profiles))
    launcher = Path.home() / ".local" / "bin" / "tmux-work"
    launcher.parent.mkdir(parents=True, exist_ok=True)
    if launcher.exists():
        shutil.copy2(launcher, launcher.with_name("tmux-work.bak." + stamp))
    shutil.copy2(ROOT / "tmux" / "tmux-work", launcher)
    launcher.chmod(0o755)
    print("Installed launcher: " + str(launcher))
    print("Bash backup: " + str(backup))
    print("Terminal backup: " + str(terminal_backup))

if __name__ == "__main__":
    install()
