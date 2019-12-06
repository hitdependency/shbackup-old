#!/bin/bash

Backup () {
    # Remove old backups
  rm -rf /bitrix/*
    # MySql dump and tar everything
  mysqldump -u root --databases sitemanager > /bitrix/sitemanager-$(date +%Y%m%d-%H%M%S).sql
  GZIP=-9 tar cvzf /bitrix/bitrix-$(date +%Y%m%d-%H%M%S).tar.gz /home/bitrix /bitrix/*.sql

    # Copy to mnt
  cp -R  /bitrix/*.tar.gz ${MNT_DST} || {
    echo "something went wrong with cp -R command, exiting..."
    exit 1
  }
    # Deletes files older than 4 days
  find ${MNT_DST} -type f -mtime +4 -name '*.tar.gz' -execdir rm -- '{}' \;

    # Gets last filename with human readable size
  FILE_SIZE=$(ls -Atrs --block-size=M ${MNT_DST}*.tar.gz | tail -n1 | awk '{ print $1 }')
  FILE_DATE=$(stat -c %y $(ls -t ${MNT_DST}*.tar.gz | head -1) | awk '{ print $1 }')
  REPORT_STRING=$(echo "(OK) BITRIX ${FILE_SIZE} ${FILE_DATE}")

    # Do not put "/" symbol in report string
  UpdateReport "${REPORT_STRING}"
}
