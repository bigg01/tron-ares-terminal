# --- Tron: Ares selectable Bash profiles ---
# Make the installed workspace launcher available in new and reloaded shells.
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

_tron_ares_title() {
    printf '\033]0;Tron: Ares — %s | %s@%s\007' "${TRON_ARES_THEME^}" "$USER" "${HOSTNAME%%.*}"
}

_tron_ares_prompt() {
    case "${TRON_ARES_THEME:-}" in
        green)
            if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
                PS1='\[\e[38;2;22;194;74m\][GRID]\[\e[0m\] \[\e[1;38;2;57;255;106m\]\u@\h\[\e[0m\] \[\e[38;2;224;255;232m\]\w\[\e[0m\] \[\e[1;38;2;57;255;106m\]❯\[\e[0m\] '
            fi
            ;;
        red)
            if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
                PS1='\[\e[38;2;194;22;36m\][GRID]\[\e[0m\] \[\e[1;38;2;255;57;74m\]\u@\h\[\e[0m\] \[\e[38;2;255;224;228m\]\w\[\e[0m\] \[\e[1;38;2;255;57;74m\]❯\[\e[0m\] '
            fi
            ;;
        blue)
            if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
                PS1='\[\e[38;2;22;110;194m\][GRID]\[\e[0m\] \[\e[1;38;2;57;166;255m\]\u@\h\[\e[0m\] \[\e[38;2;224;240;255m\]\w\[\e[0m\] \[\e[1;38;2;57;166;255m\]❯\[\e[0m\] '
            fi
            ;;
        yellow)
            if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
                PS1='\[\e[38;2;194;160;22m\][GRID]\[\e[0m\] \[\e[1;38;2;255;222;57m\]\u@\h\[\e[0m\] \[\e[38;2;255;248;224m\]\w\[\e[0m\] \[\e[1;38;2;255;222;57m\]❯\[\e[0m\] '
            fi
            ;;
    esac
    case "${TRON_ARES_THEME:-}" in
        green|red|blue|yellow)
            if [[ "${TRON_ARES_PROMPT:-powerline}" == grid ]]; then
                # Remove only Powerline's PS1 updater, keeping other prompt hooks.
                PROMPT_COMMAND="${PROMPT_COMMAND//_powerline_status_wrapper _powerline_set_prompt/}"
                PS2='> '
                PS3='#? '
            elif command -v powerline-render >/dev/null 2>&1 && [ -r /usr/share/powerline/bindings/bash/powerline.sh ]; then
                # Independent configuration keeps simultaneous profiles separate.
                export POWERLINE_CONFIG_PATHS="/usr/share/powerline/config_files:${XDG_CONFIG_HOME:-$HOME/.config}/tron-ares/powerline/$TRON_ARES_THEME"
                POWERLINE_COMMAND="$(command -v powerline-render)"
                POWERLINE_BASH_CONTINUATION=1
                POWERLINE_BASH_SELECT=1
                source /usr/share/powerline/bindings/bash/powerline.sh
            fi
            if [[ "${PROMPT_COMMAND:-}" != *"_tron_ares_title"* ]]; then
                PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}_tron_ares_title"
            fi
            ;;
    esac
}

# Set the current shell and terminal colors without opening another shell.
tron_color() {
    local color="${1:-}" foreground background cursor index
    local -a palette
    case "$color" in
        green)
            foreground='#39FF6A'
            background='#020302'
            cursor='#39FF6A'
            palette=('#020302' '#16C24A' '#3A3A3A' '#0E8A32' '#2A2A2A' '#12A83E' '#0A5A22' '#C0C9C0' '#4A4A4A' '#39FF6A' '#666666' '#6CFF94' '#666666' '#7CFFA0' '#999999' '#E0FFE8')
            ;;
        red)
            foreground='#FF394A'
            background='#030202'
            cursor='#FF394A'
            palette=('#030202' '#C21624' '#3A3A3A' '#8A0E20' '#2A2A2A' '#A81226' '#5A0A16' '#C9C0C0' '#4A4A4A' '#FF394A' '#666666' '#FF6C80' '#666666' '#FF7C8C' '#999999' '#FFE0E4')
            ;;
        blue)
            foreground='#39A6FF'
            background='#020203'
            cursor='#39A6FF'
            palette=('#020203' '#166EC2' '#3A3A3A' '#0E4E8A' '#2A2A2A' '#1264A8' '#0A325A' '#C0C4C9' '#4A4A4A' '#39A6FF' '#666666' '#6CC4FF' '#666666' '#7CCCFF' '#999999' '#E0F0FF')
            ;;
        yellow)
            foreground='#FFDE39'
            background='#030302'
            cursor='#FFDE39'
            palette=('#030302' '#C2A016' '#3A3A3A' '#8A720E' '#2A2A2A' '#A88B12' '#5A4A0A' '#C9C7C0' '#4A4A4A' '#FFDE39' '#666666' '#FFE96C' '#666666' '#FFEC7C' '#999999' '#FFF8E0')
            ;;
        *)
            printf 'Usage: tron_color {red|green|blue|yellow}\n' >&2
            return 2
            ;;
    esac
    export TRON_ARES_THEME="$color"
    _tron_ares_prompt
    if [[ -n "${TMUX:-}" ]]; then
        # Palette OSC changes affect every pane; set this pane's defaults instead.
        tmux select-pane -t "${TMUX_PANE:-.}" -P "fg=$foreground,bg=$background"
    else
        printf '\033]10;%s\007\033]11;%s\007\033]12;%s\007' "$foreground" "$background" "$cursor"
        for index in "${!palette[@]}"; do
            printf '\033]4;%s;%s\007' "$index" "${palette[index]}"
        done
    fi
    if [[ "${TRON_ARES_PROMPT:-powerline}" == powerline ]] && declare -F _powerline_set_prompt >/dev/null; then
        _powerline_set_prompt 0 '0'
    fi
    if declare -F _tron_ares_title >/dev/null; then
        _tron_ares_title
    fi
}

# Prompt mode is independent of the selected terminal color.
tron_prompt() {
    case "${1:-}" in
        grid|powerline) ;;
        *) printf 'Usage: tron_prompt {grid|powerline}\n' >&2; return 2 ;;
    esac
    export TRON_ARES_PROMPT="$1"
    export TRON_ARES_THEME="${TRON_ARES_THEME:-green}"
    _tron_ares_prompt
    if [[ "$TRON_ARES_PROMPT" == powerline ]] && declare -F _powerline_set_prompt >/dev/null; then
        _powerline_set_prompt 0 '0'
    fi
    _tron_ares_title
}

alias tron-grid='tron_prompt grid'
alias tron-powerline='tron_prompt powerline'

alias tron-red='tron_color red'
alias tron-green='tron_color green'
alias tron-blue='tron_color blue'
alias tron-yellow='tron_color yellow'

alias sync-on='tmux setw synchronize-panes on'
alias sync-off='tmux setw synchronize-panes off'

_tron_ares_prompt
# --- end Tron: Ares selectable Bash profiles ---
