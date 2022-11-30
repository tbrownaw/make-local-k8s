#!/bin/bash

NAME=$1
if [[ -z $NAME ]]
then
    NAME=clone-00
fi

sudo true
IP=$(sudo virsh domifaddr $NAME 2>/dev/null| awk '/ipv4/ {gsub("/.*", "", $4); print($4);}')

exec ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@${IP}
