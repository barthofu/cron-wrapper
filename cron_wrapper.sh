#!/bin/sh

# Check that there are at least one argument
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <command> [args...]"
  exit 1
fi

# Define the log file
if [ -z $CRON_LOG_DIR ]; then
    echo "CRON_LOG_DIR is not set"
    exit 1
fi
mkdir -p "$CRON_LOG_DIR"
log_file="$CRON_LOG_DIR/$(date +'%Y-%m-%d')_cron.log"
exec 2>&1 1>>"$log_file" # redirect stdout and stderr to the log file

# Run an optional environment setup script if necessary
if [ -n "$CRON_ENV_SCRIPT" ]; then
  if [ -f "$CRON_ENV_SCRIPT" ]; then
    echo "$(date): running environment setup script $CRON_ENV_SCRIPT"
    source "$CRON_ENV_SCRIPT"
  else
    echo "$(date): environment setup script $CRON_ENV_SCRIPT not found"
    exit 1
  fi
fi

# Garbage collect old log files if retention is set
if [ -n "$CRON_LOG_RETENTION" ]; then
  if [[ "$CRON_LOG_RETENTION" =~ ^-?[0-9]+$ ]]; then

    log_files=$(ls -1 "$CRON_LOG_DIR" | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}_cron.log$' | sort)
    file_count=$(echo "$log_files" | wc -l)

    if [ "$file_count" -gt "$CRON_LOG_RETENTION" ]; then
      files_to_delete=$(echo "$log_files" | head -n $(($file_count - 3)))
      echo "$(date): deleting $files_to_delete log files"

      for file in $files_to_delete; do
        rm "$CRON_LOG_DIR/$file"
      done
    fi
  else
    echo "CRON_LOG_RETENTION is not a number"
    exit 1
  fi
fi

# Retrieve all arguments for the command
echo "$(date): starting cron, command=[$*]"
source $@
exit_code=$?
echo "$(date): cron ended, exit code is $exit_code"

# Return the exit code of the executed command
exit $exit_code
