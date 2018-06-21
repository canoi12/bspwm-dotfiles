#!/usr/bin/env bash


FG1=$(xrdb -query ~/.Xresources | grep -w '*.color5' | awk '{print $NF}')
FG2=$(xrdb -query ~/.Xresources | grep -w '*.color3' | awk '{print $NF}')
COL=$(xrdb -query ~/.Xresources | grep -w '*.color1' | awk '{print $NF}')
BG1=$(xrdb -query ~/.Xresources | grep -w '*.background' | awk '{print $NF}')
NC="\033[0m"
count=0
num=1
dots=""
musicroll=0
musiccount=1
musiclen=25
#export currentplayer=
if [[ "$#" -eq 0 ||  "$1" = "-w" ]]; then
    while true; do
        # echo -e "$currentplayer";
        TEST=$(playerctl --player=$currentplayer status 2> /dev/null)
    
        #COUNT=$(($COUNT + $num))
        if [[ "$TEST" = "Playing" ]]; then
            #echo "PUTZ" 
            count=$((count + 1))
            AUTOR=$(playerctl --player=$currentplayer metadata xesam:artist 2> /dev/null)
            #AUTOR=$(echo $AUTOR | cut -c -35)
            MUSIC=$(playerctl --player=$currentplayer metadata xesam:title 2> /dev/null)
            musiccount=${#MUSIC}
            musicroll=$((musicroll + 1))
            #echo $musicroll
            #echo $musiccount
            if [ $musiccount -gt $musiclen ]; then
                max=$((musicroll + musiclen))
                if [ $max -gt $musiccount ]; then
                    musicroll=1
                    max=$((musiclen))
                fi
                MUSIC=$(echo $MUSIC | cut -c$musicroll-$max | iconv -c)    
                #MUSIC=$(echo $MUSIC | cut -c -$musiclen | iconv -c)
                MUSIC="$MUSIC"
            fi

            #echo -e "Playing: %{F$FG1}$MUSIC%{F-} by %{F$FG2}$AUTOR %{F-}$dots";
            echo -e "  Playing: %{B$COL}%{F$BG1} $MUSIC %{F-}%{B-} by %{B-}%{F$COL} $AUTOR %{F-}%{B-}";
            #dots="$dots o"
            if [ $count -gt 3 ]; then
                count=0
                dots=""
            fi
        else
            players=($(playerctl --list-all))
            found=false
            for (( a=1; a <= ${#players[@]}; a++ )) do
                tstaux=$(playerctl --player=${players[$a]} status 2> /dev/null)
                if [[ "$tstaux" = "Playing" ]]; then
                    export currentplayer=${players[$a]}
                    found=true
                    break;
                fi
            done
            if [[ "${#players[@]}" -le 0 ]]; then
                echo -e " ";
            fi
            if [[ "$found" = false ]]; then
                #currentplayer=
                echo -e "  Paused";
            fi

            musicroll=0
        fi 

        sleep 1s
    done
fi

if [[ "$1" = "-p" ]]; then
    players=($(playerctl --list-all))
    found=false
    for (( a=1; a <= ${#players[@]}; a++ )) do
        tstaux=$(playerctl --player=${players[$a]} status 2> /dev/null)
        if [[ "$tstaux" = "Playing" ]]; then
            export currentplayer=${players[$a]}
            found=true
            break;
        fi
    done
    $(playerctl --player=$currentplayer play-pause) 
fi
