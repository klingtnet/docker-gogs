#!/bin/bash

echo ${GOGS_TIMEZONE} > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata\
    && service ssh start\
    && su -s /bin/sh -c '/opt/gogs/gogs web' gogs
