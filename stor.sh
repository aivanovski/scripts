#!/bin/sh

cd $HOME/dev/storage
fzf --preview "bat --style=numbers --color=always --line-range :500 {}" --bind "enter:execute(nvim {})"
