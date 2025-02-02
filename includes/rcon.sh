# shellcheck disable=SC2148,SC1091
source /includes/colors.sh

# Function to run RCON commands
# Arguments: <command>
# Example: run_rcon "showplayers"

run_rcon() {
    local cmd=$1
    local message=$2


    if [[ -z ${RCON_ENABLED+x} ]] || [[ "$RCON_ENABLED" != "true" ]]; then
        exit
    fi

    pp --info "${message}"
    output=$(rconcli -c /configs/rcon.yaml "${cmd}")
    pp --info "> RCON: ${output}"

    if [[ $cmd == "save" ]]; then
        sleep 5
    fi
}

