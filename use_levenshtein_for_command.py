#!/usr/bin/python

import sys
import os
import Levenshtein

attemptedCommand = sys.argv[1]

LEVENSHTEIN_CHECK_RATIO = 1/2     # edits per char length
LEVENSHTEIN_CHECK_DIST = LEVENSHTEIN_CHECK_RATIO * len(attemptedCommand)

filePath = os.path.expanduser("~/.zsh/commandNotFoundFile")
commandsFoundFile = open(filePath,"r")

usableCommands = []
for line in commandsFoundFile:
    if (Levenshtein.distance(line,attemptedCommand) < LEVENSHTEIN_CHECK_DIST):
        usableCommands.append(line)

if (len(usableCommands) != 0):
    print("\n\033[1;35mdid you mean:\033[1;0m")

    for command in usableCommands:
        print(command, "", end="", sep="")

else:
    print("\033[1;31mnone found.\033[1;0m")
