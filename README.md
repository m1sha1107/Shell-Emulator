
# Custom Shell - A Basic Shell Implementation

This project is a custom shell implemented using Bash and enhanced with Python to demonstrate various operating system-related features. The shell supports command history, environment variable management, command aliases, and the ability to handle chaining, piping, and redirection.

## Features

- **Command History**: Stores and displays previously executed commands.
- **Environment Variables**: Set and display environment variables.
- **Aliases**: Create, list, and remove aliases for commands.
- **Command Chaining (`&&`)**: Execute multiple commands sequentially, stopping if one fails.
- **Piping (`|`)**: Redirect the output of one command as input to another.
- **Redirection (`>`, `>>`)**: Redirect command output to files.
- **Background Jobs (`&`)**: Execute commands in the background.
- **Directory Navigation (`cd`)**: Change the current working directory.
- **Website Opening**: Open a URL in the default browser with `open <URL>`.
- **Help**: Provides a list of available commands.

## Installation

To use this custom shell, you must have Bash and Python installed. Ensure that you have access to `xdg-open` for opening URLs.

1. Clone the repository:
    ```bash
    git clone https://github.com/yourusername/custom-shell.git
    ```

2. Navigate to the project directory:
    ```bash
    cd custom-shell
    ```

3. Run the shell:
    ```bash
    ./myshell.sh
    ```

## Usage

Once the shell starts, you can use the following commands:

- `history` - Display the command history.
- `env` - Show the current environment variables.
- `set VAR VALUE` - Set an environment variable.
- `alias name command` - Create a command alias.
- `alias -l` - List all aliases.
- `unalias name` - Remove an alias.
- `cd <directory>` - Change the directory.
- `open <URL>` - Open a website in the browser.
- `help` - Display this help message.
- `exit` - Exit the shell.

### Command Chaining

You can chain commands together using `&&`:

```bash
$ ls && echo "Directory listed"
```

### Command Piping

You can pipe the output of one command into another using `|`:

```bash
$ ls | grep "file"
```

### Redirection

Redirect the output of a command to a file using `>` for overwriting or `>>` for appending:

```bash
$ echo "Hello, World" > output.txt
$ echo "Appended text" >> output.txt
```

### Background Jobs

You can run commands in the background using `&`:

```bash
$ long_running_command &
```

### Aliases

You can create command aliases to shorten repetitive commands:

```bash
$ alias ll="ls -l"
$ ll  # Executes ls -l
```

To remove an alias:

```bash
$ unalias ll
```

## Contributing

Contributions are welcome! Please feel free to fork the repository and submit pull requests. For bug reports or feature requests, open an issue.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- This project was created as part of an Operating Systems course.
- Thanks to the community for open-source contributions and tutorials that helped guide the development of this shell.
