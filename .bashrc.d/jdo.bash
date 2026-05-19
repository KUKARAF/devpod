# Just Do - quick claude code execution with tool selection
jdo() {
    local stdin_input prompt selected_tools tools_list

    # Read stdin if available
    if ! tty -s; then
        stdin_input=$(cat)
    fi

    # Get prompt from argument or interactively
    if [[ $# -gt 0 ]]; then
        prompt="$@"
    else
        echo "Enter your prompt (or Ctrl+D when done):"
        prompt=$(cat)
    fi

    # Preselected tools (always included by default)
    local -a preselected_tools=(
        "Read"
        "Edit"
        "Write"
        "Bash"
        "WebFetch"
        "WebSearch"
        "TaskCreate"
        "TaskUpdate"
        "TaskList"
        "TaskGet"
        "TaskStop"
        "TaskOutput"
    )

    # Additional available tools
    local -a additional_tools=(
        "LSP"
        "Agent"
        "Skill"
    )

    local selected_tools
    # FZF multi-select for additional tools
    echo "📌 Preselected tools: $(printf '%s, ' "${preselected_tools[@]}" | sed 's/, $//')"
    echo ""
    echo "Select additional tools (or press ESC to skip):"
    local additional=$(printf '%s\n' "${additional_tools[@]}" | fzf -m --preview="echo 'Choose optional tools to add'")

    # Combine preselected + additional
    if [[ -n "$additional" ]]; then
        selected_tools=$(printf '%s\n' "${preselected_tools[@]}" "$additional")
        selected_tools=$(echo "$selected_tools" | tr '\n' ',' | sed 's/,$//')
    else
        selected_tools=$(printf '%s\n' "${preselected_tools[@]}" | tr '\n' ',' | sed 's/,$//')
    fi

    # Combine stdin with prompt if stdin exists
    if [[ -n "$stdin_input" ]]; then
        prompt="$stdin_input

---

$prompt"
    fi

    # Run claude with selected tools
    claude -p --allowedTools "$selected_tools" "$prompt"
}
