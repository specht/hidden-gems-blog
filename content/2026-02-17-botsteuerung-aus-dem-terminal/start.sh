#!/bin/bash
set -e

CMDFIFO=/tmp/cmd.fifo

function inject_move
{
    exec 3< "$CMDFIFO"

    while read MOVE REST
    do
        read -u 3 MOVE
        echo $MOVE $REST
    done
}

if [[ -p $CMDFIFO ]]; then
    exec > >(inject_move)
fi

exec lua bot.lua "$@"
