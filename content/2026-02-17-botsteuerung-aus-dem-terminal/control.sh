#!/bin/bash

CMDFIFO=/tmp/cmd.fifo

trap "rm -f $CMDFIFO" EXIT

mkfifo "$CMDFIFO"
exec 4>"$CMDFIFO"

while read -rsn1 KEY
do
    MOVE=
    case $KEY in
        [wW]) MOVE=N ;;
        [aA]) MOVE=W ;;
        [dD]) MOVE=E ;;
        [sS]) MOVE=S ;;
        [.])  MOVE=WAIT ;;
        *) continue ;;
    esac
    echo -n $KEY
    echo $MOVE >&4
done
