import os
import subprocess
import webbrowser

# Global variables for command history and aliases
command_history = []
aliases = {}

def execute_command(command):
    global command_history
    command = command.strip()  # strip it down word by word
    command_history.append(command)  # Record the command in history

    if command == "exit":
        return "exit"

    elif command == "history":
        show_history()
        return

    elif command.startswith("history search"):
        search_history(command)
        return

    elif command == "env":
        show_environment_variables()
        return

    elif " | " in command:
        handle_piping(command)
        return

    elif " && " in command:
        handle_chaining(command)
        return

    elif ">" in command:
        handle_redirection(command)
        return

    elif command.endswith("&"):
        run_in_background(command[:-1].strip())
        return

    elif command.startswith("set"):
        set_environment_variable(command)
        return

    elif command.startswith("alias"):
        set_alias(command)
        return

    elif command.startswith("unalias"):
        remove_alias(command)
        return

    elif command.startswith("cd"):
        change_directory(command)
        return
    
    elif command.startswith("open "):
        open_website(command)
        return

    elif command == "help":
        show_help()
        return

    # Replace alias if exists
    for alias in aliases:
        if command.startswith(alias):
            command = aliases[alias]

    # Execute the command normally
    try:
        subprocess.run(command, shell=True)
    except Exception as e:
        print(f"Error: {e}")

def show_history():
    print("Command History:")
    for idx, cmd in enumerate(command_history, 1):
        print(f"{idx}: {cmd}")

def search_history(command):
    _, _, search_term = command.partition(" ")
    results = [cmd for cmd in command_history if search_term in cmd]
    print("Search Results in History:")
    for result in results:
        print(result)

def show_environment_variables():
    print("Environment Variables:")
    for key, value in os.environ.items():
        print(f"{key}={value}")

def handle_piping(command):
    commands = command.split('|')
    output = None

    for cmd in commands:
        cmd = cmd.strip()
        process = subprocess.Popen(cmd, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        output, _ = process.communicate(input=output)

    print(output)

def handle_chaining(command):
    commands = command.split(' && ')
    for cmd in commands:
        cmd = cmd.strip()
        try:
            subprocess.run(cmd, shell=True, check=True)
        except subprocess.CalledProcessError:
            print(f"Error executing command: {cmd}")
            break

def handle_redirection(command):
    parts = command.split('>')
    cmd = parts[0].strip()
    output_file = parts[1].strip()

    mode = 'a' if ">>" in command else 'w'

    with open(output_file, mode) as f:
        result = subprocess.run(cmd, shell=True, stdout=f, stderr=subprocess.PIPE, text=True)
        if result.returncode != 0:
            print(f"Error: {result.stderr}")

def run_in_background(command):
    subprocess.Popen(command, shell=True)

def set_environment_variable(command):
    args = command.strip().split()
    if len(args) == 3:
        os.environ[args[1]] = args[2]
        print(f"Environment variable {args[1]} set to {args[2]}")
    elif len(args) == 2:
        print(f"{args[1]}={os.getenv(args[1], 'Not set')}")
    else:
        print("Usage: set VAR VALUE or set VAR")

def set_alias(command):
    args = command.strip().split()
    if len(args) > 2:
        alias_name = args[1]
        alias_command = " ".join(args[2:])
        aliases[alias_name] = alias_command
        print(f"Alias set: {alias_name} = {alias_command}")
    elif len(args) == 2 and args[1] == "-l":
        print("Aliases:")
        for name, cmd in aliases.items():
            print(f"{name} = {cmd}")
    else:
        print("Usage: alias name command or alias -l")

def remove_alias(command):
    args = command.strip().split()
    if len(args) == 2:
        alias_name = args[1]
        if alias_name in aliases:
            del aliases[alias_name]
            print(f"Alias '{alias_name}' removed")
        else:
            print(f"No such alias: {alias_name}")
    else:
        print("Usage: unalias name")

def change_directory(command):
    args = command.strip().split()
    if len(args) == 2:
        try:
            os.chdir(args[1])
        except FileNotFoundError:
            print(f"Directory not found: {args[1]}")
        except Exception as e:
            print(f"Error changing directory: {e}")
    else:
        print("Usage: cd <directory>")

def open_website(command):
    args = command.strip().split()
    if len(args) == 2:
        url = args[1]
        try:
            webbrowser.open(url)
            print(f"Opening {url}...")
        except Exception as e:
            print(f"Error opening URL: {e}")
    else:
        print("Usage: open <URL>")

def show_help():
    print("Available Commands:")
    print("  history                  - Show command history")
    print("  history search <term>    - Search command history")
    print("  env                      - Show environment variables")
    print("  set VAR VALUE            - Set environment variable")
    print("  alias name command       - Set command alias")
    print("  alias -l                 - List all aliases")
    print("  unalias name             - Remove an alias")
    print("  cd <directory>           - Change directory")
    print("  open <URL>               - Open a website")
    print("  help                     - Show this help message")
    print("  exit                     - Exit the shell")

def main():
    while True:
        command = input("myshell> ")
        if execute_command(command) == "exit":
            break

if __name__ == "__main__":
    main()
