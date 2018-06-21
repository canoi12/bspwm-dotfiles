#!/usr/bin/python

import subprocess
import sys
import time

import gi
gi.require_version('Playerctl', '1.0')
from gi.repository import Playerctl, GLib


def listPlayers():
    return [
        playername.split('"')[1].split('.')[-1]
        for playername 
        in subprocess.getoutput(
           'dbus-send --session --dest=org.freedesktop.DBus --type=method_call --print-reply /org/freedesktop/DBus org.freedesktop.DBus.ListNames | grep org.mpris.MediaPlayer2'
        ).split("\n")
    ]

def getPlayerStatus(playername):
    return subprocess.getoutput(
        'playerctl --player="%s" status' % playername
    )

def getActivePlayer():
    players = [ {'name': player, 'status': getPlayerStatus(player)} for player in listPlayers()]
    playing = [ player['name'] for player in players if player['status'] == 'Playing']
    paused = [ player['name'] for player in players if player['status'] == 'Paused']

    if len(playing):
        return playing[-1]
    if len(paused):
        return paused[-1]
    if len(players):
        return players[-1]['name']

class PlayerStatus:
    def __init__(self):
        self._player = None
        self._player_class = None
        self._player_name = None
        self._icon = None

        self._last_artist = None
        self._last_title = None

        self._last_status = ""

    def _init_player(self):
        while True:
            try:
                self._player_name = getActivePlayer()
                self._player_class = Playerctl.Player()

                if self._player_name:
                    self._player = self._player_class.new(self._player_name)
                else:
                    self._player = self._player_class.new()

                self._player.on('metadata', self._on_metadata)
                self._player.on('play', self._on_play)
                self._player.on('pause', self._on_pause)
                self._player.on('exit', self._on_exit)

                status = self._player.get_property('status')
                #if status == 'Playing':

                self._on_metadata(self._player, self._player.__get_property('metadata'))
                
                break
            
            except:
                #self._print_flush()
                time.sleep(2)

    def _on_metadata(self, player, e):
        if 'xesam:artist' in e.keys() and 'xesam:title' in e.keys():
            self._artist = e['xesam:artist'][0]
            self._title = e['xesam:title']

    def _on_play(self, player):
        self._print_song()

    def _on_pause(self, player):
        self._print_song()

    def _on_exit(self, player):
        self._init_player()

    def _print_song(self):
        self._print_flush(
            '{} by {}'.format(self._title, self._artist)
        )

    def _print_flush(self, status, **kwargs):
        if status != self._last_status:
            print(status, **kwargs)
            sys.stdout.flush()
            self._last_status = status

    def show(self):
        self._init_player()

        main = GLib.MainLoop()
        main.run()


#while True:
#    print("EITAA")
#    sys.stdout.flush();
#    time.sleep(2) 

PlayerStatus().show()
#print(listPlayers())
#print(getActivePlayer())