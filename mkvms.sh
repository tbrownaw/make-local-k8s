#!/bin/bash

if [[ $USER != root ]]
then
    echo "You should have run this under sudo." >&2
    exec sudo "$0" "$@"
fi

#set -e

COUNT="${1-5}"

#TEMPLATE=debian11
TEMPLATE=newtemplate-debian115

_status_of () {
    virsh list --all | awk /$1/' {print $3;}'
}

_start () {
    virsh start "$1"
    while [[ $(_status_of "$1") != running ]]
    do
        printf .
        sleep 1
    done
    echo
}

_set_sshkey () {
    RESET_CMD='{"execute": "guest-exec", "arguments": {"path": "dpkg-reconfigure", "arg": ["openssh-server"], "capture-output": true}}'
    RESET_PID=
    while [[ -z $RESET_PID ]]
    do
        printf .
        sleep 1
        RESET_CMD_RSLT=$(virsh qemu-agent-command "$1" "$RESET_CMD" 2>/dev/null || true)
        RESET_PID=$(echo "$RESET_CMD_RSLT" | jq .return.pid || true)
        if [[ ! -z "$RESET_CMD_RSLT" && -z "$RESET_PID" ]]
        then
            echo "Reset cmd result: $RESET_CMD_RSLT"
        fi
    done
    echo

    echo "Waiting for reset command"
    CHK_CMD='{"execute": "guest-exec-status", "arguments": {"pid": '$RESET_PID'}}'
    EXITED=
    while [[ $EXITED != true ]]
    do
        printf .
        sleep 1
        CHK_CMD_RSLT=$(virsh qemu-agent-command $NAME "$CHK_CMD")
        EXITED=$(echo "$CHK_CMD_RSLT" | jq .return.exited)
    done
    echo
}

mkvm () {
    virt-clone -o $TEMPLATE -n $1 --auto-clone
    virt-sysprep -d $1 --hostname $1 --ssh-inject root:file:/home/tbrownaw/.ssh/id_ed25519.pub

    _start "$1"

    _set_sshkey "$1"
}

EXISTING=( $(virsh list --all | awk '/clone-/ {print $2;}') )
exists () {
    for ((i=0; i< ${#EXISTING[*]}; ++i))
    do
        if [[ ${EXISTING[i]} == "$1" ]]
        then
            return 0
        fi
    done
    return 1
}

echo "You asked for $COUNT VMs"

for ((n = 0; n < COUNT; ++n))
do
    NAME=$(printf 'clone-%02d' $n)
    if ! exists $NAME
    then
        mkvm $NAME
    fi
done


