#!/bin/bash

cp -r /mnt/d/projects/zat-projects/handy/app/assets/* input/
LOCAL_DEBUG="true" INPUT_INPUT="input" INPUT_OUTPUT="min" bash ../entrypoint.sh 