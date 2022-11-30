#!/bin/bash

if [[ $USER != root ]]
then
    echo "You should have run this under sudo." >&2
    exec sudo "$0" "$@"
fi

status_of () {
    virsh list --all | awk /$1/' {print $3};'
}

virsh list --all | awk '/clone-/ {print $2 " " $3;}' | while read NAME STATUS
do
    if [[ $STATUS == running ]]
    then
        echo "Shutting down $NAME "
        virsh destroy $NAME
        while [[ $(status_of $NAME) != "shut" ]]
        do
            printf .
            sleep 5
        done
        echo done.
    fi
    virsh undefine $NAME --remove-all-storage
done
