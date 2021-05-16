#!/usr/bin/env python3
#Written by DarviL (David Losantos)
#Please don't expect beautiful things here, it would be even better to expect the worst.

from time import sleep
from os import get_terminal_size, system as runsys
from random import randrange, randint
import argparse

prjVersion = "1.3.1"



def terminalOpt(*args):
    """
    Quick terminal options

    Options:
        - clear
        - reset
        - newbuffer / oldbuffer
        - showcursor / hidecursor
    """

    ESCcodes = {
        "clear": "\u001b[H\u001b[2J",
        "reset": "\u001b[0m",
        "newbuffer": "\u001b[?1049h",
        "oldbuffer": "\u001b[?1049l",
        "showcursor": "\u001b[?25h",
        "hidecursor": "\u001b[?25l"
    }

    out = ""
    for arg in args:
        out = out + ESCcodes.get(arg)

    print(out, end="")


def getWindowSize():
    """
    Returns a list with the size of the terminal.
    Also it subtracts 2 to cols because otherwise the lines won't be aligned or something.
    """
    size = list(get_terminal_size())
    return (size[0] - 2, size[1])


randomColor = lambda: [randint(0,255), randint(0,255), randint(0,255)]


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




runsys("")  # Idk the purpose of this but it's needed in Windows to display proper VT100 sequences... (Windows dumb)

# Parse parms
argparser = argparse.ArgumentParser(description="A small python script to display moving lines in the terminal.",epilog=f"Written by DarviL (David Losantos). Version {prjVersion}.")
argparser.add_argument("-n", help="Number of lines to display", type=int, default=1)
argparser.add_argument("-c", help="Clear the screen when colliding", action="store_true")
argparser.add_argument("-s", help="Delay per screen frame in seconds", type=float, default=0.02)
argparser.add_argument("-l", help="Length of the line. Use '0' to make it infinite", type=int, default=10)
argparser.add_argument("-d", help="Create a new line at every collision with the same color as it's parent", action="store_true")
argparser.add_argument("-w", help="Make lines collide with each other, causing them to wait until the path is free. Not supported with 0 length lines", action="store_true")
argparser.add_argument("-r", help="Change the color of the line on every frame", action="store_true")
argparser.add_argument("--max", help="Maximun number of line objects that can be created. Default is 5000", type=int, default=5000)
argparser.add_argument("--debug", help="Debug mode. Displays information about the current session, and appends all the events to the log file './pt2.log'. It is recommended to use 'tail -f' to view the contents of the file.", action="store_true")
args = argparser.parse_args()

invalid = False
if args.n <= 0: showMsg(error="Number of lines cannot be 0 or below"); invalid = True
if args.l > 500: showMsg(error="Length cannot exceed 500"); invalid = True
if args.max <= 0: showMsg(error="Number of max lines cannot be 0 or below"); invalid = True
if invalid: quit(1)









windowSize = getWindowSize()
terminalOpt("newbuffer", "hidecursor", "clear")
if args.debug: logfile = open("./pt2.log", "w", buffering=1)





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

        if args.debug:
            logfile.write(f"Created new \u001b[38;2;{self._color[0]};{self._color[1]};{self._color[2]}mline\u001b[0m.\n")
            self.logmsg = lambda msg: logfile.write(f"\t\u001b[38;2;{self._color[0]};{self._color[1]};{self._color[2]}m#\u001b[0m {msg}\n")


    def __str__(self):
        return f"\u001b[H\u001b[0m\u001b[7m\u001b[KLength: {self._llength}\tColor: {self._color}\tPos: {self._pos}\tState: {self._state}\t\tObjects: {len(lines)}\nPosHistory: {self._posHistory}\u001b[K\u001b[27m"


    def collide(self, axis, state):
        self._state[axis] = state
        if args.d and len(lines) < args.max: lines.append(Line(color=self._color))
        if args.c:
            terminalOpt("clear")
            self._posHistory.clear()
        if args.debug:
            self.logmsg(f"Border collision at {self._pos}")


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
        _nextPos = self.operate()

        # Line to line collision detection
        if args.w and args.n != 0:
            for obj in lines:
                if obj is self.__class__: continue
                if _nextPos in self._posHistory: continue
                if _nextPos in obj._posHistory:
                    if args.debug: self.logmsg(f"Line collision at {self._pos}")
                    return

        # Add / Subtract to the current coordinates
        self._pos = _nextPos
        if self._pos[0] <= 1: self.collide(0, 0)
        if self._pos[1] <= 1: self.collide(1, 0)
        if self._pos[0] >= windowSize[0]: self.collide(0, 1)
        if self._pos[1] >= windowSize[1]: self.collide(1, 1)

        if args.r: self._color = randomColor()

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
                self._oldPos = self._posHistory[-1]
                _brush = f"\u001b[{self._oldPos[1]};{self._oldPos[0]}f  "

                if self._oldPos in self._posHistory[0:-2]:
                    _brush = f"\u001b[{self._oldPos[1]};{self._oldPos[0]}f\u001b[38;2;{self._color[0]};{self._color[1]};{self._color[2]}m██"
                else:
                    for obj in lines:
                        if obj._posHistory is self._posHistory: continue
                        if self._oldPos in obj._posHistory:
                            _brush = f"\u001b[{self._oldPos[1]};{self._oldPos[0]}f\u001b[38;2;{obj._color[0]};{obj._color[1]};{obj._color[2]}m██"
                            break

                print(_brush, end="", flush=True)

                self._posHistory.pop(-1)








lines = []
for x in range(0, capValue(args.n, args.max)):
    lines.append(Line())

getSizeCounter = 0
try:
    while True:
        if getSizeCounter >= 10:
            windowSize = getWindowSize()
            getSizeCounter = 0

        for x in range(0, len(lines)):
            lines[x].move()
            if args.debug: print(lines[x])

        sleep(args.s)
        getSizeCounter += 1

except KeyboardInterrupt:
    terminalOpt("clear", "oldbuffer", "reset", "showcursor")
    if args.debug:
        logfile.write("Interrupted.\n")
        logfile.close()
    quit(0)
