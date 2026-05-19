# Zellij tab switching function
tab() {
    if [[ -z "$ZELLIJ" ]]; then
        echo "Error: Not in a zellij session" >&2
        return 1
    fi

    # Case 1: No arguments - use fzf to select from tab names
    if [[ $# -eq 0 ]]; then
        local selected_tab
        selected_tab=$(zellij action query-tab-names 2>/dev/null | fzf)
        if [[ -z "$selected_tab" ]]; then
            return 1
        fi
        zellij action go-to-tab-name "$selected_tab"
    # Case 2: Numeric argument - switch directly to tab index
    elif [[ "$1" =~ ^[0-9]+$ ]]; then
        zellij action go-to-tab "$1"
    # Case 3: String argument - fuzzy match through tab names
    else
        local selected_tab
        selected_tab=$(zellij action query-tab-names 2>/dev/null | fzf --filter="$1" --no-multi | head -1)
        if [[ -z "$selected_tab" ]]; then
            echo "Error: No tab matching '$1'" >&2
            return 1
        fi
        zellij action go-to-tab-name "$selected_tab"
    fi
}
