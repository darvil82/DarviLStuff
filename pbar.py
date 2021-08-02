#!/bin/python3


from multiprocessing.context import Process
from typing import Union
from os import get_terminal_size as _get_terminal_size
from time import sleep as _sleep



__all__ = ["pBar"]




_DEFAULT_CHARSETS: "dict[str, dict[str, Union[str, dict]]]" = {
	"empty": {
		"empty":	" ",
		"full":		" ",
		"vert":		" ",
		"horiz":	" ",
		"corner": {
			"tleft":	" ",
			"tright":	" ",
			"bleft":	" ",
			"bright":	" "
		}
	},

	"normal": {
		"empty":	"░",
		"full":		"█",
		"vert":		"│",
		"horiz":	"─",
		"corner": {
			"tleft":	"┌",
			"tright":	"┐",
			"bleft":	"└",
			"bright":	"┘"
		}
	},

	"basic": {
		"empty":	".",
		"full":		"#",
		"vert":		"│"
	},

	"slim": {
		"empty":	"░",
		"full":		"█"
	},

	"circles": {
		"empty":	"○",
		"full":		"●"
	}
}




_DEFAULT_COLORSETS: "dict[str, Union[list[int, int, int], dict]]" = {
	"default": {
		"empty":	None,
		"full":		None,
		"vert":		None,
		"horiz":	None,
		"corner":	{
			"tleft":	None,
			"tright":	None,
			"bleft":	None,
			"bright":	None
		}
	},

	"green-red": {
		"empty":	[255, 0, 0],
		"full":		[0, 255, 0]
	},
}









def _capValue(value, max=float('inf'), min=float('-inf')):
    """Clamp a value to a minimun and/or maximun value."""

    if value > max:
        return max
    elif value < min:
        return min
    else:
        return value











class VT100():
	"""Class for using VT100 sequences a bit easier"""

	def pos(pos: list, offset: list = [0, 0]):
		if pos and len(pos) == 2:
			position = list(pos)
			for index, value in enumerate(position):
				if isinstance(value, str):
					if value == "center":
						position[index] = int(_get_terminal_size()[index] / 2)
					else:
						return ""
				elif isinstance(value, int):
					pass
				else:
					raise TypeError("Invalid type for position value")

				if isinstance(position[index], int):
					position[index] += offset[index]

			return f"\x1b[{position[1]};{position[0]}f"
		else:
			return ""

	def color(RGB: list):
		if RGB and len(RGB) == 3:
			for value in RGB:
				if value not in range(0, 256): return ""
			return f"\x1b[38;2;{RGB[0]};{RGB[1]};{RGB[2]}m"
		else:
			return ""

	def moveHoriz(pos: int):
		if pos < 0:
			return f"\x1b[{abs(pos)}D"
		else:
			return f"\x1b[{pos}C"


	cursorStore = "\x1b7"
	cursorLoad = "\x1b8"
	reset = "\x1b[0m"
	invert = "\x1b[7m"
	revert = "\x1b[27m"








class pBar():
	"""hoho progress bar"""

	class options():
		"""### Available options:
			- `VERTICAL`:		Show the progress bar vertically.
			- `NO_PERCENT`:		Do not show the percentage.
			- `SHOW_RANGE`:		Show the range specified.
			- `NO_OVERRIDE`:	Do not override the bar when drawing again.
			- `TEXT_INSIDE`:	Show the specified text inside the bar.
		"""
		VERTICAL	= 0
		NO_PERCENT	= 1
		SHOW_RANGE	= 2
		NO_OVERRIDE	= 3
		TEXT_INSIDE	= 4


	def __init__(self,
			range: "list[int, int]" = [0, 1],
			text: str = None,
			length: int = 20,
			charset: Union[str, dict] = None,
			colorset: "Union[str, dict[str, list[int, int, int]]]" = None,
			position: "list[int, int]" = None,
			options: "list[int]" = []
		) -> None:
		self._range = range
		self._test = text
		self._length = _capValue(length, 255, 2)
		self._charset = self.getCharset(charset)
		self._colors = self.getColorset(colorset)
		self._pos = position
		self._options = options

		self._segments = self.getSegments(self._range, self._length)

		self.draw()




	def getCharset(self, charset):
		if charset:
			if isinstance(charset, str):
				charset = _DEFAULT_CHARSETS.get(charset, _DEFAULT_CHARSETS["normal"])
				set = {**_DEFAULT_CHARSETS["empty"], **charset}
			elif isinstance(charset, dict):
				if "corner" in charset.keys():
					if isinstance(charset["corner"], str):
						charset["corner"] = {
							"tleft": charset["corner"],
							"tright": charset["corner"],
							"bleft": charset["corner"],
							"bright": charset["corner"]
						}
					elif isinstance(charset["corner"], dict):
						charset["corner"] = {**_DEFAULT_CHARSETS["empty"]["corner"], **charset["corner"]}

				set = {**_DEFAULT_CHARSETS["empty"], **charset}
			else:
				raise ValueError(f"Invalid type ({type(charset)}) for charset")
		else:
			set = _DEFAULT_CHARSETS["normal"]

		return set




	def getColorset(self, colorset):
		if colorset:
			if isinstance(colorset, str):
				colorset = _DEFAULT_COLORSETS.get(colorset, _DEFAULT_COLORSETS["default"])
				set = {**_DEFAULT_COLORSETS["default"], **colorset}
			elif isinstance(colorset, dict):
				if "corner" in colorset.keys():
					if isinstance(colorset["corner"], list):
						colorset["corner"] = {
							"tleft": colorset["corner"],
							"tright": colorset["corner"],
							"bleft": colorset["corner"],
							"bright": colorset["corner"]
						}
					elif isinstance(colorset["corner"], dict):
						colorset["corner"] = {**_DEFAULT_COLORSETS["default"]["corner"], **colorset["corner"]}

				set = {**_DEFAULT_COLORSETS["default"], **colorset}
			else:
				raise ValueError(f"Invalid type ({type(colorset)}) for colorset")
		else:
			set = _DEFAULT_COLORSETS["default"]

		return set




	def getSegments(self, range: list, length: int):
		return int((_capValue(range[0], range[1], 0) / _capValue(range[1], min=1)) * length)



	def isOption(self, option: int):
		return option in self._options



	@property
	def percent(self):
		return int((self._range[0] * 100) / self._range[1])




	def draw(self):
		centerPos = int((self._length + 2) / -2)

		# cbt
		def buildTop():
			left = VT100.color(self._colors["corner"]["tleft"]) + self._charset["corner"]["tleft"] + VT100.reset
			middle = VT100.color(self._colors["horiz"]) + self._charset["horiz"] * (self._length + 2) + VT100.reset
			right = VT100.color(self._colors["corner"]["tright"]) + self._charset["corner"]["tright"] + VT100.reset

			return VT100.pos(self._pos, [centerPos, 0]) + left + middle + right


		def buildMid():
			segmentsFull = self._segments
			segmentsEmpty = self._length - segmentsFull

			vert = VT100.color(self._colors["vert"]) + self._charset["vert"] + VT100.reset
			middle = VT100.color(self._colors["full"]) + self._charset["full"] * segmentsFull + VT100.reset + VT100.color(self._colors["empty"]) + self._charset["empty"] * segmentsEmpty + VT100.reset

			percent = VT100.moveHoriz(centerPos - len(str(self.percent)))

			if self.percent < 50:
				percent += VT100.color(self._colors["empty"])
			else:
				percent += VT100.invert + VT100.color(self._colors["full"])

			percent += str(self.percent) + "%" + VT100.reset

			return VT100.pos(self._pos, [centerPos, 1]) + vert + " " + middle + " " + vert + percent


		def buildBottom():
			left = VT100.color(self._colors["corner"]["bleft"]) + self._charset["corner"]["bleft"] + VT100.reset
			middle = VT100.color(self._colors["horiz"]) + self._charset["horiz"] * (self._length + 2) + VT100.reset
			right = VT100.color(self._colors["corner"]["bright"]) + self._charset["corner"]["bright"] + VT100.reset

			return VT100.pos(self._pos, [centerPos, 2]) + left + middle + right



		print(VT100.cursorStore, end="")


		print(
			buildTop(),
			buildMid(),
			buildBottom(),

			sep="\n",
			end="\n"
		)






test = pBar(
	range=[1, 3],
	charset="normal",
	colorset="default",
	length=50
	)

