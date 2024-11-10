#!/bin/bash

# Global variables for command history, aliases, and theme colors
declare -a command_history
declare -A aliases
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'  # No Color

# Load configuration file
load_rc_file() {
    local rc_file="$HOME/.myshellrc"
    if [[ -f "$rc_file" ]]; then
        source "$rc_file"
        echo -e "${GREEN}Loaded configuration from .myshellrc${NC}"
    fi
}

# Function to execute a command with error handling
execute_command() {
    local command="$1"
    command_history+=("$command")

    # Check for built-in commands
    case "$command" in
        "exit") exit 0 ;;
        "history") show_history ;;
        "env") show_environment_variables ;;
        "help") show_help ;;
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
            elif [[ "$command" == nice* ]]; then
                set_process_priority "$command"
            elif [[ "$command" == "ls "* ]]; then
                custom_ls "$command"
            elif [[ "$command" == stat* ]]; then
                file_metadata "$command"
            elif [[ "$command" == listusers ]]; then
                list_users
            elif [[ "$command" == adduser* ]]; then
                add_user "$command"
            else
                echo -e "${RED}Unknown command: '$command'${NC}"
                suggest_command "$command"
            fi
            ;;
    esac
}

# Show command history
show_history() {
    echo -e "${YELLOW}Command History:${NC}"
    for i in "${!command_history[@]}"; do
        echo "$((i + 1)): ${command_history[i]}"
    done
}

# Show environment variables
show_environment_variables() {
    echo -e "${YELLOW}Environment Variables:${NC}"
    printenv
}

# Function for chaining commands with &&
handle_chaining() { ... }  # (kept same)

# Function for piping commands with |
handle_piping() { ... }  # (kept same)

# Function for redirection > and >>
handle_redirection() { ... }  # (kept same)

# Function for running command in background
run_in_background() { ... }  # (kept same)

# Set environment variable
set_environment_variable() { ... }  # (kept same)

# Set alias and display with color
set_alias() { ... }  # (kept same)

# Remove alias
remove_alias() { ... }  # (kept same)

# Change directory
change_directory() { ... }  # (kept same)

# Open website
open_website() { ... }  # (kept same)

# Set process priority using nice/renice
set_process_priority() {
    local cmd="${1#nice }"
    if [[ -n "$cmd" ]]; then
        eval "nice $cmd"
    else
        echo -e "${YELLOW}Usage: nice command or renice <priority> <pid>${NC}"
    fi
}

# List files with custom formatting for ls
custom_ls() {
    ls --color=auto "$@"
}

# Show file metadata
file_metadata() {
    local file="${1#stat }"
    if [[ -f "$file" || -d "$file" ]]; then
        stat "$file"
    else
        echo -e "${RED}File not found: $file${NC}"
    fi
}

# List users (limited to /etc/passwd file users)
list_users() {
    echo -e "${YELLOW}System Users:${NC}"
    cut -d: -f1 /etc/passwd
}

# Add a new user (requires sudo)
add_user() {
    local username="${1#adduser }"
    if [[ -n "$username" ]]; then
        sudo adduser "$username"
    else
        echo -e "${YELLOW}Usage: adduser <username>${NC}"
    fi
}

# Error handling with command suggestions
suggest_command() {
    local unknown_cmd="$1"
    echo -e "${YELLOW}Did you mean:${NC}"
    if [[ "$unknown_cmd" == "hst"* ]]; then
        echo "  history"
    elif [[ "$unknown_cmd" == "evn"* ]]; then
        echo "  env"
    elif [[ "$unknown_cmd" == "alais"* ]]; then
        echo "  alias"
    fi
}

# Show help with color
show_help() {
    echo -e "${GREEN}Available Commands:${NC}"
    echo "  history                  - Show command history"
    echo "  env                      - Show environment variables"
    echo "  set VAR VALUE            - Set environment variable"
    echo "  alias name command       - Set command alias"
    echo "  alias -l                 - List all aliases"
    echo "  unalias name             - Remove an alias"
    echo "  cd <directory>           - Change directory"
    echo "  open <URL>               - Open a website"
    echo "  nice command             - Run command with set priority"
    echo "  ls [options]             - List files with options"
    echo "  stat <file>              - Show file metadata"
    echo "  listusers                - List system users"
    echo "  adduser <username>       - Add a new user"
    echo "  help                     - Show this help message"
    echo "  exit                     - Exit the shell"
}

# Load .myshellrc file if available
load_rc_file

# Main loop
while true; do
    read -p "myshell> " command
    execute_command "$command"
done

