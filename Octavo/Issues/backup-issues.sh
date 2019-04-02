#! /bin/bash

wget https://api.github.com/repos/laforest/octavo/issues?state=all -O issues.json
wget https://api.github.com/repos/laforest/octavo/issues/comments  -O issues-comments.json

