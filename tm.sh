#!/bin/sh
tmux kill-server
tmux new-session -d -n Ranger ranger
tmux new-window -n Terminal
tmux new-window -n Vim
tmux selectw -t 1
tmux -2 attach-session -d

