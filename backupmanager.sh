#!/bin/bash

#### Backup Manager

# Default values if the environment variables exist

# Dir where the backup files are stored
BACKUP_DIR=${BACKUP_PATH}

# Dir where the restore trigger file with the backup file name is stored
# RESTORE_FILE_PATH=${TRIGGER_RESTORE_PATH}

# Path for the backup file
BACKUP_FILE=${TRIGGER_RESTORE_FILE}

# Dir where the game save files are stored
SAVE_DIR=${GAME_SAVE_PATH}

# Number of backup files to keep
BACKUPS_TO_KEEP=${BACKUP_RETENTION_AMOUNT}


# Function to print usage information
function printUsage() {
    echo "Usage:"
    echo "  $0 [backup_directory] -c|--create"
    echo "  $0 [backup_directory] -r|--restore [backup_name]"
    echo "  $0 [backup_directory] -l|--list [num_entries]"
    echo "  $0 [backup_directory] -cl|--clean [num_to_keep]"
    echo "  $0 -h|--help"
    echo ""
    echo "Options:"
    echo "  -c, --create                    Create a backup"
    echo "  -r, --restore [backup_name]     Restore from a backup"
    echo "  -l, --list [num_entries]        List the backup files. If num_entries isn't"
    echo "                                  provided, all backup files will be listed"
    echo "  -cl, --clean [num_to_keep]      Deletes old backups keeping the num_to_keep"
    echo "                                  most recent backups. If num_to_keep isn't"
    echo "                                  provided, keep 5 most recent backups"
    echo "  -h, --help                      Display this help message"
    echo ""
    echo "Arguments:"
    echo "  backup_directory    (optional) The directory where the backup files are stored."
    echo "                                 If not provided, the value of the BACKUP_PATH"
    echo "                                 environment variable will be used if it exists"
    echo "                                 and is not empty."
    echo "  backup_name         (optional) The name of the backup file to restore from."
    echo "                                 If not provided, the value of the GAME_SAVE_PATH"
    echo "                                 environment variable will be used if it exists"
    echo "                                 and is not empty."
    echo "  num_entries         (optional) The number of backup files to list."
    echo "                                 If not provided, all backup files will be listed"
    echo "  num_to_keep         (optional) The number of the most recent backup files to keep."
    echo "                                 If not provided, 5 most recent backups will be kept"
}


# Function to parse input arguments
function parseArguments() {
    if [ $# -lt 1 ]; then
        echo "> Not enough arguments"
        printUsage
        exit 1
    fi

    # Check if the backup directory was given as an argument
    case "$2" in 
        -c|--create|-r|--restore|-l|--list)
        BACKUP_DIR=$1
            echo "> Backup directory provided: $BACKUP_DIR"
            # Check if backup directory exists
            if [ ! -d "$BACKUP_DIR" ]; then
                echo "> Directory $BACKUP_DIR doesn't exist!"
                exit 1
            fi
            skip 1 # Skip the backup directory argument
            ;;
    esac

    # Check the command
    case "$1" in
        -c|--create)
            if [ $# -ne 1 ]; then
                echo "Invalid number of arguments for create"
                printUsage
                exit 1
            fi
            createBackup
            ;;
        -l|--list)
            if [ $# -gt 2 ]; then
                echo "Invalid number of arguments for list"
                printUsage
                exit 1
            fi
            listBackups "${2:-}"
            ;;
        -r|--restore)
            if [ $# -gt 2 ]; then
                echo "Invalid number of arguments for restore"
                printUsage
                exit 1
            fi
            restoreBackup "${2:-}"
            ;;
        -cl|--clean)
            if [ $# -ne 3 ]; then
                echo "Invalid number of arguments for clean"
                printUsage
                exit 1
            fi
            cleanBackups "${2:-}"
            ;;
        -h|--help)
            if [ $# -ne 1 ]; then
                echo "Invalid number of arguments for help"
                printUsage
                exit 1
            fi
            printUsage
            ;;
        *)
            echo "Illegal option $1"
            printUsage
            exit 1
            ;;
    esac
}

# Function to run RCON commands
runRCON() {
    # Wraps the command to print a pretty version of output
    local cmd=$1
    (cd ~/steamcmd/ && echo -n "> RCON: " && rconcli "$cmd")
}

### Backup Functions

# Function to create a backup
function createBackup() {

    if [ -z "$BACKUP_DIR" ]; then
        echo "> BACKUP_DIR variable not set. Exiting..."
        exit 1
    fi

    if [ -z "$GAME_PATH" ]; then
        echo "> RESTORE_FILE_PATH environment variable not set. Exiting..."
        exit 1
    fi
    
    DATE=$(date +%Y%m%d_%H%M%S)
    TIME=$(date +%H-%M-%S)

    echo -e "\n>>> Creating backup..."

    #Send message to gameserver via RCON if enabled
    if [[ -n ${RCON_ENABLED+x} ]] && [[ "$RCON_ENABLED" == "true" ]]; then
        echo "> Broadcasting server shutdown via RCON..."
        runRCON "broadcast $TIME-Backup_in_progress"
    fi

    # Create backup dir if it doesn't exist
    mkdir -p "$BACKUP_DIR"

    # Create backup
    tar cfz "$BACKUP_DIR/saved-$DATE.tar.gz" -C "$GAME_PATH" Saved/
    echo ">>> Done"

    echo "> Sending message to gameserver via RCON..."

    cd ~/steamcmd/ || exit

    #Send message to gameserver via RCON if enabled
    if [[ -n ${RCON_ENABLED+x} ]] && [[ "$RCON_ENABLED" == "true" ]]; then
        echo -n "> RCON: "
        runRCON 'broadcast Saving world...'
        runRCON 'save'
        runRCON 'broadcast Done!'
        echo "> Broadcast via RCON complete!"
    fi
}


# Function to list a backup
#   Arguments:"
#       num_backup_entries (optional) - The number of the latest backups to list. Must be a positive number.
#                                       If not provided, all backups will be listed.
function listBackups() {
    local num_backup_entries=${1:-""}

    echo -e "\n>>> Listing backups"

    # Check num_backup_entries argument
    # if argument exists and is not a positive integer, print usage message and exit
    if [[ -n "$num_backup_entries" && ! "$num_backup_entries" =~ ^[0-9]+$ ]]; then
        echo -e "> Error: Invalid argument. Please provide a positive integer.\n\n"
        printUsage
        exit 1
    fi

    # Check if backup directory exists
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "> Error: Backup directory $BACKUP_DIR does not exist.\n\n"
        exit 1
    fi

    # Check if there are any files in the backup directory
    if [ -z "$(ls -A "$BACKUP_DIR")" ]; then
        echo -e "> No backups in the backup directory $BACKUP_DIR.\n\n"
        exit 0
    fi

    # get file list
    if [ -z "$num_files" ]; then
        files=$(find "$BACKUP_DIR" -maxdepth 1 -type f -name "*.tar.gz" \
                | sort -r)
    else
        files=$(find "$BACKUP_DIR" -maxdepth 1 -type f -name "*.tar.gz" \
                | sort -r \
                | head -n "$num_files")
    fi

    # print file list (currently using date from file name but can use creation date from 'stat')
    for file in $files; do
        filename=$(basename "$file")
        # get date from creation date
        #creation_date=$(stat -c %w "$file")

        # Reformat the date string
        #date=$(date -d "$creation_date" +'%Y-%m-%d %H:%M:%S')

        # get date from filename
        date_str=${filename#saved-}    # Remove 'saved-' prefix
        date_str=${date_str%.tar.gz}   # Remove '.tar.gz' suffix

        # Reformat the date string
        date=$(date -d "${date_str:0:8} ${date_str:9:2}:${date_str:11:2}:${date_str:13:2}" +'%Y-%m-%d %H:%M:%S')

        echo "${date} |    ${filename}"
    done
}

function cleanBackups() {
    local num_files_to_keep=${1:-${BACKUPS_TO_KEEP}}

    echo -e "\n>>> Backup Cleanup started!"

    if [[ -n "$num_files_to_keep" ]]; then
        echo -e "> Number of backups to keep not provided. Using default value of 5."
        num_files_to_keep=5
    fi

    if ! [[ "$num_files_to_keep" =~ ^[0-9]+$ ]]; then
        echo -e "> Error: Invalid argument. Please provide a positive integer.\n\n"
        printUsage
        exit 1
    fi

    # Check if backup directory exists
    if [ ! -d "${BACKUP_DIR}" ]; then
        echo -e "> Error: Backup directory ${BACKUP_DIR} does not exist.\n\n"
        exit 1
    fi

    # Check if there are any files in the backup directory
    if [ -z "$(ls -A "${BACKUP_DIR}")" ]; then
        echo -e "> No backups in the backup directory ${BACKUP_DIR}."
        echo ">>> No cleanup needed."
        exit 0
    fi

    echo "> Keeping latest ${num_files_to_keep} backups"
    
    find "${BACKUP_DIR}" -maxdepth 1 -type f -name "saved-*.tar.gz" \
    | sort -r \
    | tail -n +$(("${num_files_to_keep}"+1)) \
    | xargs -d '\n' rm -f --

    echo ">>> Cleanup finished"
}


# Function to restore a backup
function restoreBackup() {
    local backup_name=${1:-$(tr -d '\n' < "${BACKUP_FILE}")}

    echo -e "\n>>> Restoring backup..."

    # Check if backup file exists
    if [ ! -f "${BACKUP_DIR}/${backup_name}" ]; then
        echo "> Error: Backup file '${backup_name}' does not exist."
        exit 1
    fi

    echo -e "> Backup '${backup_name}' will be restored to '${SAVE_DIR}'."

    DATE=$(date +%Y%m%d_%H%M%S)

    tar -czf "${BACKUP_DIR}/restore-${DATE}.tar.gz" -C /palworld/Pal Saved/
    echo -e "> INFO - Backup of current state saved to: ${BACKUP_DIR}/restore-${DATE}.tar.gz"

    echo -e "> INFO - Removing current saved data"
    rm -r "${SAVE_DIR}"

    echo -e "> INFO - Restoring backup"
    tar -xzf "${BACKUP_DIR}/${backup_name}" -C /palworld/Pal
}



### Backup Manager Initialization

# Function to initialize the backup manager
function initializeBackupManager() {

    # Check if the backup directory exists, if not create it
    if [ ! -d "${BACKUP_DIR}" ]; then
        echo "> Backup directory ${BACKUP_DIR} doesn't exist. Creating it..."
        mkdir -p "${BACKUP_DIR}"
    fi

    parseArguments "${@}"
}

# Call the initializeBackupManager function and pass the arguments
initializeBackupManager "${@}"
