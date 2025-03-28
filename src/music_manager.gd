extends Node

var playlist = []
var current_song_index = 0
var audio_player: AudioStreamPlayer


func _ready():
	# Create our audio player
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
	# Connect to the finished signal to know when to play the next song
	audio_player.finished.connect(_on_song_finished)
	
	# Load all songs into the playlist
	_load_songs()
	
	# Randomize the starting song
	randomize()
	current_song_index = randi() % playlist.size()
	print("Current song: ", str(current_song_index))
	
	set_volume(0.25) # Set initial volume to 25%
	
	# Start playing
	play_current_song()


func _load_songs():
	# Load all songs into the playlist array
	# Make sure these paths match your project structure
	var song1 = load("res://assets/music/edm-loop.mp3")
	var song2 = load("res://assets/music/neon-gaming.mp3")
	var song3 = load("res://assets/music/pixelated-dreams.mp3")
	var song4 = load("res://assets/music/sunny-day.mp3")
	
	playlist = [song1, song2, song3, song4]


func play_current_song():
	if playlist.size() > 0:
		audio_player.stream = playlist[current_song_index]
		audio_player.play()


func _on_song_finished():
	# Move to the next song
	current_song_index = (current_song_index + 1) % playlist.size()
	play_current_song()


func stop_music():
	audio_player.stop()


func pause_music():
	audio_player.stream_paused = true


func resume_music():
	audio_player.stream_paused = false


## Accepts a float between 0.0 and 1.0
func set_volume(volume: float):
	# Clamp the volume between 0 and 1
	volume = clamp(volume, 0.0, 1.0)
	audio_player.volume_db = linear_to_db(volume)


## Returns a float between 0.0 and 1.0
func get_volume() -> float:
	# Convert from decibels back to linear volume
	return db_to_linear(audio_player.volume_db)
