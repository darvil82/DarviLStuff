#!/bin/python3

from collections.abc import Sequence
from typing import Any, NamedTuple, Optional, Set, SupportsInt, TypeVar, Union, cast
from os import get_terminal_size as _get_terminal_size



__all__ = ["PBar"]
__author__ = "David Losantos (DarviL)"
__version__ = "0.1"


CharSetEntry = Union[str, dict[str, str]]
CharSet = dict[str, Union[str, CharSetEntry]]

_DEFAULT_CHARSETS: dict[str, CharSet] = {
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
	},

	"basic2": {
		"empty":	".",
		"full":		"#",
		"vert":		"|",
		"horiz":	"-",
		"corner": {
			"tleft":	"+",
			"tright":	"+",
			"bleft":	"+",
			"bright":	"+"
		}
	},

	"full": {
		"empty":	"█",
		"full":		"█"
	},
}

Color = Optional[tuple[int, int, int]]
ColorSet = dict[str, Union[Color, dict[str, Color]]]

_DEFAULT_COLORSETS: dict[str, ColorSet] = {
	"empty": {
		"empty":	None,
		"full":		None,
		"vert":		None,
		"horiz":	None,
		"corner": {
			"tleft":	None,
			"tright":	None,
			"bleft":	None,
			"bright":	None,
		},
		"text":	{
			"inside":	None,
			"outside":	None,
		}
	},

	"green-red": {
		"empty":	(255, 0, 0),
		"full":		(0, 255, 0)
	},

	"darvil": {
		"empty":	(0, 103, 194),
		"full":		(15, 219, 162),
		"vert":		(247, 111, 152),
		"horiz":	(247, 111, 152),
		"corner":	{
			"tleft":	(247, 111, 152),
			"tright":	(247, 111, 152),
			"bleft":	(247, 111, 152),
			"bright":	(247, 111, 152)
		},
		"text": {
			"outside":	(247, 111, 152),
			"inside":	None
		}
	}
}


FormatSet = dict[str, str]

_DEFAULT_FORMATTING: dict[str, FormatSet] = {
	"empty": {
		"inside":	"",
		"outside":	""
	},

	"default": {
		"inside":	"<percentage>",
		"outside":	"<text>"
	},

	"all-out": {
		"outside":	"<percentage>, <range>, <text>"
	},

	"all-in": {
		"inside":	"<percentage>, <range>, <text>"
	}
}




Num = TypeVar("Num", int, float)

def _capValue(value: Num, max: Optional[Num]=None, min: Optional[Num]=None) -> Num:
    """Clamp a value to a minimun and/or maximun value."""

    if max and value > max:
        return max
    elif min and value < min:
        return min
    else:
        return value








class VT100():
	"""Class for using VT100 sequences a bit easier"""

	@staticmethod
	def pos(pos: Optional[Sequence[Any]], offset: tuple[int, int] = (0, 0)):
		if pos and len(pos) == 2:
			position = list(pos)
			for index, value in enumerate(position):
				if isinstance(value, str):
					if value == "center":
						position[index] = int(_get_terminal_size()[index] / 2)
					else:
						return ""
				elif isinstance(value, int):
					value = int(value)
				else:
					raise TypeError("Invalid type for position value")

				if isinstance(position[index], int):
					position[index] += offset[index]

			return f"\x1b[{position[1]};{position[0]}f"
		else:
			return ""

	@staticmethod
	def color(RGB: Optional[Sequence[int]]):
		if RGB and len(RGB) == 3:
			for value in RGB:
				if value not in range(0, 256): return ""
			return f"\x1b[38;2;{RGB[0]};{RGB[1]};{RGB[2]}m"
		else:
			return ""

	@staticmethod
	def moveHoriz(pos: SupportsInt):
		pos = int(pos)
		if pos < 0:
			return f"\x1b[{abs(pos)}D"
		else:
			return f"\x1b[{pos}C"

	@staticmethod
	def moveVert(pos: SupportsInt):
		pos = int(pos)
		if pos < 0:
			return f"\x1b[{abs(pos)}A"
		else:
			return f"\x1b[{pos}B"


	reset = "\x1b[0m"
	invert = "\x1b[7m"
	revert = "\x1b[27m"
	clearLine = "\x1b[2K"








class PBar():
	"""
	# pBar - Progress bar

	pBar is an object for managing progress bars in python.

	---

	## Initialization

	>>> mybar = pBar()

	- A progress bar will be initialized with all the default values. For customization, use the arguments or the properties available.

	---

	## Methods

	- mybar.draw()
	- mybar.step()

	---

	## Properties

	- mybar.percentage
	- mybar.text
	- mybar.range
	- mybar.charset
	- mybar.colorset
	- mybar.format
	"""

	def __init__(self,
			range: tuple[int, int] = (0, 1),
			text: str = "",
			length: int = 20,
			charset: Union[None, str, dict[str, str]] = None,
			colorset: Union[None, str, dict[str, tuple[int, int, int]]] = None,
			position: Optional[tuple[int, int]] = None,
			format: Union[None, str, dict[str, str]] = None
		) -> None:
		"""
		>>> range: list[int, int]:

		- This list will specify the range of two values to display in the progress bar.
		---

		>>> text: str:

		- String to show in the progress bar.
		---

		>>> length: int:

		- Intenger that specifies how long the bar will be.
		---

		>>> charset: Union[str, dict[str, str]]:

		- Set of characters to use when drawing the progress bar. This value can either be a
		string which will specify a default character set to use, or a dictionary, which should specify the custom characters:
			- Available default character sets: `empty`, `normal`, `basic`, `basic2`, `slim` and `circles`.
			- Custom character set dictionary:

				![image](https://user-images.githubusercontent.com/48654552/127887419-acee1b4f-de1b-4cc7-a1a6-1be75c7f97c9.png)

			Note: It is not needed to specify all the keys and values.

		---

		>>> colorset: Union[str, dict[str, list[int, int, int]]]:

		- Set of colors to use when drawing the progress bar. This value can either be a
		string which will specify a default character set to use, or a dictionary, which should specify the custom characters:
			- Available default color sets: `empty`, `green-red` and `darvil`.
			- Custom color set dictionary:

				![image](https://user-images.githubusercontent.com/48654552/127904550-15001058-cbf2-4ebf-a543-8d6566e9ef36.png)

			Note: It is not needed to specify all the keys and values.

		---

		>>> position: list[int, int]:

		- List containing the position (X and Y axles) of the progress bar on the terminal.
		If a value is `center`, the bar will be positioned at the center of the terminal on that axis.
		---

		>>> format: Union[str, dict[str, str]]:

		- Formatting used when displaying the values inside and outside the bar. This value can either be a
		string which will specify a default formatting set to use, or a dictionary, which should specify the custom formats:
			- Available default formatting sets: `empty`, `default`, `all-out` and `all-in`.
			- Custom color set dictionary:

				![image](https://user-images.githubusercontent.com/48654552/127889950-9b31d7eb-9a52-442b-be7f-8b9df23b15ae.png)

			Note: It is not needed to specify all the keys and values.

		- Available formatting keys: `<percentage>`, `<range>` and `<text>`.
		"""

		self._range = list(range)
		self._text = str(text)
		self._length = _capValue(length, 255, 5)
		self._charset = self._getCharset(charset)
		self._colorset = self._getColorset(colorset)
		self._pos = position
		self._format = self._getFormat(format)

		self._drawtimes = 0
		# self._draw()




	# --------- Properties / Methods the user should use. ----------

	def draw(self):
		"""Print the progress bar on screen"""
		self._draw()


	def step(self, steps: int = 1, overwrite: bool = True):
		"""Add `steps` to the first value in range, then draw the bar.
		Overwrites the already drawn bar by default"""
		self._range[0] += _capValue(steps, self._range[1] - self._range[0])
		self._draw(overwrite)


	@property
	def percentage(self):
		"""Percentage of the progress of the current range"""
		return int((self._range[0] * 100) / self._range[1])


	@property
	def text(self):
		"""Text to be displayed on the bar"""
		return self._text
	@text.setter
	def text(self, text: str):
		self._text = str(text)


	@property
	def range(self) -> tuple[int, int]:
		"""Range for the bar progress"""
		return self._range[0], self._range[1]
	@range.setter
	def range(self, range: tuple[int, int]):
		self._range = list(range)


	@property
	def charset(self) -> CharSet:
		"""Set of characters for the bar"""
		return self._charset
	@charset.setter
	def charset(self, charset: Any):
		self._charset = self._getCharset(charset)


	@property
	def colorset(self) -> ColorSet:
		"""Set of colors for the bar"""
		return self._colorset
	@colorset.setter
	def colorset(self, colorset: Any):
		self._colorset = self._getColorset(colorset)


	@property
	def format(self):
		"""Formatting used for the bar"""
		return self._format
	@format.setter
	def format(self, format: Any):
		self._format = self._getFormat(format)


	@property
	def length(self):
		"""Length of the progress bar"""
		return self._length
	@length.setter
	def length(self, length: int):
		self._length = _capValue(length, 255, 5)

	# --------- ///////////////////////////////////////// ----------



	def _getCharset(self, charset: Any) -> CharSet:
		if charset:
			if isinstance(charset, str):
				charset = _DEFAULT_CHARSETS.get(charset, _DEFAULT_CHARSETS["normal"])
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
						charset["corner"] |= cast(dict[str, str], _DEFAULT_CHARSETS["empty"]["corner"])
			else:
				raise ValueError(f"Invalid type ({type(charset)}) for charset")

			set: CharSet = {**_DEFAULT_CHARSETS["empty"], **charset}
		else:
			set = _DEFAULT_CHARSETS["normal"]

		return set




	def _getColorset(self, colorset: Any) -> ColorSet:
		if colorset:
			if isinstance(colorset, str):
				colorset = _DEFAULT_COLORSETS.get(colorset, _DEFAULT_COLORSETS["empty"])
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
						colorset["corner"] |= cast(dict[str, Color], _DEFAULT_COLORSETS["empty"]["corner"])
				if "text" in colorset.keys():
					if isinstance(colorset["text"], list):
						colorset["text"] = {
							"inside": colorset["text"],
							"outside": colorset["text"]
						}
					elif isinstance(colorset["text"], dict):
						colorset["text"] |= cast(dict[str, Color], _DEFAULT_COLORSETS["empty"]["text"])
			else:
				raise ValueError(f"Invalid type ({type(colorset)}) for colorset")

			set: ColorSet = {**_DEFAULT_COLORSETS["empty"], **colorset}
		else:
			set = _DEFAULT_COLORSETS["empty"]

		return set




	def _getFormat(self, formatset: Any) -> FormatSet:
		if formatset:
			if isinstance(formatset, str):
				formatset = _DEFAULT_FORMATTING.get(formatset, _DEFAULT_FORMATTING["empty"])

			set = {**_DEFAULT_FORMATTING["empty"], **formatset}
		else:
			set = _DEFAULT_FORMATTING["default"]

		return set




	def _getSegments(self, range: tuple[int, int], length: int):
		return int((_capValue(range[0], range[1], 0) / _capValue(range[1], min=1)) * length)








	def _draw(self, redraw: bool = False):
		centerOffset = int((self._length + 2) / -2)
		self._segments = self._getSegments(self.range, self._length)


		def parseFormat(type: str):
			string = self._format[type]
			foundOpen = False
			tempStr = ""
			endStr = ""

			for char in string:
				if foundOpen:
					if char == ">":
						if tempStr == "percentage":
							endStr += f"{str(self.percentage)}%"
						elif tempStr == "range":
							endStr += f"{self._range[0]}/{self._range[1]}"
						elif tempStr == "text":
							if self._text:
								endStr += self._text

						foundOpen = False
						tempStr = ""
					else:
						tempStr += char
				elif char == "<":
					foundOpen = True
				else:
					endStr += char

			return endStr



		# Build all the parts of the progress bar
		def buildTop() -> str:
			left = VT100.color(self._colorset["corner"]["tleft"]) + self._charset["corner"]["tleft"] + VT100.reset
			middle = VT100.color(self._colorset["horiz"]) + self._charset["horiz"] * (self._length + 2) + VT100.reset
			right = VT100.color(self._colorset["corner"]["tright"]) + self._charset["corner"]["tright"] + VT100.reset

			return VT100.clearLine + VT100.pos(self._pos, [centerOffset, 0]) + left + middle + right



		def buildMid() -> str:
			segmentsFull = self._segments
			segmentsEmpty = self._length - segmentsFull

			vert = VT100.color(self._colorset["vert"]) + self._charset["vert"] + VT100.reset
			middle = VT100.color(self._colorset["full"]) + self._charset["full"] * segmentsFull + VT100.reset + VT100.color(self._colorset["empty"]) + self._charset["empty"] * segmentsEmpty + VT100.reset

			# ---------- Build the content outside the bar ----------
			extra = parseFormat("outside")
			extraFormatted = VT100.color(self._colorset["text"]["outside"]) + extra + VT100.reset


			# ---------- Build the content inside the bar ----------
			info = parseFormat("inside")
			infoFormatted = VT100.color(self._colorset["text"]["inside"])

			if self.percentage < 50:
				if self._charset["empty"] == "█":
					infoFormatted += VT100.invert
				infoFormatted += VT100.color(self._colorset["empty"])
			else:
				if self._charset["full"] == "█":
					infoFormatted += VT100.invert
				infoFormatted += VT100.color(self._colorset["full"])

			infoFormatted += parseFormat("inside") + VT100.reset
			# ---------- //////////////////////////////// ----------


			return (
				VT100.clearLine + VT100.pos(self._pos, [centerOffset, 1]) + vert + " " + middle + " " + vert + " " + extraFormatted +
				VT100.moveHoriz(centerOffset - len(info) / 2 - 2 - len(extra)) + infoFormatted
			)


		def buildBottom() -> str:
			left = VT100.color(self._colorset["corner"]["bleft"]) + self._charset["corner"]["bleft"] + VT100.reset
			middle = VT100.color(self._colorset["horiz"]) + self._charset["horiz"] * (self._length + 2) + VT100.reset
			right = VT100.color(self._colorset["corner"]["bright"]) + self._charset["corner"]["bright"] + VT100.reset

			return VT100.clearLine + VT100.pos(self._pos, [centerOffset, 2]) + left + middle + right


		if redraw and self._drawtimes > 0: print(VT100.moveVert(-3), end="")

		# Draw the bar
		print(
			buildTop(),
			buildMid(),
			buildBottom(),

			sep="\n",
			end="\n"
		)

		self._drawtimes += 1























if __name__ == "__main__":
	from time import sleep

	mibarra = PBar(
		range=(0, 50),
		text="Querido Hijo",
		charset="slim",
		format="all-out",
		length=50
	)

	mibarra.draw()

	while mibarra.percentage < 100:
		sleep(0.1)
		mibarra.step(1)