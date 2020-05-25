#!/bin/bash

cd $HOME/backups

# du va en kB amb -k
while [ $(du -k . | cut -f1) -gt 100000  ] ; do
  # eborrem els backups d'antic a nou
  rm $(ls -t | head -n1)
done

