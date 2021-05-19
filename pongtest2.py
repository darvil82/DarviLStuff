#!/usr/bin/env python3
#Written by DarviL (David Losantos)
#Please don't expect beautiful things here, it would be even better to expect the worst.

from time import sleep
from os import get_terminal_size, system as runsys
from random import randrange, randint
import argparse


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
        "clear": "\x1b[H\x1b[2J",
        "reset": "\x1b[0m",
        "newbuffer": "\x1b[?1049h",
        "oldbuffer": "\x1b[?1049l",
        "showcursor": "\x1b[?25h",
        "hidecursor": "\x1b[?25l"
    }

    out = ""
    for arg in args:
        out += ESCcodes.get(arg)

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
    # Display a message with a bit of color.
    for key in kwargs:
        value = kwargs.get(key)
        if key == "error":
            prefix = "\x1b[91mE:\x1b[0m"
            global invalid
            invalid = True
        print(prefix, value)


def capValue(value, max=float('inf'), min=float('-inf')):
    # Clamp a value to a minimun and/or maximun value.
    if value > max:
        return max
    elif value < min:
        return min
    else:
        return value





def parseArgs():
    # Parse parms
    global args, argPos
    argparser = argparse.ArgumentParser(description="A small python script to display moving lines in the terminal.",epilog=f"Written by DarviL (David Losantos). Version {prjVersion}.")
    argparser.add_argument("-n", help="Number of lines to display.", type=int, default=1)
    argparser.add_argument("-c", help="Clear the screen when colliding.", action="store_true")
    argparser.add_argument("-s", help="Delay per screen frame in seconds.", type=float, default=0.02)
    argparser.add_argument("-l", help="Length of the line. Use '0' to make it infinite.", type=int, default=10)
    argparser.add_argument("-d", help="Create a new line at every collision with the same color as it's parent.", action="store_true")
    argparser.add_argument("-w", help="Make lines collide with each other, causing them to wait until the path is free. Not supported with 0 length lines.", action="store_true")
    argparser.add_argument("-r", help="Change the color of the line on every border collision. Double 'r' will change it on every frame.", action="count")
    argparser.add_argument("--max", help="Maximun number of line objects that can be created. Default is 5000.", type=int, default=5000)
    argparser.add_argument("--chars", help="Select the line character to display. Default is '█'. If more than one character is supplied, the character will be picked randomly from the string.", type=str, default="█")
    argparser.add_argument("--pos", help="Start position for all the lines. X and Y values separated by ','.", type=str)
    argparser.add_argument("--urate", help="Update rate of terminal size detection. For example, 1 will check for the size on every frame, while 10 will check one time every 10 frames. Default is 10.", type=int, default=10)
    argparser.add_argument("--debug", help="Debug mode. Displays information about the lines on screen. If double --debug is used, appends all the events to the log file './pt2.log'. It is recommended to use 'tail -f' to view the contents of the file.", action="count")
    args = argparser.parse_args()

    invalid = False
    if args.n <= 0: showMsg(error="Number of lines cannot be 0 or below.")
    if args.l > 500: showMsg(error="Length cannot exceed 500.")
    if args.max <= 0: showMsg(error="Number of max lines cannot be 0 or below.")
    if len(args.chars) <= 0: showMsg(error="Specified invalid character/s.")
    if args.pos:
        try:
            argPos = [int(x) for x in args.pos.split(",")]
            if len(argPos) != 2:
                showMsg(error="Position X and position Y values required.")
        except ValueError:
            showMsg(error="Invalid position value.")

    if invalid: quit(1)







class Line:
    def __init__(self, **kwargs):
        self._length = args.l + 1                                                    # Length of the line.
        self._color = randomColor()                                                  # Color of the line in RGB.
        self._pos = [randrange(1, windowSize[0], 2), randrange(1, windowSize[1])]    # Position of the line.
        self._state = [randint(0, 1), randint(0, 1)]                                 # Bools for controlling when to add or substract to the current pos.
        self._posHistory = []                                                        # Position history of the line.
        self._char = args.chars[randint(0,len(args.chars)-1)] * 2                    # Character to display as the line body.

        for key in kwargs:
            value = kwargs.get(key)
            if key == "color":
                self._color = value
            elif key == "pos":
                self._pos = list(value)
            elif key == "char":
                self._char = value

        if args.pos: self._pos = argPos

        if args.debug and args.debug >= 2:
            logfile.write(f"Created new line \x1b[38;2;{self._color[0]};{self._color[1]};{self._color[2]}m{self._char}\x1b[0m.\n")
            self.logmsg = lambda msg: logfile.write(f"\t\x1b[38;2;{self._color[0]};{self._color[1]};{self._color[2]}m{self._char}\x1b[0m → {msg}\x1b[0m\n")


    def __str__(self):
        return f"\x1b[H\x1b[0m\x1b[7m\x1b[KLength: {self._length}\tColor: {self._color}\tPos: {self._pos}\tState: {self._state}\t\tObjects: {len(lines)}\nPosHistory: {self._posHistory}\x1b[K\x1b[27m"


    def collide(self, axis, state):
        if args.debug and args.debug >= 2: self.logmsg(f"Border collision at {self._pos}")
        if args.d and len(lines) < args.max: lines.append(Line(color=self._color, char=self._char))
        self._state[axis] = state
        if args.c:
            terminalOpt("clear")
            self._posHistory.clear()
        if args.r and args.r == 1: self._color = randomColor()


    def operate(self):
        currentPos = nextPos = list(self._pos)

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
                    if args.debug and args.debug >= 2: self.logmsg(f"Line collision at {self._pos}")
                    return

        # Add / Subtract to the current coordinates
        self._pos = _nextPos
        if self._pos[0] <= 1: self.collide(0, 0)
        if self._pos[1] <= 1: self.collide(1, 0)
        if self._pos[0] == windowSize[0]:
            self.collide(0, 1)
        elif self._pos[0] > windowSize[0]:
            self.collide(0, 1)
            self._pos[0] = windowSize[0]
        
        if self._pos[1] == windowSize[1]:
            self.collide(1, 1)
        elif self._pos[1] > windowSize[1]:
            self.collide(1, 1)
            self._pos[1] = windowSize[1]
        
        if not self._pos[0] % 2: self._pos[0] += 1

        if args.r and args.r >= 2: self._color = randomColor()

        print(
            f"\x1b[{self._pos[1]};{self._pos[0]}f\x1b[38;2;{self._color[0]};{self._color[1]};{self._color[2]}m{self._char}",
            end="",
            flush=True
        )

        if args.l > 0:
            """
            Save the current position of the line into posHistory, which will contain an history of coordinates of the line.
            To remove the tail of the line progressively, we get the last value in the list, which is the position of the
            line -self._length- steps back.
            """
            self._posHistory.insert(0, list(self._pos))

            if len(self._posHistory) == self._length:
                self._oldPos = self._posHistory[-1]

                _brush = f"\x1b[{self._oldPos[1]};{self._oldPos[0]}f  "

                if self._oldPos in self._posHistory[0:-2]:
                    _brush = f"\x1b[{self._oldPos[1]};{self._oldPos[0]}f\x1b[38;2;{self._color[0]};{self._color[1]};{self._color[2]}m{self._char}"
                    if args.debug and args.debug >= 2: self.logmsg(f"Replaced self body at {self._oldPos}")
                else:
                    for obj in lines:
                        if obj._posHistory is self._posHistory: continue
                        if self._oldPos in obj._posHistory:
                            _brush = f"\x1b[{self._oldPos[1]};{self._oldPos[0]}f\x1b[38;2;{obj._color[0]};{obj._color[1]};{obj._color[2]}m{obj._char}"
                            if args.debug and args.debug >= 2: self.logmsg(f"Replaced \x1b[38;2;{obj._color[0]};{obj._color[1]};{obj._color[2]}m{obj._char}'s\x1b[0m body at {self._oldPos}")
                            break

                print(_brush, end="", flush=True)

                self._posHistory.pop(-1)






def stopScript():
    terminalOpt("clear", "oldbuffer", "reset", "showcursor")
    if args.debug and args.debug >= 2:
        logfile.write("Interrupted.\n")
        logfile.close()







def main():
    global prjVersion, windowSize, lines, logfile
    prjVersion = "1.4.5-1"

    parseArgs()

    runsys("")  # Idk the purpose of this but it's needed in Windows to display proper VT100 sequences... (Windows dumb)

    windowSize = getWindowSize()
    terminalOpt("newbuffer", "hidecursor", "clear")
    if args.debug and args.debug >= 2: logfile = open("./pt2.log", "w", buffering=1, encoding='utf-8')


    lines = []
    for x in range(0, capValue(args.n, args.max)):
        lines.append(Line())


    getSizeCounter = 0
    try:
        while True:
            if getSizeCounter >= args.urate:
                windowSize = getWindowSize()
                getSizeCounter = 0

            for x in range(0, len(lines)):
                lines[x].move()
                if args.debug: print(lines[x])

            sleep(args.s)
            getSizeCounter += 1

    except KeyboardInterrupt:
        stopScript()
    
    except Exception as error:
        stopScript()
        showMsg(error=f"An error occurred while trying to run the script:\n\t {error}")






if __name__ == "__main__":
    main()