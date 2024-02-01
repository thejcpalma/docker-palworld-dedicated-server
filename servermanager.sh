#!/bin/bash

#### Server Manager     

# Stop on errors, comment in, if needed
#set -e

### Settings Functions

# Function to setup the engine config file
function setup_engine_ini() {

    echo -e "\n>>> Setting up Engine.ini ..."
    if [[ -n $SERVER_SETTINGS_MODE ]] && [[ $SERVER_SETTINGS_MODE == "auto" ]]; then
        echo "> SERVER_SETTINGS_MODE is set to '$SERVER_SETTINGS_MODE', using environment variables to configure the server!"

        config_file=$SERVER_SETTINGS_PATH
        pattern1="OnlineSubsystemUtils.IpNetDriver"
        pattern2="^NetServerMaxTickRate=[0-9]*"

        if grep -qE "$pattern1" "$config_file" 2>/dev/null; then
            echo "> Found [/Script/OnlineSubsystemUtils.IpNetDriver] section"
        else
            echo "> Found no [/Script/OnlineSubsystemUtils.IpNetDriver], adding it"
            echo -e "\n[/Script/OnlineSubsystemUtils.IpNetDriver]" >> "$config_file"
        fi

        if grep -qE "$pattern2" "$config_file" 2>/dev/null; then
            echo "> Found NetServerMaxTickRate parameter, changing it to $NETSERVERMAXTICKRATE"
            sed -E -i "s/$pattern2/NetServerMaxTickRate=$NETSERVERMAXTICKRATE/" "$config_file"
        else
            echo "> Found no NetServerMaxTickRate parameter, adding it to $NETSERVERMAXTICKRATE"
            echo "NetServerMaxTickRate=$NETSERVERMAXTICKRATE" >> "$config_file"
        fi
    else
        echo "> SERVER_SETTINGS_MODE is set to '$SERVER_SETTINGS_MODE', NOT using environment variables to configure the server!"
        echo "> File $SERVER_SETTINGS_PATH has to be manually set by user"
    fi
    echo ">>> Finished setting up Engine.ini"
}

# Function to setup the game config file
function setup_palworld_settings_ini() {
    # setup the server config file
    echo -e "\n>>> Setting up PalWorldSettings.ini ..."
    echo "> Checking if config already exists"
    if [ ! -f "$GAME_SETTINGS_PATH" ]; then
        echo "> No config found, generating one"
        if [ ! -d "$GAME_CONFIG_PATH" ]; then
            mkdir -p "$GAME_CONFIG_PATH/"
        fi
        # Copy default-config, which comes with the server to gameserver-save location
        cp "${GAME_ROOT}/DefaultPalWorldSettings.ini" "$GAME_SETTINGS_PATH"
    else 
        echo "> Found existing config"
    fi

    if [[ -n $SERVER_SETTINGS_MODE ]] && [[ $SERVER_SETTINGS_MODE == "auto" ]]; then
        echo "> SERVER_SETTINGS_MODE is set to auto, using environment variables to configure the server!"
        if [[ -n ${DIFFICULTY+x} ]]; then
            echo "> Setting Difficulty to '$DIFFICULTY'"
            sed -E -i "s/Difficulty=[a-zA-Z]*/Difficulty=$DIFFICULTY/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${DAYTIME_SPEEDRATE+x} ]]; then
            echo "> Setting DayTimeSpeedRate to '$DAYTIME_SPEEDRATE'"
            sed -E -i "s/DayTimeSpeedRate=[+-]?([0-9]*[.])?[0-9]+/DayTimeSpeedRate=$DAYTIME_SPEEDRATE/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${NIGHTTIME_SPEEDRATE+x} ]]; then
            echo "> Setting NightTimeSpeedRate to '$NIGHTTIME_SPEEDRATE'"
            sed -E -i "s/NightTimeSpeedRate=[+-]?([0-9]*[.])?[0-9]+/NightTimeSpeedRate=$NIGHTTIME_SPEEDRATE/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${EXP_RATE+x} ]]; then
            echo "> Setting ExpRate to '$EXP_RATE'"
            sed -E -i "s/ExpRate=[+-]?([0-9]*[.])?[0-9]+/ExpRate=$EXP_RATE/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${PAL_CAPTURE_RATE+x} ]]; then
            echo "> Setting PalCaptureRate to '$PAL_CAPTURE_RATE'"
            sed -E -i "s/PalCaptureRate=[+-]?([0-9]*[.])?[0-9]+/PalCaptureRate=$PAL_CAPTURE_RATE/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${PAL_SPAWN_NUM_RATE+x} ]]; then
            echo "> Setting PalSpawnNumRate to '$PAL_SPAWN_NUM_RATE'"
            sed -E -i "s/PalSpawnNumRate=[+-]?([0-9]*[.])?[0-9]+/PalSpawnNumRate=$PAL_SPAWN_NUM_RATE/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${PAL_DAMAGE_RATE_ATTACK+x} ]]; then
            echo "> Setting PalDamageRateAttack to '$PAL_DAMAGE_RATE_ATTACK'"
            sed -E -i "s/PalDamageRateAttack=[+-]?([0-9]*[.])?[0-9]+/PalDamageRateAttack=$PAL_DAMAGE_RATE_ATTACK/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${PAL_DAMAGE_RATE_DEFENSE+x} ]]; then
            echo "> Setting PalDamageRateDefense to '$PAL_DAMAGE_RATE_DEFENSE'"
            sed -E -i "s/PalDamageRateDefense=[+-]?([0-9]*[.])?[0-9]+/PalDamageRateDefense=$PAL_DAMAGE_RATE_DEFENSE/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${PLAYER_DAMAGE_RATE_ATTACK+x} ]]; then
            echo "> Setting PlayerDamageRateAttack to '$PLAYER_DAMAGE_RATE_ATTACK'"
            sed -E -i "s/PlayerDamageRateAttack=[+-]?([0-9]*[.])?[0-9]+/PlayerDamageRateAttack=$PLAYER_DAMAGE_RATE_ATTACK/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${PLAYER_DAMAGE_RATE_DEFENSE+x} ]]; then
            echo "> Setting PlayerDamageRateDefense to '$PLAYER_DAMAGE_RATE_DEFENSE'"
            sed -E -i "s/PlayerDamageRateDefense=[+-]?([0-9]*[.])?[0-9]+/PlayerDamageRateDefense=$PLAYER_DAMAGE_RATE_DEFENSE/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${PLAYER_STOMACH_DECREASE_RATE+x} ]]; then
            echo "> Setting PlayerStomachDecreaceRate to '$PLAYER_STOMACH_DECREASE_RATE'"
            sed -E -i "s/PlayerStomachDecreaceRate=[+-]?([0-9]*[.])?[0-9]+/PlayerStomachDecreaceRate=$PLAYER_STOMACH_DECREASE_RATE/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${PLAYER_STAMINA_DECREACE_RATE+x} ]]; then
            echo "> Setting PlayerStaminaDecreaceRate to '$PLAYER_STAMINA_DECREACE_RATE'"
            sed -E -i "s/PlayerStaminaDecreaceRate=[+-]?([0-9]*[.])?[0-9]+/PlayerStaminaDecreaceRate=$PLAYER_STAMINA_DECREACE_RATE/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${PLAYER_AUTO_HP_REGENE_RATE+x} ]]; then
            echo "> Setting PlayerAutoHPRegeneRate to '$PLAYER_AUTO_HP_REGENE_RATE'"
            sed -E -i "s/PlayerAutoHPRegeneRate=[+-]?([0-9]*[.])?[0-9]+/PlayerAutoHPRegeneRate=$PLAYER_AUTO_HP_REGENE_RATE/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${PLAYER_AUTO_HP_REGENE_RATE_IN_SLEEP+x} ]]; then
            echo "> Setting PlayerAutoHpRegeneRateInSleep to '$PLAYER_AUTO_HP_REGENE_RATE_IN_SLEEP'"
            sed -E -i "s/PlayerAutoHpRegeneRateInSleep=[+-]?([0-9]*[.])?[0-9]+/PlayerAutoHpRegeneRateInSleep=$PLAYER_AUTO_HP_REGENE_RATE_IN_SLEEP/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${PAL_STOMACH_DECREACE_RATE+x} ]]; then
            echo "> Setting PalStomachDecreaceRate to '$PAL_STOMACH_DECREACE_RATE'"
            sed -E -i "s/PalStomachDecreaceRate=[+-]?([0-9]*[.])?[0-9]+/PalStomachDecreaceRate=$PAL_STOMACH_DECREACE_RATE/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${PAL_STAMINA_DECREACE_RATE+x} ]]; then
            echo "> Setting PalStaminaDecreaceRate to '$PAL_STAMINA_DECREACE_RATE'"
            sed -E -i "s/PalStaminaDecreaceRate=[+-]?([0-9]*[.])?[0-9]+/PalStaminaDecreaceRate=$PAL_STAMINA_DECREACE_RATE/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${PAL_AUTO_HP_REGENE_RATE+x} ]]; then
            echo "> Setting PalAutoHPRegeneRate to '$PAL_AUTO_HP_REGENE_RATE'"
            sed -E -i "s/PalAutoHPRegeneRate=[+-]?([0-9]*[.])?[0-9]+/PalAutoHPRegeneRate=$PAL_AUTO_HP_REGENE_RATE/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${PAL_AUTO_HP_REGENE_RATE_IN_SLEEP+x} ]]; then
            echo "> Setting PalAutoHpRegeneRateInSleep to '$PAL_AUTO_HP_REGENE_RATE_IN_SLEEP'"
            sed -E -i "s/PalAutoHpRegeneRateInSleep=[+-]?([0-9]*[.])?[0-9]+/PalAutoHpRegeneRateInSleep=$PAL_AUTO_HP_REGENE_RATE_IN_SLEEP/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${BUILD_OBJECT_DAMAGE_RATE+x} ]]; then
            echo "> Setting BuildObjectDamageRate to '$BUILD_OBJECT_DAMAGE_RATE'"
            sed -E -i "s/BuildObjectDamageRate=[+-]?([0-9]*[.])?[0-9]+/BuildObjectDamageRate=$BUILD_OBJECT_DAMAGE_RATE/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${BUILD_OBJECT_DETERIORATION_DAMAGE_RATE+x} ]]; then
            echo "> Setting BuildObjectDeteriorationDamageRate to '$BUILD_OBJECT_DETERIORATION_DAMAGE_RATE'"
            sed -E -i "s/BuildObjectDeteriorationDamageRate=[+-]?([0-9]*[.])?[0-9]+/BuildObjectDeteriorationDamageRate=$BUILD_OBJECT_DETERIORATION_DAMAGE_RATE/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${COLLECTION_DROP_RATE+x} ]]; then
            echo "> Setting CollectionDropRate to '$COLLECTION_DROP_RATE'"
            sed -E -i "s/CollectionDropRate=[+-]?([0-9]*[.])?[0-9]+/CollectionDropRate=$COLLECTION_DROP_RATE/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${COLLECTION_OBJECT_HP_RATE+x} ]]; then
            echo "> Setting CollectionObjectHpRate to '$COLLECTION_OBJECT_HP_RATE'"
            sed -E -i "s/CollectionObjectHpRate=[+-]?([0-9]*[.])?[0-9]+/CollectionObjectHpRate=$COLLECTION_OBJECT_HP_RATE/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${COLLECTION_OBJECT_RESPAWN_SPEED_RATE+x} ]]; then
            echo "> Setting CollectionObjectRespawnSpeedRate to '$COLLECTION_OBJECT_RESPAWN_SPEED_RATE'"
            sed -E -i "s/CollectionObjectRespawnSpeedRate=[+-]?([0-9]*[.])?[0-9]+/CollectionObjectRespawnSpeedRate=$COLLECTION_OBJECT_RESPAWN_SPEED_RATE/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${ENEMY_DROP_ITEM_RATE+x} ]]; then
            echo "> Setting EnemyDropItemRate to '$ENEMY_DROP_ITEM_RATE'"
            sed -E -i "s/EnemyDropItemRate=[+-]?([0-9]*[.])?[0-9]+/EnemyDropItemRate=$ENEMY_DROP_ITEM_RATE/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${DEATH_PENALTY+x} ]]; then
            echo "> Setting DeathPenalty to '$DEATH_PENALTY'"
            sed -E -i "s/DeathPenalty=[a-zA-Z]*/DeathPenalty=$DEATH_PENALTY/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${ENABLE_PLAYER_TO_PLAYER_DAMAGE+x} ]]; then
            echo "> Setting bEnablePlayerToPlayerDamage to '$ENABLE_PLAYER_TO_PLAYER_DAMAGE'"
            sed -E -i "s/bEnablePlayerToPlayerDamage=[a-zA-Z]*/bEnablePlayerToPlayerDamage=$ENABLE_PLAYER_TO_PLAYER_DAMAGE/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${ENABLE_FRIENDLY_FIRE+x} ]]; then
            echo "> Setting bEnableFriendlyFire to '$ENABLE_FRIENDLY_FIRE'"
            sed -E -i "s/bEnableFriendlyFire=[a-zA-Z]*/bEnableFriendlyFire=$ENABLE_FRIENDLY_FIRE/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${ENABLE_INVADER_ENEMY+x} ]]; then
            echo "> Setting bEnableInvaderEnemy to '$ENABLE_INVADER_ENEMY'"
            sed -E -i "s/bEnableInvaderEnemy=[a-zA-Z]*/bEnableInvaderEnemy=$ENABLE_INVADER_ENEMY/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${ACTIVE_UNKO+x} ]]; then
            echo "> Setting bActiveUNKO to '$ACTIVE_UNKO'"
            sed -E -i "s/bActiveUNKO=[a-zA-Z]*/bActiveUNKO=$ACTIVE_UNKO/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${ENABLE_AIM_ASSIST_PAD+x} ]]; then
            echo "> Setting bEnableAimAssistPad to '$ENABLE_AIM_ASSIST_PAD'"
            sed -E -i "s/bEnableAimAssistPad=[a-zA-Z]*/bEnableAimAssistPad=$ENABLE_AIM_ASSIST_PAD/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${ENABLE_AIM_ASSIST_KEYBOARD+x} ]]; then
            echo "> Setting bEnableAimAssistKeyboard to '$ENABLE_AIM_ASSIST_KEYBOARD'"
            sed -E -i "s/bEnableAimAssistKeyboard=[a-zA-Z]*/bEnableAimAssistKeyboard=$ENABLE_AIM_ASSIST_KEYBOARD/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${DROP_ITEM_MAX_NUM+x} ]]; then
            echo "> Setting DropItemMaxNum to '$DROP_ITEM_MAX_NUM'"
            sed -E -i "s/DropItemMaxNum=[0-9]*/DropItemMaxNum=$DROP_ITEM_MAX_NUM/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${DROP_ITEM_MAX_NUM_UNKO+x} ]]; then
            echo "> Setting DropItemMaxNum_UNKO to '$DROP_ITEM_MAX_NUM_UNKO'"
            sed -E -i "s/DropItemMaxNum_UNKO=[0-9]*/DropItemMaxNum_UNKO=$DROP_ITEM_MAX_NUM_UNKO/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${BASE_CAMP_MAX_NUM+x} ]]; then
            echo "> Setting BaseCampMaxNum to '$BASE_CAMP_MAX_NUM'"
            sed -E -i "s/BaseCampMaxNum=[0-9]*/BaseCampMaxNum=$BASE_CAMP_MAX_NUM/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${BASE_CAMP_WORKER_MAXNUM+x} ]]; then
            echo "> Setting BaseCampWorkerMaxNum to '$BASE_CAMP_WORKER_MAXNUM'"
            sed -E -i "s/BaseCampWorkerMaxNum=[0-9]*/BaseCampWorkerMaxNum=$BASE_CAMP_WORKER_MAXNUM/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${DROP_ITEM_ALIVE_MAX_HOURS+x} ]]; then
            echo "> Setting DropItemAliveMaxHours to '$DROP_ITEM_ALIVE_MAX_HOURS'"
            sed -E -i "s/DropItemAliveMaxHours=[+-]?([0-9]*[.])?[0-9]+/DropItemAliveMaxHours=$DROP_ITEM_ALIVE_MAX_HOURS/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${AUTO_RESET_GUILD_NO_ONLINE_PLAYERS+x} ]]; then
            echo "> Setting bAutoResetGuildNoOnlinePlayers to '$AUTO_RESET_GUILD_NO_ONLINE_PLAYERS'"
            sed -E -i "s/bAutoResetGuildNoOnlinePlayers=[a-zA-Z]*/bAutoResetGuildNoOnlinePlayers=$AUTO_RESET_GUILD_NO_ONLINE_PLAYERS/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS+x} ]]; then
            echo "> Setting AutoResetGuildTimeNoOnlinePlayers to '$AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS'"
            sed -E -i "s/AutoResetGuildTimeNoOnlinePlayers=[+-]?([0-9]*[.])?[0-9]+/AutoResetGuildTimeNoOnlinePlayers=$AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${GUILD_PLAYER_MAX_NUM+x} ]]; then
            echo "> Setting GuildPlayerMaxNum to '$GUILD_PLAYER_MAX_NUM'"
            sed -E -i "s/GuildPlayerMaxNum=[0-9]*/GuildPlayerMaxNum=$GUILD_PLAYER_MAX_NUM/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${PAL_EGG_DEFAULT_HATCHING_TIME+x} ]]; then
            echo "> Setting PalEggDefaultHatchingTime to '$PAL_EGG_DEFAULT_HATCHING_TIME'"
            sed -E -i "s/PalEggDefaultHatchingTime=[+-]?([0-9]*[.])?[0-9]+/PalEggDefaultHatchingTime=$PAL_EGG_DEFAULT_HATCHING_TIME/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${WORK_SPEED_RATE+x} ]]; then
            echo "> Setting WorkSpeedRate to '$WORK_SPEED_RATE'"
            sed -E -i "s/WorkSpeedRate=[+-]?([0-9]*[.])?[0-9]+/WorkSpeedRate=$WORK_SPEED_RATE/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${IS_MULTIPLAY+x} ]]; then
            echo "> Setting bIsMultiplay to '$IS_MULTIPLAY'"
            sed -E -i "s/bIsMultiplay=[a-zA-Z]*/bIsMultiplay=$IS_MULTIPLAY/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${IS_PVP+x} ]]; then
            echo "> Setting bIsPvP to $IS_PVP"
            sed -E -i "s/bIsPvP=[a-zA-Z]*/bIsPvP=$IS_PVP/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP+x} ]]; then
            echo "> Setting bCanPickupOtherGuildDeathPenaltyDrop to '$CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP'"
            sed -E -i "s/bCanPickupOtherGuildDeathPenaltyDrop=[a-zA-Z]*/bCanPickupOtherGuildDeathPenaltyDrop=$CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${ENABLE_NON_LOGIN_PENALTY+x} ]]; then
            echo "> Setting bEnableNonLoginPenalty to '$ENABLE_NON_LOGIN_PENALTY'"
            sed -E -i "s/bEnableNonLoginPenalty=[a-zA-Z]*/bEnableNonLoginPenalty=$ENABLE_NON_LOGIN_PENALTY/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${ENABLE_FAST_TRAVEL+x} ]]; then
            echo "> Setting bEnableFastTravel to '$ENABLE_FAST_TRAVEL'"
            sed -E -i "s/bEnableFastTravel=[a-zA-Z]*/bEnableFastTravel=$ENABLE_FAST_TRAVEL/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${IS_START_LOCATION_SELECT_BY_MAP+x} ]]; then
            echo "> Setting bIsStartLocationSelectByMap to '$IS_START_LOCATION_SELECT_BY_MAP'"
            sed -E -i "s/bIsStartLocationSelectByMap=[a-zA-Z]*/bIsStartLocationSelectByMap=$IS_START_LOCATION_SELECT_BY_MAP/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${EXIST_PLAYER_AFTER_LOGOUT+x} ]]; then
            echo "> Setting bExistPlayerAfterLogout to '$EXIST_PLAYER_AFTER_LOGOUT'"
            sed -E -i "s/bExistPlayerAfterLogout=[a-zA-Z]*/bExistPlayerAfterLogout=$EXIST_PLAYER_AFTER_LOGOUT/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${ENABLE_DEFENSE_OTHER_GUILD_PLAYER+x} ]]; then
            echo "> Setting bEnableDefenseOtherGuildPlayer to '$ENABLE_DEFENSE_OTHER_GUILD_PLAYER'"
            sed -E -i "s/bEnableDefenseOtherGuildPlayer=[a-zA-Z]*/bEnableDefenseOtherGuildPlayer=$ENABLE_DEFENSE_OTHER_GUILD_PLAYER/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${COOP_PLAYER_MAX_NUM+x} ]]; then
            echo "> Setting CoopPlayerMaxNum to '$COOP_PLAYER_MAX_NUM'"
            sed -E -i "s/CoopPlayerMaxNum=[0-9]*/CoopPlayerMaxNum=$COOP_PLAYER_MAX_NUM/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${MAX_PLAYERS+x} ]]; then
            echo "> Setting max-players to '$MAX_PLAYERS'"
            sed -E -i "s/ServerPlayerMaxNum=[0-9]*/ServerPlayerMaxNum=$MAX_PLAYERS/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${SERVER_NAME+x} ]]; then
            echo "> Setting server name to '$SERVER_NAME'"
            sed -E -i "s/ServerName=\"[^\"]*\"/ServerName=\"$SERVER_NAME\"/" "$GAME_SETTINGS_PATH"
            if [[ "$SERVER_NAME" == *"###RANDOM###"* ]]; then
                RAND_VALUE=$RANDOM
                echo "> Found standard template, using random numbers in server name"
                sed -E -i -e "s/###RANDOM###/$RAND_VALUE/g" "$GAME_SETTINGS_PATH"
                echo "> Server name is now 'jammsen-docker-generated-$RAND_VALUE'"
            fi
        fi
        if [[ -n ${SERVER_DESCRIPTION+x} ]]; then
            echo "> Setting server description to '$SERVER_DESCRIPTION'"
            sed -E -i "s/ServerDescription=\"[^\"]*\"/ServerDescription=\"$SERVER_DESCRIPTION\"/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${ADMIN_PASSWORD+x} ]]; then
            echo "> Setting server admin password to '$ADMIN_PASSWORD'"
            sed -E -i "s/AdminPassword=\"[^\"]*\"/AdminPassword=\"$ADMIN_PASSWORD\"/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${SERVER_PASSWORD+x} ]]; then
            echo "> Setting server password to '$SERVER_PASSWORD'"
            sed -E -i "s/ServerPassword=\"[^\"]*\"/ServerPassword=\"$SERVER_PASSWORD\"/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${PUBLIC_PORT+x} ]]; then
            echo "> Setting public port to '$PUBLIC_PORT'"
            sed -E -i "s/PublicPort=[0-9]*/PublicPort=$PUBLIC_PORT/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${PUBLIC_IP+x} ]]; then
            echo "> Setting public ip to '$PUBLIC_IP'"
            sed -E -i "s/PublicIP=\"[^\"]*\"/PublicIP=\"$PUBLIC_IP\"/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${RCON_ENABLED+x} ]]; then
            echo "> Setting rcon-enabled to '$RCON_ENABLED'"
            sed -E -i "s/RCONEnabled=[a-zA-Z]*/RCONEnabled=$RCON_ENABLED/" "$GAME_SETTINGS_PATH"
            if [ "$RCON_ENABLED" == "true" ]; then
                echo "> Because RCON is enabled, setting rcon.yaml config file"
                sed -i "s/###RCON_PORT###/$RCON_PORT/" ~/steamcmd/rcon.yaml
                sed -i "s/###ADMIN_PASSWORD###/$ADMIN_PASSWORD/" ~/steamcmd/rcon.yaml
            fi
        fi
        if [[ -n ${RCON_PORT+x} ]]; then
            echo "> Setting RCONPort to '$RCON_PORT'"
            sed -E -i "s/RCONPort=[0-9]*/RCONPort=$RCON_PORT/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${REGION+x} ]]; then
            echo "> Setting Region to '$REGION'"
            sed -E -i "s/Region=\"[^\"]*\"/Region=\"$REGION\"/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${USEAUTH+x} ]]; then
            echo "> Setting bUseAuth to '$USEAUTH'"
            sed -E -i "s/bUseAuth=[a-zA-Z]*/bUseAuth=$USEAUTH/" "$GAME_SETTINGS_PATH"
        fi
        if [[ -n ${BAN_LIST_URL+x} ]]; then
            echo "> Setting BanListURL to '$BAN_LIST_URL'"
            sed -E -i "s~BanListURL=\"[^\"]*\"~BanListURL=\"$BAN_LIST_URL\"~" "$GAME_SETTINGS_PATH"
        fi
    else 
        echo "> SERVER_SETTINGS_MODE is set to manual, NOT using environment variables to configure the server!"
        echo "> File '$GAME_SETTINGS_PATH' has to be manually edited by user"
    fi
    echo ">>> Finished setting up PalWorldSettings.ini"
}



### Server Functions

# Function to start server
function start_server() {
    # IF Bash extension used:
    # https://stackoverflow.com/a/13864829
    # https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_02

    echo -e "\n>>> Starting the gameserver"
    cd "$GAME_ROOT" || exit

    setup_engine_ini
    setup_palworld_settings_ini

    START_OPTIONS=""
    if [[ -n $COMMUNITY_SERVER ]] && [[ $COMMUNITY_SERVER == "true" ]]; then
        echo "> Setting Community-Mode to enabled"
        START_OPTIONS="$START_OPTIONS EpicApp=PalServer"
    fi
    if [[ -n $MULTITHREAD_ENABLED ]] && [[ $MULTITHREAD_ENABLED == "true" ]]; then
        echo "> Setting Multi-Core-Enhancements to enabled"
        START_OPTIONS="$START_OPTIONS -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS"
    fi
    ./PalServer.sh "$START_OPTIONS"
}

# Function to stop server
function stop_server() {

    echo -e "\n>>> Stopping server"


    if [[ -n ${RCON_ENABLED+x} ]] && [[ "$RCON_ENABLED" == "true" ]]; then
        echo "> Broadcasting server shutdown request"
        rconcli 'broadcast Server_Shutdown_requested'
        rconcli 'broadcast Saving...'
        rconcli 'save'
        rconcli 'broadcast Done...'
        sleep 3
    fi

    echo -e "> Creating server backup before stopping server..."
    ./backupmanager.sh --create

    kill -SIGTERM "$(pidof PalServer-Linux-Test)"
    tail --pid="$(pidof PalServer-Linux-Test)" -f 2>/dev/null
    exit 143;
}

function install_server() {
    # force a fresh install of all
    echo -e "\n>>> Doing a fresh install of the gameserver\n"
    /home/steam/steamcmd/steamcmd.sh +force_install_dir "$GAME_ROOT" +login anonymous +app_update 2394010 validate +quit
}

function update_server() {
    # force an update and validation
    if [[ -n $STEAMCMD_VALIDATE_FILES ]] && [[ $STEAMCMD_VALIDATE_FILES == "true" ]]; then
        echo -e "\n>>> Doing an update and validate of the gameserver files"
        /home/steam/steamcmd/steamcmd.sh +force_install_dir "$GAME_ROOT" +login anonymous +app_update 2394010 validate +quit
    else
        echo -e "\n>>> Doing an update of the gameserver files"
        /home/steam/steamcmd/steamcmd.sh +force_install_dir "$GAME_ROOT" +login anonymous +app_update 2394010 +quit
    fi
}

# Function to restore server backup
function restart_server() { 
    echo -e "\n>>> Starting server restart..."
    # Cleanup the trigger restart directory
    rm -rf "${TRIGGER_RESTART_PATH:?}"/*
}

# Function to restore server backup
function restore_server_backup() { 
    echo -e "\n>>> Starting server backup restore"
    
    backup_file_path=$(cat "${TRIGGER_RESTORE_PATH}/backup_name")
    echo -e "> Backup '$backup_file_path' will be restored to '$GAME_SAVE_PATH'"
    ./backupmanager.sh --restore

    # Cleanup the trigger restore directory
    rm -rf "${TRIGGER_RESTORE_PATH:?}"/*
    echo -e "> Cleanup ${TRIGGER_RESTORE_PATH:?}/* done"
}


function check_for_default_credentials() {
    echo -e "\n>>> Checking for existence of default credentials"
    if [[ -n ${ADMIN_PASSWORD} ]] && [[ ${ADMIN_PASSWORD} == "adminPasswordHere" ]]; then
        echo "> ERROR: Security thread detected: Please change the default admin password. Aborting server start ..."
        exit 1
    fi
    if [[ -n ${SERVER_PASSWORD} ]] && [[ ${SERVER_PASSWORD} == "serverPasswordHere" ]]; then
        echo "> ERROR: Security thread detected: Please change the default server password. Aborting server start ..."
        exit 1
    fi
}

function setup_crons() { 
    touch cronlist
    if [[ -n ${BACKUP_ENABLED} ]] && [[ ${BACKUP_ENABLED} == "true" ]]; then
        echo "${BACKUP_CRON_EXPRESSION} /backupmanager.sh --create > /dev/null 2>&1" >> cronlist
    fi
    if [[ -n ${BACKUP_RETENTION_POLICY} ]] && [[ ${BACKUP_RETENTION_POLICY} == "true" ]]; then
        echo "${BACKUP_CRON_EXPRESSION} /backupmanager.sh --clean > /dev/null 2>&1" >> cronlist
    fi

    (sleep 300 && /usr/local/bin/supercronic cronlist) &
}


### Signal Handling (Handlers & Traps)

# Function to handle SIGTERM from docker stop command
function term_handler() {
    stop_server
}

# Function to handle server restart
function restart_handler() {
    echo -e "> Starting restart handler"
    # Create the backup directory if it doesn't exist
    echo -e "> Creating '${TRIGGER_RESTART_PATH}' directory"
    mkdir -p "${TRIGGER_RESTART_PATH}"

    # Watch for file creation inside the .backup_restore directory
    while inotifywait -q -e create "${TRIGGER_RESTART_PATH}"; do
        echo -e "\n>>> Restart signal received."
        # If the file created is restart, then we know it's time to restart and restore the backup
        if find "${TRIGGER_RESTART_PATH}" -maxdepth 1 -type f -name "restart" -print -quit | grep -q "restart" 2>/dev/null; then
            restart_time=$(tr -d '\n' < "${TRIGGER_RESTART_PATH}/restart")

            if [[ -z ${restart_time} ]]; then
                echo "> Restarting server immediately..."
                stop_server
            elif ! [[ "${restart_time}" =~ ^[0-9]+$ ]]; then
                echo "> ERROR: Restart time '${restart_time}' is not a number."
            else
                echo "> Restarting server in ${restart_time} seconds..."
                sleep "${restart_time}"
                echo "> Restarting server now..."
                stop_server
            fi
        else
            echo "> Unknown file created in '${TRIGGER_RESTART_PATH}' directory, ignoring server restart!"
            # Cleanup the trigger restart directory
            rm -rf "${TRIGGER_RESTART_PATH:?}"/*
        fi
    done

}

# Function to handle server backup restore
function restore_handler() {
    echo -e "> Starting restore backup handler"
    # Create the backup directory if it doesn't exist
    echo -e "> Creating '${TRIGGER_RESTORE_PATH}' directory"
    mkdir -p "${TRIGGER_RESTORE_PATH}"

    # Watch for file creation inside the .backup_restore directory
    while inotifywait -q -e create "${TRIGGER_RESTORE_PATH}"; do
        echo -e "\n>>> Backup restore signal received"
        # If the file created is backup_name, then we know it's time to restart and restore the backup
        if find "${TRIGGER_RESTORE_PATH}" -maxdepth 1 -type f -name "backup_name" -print -quit | grep -q "backup_name" 2>/dev/null; then
            backup_name=$(tr -d '\n' < "${TRIGGER_RESTORE_PATH}/backup_name")
            # Check if backup file exists
            if [ ! -f "${BACKUP_PATH}/${backup_name}" ]; then
                echo "> ERROR: Backup file '${BACKUP_PATH}/${backup_name}' does not exist."
                # Cleanup the trigger restore directory
                rm -rf "${TRIGGER_RESTORE_PATH:?}"/*
                # Continue to the next iteration of the loop, which will restart the inotifywait command
                continue
            fi
            echo "> Restarting server..."
            stop_server
        else
            echo "> Unknown file created in .backup_restore directory, ignoring backup restore!"
            # Cleanup the trigger restore directory
            rm -rf "${TRIGGER_RESTORE_PATH:?}"/*
            # Continue to the next iteration of the loop, which will restart the inotifywait command
            continue
        fi
    done
}

function start_handlers() {
    echo -e "\n>>> Starting handlers..."

    echo -e "> Starting termination handler"
    # If SIGTERM is sent to the process, call term_handler function
    trap 'kill ${!}; term_handler' SIGTERM


    # Start the restart handler
    restart_handler &
    sleep 1

    # Start the restore handler
    restore_handler &
    sleep 1
}



### Main Function

# Function to start the server manager
function start_main() {

    check_for_default_credentials

    setup_crons

    # Check if server is installed, if not try again
    if [ ! -f "${GAME_ROOT}/PalServer.sh" ]; then
        install_server
        
    fi
    if [ "${ALWAYS_UPDATE_ON_START}" == "true" ]; then
        update_server
    fi

    start_server

}



### Server Manager Initialization

# Server manager is running in a loop, so we can restart the server
while true
do

echo -e ">>> Starting server manager <<<"
    start_handlers

    # Start the server manager
    start_main &

    killpid="$!"
    echo -e "\n>>> Server started with pid ${killpid}"
    wait ${killpid}
    
    echo -e "\n>>> Server stopped, checking for restart or backup restore"

    # If file 'restart' in server_restart exists, we do a server restart
    if [ "$(ls -A "${TRIGGER_RESTART_PATH}")" ]; then
    echo -e "> Restart detected, restarting server!"
        restart_server
        continue
    # If file 'backup_name' in backup restore exists, we do a backup restore 
    elif [ "$(ls -A "${TRIGGER_RESTORE_PATH}")" ]; then
        echo -e "> Backup restore detected, restoring backup!"
        restore_server_backup
        continue
    fi

    echo -e "\n>>> Exiting server"

    exit 0;
done
