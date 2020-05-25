#!/bin/bash

tar -cf $HOME/backups/backup-home-nivell0-$(date +%Y%m%d%H%M).tar --exclude=$HOME/backups $HOME
