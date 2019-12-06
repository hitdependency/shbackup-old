#!/bin/bash

#######################################################
# Help info
#######################################################

PrintHelp () {
  echo '
    Requirements : curl, sshfs

    Bash script that provides sending anything to sftp
    server with telegram notifications. 03/12/2019

    Usage: main.sh ${CLIENT-NAME}   - on client node
    main.sh --report                - on master node to send report
    main.sh --help                  - to get this message
  '
}

#######################################################
# .env example
#######################################################

# SH_HOME=/shbackup
# TG_BOT_TOKEN=80853:AAHpfEqj2RmYXEZpjfK-p_amnI
# TG_CHAT_ID=-000000000
# REPORT_PATH=${SH_HOME}/report.txt
# REPORT_PATH_TEMP=${SH_HOME}/report_template.txt
# LOGS_PATH=${SH_HOME}/logs.txt
# MNT_SRC=user@ftp.com:/ftp/data/
# MNT_DST=${SH_HOME}/mnt/
# MNT_PWD=password
# SSH_KEY_PATH=${SH_HOME}/skey
# SSH_MASTER_NODE=user@127.0.0.1

source .env

#######################################################
# Backup() import client for every project
#######################################################

Import () {
    CLIENT=${1}
    if [ "${1}" == "" ]; then
        PrintHelp
        exit $WRONG_ARGS
    elif [ "${1}" == "--help" ]; then
        PrintHelp
        exit 1
    elif [ "${1}" == "--report" ]; then
          SendReport
          exit 1
    else
        if ! [ -f "${SH_HOME}/clients/${1}.sh" ]; then
          echo "Client not found"
          exit $WRONG_ARGS
        fi
        . ${SH_HOME}/clients/${1}.sh

        Entrypoint
    fi
}

#######################################################
# Entrypoint
#######################################################

Entrypoint () {
    ClearLogs
    Mount
    Backup
    Umount
}

#######################################################
# Clear all logs
#######################################################

ClearLogs () {
  echo "" > ${LOGS_PATH}
}

#######################################################
# Mounts ftp server with sshfs < password
#######################################################

Umount () {
  umount ${MNT_DST} > /dev/null 2>&1 || {
    echo "already mounted ${MNT_DST}" >> ${LOGS_PATH}
  }
}

Mount () {
  Umount
  echo "${MNT_PWD}" | sshfs -o cache_timeout=115200 \
                            -o attr_timeout=115200 \
                            -o password_stdin \
                            -o allow_other \
                            -o max_readahead=90000 \
                            -o big_writes \
                            -o no_remote_lock \
                            ${MNT_SRC} ${MNT_DST} >> ${LOGS_PATH}
}

#######################################################
# Usage: SendNotification "text everything"
#######################################################

SendNotification () {
  MESSAGE_TEXT=$1
  if [ $# -ne 1 ]
  then
    echo "usage: $0 {MESSAGE_TEXT}"
    exit $WRONG_ARGS
  fi
  ping -c 1 -w 2 api.telegram.org > /dev/null || {
    echo "${ERROR_TRACE} api.telegram.org is not available" >> /
    exit 1
  }
  curl --silent -X POST "https://api.telegram.org/bot${TG_BOT_TOKEN}/sendMessage" \
                -d "chat_id=${TG_CHAT_ID}&text=${MESSAGE_TEXT}" >> ${LOGS_PATH}
}

#######################################################
# Update report on master node
#######################################################

UpdateReport () {
  REPORT_STRING=$1
  SED_STRING="s/v${CLIENT}v/${REPORT_STRING}/g"
  ssh -i ${SSH_KEY_PATH} ${SSH_MASTER_NODE} "sed -i '${SED_STRING}' ${REPORT_PATH}"
}

#######################################################
# Master node send report
#######################################################

SendReport () {
  SendNotification $(<${REPORT_PATH})
  cp ${REPORT_PATH_TEMP} ${REPORT_PATH}
}

#######################################################
# Init
#######################################################

Import ${1}
