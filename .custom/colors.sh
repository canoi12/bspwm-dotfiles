#!/usr/bin/env bash

$(xrdb -merge ~/.Xresources)

BG1=$(xrdb -query ~/.Xresources | grep -w '*.background' | awk '{print $2}')
FG1=$(xrdb -query ~/.Xresources | grep -w '*.foreground' | awk '{print $2}')

declare -A color

for ((a=0; a < 16; a++)) do
    aux="*.color$a"
    color[$a]=$(xrdb -query ~/.Xresources | grep -w $aux | awk '{print $2}')
    #echo $aux
done

