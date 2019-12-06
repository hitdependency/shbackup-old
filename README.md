# SHbackup

Backup main services with manual .sh scripts and master node report

# Installation

* git clone
* mkdir mnt
* create .env file
* create ssh key
* add to crontab

## .env example
```bash
SH_HOME=/shbackup
TG_BOT_TOKEN=80853:AAHpfEqj2RmYXEZpjfK-p_amnI
TG_CHAT_ID=-000000000
REPORT_PATH=${SH_HOME}/report.txt
REPORT_PATH_TEMP=${SH_HOME}/report_template.txt
LOGS_PATH=${SH_HOME}/logs.txt
MNT_SRC=user@ftp.com:/ftp/data/
MNT_DST=${SH_HOME}/mnt/
MNT_PWD=password
SSH_KEY_PATH=${SH_HOME}/skey
SSH_MASTER_NODE=user@127.0.0.1

```
