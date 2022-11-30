#!/bin/bash

if [[ $USER != root ]]
then
    echo "You should have run this under sudo." >&2
    exec sudo "$0" "$@"
fi

virsh list --all | awk '/clone-/ {print $2;}' | while read NAME
do
    virsh shutdown $NAME
done
