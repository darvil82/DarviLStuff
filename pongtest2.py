#!/usr/bin/env python3
#Written by DarviL (David Losantos)
#Please don't expect beautiful things here, it would be even better to expect the worst.

from time import sleep
from os import popen, get_terminal_size, system as runsys
from random import randrange, randint
import argparse
from sys import exit

prjVersion = "1.2.1-1"



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
    Returns a tuple with the size of the terminal.
    Also it subtracts 2 to cols because otherwise the lines won't be aligned or something.
    """
<<<<<<< Updated upstream
    size = list(get_terminal_size())
    cols = size[0] - 2
    lines = size[1]
    return (cols, lines)
=======
    size = get_terminal_size()
    return (size[0] - 2, size[1])
>>>>>>> Stashed changes


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


<<<<<<< Updated upstream


runsys("")  # Idk the purpose of this but it's needed in Windows to display proper VT100 sequences... (Windows dumb)

# Parse parms
argparser = argparse.ArgumentParser(description="A small python script to display moving lines in the terminal.",epilog=f"Written by DarviL (David Losantos). Version {prjVersion}.")
argparser.add_argument("-n", help="number of lines to display", type=int, default=1)
argparser.add_argument("-c", help="clear the screen when colliding", action="store_true")
argparser.add_argument("-s", help="delay per screen frame in seconds", type=float, default=0.02)
argparser.add_argument("-l", help="length of the line. Use '0' to make it infinite", type=int, default=10)
argparser.add_argument("-d", help="create a new line at every collision with the same color as it's parent", action="store_true")
argparser.add_argument("-w", help="make lines collide with each other, causing them to wait until the path is free. Not supported with 0 length lines", action="store_true")
argparser.add_argument("-r", help="change the color of the line on every frame", action="store_true")
argparser.add_argument("--debug", help="debug mode", action="store_true")
argparser.add_argument("--max", help="maximun number of line objects that can be created. Default is 5000", type=int, default=5000)
args = argparser.parse_args()

invalid = False
if args.n <= 0: showMsg(error="Number of lines cannot be 0 or below"); invalid = True
if args.l > 500: showMsg(error="Length cannot exceed 500"); invalid = True
if args.max <= 0: showMsg(error="Number of max lines cannot be 0 or below"); invalid = True
if invalid: exit()

=======
def lstToInt(list) -> list:
    # Return list with ints
    values = []
    for item in list:
        values.append(int(item))
    return values





class Parameters():
    pass




def parseArgs() -> bool:
    # Parse parms
    global args, argPos, argColor, isValid
    argparser = argparse.ArgumentParser(description="A small python script to display moving lines in the terminal.", epilog=f"Written by DarviL (David Losantos). Version {prjVersion}.")
    argparser.add_argument("-n", "--number", help="Number of lines to display.", type=int, default=1)
    argparser.add_argument("-s", "--speed", help="Delay per screen frame in seconds.", type=float, default=0.02)
    argparser.add_argument("-l", "--lenght", help="Length of the line. Use '0' to make it infinite. Note: A value of 0 might not be supported with some other options.", type=int, default=10)
    argparser.add_argument("-c", "--clear", help="Clear the line when colliding with a border. Double 'c' will clear the entire screen.", action="count")
    argparser.add_argument("-d", "--duplicate", help="Create a new line at every collision with the same color as it's parent.", action="store_true")
    argparser.add_argument("-w", "--collide", help="Make lines collide with each other, causing them to wait until the path is free.", action="store_true")
    argparser.add_argument("-r", "--random", help="Change the color of the line on every border collision. Double 'r' will change it on every frame.", action="count")
    argparser.add_argument("--chars", help="Select the line character to display. Default is '█'. If more than one character is supplied, the character will be picked randomly from the string.", type=str, default="█")
    argparser.add_argument("--pos", help="Start position for all the lines. Position values formatted like 'PosX:PosY,[...]'. If multiple Position values are supplied, a random one will be selected when creating a new line.", type=str)
    argparser.add_argument("--color", help="Color of the lines. RGB values formatted like 'RED:GREEN:BLUE,[...]'. If multiple RGB values are supplied, a random one will be selected when creating a new line.", type=str)
    argparser.add_argument("--urate", help="Update rate of terminal size detection. For example, 1 will check for the size on every frame, while 10 will check one time every 10 frames. Default is 10.", type=int, default=10)
    argparser.add_argument("--max", help="Maximun number of line objects that can be created. Default is 5000.", type=int, default=5000)
    argparser.add_argument("--debug", help="Debug mode. Displays information about the lines on screen. If double --debug is used, appends all the events to the log file './pt2.log'. It is recommended to use 'tail -f' to view the contents of the file.", action="count")
    args = argparser.parse_args()


    isValid = True
    if args.number <= 0: showMsg(error="Number of lines cannot be 0 or below.")
    if args.lenght > 500: showMsg(error="Length cannot exceed 500.")
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
        
            if isValid: setattr(Parameters, "pos", [posSplitted])
    
    print(Parameters.pos)

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
>>>>>>> Stashed changes








windowSize = getWindowSize()
terminalOpt("newbuffer", "hidecursor", "clear")



class Line:
    def __init__(self, **kwargs):
<<<<<<< Updated upstream
        self._llength = args.l + 1       # length of the line.
        self._color = randomColor()       # Color of the line in RGB.
        self._pos = [randrange(1, windowSize[0], 2), randrange(1, windowSize[1])]      # Position of the line.
        self._state = [randint(0, 1), randint(0, 1)]        # Bools for controlling when to add or substract to the current pos.
        self._posHistory = []       # Position history of the line.

=======
        self._length = args.lenght + 1                                               # Length of the line.
        self._color = randomColor()                                                  # Color of the line in RGB.
        self._pos = [randrange(1, windowSize[0], 2), randrange(1, windowSize[1])]    # Position of the line.
        self._state = [randint(0, 1), randint(0, 1)]                                 # Bools for controlling when to add or substract to the current pos.
        self._posHistory = []                                                        # Position history of the line.
        self._char = args.chars[randint(0,len(args.chars)-1)] * 2                    # Character to display as the line body.

        if Parameters.pos: self._pos = choice(Parameters.pos)

        if args.color: self._color = choice(argColor)
    
>>>>>>> Stashed changes
        for key in kwargs:
            value = kwargs.get(key)
            if key == "color":
                self._color = value
            elif key == "pos":
                self._pos = list(value)


    def __str__(self):
        return f"\u001b[H\u001b[0m\u001b[7m\u001b[KLength: {self._llength}\tColor: {self._color}\tPos: {self._pos}\tState: {self._state}\t\tObjects: {len(lines)}\nPosHistory: {self._posHistory}\u001b[K\u001b[27m"


<<<<<<< Updated upstream
    def collide(self, axis, state):
        self._state[axis] = state
        if args.d and len(lines) < args.max: lines.append(Line(color=self._color))
        if args.c:
            terminalOpt("clear")
            self._posHistory.clear()
=======
    def collide(self, axis: list, state: list):
        if args.debug and args.debug >= 2: self.logmsg(f"Border collision at {self._pos}")
        if args.duplicate and len(lines) < args.max: lines.append(Line(char=self._char))
        self._state[axis] = state

        if args.clear:

            if args.clear== 1:
                for pos in self._posHistory:
                    self.clearSegment(pos, True)
                self._posHistory.clear()

            elif args.clear>= 2:
                terminalOpt("clear")
                for obj in lines:
                    obj._posHistory.clear()
        
        if args.random and args.random == 1: self._color = randomColor()
>>>>>>> Stashed changes


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
        if args.collide and args.number != 0:
            for obj in lines:
                if obj is self.__class__: continue
                if _nextPos in self._posHistory: continue
<<<<<<< Updated upstream
                if _nextPos in obj._posHistory: return
=======
                if _nextPos in obj._posHistory:
                    if args.debug and args.debug >= 2: self.logmsg(f"Line collision at {self._pos}")
                    self.kill()
                    return
>>>>>>> Stashed changes

        # Add / Subtract to the current coordinates
        self._pos = _nextPos
        if self._pos[0] <= 1: self.collide(0, 0)
        if self._pos[1] <= 1: self.collide(1, 0)
        if self._pos[0] >= windowSize[0]: self.collide(0, 1)
        if self._pos[1] >= windowSize[1]: self.collide(1, 1)

        if args.r: self._color = randomColor()

<<<<<<< Updated upstream
        print(
            f"\u001b[{self._pos[1]};{self._pos[0]}f\u001b[38;2;{self._color[0]};{self._color[1]};{self._color[2]}m██",
            end="",
            flush=True
        )

        if not args.l <= 0:
=======
        if args.random and args.random >= 2: self._color = randomColor()

        if args.lenght > 0:
>>>>>>> Stashed changes
            """
            Save the current position of the line into posHistory, which will contain an history of coordinates of the line.
            To remove the tail of the line progressively, we get the last value in the list, which is the position of the
            line -self._llength- steps back.
            """
            self._posHistory.insert(0, list(self._pos))

            if len(self._posHistory) == self._llength:
                self._oldPos = self._posHistory[-1]
<<<<<<< Updated upstream
                _brush = f"\u001b[{self._oldPos[1]};{self._oldPos[0]}f  "
=======
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
    

    def kill(self):
        for pos in self._posHistory:
            self.clearSegment(pos, True)
        lines.remove(self)
        if args.debug and args.debug >= 2: self.logmsg("Killed self")



>>>>>>> Stashed changes

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

<<<<<<< Updated upstream
=======
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
    for x in range(0, capValue(args.number, args.max)):
        lines.append(Line())
>>>>>>> Stashed changes



<<<<<<< Updated upstream


=======
            for obj in lines:
                obj.move()
                if args.debug: print(obj)

            sleep(args.speed)
            getSizeCounter += 1

    except KeyboardInterrupt:
        stopScript()
    
    except Exception as error:
        stopScript()
        showMsg(error=f"Unhandled exception while running the script:\n\t'{error}'")
>>>>>>> Stashed changes


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
    exit()
