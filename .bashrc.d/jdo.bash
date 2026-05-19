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

    # Available tools
    tools_list=(
        "Read"
        "Edit"
        "Write"
        "Bash"
        "LSP"
        "Agent"
        "WebFetch"
        "WebSearch"
        "Skill"
        "TaskCreate"
        "TaskUpdate"
        "TaskList"
        "TaskGet"
    )

    # FZF multi-select for tools
    selected_tools=$(printf '%s\n' "${tools_list[@]}" | fzf -m --preview="echo 'Selected tools will be allowed for this session'")

    if [[ -z "$selected_tools" ]]; then
        echo "Error: No tools selected" >&2
        return 1
    fi

    # Convert newline-separated tools to comma-separated
    selected_tools=$(echo "$selected_tools" | tr '\n' ',' | sed 's/,$//')

    # Combine stdin with prompt if stdin exists
    if [[ -n "$stdin_input" ]]; then
        prompt="$stdin_input

---

$prompt"
    fi

    # Run claude with selected tools
    claude -p --allowedTools "$selected_tools" "$prompt"
}
