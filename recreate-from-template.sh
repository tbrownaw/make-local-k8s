#!/bin/bash


./delete-all.sh

./mkvms.sh

(
    cd automation
    . env/bin/activate
    ansible-playbook cluster.yml
)

