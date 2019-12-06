#!/bin/bash

Backup () {

  # Remove old backups
  rm -rf /var/opt/gitlab/backups/*

  # Main backup
  gitlab-rake gitlab:backup:create SKIP=artifacts

  # Copy to mnt
  cp -R  /var/opt/gitlab/backups/*.tar ${MNT_DST} || {
    echo "something went wrong with cp -R command, exiting..." >> ${LOGS_PATH}
    SendNotification $(<${LOGS_PATH})
    exit 1
  }

  # Deletes files older than 7 days
  find ${MNT_DST} -type f -mtime +4 -name '*.tar' -execdir rm -- '{}' \;

  # Form report string
  FILE_SIZE=$(ls -Atrs --block-size=M ${MNT_DST}*.tar | tail -n1 | awk '{ print $1 }')
  FILE_DATE=$(stat -c %y $(ls -t ${MNT_DST}*.tar | head -1) | awk '{ print $1 }')
  REPORT_STRING=$(echo "(OK) GITLAB ${FILE_SIZE} ${FILE_DATE}")

  # Do not put "/" symbol in report string
  UpdateReport "${REPORT_STRING}"
}
