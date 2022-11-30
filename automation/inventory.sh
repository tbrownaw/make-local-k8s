#!/bin/bash

if [[ $USER != root ]]
then
    BECOME=pkexec
    if [[ -t 0 ]]
    then
        BECOME=sudo
    fi
    $BECOME "$0" "$@" | tee inventory.sh.log
    exit $? # can't use `exec` with a pipeline, only a single command.
fi

OPTION="$1"; shift

NUM_ADMIN_HOSTS=1

_list () {
    
    HOSTS="$(virsh list --all | awk '/clone-/ {print $2;}')"
    
    ADMIN_HOST_LIST=
    USER_HOST_LIST=
    HOSTLINE='  "hosts": ['
    SEP=
    for NAME in $HOSTS
    do
        HOSTLINE="$HOSTLINE$SEP\"$NAME\""
        SEP=","
        HOST_NUM=${NAME#*-}

        if ((HOST_NUM < NUM_ADMIN_HOSTS))
        then
            if [[ ! -z $ADMIN_HOST_LIST ]]
            then
                ADMIN_HOST_LIST="$ADMIN_HOST_LIST, "
            fi
            ADMIN_HOST_LIST="${ADMIN_HOST_LIST}\"${NAME}\""
        else
            if [[ ! -z $USER_HOST_LIST ]]
            then
                USER_HOST_LIST="$USER_HOST_LIST, "
            fi
            USER_HOST_LIST="${USER_HOST_LIST}\"${NAME}\""
        fi
    done

    HOSTVAR_ITEMS=
    for NAME in $HOSTS
    do
        IP=
        for ((i=0; i<5; ++i))
        do
            if ((i>0))
            then
                sleep 1
            fi
            IP=$(virsh domifaddr $NAME 2>/dev/null| awk '/ipv4/ {gsub("/.*", "", $4); print($4);}')
            if [[ ! -z "$IP" ]]
            then
                RSLT="$(ssh -n -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o IdentityFile=/home/$SUDO_USER/.ssh/id_ed25519 -o LogLevel=ERROR root@$IP echo fnord)"
                if [[ $RSLT == fnord ]]
                then
                    break
                fi
            fi
        done
        if [[ ! -z "$IP" ]]
        then
            HOSTVAR_ITEM="\"$NAME\": { \"ansible_host\": \"$IP\" }"
            if [[ ! -z $HOSTVAR_ITEMS ]]
            then
                HOSTVAR_ITEMS="$(printf '%s,
            ' "$HOSTVAR_ITEMS")"
            fi
            HOSTVAR_ITEMS="${HOSTVAR_ITEMS}${HOSTVAR_ITEM}"
        fi
    done

    cat <<EOF
{
    "nodes": {
        "children": ["nodes_admin", "nodes_user"]
    },
    "nodes_admin": {
        "hosts": [ $ADMIN_HOST_LIST ],
        "vars": { "ansible_user": "root", "ansible_ssh_common_args": "-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" }
    },
    "nodes_user": {
        "hosts": [ $USER_HOST_LIST ],
        "vars": { "ansible_user": "root", "ansible_ssh_common_args": "-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" }
    },
    "_meta": {
        "hostvars": {
            $HOSTVAR_ITEMS
        }
    }
}
EOF
}


case "$OPTION"
in
    --list) _list;;
    --host) exit 1;;
    *) exit 1;;
esac

