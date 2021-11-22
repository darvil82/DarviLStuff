#!/bin/env python3


from os import path
from random import randint
import argparse





def parseArgs():
	global args

	argparser = argparse.ArgumentParser(description="Damages a file by writing random bytes at random positions to it.", epilog="Written by David Losantos")
	argparser.add_argument("file", help="File to open")
	argparser.add_argument("-p", "--passes", help="Quantity of bytes to modify. Default is 15", type=int, default=15)
	argparser.add_argument("-o", "--output", help="File to output the generated bytes to", default=None)
	argparser.add_argument("-s", "--string", help="Take the string specified for the filename as input", action="store_true")
	argparser.add_argument("-q", "--quiet", help="Do not output any text to stdout", action="store_true")

	args = argparser.parse_args()

	if not path.isfile(args.file) and not args.string:
		print(f"The file '{args.file}' does not exist.")
		quit()





def capValue(value, max=float('inf'), min=float('-inf')):
    """Clamp a value to a minimun and/or maximun value."""

    if value > max:
        return max
    elif value < min:
        return min
    else:
        return value






def main():
	byteArr: list = []
	positions: list = []


	if args.string:
		for char in args.file:
			byteArr.append(str.encode(char))
	else:
		with open(args.file, "rb") as f:
			# Iterate over every byte and append it to a bytelist
			byte = f.read(1)
			while byte:
				byteArr.append(byte)
				byte = f.read(1)


	# Generate unique positions for all passes
	maxPasses = capValue(args.passes, len(byteArr))
	for _ in range(maxPasses):
		rnd = randint(0, len(byteArr)) - 1

		while rnd in positions:
			rnd = randint(0, len(byteArr)) - 1

		positions.append(rnd)


	# Replace a random byte on the array with a random value on every pass
	for index in positions:
		rnd = bytes([randint(0, 255)])

		byteArr.pop(index)
		byteArr.insert(index, rnd)


	if not args.quiet:
		for byte in byteArr:
			print(str(byte.decode("utf-8", "replace")), end="")
		print()

	if args.output:
		with open(args.output, "wb") as out:
			for byte in byteArr:
				out.write(byte)







if __name__ == "__main__":
	try:
		parseArgs()
		main()
	except KeyboardInterrupt:
		quit()