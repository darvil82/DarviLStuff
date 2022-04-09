import requests
import youtube_dl
import os
import eyed3

from PIL import Image



THUMB_CROP_SIZE = 280


def print_center(text):
	print(text.center(os.get_terminal_size()[0], "—"))

if not os.path.isfile("songlist.txt"):
	with open("songlist.txt", "w"):
		pass
	exit(0)

os.makedirs("./songs", exist_ok=True)

if os.path.isfile("./temp.webm.part"):
	os.remove("./temp.webm.part")



with open("songlist.txt", "r") as f:
	songs = set(v for x in f.readlines() if (v := x.strip()) != "")


failed_songs = []


with youtube_dl.YoutubeDL({
	"format": "bestaudio/best",
	"postprocessors": [{
		"key": "FFmpegExtractAudio",
		"preferredcodec": "mp3",
		"preferredquality": "192",
	}],
	"outtmpl": "./temp.%(ext)s",
}) as ydl:
	for song in songs:
		try:
			song_data = ydl.extract_info(song, False)
		except Exception:
			failed_songs.append(song)
			continue

		artist, track = song_data["artist"], song_data["title"]
		title = f"{artist} - {track}.mp3"

		print_center(f"{artist} - {track}")

		if os.path.isfile(f"./songs/{title}"):
			print(f"Already exists! Skipping...")
			continue

		# download image
		with open("./temp.jpg", "wb") as f:
			f.write(requests.get(song_data["thumbnails"][-1]["url"]).content)

		# crop image
		img = Image.open("./temp.jpg")
		img = img.crop((THUMB_CROP_SIZE, 0, img.width - THUMB_CROP_SIZE, img.height))
		img.save("./temp.jpg")

		ydl.download([song])

		# add metadata
		audio_file = eyed3.load("./temp.mp3")
		audio_file.initTag()
		audio_file.tag.images.set(3, open("./temp.jpg", "rb").read(), "image/jpeg")
		audio_file.tag.artist = artist
		audio_file.tag.album = song_data["album"]
		audio_file.tag.title = track
		audio_file.tag.save()

		# move file
		os.rename("./temp.mp3", f"./songs/{title}")


os.remove("./temp.jpg")



if failed_songs:
	print("Failed:" + "\n\t".join(failed_songs))