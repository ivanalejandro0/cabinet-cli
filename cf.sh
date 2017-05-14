#!/bin/bash

# Consider a POSIX alternative: http://stackoverflow.com/a/28393320/687989
# read -s -p "Password: " password
# echo
password="asdfasdf"
export CABPASS=$password

BASE="$(pwd)/shell-helpers"

get_name() {
    line=$1
    # echo "line: $line"
    [[ -z $line ]] && exit
    name=$(echo $line | sed 's/\ *tags:.*//g')
    echo $name
}

copy_pass() {
    name=$1
    cab -p get "$name" | $BASE/grep-field.sh | $BASE/clipboard.sh
    echo "'$name' password was copied to clipboard"
}

copy_content() {
    name=$1
    cab -p get "$name" | $BASE/clipboard.sh
    echo "'$name' content was copied to clipboard"
}

edit_item() {
    name=$1
    cab -p update -e "$name"
}

delete_item() {
    name=$1
    cab -p rm "$name"
}

rename_item() {
    name=$1
    cab -p rename "$name"
}

# NOTE: preview is slow due to cabinet opening the vault each time for each preview
# maybe this script should use rpc server/client approach

fzf_opts='--reverse --no-hscroll --no-multi --ansi --print-query --tiebreak=index'
fzf_header="
Cabinet - filter your saved items
Ctrl+O: toggle preview / Enter: copy 'Password: ' field from item
Ctrl-E: edit contents / Ctrl-D: delete item / Ctrl-R: rename item / Ctrl-Y: copy contents

"

query=""
while [ 1 ]; do
    items=$(cab -p search -s | column -t -s '	' | sort)
    out=$(
    fzf $fzf_opts \
        --prompt="name> " \
        --query="$query" \
        --bind="ctrl-o:toggle-preview" \
        --header="$fzf_header" \
        --preview-window="down:hidden" \
        --preview="echo {} | sed 's/\ *tags:.*//g' | xargs -I {} cab -p get {} " \
        --expect="ctrl-d,ctrl-e,ctrl-y,ctrl-r,enter" \
        <<< "$items"
    );

        # --header=$'\nCabinet - filter your saved items\nCtrl+O: toggle preview / Ctrl-E: edit contents / Ctrl-R: remove item / Ctrl-Y: copy contents / Enter: select item\n\n' \
    # 2: Error / 130: Interrupt
    # (( $? % 128 == 2 )) && exit 1
    (( $? % 128 == 2 )) && break

    # [ $(wc -l <<< "$out") -lt 2 ] && continue

    query=$(head -1 <<< "$out")
    key=$(head -2 <<< "$out" | tail -1)
    line=$(tail -1 <<< "$out")
    name=$(get_name "$line")

    # echo "out:" $out
    # echo "query: $query"
    # echo "key: $key"
    # echo "line: $line"
    # echo "name: $name"

    [[ -z $name ]] && continue  # this shouldn't happen

    case "$key" in
      enter) copy_pass "$name"; exit 0 ;;
      # enter) break ;;
      ctrl-e) edit_item "$name" ;;
      ctrl-d) delete_item "$name" ;;
      ctrl-y) copy_content "$name" ;;
    esac

done

# echo "out:" $out
# echo "query: $query"
# echo "key: $key"

# copy_pass $query
