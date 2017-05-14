#!/bin/bash

# thanks to https://github.com/rfairburn
clipboard() {
    case "${OSTYPE}" in
        linux*)
            if which xsel &>/dev/null; then
                xsel --input --clipboard
            elif which xclip &>/dev/null; then
                xclip -selection "clipboard"
            else
                echo "No clipboard utility!" >&2
                return 1
            fi
            ;;
        darwin*)
            if which pbcopy &>/dev/null; then
                pbcopy
            else
                echo "No clipboard utility!" >&2
                return 1
            fi
            ;;
        cygwin*)
            cat > /dev/clipboard
            ;;
        *)
            echo "No clipboard utility!" >&2
            return 1
            ;;
    esac
}

clipboard
