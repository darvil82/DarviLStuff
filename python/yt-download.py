import requests
import youtube_dl
import os
import eyed3
import re

from dataclasses import dataclass
from PIL import Image



THUMB_CROP_SIZE = 280


def print_center(text):
	print(text.center(os.get_terminal_size()[0], "—"))

@dataclass
class Options:
	no_crop: bool
	original_title: bool



def download_song(url: str, options: Options):
	with youtube_dl.YoutubeDL({
		"format": "bestaudio/best",
		"postprocessors": [{
			"key": "FFmpegExtractAudio",
			"preferredcodec": "mp3",
			"preferredquality": "192",
		}],
		"outtmpl": "./temp.%(ext)s",
	}) as ydl:
		song_data = get_song_data(url)

		artist, track = (
			song_data.get("artist", song_data["channel"]),
			song_data["title"] if options.original_title else clean_title(song_data["title"])
		)

		title = f"{artist} - {track}.mp3"

		print_center(f"{artist} - {track}")

		if os.path.isfile(f"./songs/{title.replace('/', '|')}"):
			print(f"Already exists!")
			return

		# download image
		with open("./temp.jpg", "wb") as f:
			f.write(requests.get(song_data["thumbnails"][-1]["url"]).content)

		if not options.no_crop:
			# crop image
			img = Image.open("./temp.jpg")
			img = img.crop((THUMB_CROP_SIZE, 0, img.width - THUMB_CROP_SIZE, img.height))
			img.save("./temp.jpg")

		ydl.download([url])

		# add metadata
		audio_file = eyed3.load("./temp.mp3")
		audio_file.initTag()
		audio_file.tag.images.set(3, open("./temp.jpg", "rb").read(), "image/jpeg")
		audio_file.tag.artist = artist
		audio_file.tag.album = song_data.get("album")
		audio_file.tag.title = track
		audio_file.tag.save()

		# move file
		os.rename("./temp.mp3", f"./songs/{title.replace('/', '|')}")


def get_options_from_strs(options: list[str]) -> Options:
	return Options(
		no_crop = "no-crop" in options,
		original_title = "original-title" in options
	)


def get_song_data(url: str) -> dict | bool:
	with youtube_dl.YoutubeDL({
		"format": "bestaudio/best",
		"outtmpl": "./temp.%(ext)s",
	}) as ydl:
		try:
			song_data = ydl.extract_info(url, False)
		except Exception:
			print("Error downloading song")
			return False

		return song_data


def clean_title(title: str) -> str:
	return re.sub(r"\([^)]*\)", "", title.split("-")[-1]).strip()


def parse_entries(entry_list: list[str]):
	for entry in entry_list:
		if entry.startswith("#"):
			continue

		url, *options = entry.split()
		download_song(url, get_options_from_strs(options))




def main():
	if not os.path.isfile("songlist.txt"):
		with open("songlist.txt", "w"):
			pass
		exit(0)

	os.makedirs("./songs", exist_ok=True)

	if os.path.isfile("./temp.webm.part"):
		os.remove("./temp.webm.part")

	with open("songlist.txt", "r") as f:
		songs = set(v for x in f.readlines() if (v := x.strip()) != "")
		if failed := parse_entries(songs):
			print("Failed:\n\t" + "\n\t".join(failed))

	if os.path.isfile("./temp.jpg"):
		os.remove("./temp.jpg")


if __name__ == "__main__":
	main()
