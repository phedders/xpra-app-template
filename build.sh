#!/bin/bash
cd $(dirname "$0")

curl https://xpra.org/gpg.asc > xpra.asc

docker build -t my-xpraapp:latest .
