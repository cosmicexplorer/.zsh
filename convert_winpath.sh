#!/bin/bash

# the file contained in #1 should be the result of the command:
# /cygdrive/c/Windows/System32/cmd.exe /c "echo export PATH='%PATH%'"

sed -i -e 's/\\/\//g' -e 's/C:/\/cygdrive\/c/g' -e 's/;/:/g' "$1"
