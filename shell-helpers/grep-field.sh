#!/bin/bash

FIELD="Password: "
if [[ -n $1 ]]; then
    FIELD=$1
fi

grep -oP "$FIELD\K.*"
