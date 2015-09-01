#!/bin/sh

# use this script to backup the contents of your gogs-data container

if [ "$#" -ne 1 ]; then
    echo "USAGE: ./backup.sh /backuppath"
    exit 1
fi

if [ -d "$1" ]; then
    docker run --volumes-from gogs-data -v $1:/backup klingtdotnet/gogs \
    tar cvzf /backup/gogs_backup-$(date --iso-8601).tar.gz \
    /home/gogs \
    /etc/ssh \
    /opt/gogs/custom \
    /opt/gogs/log
else
    echo "\"$1\" is not a folder or does not exist"
fi
