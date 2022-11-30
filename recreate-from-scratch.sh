#!/bin/bash

XAUTHORITY=${HOME}/.Xauthority
export XAUTHORITY

./build-template.sh

./recreate-from-template.sh
