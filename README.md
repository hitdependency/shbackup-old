eew

# SHbackup

Bash script that provides sending anything to sftp
server with telegram notifications. 03/12/2019

Requirements : curl, sshfs

# Usage
```
Usage: main.sh ${CLIENT-NAME}   - on client node
main.sh --report                - on master node to send report
main.sh --help                  - to get this message
```
# Installation

1. Create mount directory
2. Create .env file
3. Create ssh key
4. Add to crontab

## .env example
```bash
SH_HOME=/shbackup
TG_BOT_TOKEN=80853:AAHpfEqj2RmYXEZpjfK-p_amnI
TG_CHAT_ID=-000000000

MNT_SRC=user@ftp.com:/ftp/data/
MNT_DST=${SH_HOME}/mnt/
MNT_PWD=password

SSH_KEY_PATH=${SH_HOME}/skey
SSH_MASTER_NODE=user@127.0.0.1

```
