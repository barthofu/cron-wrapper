# Cron Wrapper Script

This script acts as a wrapper for running cron jobs. It ensures proper logging, optional environment setup, and log file rotation based on configurable retention settings.

## Features

- Logs the output (stdout and stderr) of the executed command into timestamped log files.
- Supports optional environment setup via a custom script.
- Automatically removes old log files based on a specified retention policy.

## Requirements

- A POSIX-compliant shell (e.g., `/bin/sh`).
- Environment variables must be set before running the script.

## Environment Variables

The script relies on the following environment variables:

1. **`CRON_LOG_DIR`** *(required)*:
   - The directory where log files are stored.
   - If this variable is not set, the script exits with an error.

2. **`CRON_ENV_SCRIPT`** *(optional)*:
   - Path to a shell script that sets up the environment.
   - If specified, the script is executed before running the cron command.

3. **`CRON_LOG_RETENTION`** *(optional)*:
   - The number of log files to keep (based on the most recent files).
   - If not set, all log files are retained.

## Usage

With environment variables set in current shell:
```sh
./cron_wrapper.sh <command> [args...]
```

With inline environment variables:
```sh
CRON_LOG_DIR="/var/log/cron" CRON_LOG_RETENTION=3 CRON_ENV_SCRIPT="/etc/environment" ./cron_wrapper.sh <command> [args...]
```

### Arguments

- `<command>`: The command to execute (required).
- `[args...]`: Optional arguments for the command.

## Example

### Basic Example
Run a simple cron job and store logs in `/var/log/cron`:

```sh
export CRON_LOG_DIR="/var/log/cron"
./cron_wrapper.sh echo "Hello, Cron!"
```

### Using Environment Setup Script
Run a cron job with an environment setup script:

```sh
export CRON_LOG_DIR="/var/log/cron"
export CRON_ENV_SCRIPT="/path/to/env_setup.sh"
./cron_wrapper.sh python3 /path/to/script.py
```

### With Log Retention
Limit log retention to 7 days:

```sh
export CRON_LOG_DIR="/var/log/cron"
export CRON_LOG_RETENTION=7
./cron_wrapper.sh echo "This is a cron job with log rotation."
```

## Log File Naming Convention

The script creates log files with the following naming pattern:

```
<YYYY-MM-DD>_cron.log
```

For example:

- `2024-12-18_cron.log`
- `2024-12-17_cron.log`

## Error Handling

The script exits with an appropriate error message and code in the following scenarios:

- `CRON_LOG_DIR` is not set.
- `CRON_ENV_SCRIPT` is specified but does not exist.
- `CRON_LOG_RETENTION` is set but is not a valid integer.
- The executed command fails (the script propagates the command's exit code).

## Exit Codes

- `0`: The script and the executed command completed successfully.
- `1`: General error (e.g., missing variables, invalid input).
- Propagated exit code: If the executed command fails, its exit code is returned.

## Notes

- Ensure that `CRON_LOG_DIR` is writable by the user executing the script.
- Use `chmod +x cron_wrapper.sh` to make the script executable.

## License

This script is open source. Feel free to modify and use it according to your needs.