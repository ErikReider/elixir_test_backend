#!/bin/bash

echo "Start"

yarn --version

yarn install || exit 1

yarn start
