#!/usr/bin/env python3
#Written by DarviL (David Losantos)
#Please don't expect beautiful things here, it would be even better to expect the worst.

from time import sleep
from os import get_terminal_size, system as runsys
from random import choice, randrange, randint
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


def getWindowSize() -> tuple:
    """
    Returns a list with the size of the terminal.
    Also it subtracts 2 to cols because otherwise the lines won't be aligned or something.
    """
    size = tuple(get_terminal_size())
    return (size[0] - 2, size[1])


randomColor = lambda: [randint(0,255), randint(0,255), randint(0,255)]


def showMsg(**kwargs):
    # Display a message with a bit of color.
    global isValid
    for key in kwargs:
        value = kwargs.get(key)
        if key == "error":
            prefix = "\x1b[91mE:\x1b[0m"
            isValid = False
        print(prefix, value)


def capValue(value, max=float('inf'), min=float('-inf')):
    # Clamp a value to a minimun and/or maximun value.
    if value > max:
        return max
    elif value < min:
        return min
    else:
        return value


def lstToInt(list) -> list:
    # Return list with ints
    values = []
    for item in list:
        values.append(int(item))
    return values






def parseArgs() -> bool:
    # Parse parms
    global args, argPos, argColor, isValid
    argparser = argparse.ArgumentParser(description="A small python script to display moving lines in the terminal.",epilog=f"Written by DarviL (David Losantos). Version {prjVersion}.")
    argparser.add_argument("-n", help="Number of lines to display.", type=int, default=1)
    argparser.add_argument("-c", help="Clear the line when colliding with a border. Double 'c' will clear the entire screen.", action="count")
    argparser.add_argument("-s", help="Delay per screen frame in seconds.", type=float, default=0.02)
    argparser.add_argument("-l", help="Length of the line. Use '0' to make it infinite. Note: A value of 0 might not be supported with some other options.", type=int, default=10)
    argparser.add_argument("-d", help="Create a new line at every collision with the same color as it's parent.", action="store_true")
    argparser.add_argument("-w", help="Make lines collide with each other, causing them to wait until the path is free.", action="store_true")
    argparser.add_argument("-r", help="Change the color of the line on every border collision. Double 'r' will change it on every frame.", action="count")
    argparser.add_argument("--max", help="Maximun number of line objects that can be created. Default is 5000.", type=int, default=5000)
    argparser.add_argument("--chars", help="Select the line character to display. Default is '█'. If more than one character is supplied, the character will be picked randomly from the string.", type=str, default="█")
    argparser.add_argument("--pos", help="Start position for all the lines. Position values formatted like 'PosX:PosY,[...]'. If multiple Position values are supplied, a random one will be selected when creating a new line.", type=str)
    argparser.add_argument("--color", help="Color of the lines. RGB values formatted like 'RED:GREEN:BLUE,[...]'. If multiple RGB values are supplied, a random one will be selected when creating a new line.", type=str)
    argparser.add_argument("--urate", help="Update rate of terminal size detection. For example, 1 will check for the size on every frame, while 10 will check one time every 10 frames. Default is 10.", type=int, default=10)
    argparser.add_argument("--debug", help="Debug mode. Displays information about the lines on screen. If double --debug is used, appends all the events to the log file './pt2.log'. It is recommended to use 'tail -f' to view the contents of the file.", action="count")
    args = argparser.parse_args()

    isValid = True
    if args.n <= 0: showMsg(error="Number of lines cannot be 0 or below.")
    if args.l > 500: showMsg(error="Length cannot exceed 500.")
    if args.max <= 0: showMsg(error="Number of max lines cannot be 0 or below.")
    if len(args.chars) <= 0: showMsg(error="Specified invalid character/s.")

    if args.pos:
        argPos = []
        for pos in args.pos.split(","):
            posSplitted = pos.split(":")
            if len(posSplitted) == 2:
                posAxis = 0
                for posvalue in posSplitted:
                    try:
                        posSplitted[posAxis] = capValue(int(posvalue), windowSize[posAxis], 2)
                        posAxis += 1
                    except ValueError:
                        showMsg(error=f"Position: Value '{posvalue}' is not an intenger.")
            else: showMsg(error=f"Position: Values X and Y are required (2), but {len(posSplitted)} value/s were supplied ({posSplitted}).")
        
            if isValid: argPos.append(lstToInt(posSplitted))
    
    if args.color:
        argColor = []
        for rgb in args.color.split(","):
            rgbSplitted = rgb.split(":")
            if len(rgbSplitted) == 3:
                for rgbvalue in rgbSplitted:
                    try:
                        if int(rgbvalue) not in range(0,256): showMsg(error=f"'{rgbvalue}' in not a value between '0' and '255'.")
                    except ValueError:
                        showMsg(error=f"Color: Value '{rgbvalue}' is not an intenger.")
            else: showMsg(error=f"Color: Values R, G and B are required (3), but {len(rgbSplitted)} value/s were supplied ({rgbSplitted}).")
        
            argColor.append(rgbSplitted)

    return isValid







class Line:
    def __init__(self, **kwargs):
        self._length = args.l + 1                                                    # Length of the line.
        self._color = randomColor()                                                  # Color of the line in RGB.
        self._pos = [randrange(1, windowSize[0], 2), randrange(1, windowSize[1])]    # Position of the line.
        self._state = [randint(0, 1), randint(0, 1)]                                 # Bools for controlling when to add or substract to the current pos.
        self._posHistory = []                                                        # Position history of the line.
        self._char = args.chars[randint(0,len(args.chars)-1)] * 2                    # Character to display as the line body.

        if args.pos: self._pos = choice(argPos)

        if args.color: self._color = choice(argColor)
    
        for key in kwargs:
            value = kwargs.get(key)
            if key == "color":
                self._color = value
            elif key == "pos":
                self._pos = list(value)
            elif key == "char":
                self._char = value

        if args.debug and args.debug >= 2:
            logfile.write(f"Created new line \x1b[38;2;{self._color[0]};{self._color[1]};{self._color[2]}m{self._char}\x1b[0m at {self._pos}.\n")
            self.logmsg = lambda msg: logfile.write(f"\t\x1b[38;2;{self._color[0]};{self._color[1]};{self._color[2]}m{self._char}\x1b[0m → {msg}\x1b[0m\n")


    def __str__(self):
        return f"\x1b[H\x1b[0m\x1b[7mObjects: {len(lines)}\x1b[K\n\x1b[K\n\x1b[38;2;{self._color[0]};{self._color[1]};{self._color[2]}mPosHistory: {self._posHistory}\x1b[K\nLength: {self._length}\x1b[K\nColor: {self._color}\x1b[K\nChar: '{self._char}'\x1b[K\nPos: {self._pos}\x1b[K\nState: {self._state}\x1b[K\x1b[27m\n\x1b[K"


    def collide(self, axis: list, state: list):
        if args.debug and args.debug >= 2: self.logmsg(f"Border collision at {self._pos}")
        if args.d and len(lines) < args.max: lines.append(Line(color=self._color, char=self._char))
        self._state[axis] = state

        if args.c:

            if args.c == 1:
                for pos in self._posHistory:
                    self.clearSegment(pos, True)
                self._posHistory.clear()

            elif args.c >= 2:
                terminalOpt("clear")
                for obj in lines:
                    obj._posHistory.clear()
        
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

        if self._pos[0] == windowSize[0] or self._pos[0] == windowSize[0] + 1:
            self.collide(0, 1)
        elif self._pos[0] > windowSize[0]:
            self.collide(0, 1)
            self._pos[0] = windowSize[0]
            for pos in self._posHistory:
                self.clearSegment(pos, True)
            self._posHistory.clear()

        if self._pos[1] == windowSize[1]:
            self.collide(1, 1)
        elif self._pos[1] > windowSize[1]:
            self.collide(1, 1)
            self._pos[1] = windowSize[1]
            for pos in self._posHistory:
                self.clearSegment(pos, True)
            self._posHistory.clear()
        
        if not self._pos[0] % 2: self._pos[0] += 1

        if args.r and args.r >= 2: self._color = randomColor()

        if args.l > 0:
            """
            Save the current position of the line into posHistory, which will contain an history of coordinates of the line.
            To remove the tail of the line progressively, we get the last value in the list, which is the position of the
            line -self._length- steps back.
            """
            self._posHistory.insert(0, list(self._pos))

            if len(self._posHistory) == self._length:
                self._oldPos = self._posHistory[-1]
                self.clearSegment(self._oldPos)
                self._posHistory.pop(-1)

        print(
            f"\x1b[{self._pos[1]};{self._pos[0]}f\x1b[38;2;{self._color[0]};{self._color[1]};{self._color[2]}m{self._char}",
            end="",
            flush=True
        )


    def clearSegment(self, pos: list, ignoreSelf=False):
        _brush = f"\x1b[{pos[1]};{pos[0]}f  "

        if pos in self._posHistory[0:-2] and ignoreSelf == False:
            _brush = f"\x1b[{pos[1]};{pos[0]}f\x1b[38;2;{self._color[0]};{self._color[1]};{self._color[2]}m{self._char}"
            if args.debug and args.debug >= 2: self.logmsg(f"Replaced self body at {pos}")
        else:
            for obj in lines:
                if obj._posHistory is self._posHistory: continue
                if pos in obj._posHistory:
                    _brush = f"\x1b[{pos[1]};{pos[0]}f\x1b[38;2;{obj._color[0]};{obj._color[1]};{obj._color[2]}m{obj._char}"
                    if args.debug and args.debug >= 2: self.logmsg(f"Replaced \x1b[38;2;{obj._color[0]};{obj._color[1]};{obj._color[2]}m{obj._char}'s\x1b[0m body at {pos}")
                    break

        print(_brush, end="", flush=True)







def stopScript():
    terminalOpt("clear", "oldbuffer", "reset", "showcursor")
    if args.debug and args.debug >= 2:
        logfile.write("Interrupted.\n")
        logfile.close()







def main():
    global prjVersion, windowSize, lines, logfile
    prjVersion = "1.6-1"

    runsys("")                      # Idk the purpose of this but it's needed in Windows to display proper VT100 sequences... (Windows dumb)
    windowSize = getWindowSize()
    if not parseArgs(): quit()
    terminalOpt("newbuffer", "hidecursor", "clear")
    if args.debug and args.debug >= 2: logfile = open("./pt2.log", "w", buffering=1, encoding='utf-8')


    lines = []
    for x in range(0, capValue(args.n, args.max)):
        lines.append(Line())


    getSizeCounter = 1
    try:
        while True:
            if getSizeCounter >= args.urate:
                windowSize = getWindowSize()
                getSizeCounter = 1

            for x in range(0, len(lines)):
                lines[x].move()
                if args.debug: print(lines[x])

            sleep(args.s)
            getSizeCounter += 1

    except KeyboardInterrupt:
        stopScript()
    
    except Exception as error:
        stopScript()
        showMsg(error=f"An error occurred while trying to run the script:\n\t{error}")






if __name__ == "__main__":
    main()