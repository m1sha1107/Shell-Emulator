#!/bin/bash


declare -a command_history
declare -A aliases


execute_command() {
    local command="$1"
    command_history+=("$command")  

    # Check for built-in commands
    case "$command" in
        "exit")
            exit 0
            ;;
        "history")
            show_history
            ;;
        "env")
            show_environment_variables
            ;;
        "help")
            show_help
            ;;
        *) 
            if [[ "$command" == *" && "* ]]; then
                handle_chaining "$command"
            elif [[ "$command" == *" | "* ]]; then
                handle_piping "$command"
            elif [[ "$command" == *">"* || "$command" == *">>"* ]]; then
                handle_redirection "$command"
            elif [[ "$command" == *"&" ]]; then
                run_in_background "${command%&}"
            elif [[ "$command" == "set "* ]]; then
                set_environment_variable "$command"
            elif [[ "$command" == alias* ]]; then
                set_alias "$command"
            elif [[ "$command" == "unalias "* ]]; then
                remove_alias "$command"
            elif [[ "$command" == cd* ]]; then
                change_directory "$command"
            elif [[ "$command" == open* ]]; then
                open_website "$command"
            else
                
                for alias in "${!aliases[@]}"; do
                    if [[ "$command" == "$alias"* ]]; then
                        command="${aliases[$alias]}"
                    fi
                done
                eval "$command"
            fi
            ;;
    esac
}

show_history() {
    echo "Command History:"
    for i in "${!command_history[@]}"; do
        echo "$((i + 1)): ${command_history[i]}"
    done
}


show_environment_variables() {
    echo "Environment Variables:"
    printenv
}

handle_chaining() {
    IFS="&&" read -ra commands <<< "$1"
    for cmd in "${commands[@]}"; do
        cmd=$(echo "$cmd" | xargs)  # Trim whitespace
        eval "$cmd" || break  # Stop if a command fails
    done
}


handle_piping() {
    local commands=("${@//|/ }")
    eval "$1"
}


handle_redirection() {
    local output_file
    if [[ "$1" == *">>"* ]]; then
        command="${1%>>*}"
        output_file="${1#*>>}"
        command=$(echo "$command" | xargs)
        output_file=$(echo "$output_file" | xargs)
        eval "$command" >> "$output_file"
    else
        command="${1%>*}"
        output_file="${1#*>}"
        command=$(echo "$command" | xargs)
        output_file=$(echo "$output_file" | xargs)
        eval "$command" > "$output_file"
    fi
}


run_in_background() {
    eval "$1" &
}


set_environment_variable() {
    local args=($@)
    if [[ ${#args[@]} -eq 3 ]]; then
        export "${args[1]}"="${args[2]}"
        echo "Environment variable ${args[1]} set to ${args[2]}"
    elif [[ ${#args[@]} -eq 2 ]]; then
        echo "${args[1]}=${!args[1]}"
    else
        echo "Usage: set VAR VALUE or set VAR"
    fi
}


set_alias() {
    local args=($@)
    if [[ ${#args[@]} -gt 2 ]]; then
        local alias_name="${args[1]}"
        local alias_command="${args[@]:2}"
        aliases[$alias_name]="$alias_command"
        echo "Alias set: $alias_name = $alias_command"
    elif [[ ${#args[@]} -eq 2 && "${args[1]}" == "-l" ]]; then
        echo "Aliases:"
        for alias in "${!aliases[@]}"; do
            echo "$alias = ${aliases[$alias]}"
        done
    else
        echo "Usage: alias name command or alias -l"
    fi
}


remove_alias() {
    local alias_name="${1#unalias }"
    if [[ -n "${aliases[$alias_name]}" ]]; then
        unset aliases[$alias_name]
        echo "Alias '$alias_name' removed"
    else
        echo "No such alias: $alias_name"
    fi
}


change_directory() {
    local dir="${1#cd }"
    if cd "$dir" 2>/dev/null; then
        :
    else
        echo "Directory not found: $dir"
    fi
}


open_website() {
    local url="${1#open }"
    xdg-open "$url" &>/dev/null || echo "Error opening URL"
}


show_help() {
    echo "Available Commands:"
    echo "  history                  - Show command history"
    echo "  env                      - Show environment variables"
    echo "  set VAR VALUE            - Set environment variable"
    echo "  alias name command       - Set command alias"
    echo "  alias -l                 - List all aliases"
    echo "  unalias name             - Remove an alias"
    echo "  cd <directory>           - Change directory"
    echo "  open <URL>               - Open a website"
    echo "  help                     - Show this help message"
    echo "  exit                     - Exit the shell"
}

# Main 
while true; do
    read -p "myshell> " command
    execute_command "$command"
done