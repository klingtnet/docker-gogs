#!/bin/sh

service ssh start
su -s /bin/bash -c "/home/gogs/bin/gogs web" gogs
