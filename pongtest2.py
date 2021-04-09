#!/usr/bin/env python3
#Written by DarviL (David Losantos)
#Please don't expect beautiful things here, it would be even better to expect the worst.

from time import sleep
from os import popen, system
from random import randrange, randint
import argparse
from sys import exit

maxLines = 5000
prjVersion = "1.0"



def terminalOpt(*args, **kwargs):
    """
    Quick terminal options

    Options:
        - clear
    Key/values:
        - buffer = bool
        - cursor = bool
    """
    if "clear" in args: print("\u001b[H\u001b[2J", end="")
    for key in kwargs:
        value = kwargs.get(key)
        if key == "buffer":
            if value:
                out = "[?1049h"
            else: out = "[?1049l"
        elif key == "cursor":
            if value:
                out = "[?25h"
            else: out = "[?25l"
        
        print("\u001b" + out, end="")
    return


def getWindowSize():
    return (int(popen("tput cols").read()) - 2, int(popen("tput lines").read()))


def randomColor():
    return([randrange(0,255), randrange(0,255), randrange(0,255)])


def showMsg(**kwargs):
    for key in kwargs:
        value = kwargs.get(key)
        if key == "error":
            prefix = "\u001b[91mE:\u001b[0m"
        print(prefix, value)


def capValue(value, max=float('inf'), min=float('-inf')):
    if value > max:
        return max
    elif value < min:
        return min
    else:
        return value





# Getting parms
argparser = argparse.ArgumentParser(description="Pong test thing I guess.",epilog=f"Written by DarviL (David Losantos). Version {prjVersion}.")
argparser.add_argument("-n", help="number of lines to display", type=int, default=1)
argparser.add_argument("-c", help="clear the screen when colliding", action="store_true")
argparser.add_argument("-s", help="delay per screen frame in seconds", type=float, default=0.02)
argparser.add_argument("-l", help="length of the line. Use '0' to make it infinite", type=int, default=10)
argparser.add_argument("-d", help="create a new line at every collision with the same color as it's parent", action="store_true")
argparser.add_argument("-w", help="make lines collide with each other, causing them to wait until the path is free. Not supported with 0 length lines", action="store_true")
argparser.add_argument("--debug", help="debug mode", action="store_true")
args = argparser.parse_args()

invalid = False
if args.n <= 0: showMsg(error="Number of lines cannot be 0 or below"); invalid = True
if args.l > 500: showMsg(error="Length cannot exceed 500"); invalid = True
if invalid: exit()









windowSize = getWindowSize()
terminalOpt(buffer=True, cursor=False)



class Line:
    def __init__(self, **kwargs):
        self._llength = args.l + 1       # length of the line.
        self._color = randomColor()       # Color of the line in RGB.
        self._pos = [randrange(1, windowSize[0], 2), randrange(1, windowSize[1])]      # Position of the line.
        self._state = [randint(0, 1), randint(0, 1)]        # Bools for controlling when to add or substract to the current pos.
        self._posHistory = []       # Position history of the line.

        for key in kwargs:
            value = kwargs.get(key)
            if key == "color":
                self._color = value
            elif key == "pos":
                self._pos = list(value)


    def collide(self, axis=0, state=0):
        self._state[axis] = state
        if args.d and len(lines) < maxLines: lines.append(Line(color=self._color, state=self._state))
        if args.c: terminalOpt("clear")


    def operate(self):
        currentPos = list(self._pos)
        nextPos = currentPos

        if self._state[0]:
            nextPos[0] = currentPos[0] - 2
        else:
            nextPos[0] = currentPos[0] + 2

        if self._state[1]:
            nextPos[1] = currentPos[1] - 1
        else:
            nextPos[1] = currentPos[1] + 1
        return nextPos
    

    def move(self):        
        nextPos = self.operate()
        
        # Line to line collision detection
        if args.w and args.n != 0:
            for obj in lines:
                if obj is self.__class__: continue
                if nextPos in self._posHistory: continue
                if nextPos in obj._posHistory: return

        # Add / Subtract to the current coordinates
        self._pos = nextPos
        if self._pos[0] <= 1: self.collide(0, 0)
        if self._pos[1] <= 1: self.collide(1, 0)
        if self._pos[0] >= windowSize[0]: self.collide(0, 1)
        if self._pos[1] >= windowSize[1]: self.collide(1, 1)



        print(
            f"\u001b[{self._pos[1]};{self._pos[0]}f\u001b[38;2;{self._color[0]};{self._color[1]};{self._color[2]}m██",
            end="",
            flush=True
        )

        if not args.l <= 0:
            """
            Save the current position of the line into posHistory, which will contain an history of coordinates of the line.
            To remove the tail of the line progressively, we get the last value in the list, which is the position of the
            line -self._llength- steps back.
            """
            self._posHistory.insert(0, list(self._pos))

            if len(self._posHistory) == self._llength:
                self._oldPos = list(self._posHistory[-1])

                print(
                    f"\u001b[{self._oldPos[1]};{self._oldPos[0]}f  ",
                    end="",
                    flush=True
                )
                
                self._posHistory.pop(-1)
        
        if args.debug:
            print(f"\u001b[H\u001b[0mPos history: {self._posHistory}\u001b[K")
            print(f"\u001b[KCurrent pos: {self._pos}\tObjects: {len(lines)}\u001b[K")
        

    









lines = []
for x in range(0, capValue(args.n, maxLines)):
    lines.append(Line())

getSizeCounter = 0
try:
    while True:
        if getSizeCounter >= 10:
            windowSize = getWindowSize()
            getSizeCounter = 0

        for x in range(0, len(lines)):
            lines[x].move()

        sleep(args.s)
        getSizeCounter += 1

except KeyboardInterrupt:
    terminalOpt(buffer=False, cursor=True)
    exit()