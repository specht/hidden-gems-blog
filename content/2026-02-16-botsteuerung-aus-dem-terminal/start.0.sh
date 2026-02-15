#!/bin/bash
set -e

MOVES=/tmp/moves.txt

function inject_move
{
    exec 3< "$MOVES"

    while read MOVE REST
    do
        read -u 3 NEW_MOVE
        echo $NEW_MOVE $REST
    done
}

if [[ -f $MOVES ]]
then
    exec > >(inject_move)
fi

exec lua bot.lua "$@"
