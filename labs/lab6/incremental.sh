#!/bin/bash

tar -cf $HOME/backups/backup-home-nivell1-$(date +%Y%m%d%H%M).tar --newer=$(ls -t $HOME/backups/backup-home-nivell0-* | tail -n1)  --exclude=$HOME/backups $HOME
