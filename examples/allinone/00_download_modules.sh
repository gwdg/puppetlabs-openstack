#!/bin/bash
# Set up the modules. This needs to be done before the boxes
# are booted because VMWare and Vagrant are super buggy in
# syncing files

r10k -v info puppetfile install
python ../../tools/review_checkout.py -u hogepodge -c 91128 | sh
