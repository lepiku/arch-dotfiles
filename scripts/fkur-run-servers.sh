#!/bin/bash

_SNAME="fkur"

tmux new-session -ds $_SNAME "zsh -is eval '
    cd ~/Projects/ristek/fkur-backend
    conda-run && conda activate fkur
    python manage.py runserver 0.0.0.0:8001'"
tmux split-window -t $_SNAME:0.0 "zsh -is eval \"
    cd ~/Projects/ristek/fkur-web
    export GATSBY_API_URL='http://127.0.0.1:8001'
    nvm use 14
    npm start\""
tmux attach -t $_SNAME
