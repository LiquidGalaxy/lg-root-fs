#!/bin/bash

while :; do
  DISPLAY=:0 xiv $@ || break
done
