#!/bin/python3


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
	"empty": {
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





_DEFAULT_FORMATTING: "dict[str, list[int]]" = {
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
	}
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
					value = int(value)
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
		pos = int(pos)
		if pos < 0:
			return f"\x1b[{abs(pos)}D"
		else:
			return f"\x1b[{pos}C"

	def moveVert(pos: int):
		pos = int(pos)
		if pos < 0:
			return f"\x1b[{abs(pos)}A"
		else:
			return f"\x1b[{pos}B"


	reset = "\x1b[0m"
	invert = "\x1b[7m"
	revert = "\x1b[27m"
	clearRight = "\x1b[K"








class pBar():
	"""hoho progress bar"""

	def __init__(self,
			range: "list[int, int]" = [0, 1],
			text: str = None,
			length: int = 20,
			charset: Union[str, dict] = None,
			colorset: "Union[str, dict[str, list[int, int, int]]]" = None,
			position: "list[int, int]" = None,
			format: "dict[list[int]]" = None
		) -> None:
		self._range = range
		self._text = text
		self._length = _capValue(length, 255, 5)
		self._charset = self._getCharset(charset)
		self._colors = self._getColorset(colorset)
		self._pos = position
		self._format = self._getFormat(format)





	# --------- Properties / Methods the user should use. ----------

	def draw(self):
		self._draw()


	def step(self, steps: int = 1):
		self._range[0] += _capValue(steps)
		self._draw(True)


	@property
	def percentage(self):
		return int((self._range[0] * 100) / self._range[1])


	@property
	def text(self):
		return self._text

	@text.setter
	def text(self, text: str):
		self._text = str(text)


	@property
	def range(self):
		return self._range

	@range.setter
	def range(self, range: list):
		self._range = range


	@property
	def charset(self):
		return self._charset

	@charset.setter
	def charset(self, charset):
		self._charset = self._getCharset(charset)


	@property
	def colors(self):
		return self._colors

	@colors.setter
	def colors(self, colors):
		self._colors = self._getCharset(colors)


	@property
	def format(self):
		return self._format

	@format.setter
	def format(self, format):
		self._format = self._getFormat(format)

	# --------- ///////////////////////////////////////// ----------




	def _getCharset(self, charset):
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
						charset["corner"] = {**_DEFAULT_CHARSETS["empty"]["corner"], **charset["corner"]}
			else:
				raise ValueError(f"Invalid type ({type(charset)}) for charset")

			set = {**_DEFAULT_CHARSETS["empty"], **charset}
		else:
			set = _DEFAULT_CHARSETS["normal"]

		return set




	def _getColorset(self, colorset):
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
						colorset["corner"] = {**_DEFAULT_COLORSETS["empty"]["corner"], **colorset["corner"]}
			else:
				raise ValueError(f"Invalid type ({type(colorset)}) for colorset")

			set = {**_DEFAULT_COLORSETS["empty"], **colorset}
		else:
			set = _DEFAULT_COLORSETS["empty"]

		return set




	def _getFormat(self, formatset):
		if formatset:
			if isinstance(formatset, str):
				formatset = _DEFAULT_FORMATTING.get(formatset, _DEFAULT_FORMATTING["empty"])

			set = {**_DEFAULT_FORMATTING["empty"], **formatset}
		else:
			set = _DEFAULT_FORMATTING["default"]

		return set




	def _getSegments(self, range: list, length: int):
		return int((_capValue(range[0], range[1], 0) / _capValue(range[1], min=1)) * length)









	def _draw(self, redraw: bool = False):
		centerOffset = int((self._length + 2) / -2)
		self._segments = self._getSegments(self._range, self._length)


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
		def buildTop():
			left = VT100.color(self._colors["corner"]["tleft"]) + self._charset["corner"]["tleft"] + VT100.reset
			middle = VT100.color(self._colors["horiz"]) + self._charset["horiz"] * (self._length + 2) + VT100.reset
			right = VT100.color(self._colors["corner"]["tright"]) + self._charset["corner"]["tright"] + VT100.reset

			return VT100.pos(self._pos, [centerOffset, 0]) + left + middle + right



		def buildMid():
			segmentsFull = self._segments
			segmentsEmpty = self._length - segmentsFull

			vert = VT100.color(self._colors["vert"]) + self._charset["vert"] + VT100.reset
			middle = VT100.color(self._colors["full"]) + self._charset["full"] * segmentsFull + VT100.reset + VT100.color(self._colors["empty"]) + self._charset["empty"] * segmentsEmpty + VT100.reset

			# ---------- Build the content outside the bar ----------
			extra = parseFormat("outside")


			# ---------- Build the content inside the bar ----------
			info = parseFormat("inside")

			if self.percentage < 50:
				infoFormatted = VT100.color(self._colors["empty"])
			else:
				infoFormatted = VT100.invert + VT100.color(self._colors["full"])

			infoFormatted += parseFormat("inside") + VT100.reset
			# ---------- //////////////////////////////// ----------


			return (
				VT100.pos(self._pos, [centerOffset, 1]) + vert + " " + middle + " " +vert + " " + extra +
				VT100.clearRight + VT100.moveHoriz(centerOffset - len(info) / 2 - 2 - len(extra)) + infoFormatted
			)


		def buildBottom():
			left = VT100.color(self._colors["corner"]["bleft"]) + self._charset["corner"]["bleft"] + VT100.reset
			middle = VT100.color(self._colors["horiz"]) + self._charset["horiz"] * (self._length + 2) + VT100.reset
			right = VT100.color(self._colors["corner"]["bright"]) + self._charset["corner"]["bright"] + VT100.reset

			return VT100.pos(self._pos, [centerOffset, 2]) + left + middle + right


		if redraw: print(VT100.moveVert(-3), end="")


		print(
			buildTop(),
			buildMid(),
			buildBottom(),

			sep="\n",
			end="\n"
		)