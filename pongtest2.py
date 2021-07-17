#!/usr/bin/env python3
#Written by DarviL (David Losantos)
#Please don't expect beautiful things here, it would be even better to expect the worst.

from time import sleep
from os import get_terminal_size, system as runsys
from random import choice, randrange, randint
from textwrap import dedent
from sys import argv
from urllib import request
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
        if arg: out += ESCcodes.get(arg)

    print(out, end="")




def getWindowSize() -> tuple:
    """Returns the size of the terminal window"""

    size = get_terminal_size()
    return (size[0] - 2, size[1])




randomColor = lambda: [randint(0,255), randint(0,255), randint(0,255)]




def showMsg(**kwargs):
    """Display a message with a bit of color."""

    global isValid

    for key in kwargs:
        value = kwargs.get(key)
        if key == "error":
            prefix = "\x1b[91mE"
            msg = value
            isValid = False
        elif key == "good":
            prefix = "\x1b[92m√"
            msg = value

        if key == "type":
            prefix += f": {value}"

    print(f" {prefix}:\x1b[0m", msg)




def capValue(value, max=float('inf'), min=float('-inf')):
    """Clamp a value to a minimun and/or maximun value."""

    if value > max:
        return max
    elif value < min:
        return min
    else:
        return value




def updateScript(filepath: str):
    """Downloads and replaces the script with the latest version"""

    url = "https://raw.githubusercontent.com/DarviL82/DarviLStuff/master/pongtest2.py"
    try:
        with request.urlopen(url) as rawData, open(filepath, "wb") as file:
            file.write(rawData.read())

    except PermissionError:
        showMsg(error=f"Unable to write on the file '{filepath}'.", type="Update")
        return
    except Exception:
        showMsg(error="An error ocurred while downloading the file.", type="Update")
        return
    showMsg(good=f"Downloaded latest version as '{filepath}'.", type="Update")








class ArgValues(object):
    """Parsed arguments container."""

    pos = None
    color = None
    onBorderCollision = None
    onLineCollision = None
    onMove = None
    onPathFree = None




def parseArgs() -> bool:
    """Parse the parameters passed to the script"""

    global args, isValid

    argparser = argparse.ArgumentParser(
        description="A small python script to display moving lines in the terminal.",
        epilog=dedent(f"""\
            Conditional actions:
                To use conditional actions with the condition parameters, supply them
                formatted like 'action,[...]'. Available actions to use:

                    - duplicate     Create a new line like the current line.
                    - destroy       Destroy the current line.
                    - newColor      Change the color of the current line.
                    - newChar       Change the character of the current line.
                    - newPos        Change the position of the current line.
                    - clear         Clear all the pixels of the current line.
                    - clearAll      Clear all the pixels of all the lines.
                    - longer        Make the current line 1 pixel longer.
                    - shorter       Make the current line 1 pixel shorter.
                    - stop          Disable current line movement.
                    - continue      Enable current line movement.
                    - newLine       Create a new line.

            Written by DarviL (David Losantos). Version {prjVersion}.
            Repository available at: \x1b[4mhttps://github.com/DarviL82/DarviLStuff\x1b[24m"""),
        formatter_class=argparse.RawTextHelpFormatter
    )
    argparser.add_argument("-n", "--number", help="Number of lines to display.", type=int, default=1)
    argparser.add_argument("-s", "--speed", help="Delay per screen frame in seconds.", type=float, default=0.02)
    argparser.add_argument("-l", "--lenght", help=dedent("""\
        Length of the line. Use '0' to make it infinite.
        Note: A value of 0 might not be supported with some
        other options. Default value is 10."""), type=int, default=10)
    argparser.add_argument("-p", "--pos", help=dedent("""\
        Start position for all the lines. Position values
        formatted like 'PosX:PosY,[...]'. PosX and PosY can
        have a value of 'center' to make the line appear in
        the center of that axis. If multiple Position values
        are supplied, a random one will be selected when
        creating a new line."""), type=str)
    argparser.add_argument("-c", "--color", help=dedent("""\
        Color of the lines. RGB values formatted like
        'RED:GREEN:BLUE,[...]'. If multiple RGB values are
        supplied, a random one will be selected when creating
        a new line."""), type=str)
    argparser.add_argument("-C", "--chars", help=dedent("""\
        Select the line character to display. Default is '█'.
        If more than one character is supplied, the character
        will be picked randomly from the string."""), type=str, default="█")
    argparser.add_argument("-b", "--noBorders", help=dedent("""\
        Do not let lines collide with the borders of the
        terminal. Instead, lines will teleport to the other
        side."""), action="store_true")
    argparser.add_argument("-i", "--ignore", help=dedent("""\
        Don't collide with lines with the same color as the
        current line.


        """), action="store_true")
    argparser.add_argument("--onBorderCollision", help=dedent("""\
        Conditionally perform a set of actions when the line
        collides with the terminal border.
        Conditinal actions are listed below."""), type=str)
    argparser.add_argument("--onLineCollision", help=dedent("""\
        Conditionally perform a set of actions when the line
        collides with another line.
        Conditinal actions are listed below."""), type=str)
    argparser.add_argument("--onMove", help=dedent("""\
        Conditionally perform a set of actions when the line
        moves one pixel.
        Conditinal actions are listed below."""), type=str)
    argparser.add_argument("--onPathFree", help=dedent("""\
        Conditionally perform a set of actions when the path
        for the line is free.
        Conditinal actions are listed below.


        """), type=str)
    argparser.add_argument("--urate", help=dedent("""\
        Update rate of terminal size detection. For example,
        1 will check for the size on every frame, while 10
        will check one time every 10 frames. Default is 10."""), type=int, default=10)
    argparser.add_argument("--maxN", help=dedent("""\
        Maximun number of line objects that can be created.
        Default is 5000."""), type=int, default=5000)
    argparser.add_argument("--maxL", help=dedent("""\
        Maximun number of line pixels that a line can have.
        Default is 500."""), type=int, default=500)
    argparser.add_argument("--debug", help=dedent("""\
        Debug mode. Displays information about the lines on
        screen. If double --debug is used, appends all the
        events to the log file './pt2.log'. It is recommended
        to use 'tail -f' to view the contents of the file."""), action="count")
    argparser.add_argument("--update", help="Update the script with the latest version and exit.", action="store_true")

    args = argparser.parse_args()

    isValid = True
    if args.number <= 0: showMsg(error="Number of lines cannot be 0 or below.", type="Number")
    if args.maxN <= 0: showMsg(error="Number of max lines cannot be 0 or below.", type="Max")
    if len(args.chars) <= 0: showMsg(error="Cannot use a null value.", type="Chars")
    for char in args.chars:
        if char in {"\a", "\b", "\e", "\f", "\n", "\r", "\t", "\v", " "}:
            showMsg(error="Specified invalid character/s.", type="Chars")
            break



    def formatError(lst=[], index=0, delimiter=":") -> str:
        """Return a colored string positioned at a given index inside a list."""

        item = lst[index]
        string = delimiter.join(str(x) for x in lst)
        itemPos = (string.index(item), string.index(item) + len(item))
        return string[:itemPos[0]] + "\x1b[91m" + string[itemPos[0]:itemPos[1]] + "\x1b[0m" + string[itemPos[1]:]


    if args.pos:
        argPos = []
        for pos in args.pos.split(","):
            posSplitted = pos.split(":")
            if len(posSplitted) == 2:
                for posvalue in posSplitted:
                    valueIndex = posSplitted.index(posvalue)
                    if posvalue == "center": posvalue = int(windowSize[valueIndex]/2)
                    try:
                        posSplitted[valueIndex] = capValue(int(posvalue), windowSize[valueIndex], 2)
                    except ValueError:
                        showMsg(error=f"Value '{posvalue}' is not an intenger. ({formatError(posSplitted, valueIndex)})", type="Position")
                        break
            else: showMsg(error=f"Values X and Y are required (2), but {len(posSplitted)} value/s were supplied ('" + "', '".join(posSplitted) + "').", type="Position")
            argPos.append(posSplitted)

        if isValid: setattr(ArgValues, "pos", argPos)


    if args.color:
        argColor = []
        for rgb in args.color.split(","):
            rgbSplitted = rgb.split(":")
            if len(rgbSplitted) == 3:
                for rgbvalue in rgbSplitted:
                    valueIndex = rgbSplitted.index(rgbvalue)
                    try:
                        if int(rgbvalue) not in range(0,256):
                            showMsg(error=f"'{rgbvalue}' is not a value between '0' and '255'. ({formatError(rgbSplitted, valueIndex)})", type="Color")
                            break
                    except ValueError:
                        showMsg(error=f"Value '{rgbvalue}' is not an intenger. ({formatError(rgbSplitted, valueIndex)})", type="Color")
                        break
            else: showMsg(error=f"Values R, G and B are required (3), but {len(rgbSplitted)} value/s were supplied ('" + "', '".join(rgbSplitted) + "').", type="Color")
            argColor.append(rgbSplitted)

        if isValid: setattr(ArgValues, "color", argColor)




    def parseConditions():
        """Go through every condition, and populate the ArgValues class with the variable and values."""

        conditions = {"onBorderCollision", "onMove", "onLineCollision", "onPathFree"}
        condActions = {"duplicate", "destroy", "newColor", "clear", "clearAll", "longer", "shorter", "stop", "continue", "newLine", "newChar", "newPos"}

        for cond in conditions:
            usrOpts = getattr(args, cond)
            if usrOpts:
                usrOpts = usrOpts.split(",")
                options = []
                for opt in usrOpts:
                    if opt.strip() in condActions:
                        options.append(opt.strip())
                    else:
                        showMsg(error=f"'{opt}' is not a valid action. ({formatError(usrOpts, usrOpts.index(opt), ',')})", type=cond)
                        break

                if isValid: setattr(ArgValues, cond, options)

    parseConditions()

    if args.update:
        updateScript(argv[0])
        quit()

    return isValid








class Line(object):
    """Class for a line object."""

    def __init__(self, **kwargs):
        """Initialization of line object"""

        self._length = capValue(args.lenght, args.maxL) + 1                             # Length of the line.
        self._color = randomColor()                                                     # Color of the line in RGB.
        self._pos = [randrange(1, windowSize[0], 2), randrange(1, windowSize[1])]       # Position of the line.
        self._state = [randint(0, 1), randint(0, 1)]                                    # Bools for controlling when to add or substract to the current pos.
        self._posHistory = []                                                           # Position history of the line.
        self._char = choice(args.chars) * 2                                             # Character to display as the line body.
        self._doMove = True                                                             # Enable/Disable line movement.

        if ArgValues.pos: self._pos = choice(ArgValues.pos)

        if args.color: self._color = choice(ArgValues.color)

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
        """String returned when printing all the values required in debug mode"""

        return f"\x1b[H\x1b[0m\x1b[7mObjects: {len(lines)}\x1b[K\n\x1b[K\n\x1b[38;2;{self._color[0]};{self._color[1]};{self._color[2]}mPosHistory: {self._posHistory}\x1b[K\nLength: {self._length}\x1b[K\nColor: {self._color}\x1b[K\nChar: '{self._char}'\x1b[K\nPos: {self._pos}\x1b[K\nState: {self._state}\x1b[K\x1b[27m\n\x1b[K"


    def collide(self, axis: bool, state: bool):
        """Changes the state of the line, and runs the condition actions for border collisions"""

        self._state[axis] = state
        if args.debug and args.debug >= 2: self.logmsg(f"Border collision at {self._pos}")
        self.runOpts(ArgValues.onBorderCollision)


    def operate(self):
        """Add / Subtract to the current coordinates"""

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
        """All the stuff related to the movement of the line. This is hacky and ugly as hell and I feel kinda bad for it"""

        _nextPos = self.operate()

        # Line to line collision detection
        if args.onLineCollision:
            for obj in lines:
                if obj is self.__class__: continue
                if _nextPos in self._posHistory: continue
                if args.ignore:
                    if obj._color == self._color: continue
                if _nextPos in obj._posHistory:
                    if args.debug and args.debug >= 2: self.logmsg(f"Line collision at {self._pos}")
                    self.runOpts(ArgValues.onLineCollision)
                    break

                if not self._doMove: self.runOpts(ArgValues.onPathFree)


        if not self._doMove: return

        # Change the state of the position axles.
        self._pos = _nextPos
        if self._pos[0] <= 1:
            if args.noBorders:
                self._pos[0] = windowSize[0] - 1
            else:
                self.collide(0, 0)
        if self._pos[1] <= 1:
            if args.noBorders:
                self._pos[1] = windowSize[1] - 1
            else:
                self.collide(1, 0)

        if self._pos[0] == windowSize[0] or self._pos[0] == windowSize[0] + 1:
            if args.noBorders:
                self._pos[0] = 2
            else:
                self.collide(0, 1)
        elif self._pos[0] > windowSize[0]:
            self.collide(0, 1)
            self._pos[0] = windowSize[0]
            for pos in self._posHistory:
                self.clearSegment(pos, True)
            self._posHistory.clear()

        if self._pos[1] == windowSize[1]:
            if args.noBorders:
                self._pos[1] = 2
            else:
                self.collide(1, 1)
        elif self._pos[1] > windowSize[1]:
            self.collide(1, 1)
            self._pos[1] = windowSize[1]
            for pos in self._posHistory:
                self.clearSegment(pos, True)
            self._posHistory.clear()

        if self not in lines: return

        # Oh god, I know.
        if not self._pos[0] % 2: self._pos[0] += 1

        # We run the condition actions when moving it.
        self.runOpts(ArgValues.onMove)


        if args.lenght > 0:
            """
            Save the current position of the line into posHistory, which will contain an history of coordinates of the line.
            To remove the tail of the line progressively, we get the last value in the list, which is the position of the
            line -self._length- steps back.
            """
            self._posHistory.insert(0, list(self._pos))

            if len(self._posHistory) == self._length:
                self.clearSegment(self._posHistory[-1])
                self._posHistory.pop(-1)

        print(
            f"\x1b[{self._pos[1]};{self._pos[0]}f\x1b[38;2;{self._color[0]};{self._color[1]};{self._color[2]}m{self._char}\x1b[H",
            end="",
            flush=True
        )


    def clearSegment(self, pos: list, ignoreSelf=False):
        """Clear a segment of the line on the specified position. This will also detect if there's another line on that coordinate."""
        _brush = "  "

        if pos in self._posHistory[0:-2] and ignoreSelf == False:
            _brush = f"\x1b[38;2;{self._color[0]};{self._color[1]};{self._color[2]}m{self._char}"
            if args.debug and args.debug >= 2: self.logmsg(f"Replaced self body at {pos}")
        else:
            for obj in lines:
                if obj._posHistory is self._posHistory: continue
                if pos in obj._posHistory:
                    _brush = f"\x1b[38;2;{obj._color[0]};{obj._color[1]};{obj._color[2]}m{obj._char}"
                    if args.debug and args.debug >= 2: self.logmsg(f"Replaced \x1b[38;2;{obj._color[0]};{obj._color[1]};{obj._color[2]}m{obj._char}'s\x1b[0m body at {pos}")
                    break

        print(f"\x1b[{pos[1]};{pos[0]}f" + _brush, end="", flush=True)


    def runOpts(self, conditionList: tuple = None):
        """Run the selected actions listed on the supplied condition list."""

        if conditionList:
            if args.debug and args.debug >= 2: self.logmsg(f"Run action/s: " + ", ".join(conditionList) + ".")
            for opt in conditionList:
                # *I need you, Python 3.10*
                if opt == "duplicate" and len(lines) < args.maxN:
                    lines.append(Line(char=self._char, color=self._color))
                elif opt == "clear":
                    for pos in self._posHistory:
                        self.clearSegment(pos, True)
                    self._posHistory.clear()
                elif opt == "clearAll":
                    for obj in lines:
                        terminalOpt("clear")
                        obj._posHistory.clear()
                elif opt == "newColor":
                    if args.color:
                        self._color = choice(ArgValues.color)
                    else:
                        self._color = randomColor()
                elif opt == "newChar": self._char = choice(args.chars) * 2
                elif opt == "destroy":
                    if self in lines:
                        for pos in self._posHistory:
                            self.clearSegment(pos, True)
                        lines.remove(self)
                elif opt == "longer":
                    if self._length < args.maxL: self._length += 1
                elif opt == "shorter":
                    if self._length > 2:
                        self._length -= 1
                        if self._posHistory:
                            self.clearSegment(self._posHistory[-1])
                            self._posHistory.pop(-1)
                elif opt == "stop":
                    self._doMove = False
                elif opt == "continue":
                    self._doMove = True
                elif opt == "newLine":
                    lines.append(Line())
                elif opt == "newPos":
                    if args.pos:
                        self._pos = choice(ArgValues.pos)
                    else:
                        self._pos = [randrange(1, windowSize[0], 2), randrange(1, windowSize[1])]








def stopScript():
    """Close the script"""

    terminalOpt("clear", "oldbuffer", "reset", "showcursor")
    if args.debug and args.debug >= 2:
        logfile.write("Interrupted.\n")
        logfile.close()




def main():
    global prjVersion, windowSize, lines, logfile
    prjVersion = "2.4"

    runsys("")                      # Needed in Windows to display proper VT100 sequences... (Windows dumb)
    windowSize = getWindowSize()
    if not parseArgs(): quit()
    terminalOpt("newbuffer", "hidecursor", "clear")
    if args.debug and args.debug >= 2: logfile = open("./pt2.log", "w", buffering=1, encoding='utf-8')


    lines = []
    for x in range(0, capValue(args.number, args.maxN)):
        lines.append(Line())


    getSizeCounter = 1
    try:
        while True:
            if getSizeCounter >= args.urate:
                windowSize = getWindowSize()
                getSizeCounter = 1

            for obj in lines:
                obj.move()
                if args.debug: print(obj)

            sleep(args.speed)
            getSizeCounter += 1


    except KeyboardInterrupt:
        stopScript()

    except Exception as error:
        stopScript()
        showMsg(error=f"Unhandled exception while running the script:\n\t'{error}'", type="Runtime")




if __name__ == "__main__":
    main()