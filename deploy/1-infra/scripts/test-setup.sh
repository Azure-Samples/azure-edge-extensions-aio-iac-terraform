#!/usr/bin/env bash

if [[ -n "$(hash kubectl 2>&1)" ]];
then
  echo "Missing foo"
else
  echo "Found foo"
fi