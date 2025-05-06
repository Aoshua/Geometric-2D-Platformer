extends Node


## Pool of AudioStreamPlayer nodes for sound effects
var _sound_players: Array[AudioStreamPlayer] = []
## Maximum number of simultaneous sounds that can be played
@export var max_sound_players: int = 16
## Dictionary to cache loaded audio resources to avoid reloading
var _audio_cache: Dictionary = {}


## Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Create the pool of AudioStreamPlayers
	for i in range(max_sound_players):
		var player = AudioStreamPlayer.new()
		add_child(player)
		_sound_players.append(player)
		# Connect to finished signal to know when this player is available again
		player.finished.connect(_on_sound_finished.bind(player))


## Play a sound effect with the given volume
## Returns the AudioStreamPlayer if successful, null otherwise
func play_sound(file_name: String, volume_db: float = 0.0) -> AudioStreamPlayer:
	var sound_path = "res://assets/sound-effects/" + file_name + ".mp3"
	# Try to get an available player from the pool
	var player = _get_available_player()
	if player == null:
		push_warning("SoundManager: No available AudioStreamPlayer, too many sounds playing")
		return null
	
	# Try to load or get the audio stream from cache
	var stream = _load_stream(sound_path)
	if stream == null:
		push_error("SoundManager: Failed to load audio from: " + sound_path)
		return null
	
	# Set up the player
	player.stream = stream
	player.volume_db = volume_db
	player.play()
	
	return player


## Stops all currently playing sounds
func stop_all_sounds() -> void:
	for player in _sound_players:
		player.stop()


## Preloads a sound into the cache for faster access later
func preload_sound(sound_path: String) -> void:
	if not _audio_cache.has(sound_path):
		var stream = load(sound_path)
		if stream is AudioStream:
			_audio_cache[sound_path] = stream
		else:
			push_error("SoundManager: Failed to preload audio from: " + sound_path)


## Find an available player from the pool
func _get_available_player() -> AudioStreamPlayer:
	for player in _sound_players:
		if not player.playing:
			return player
	return null


## Load an audio stream from the cache or from disk
func _load_stream(sound_path: String) -> AudioStream:
	if _audio_cache.has(sound_path):
		return _audio_cache[sound_path]
		
	var stream = load(sound_path)
	if stream is AudioStream:
		_audio_cache[sound_path] = stream
		return stream
	
	return null


## Signal callback when a sound finishes playing
func _on_sound_finished(player: AudioStreamPlayer) -> void:
	# This function is called when a sound finishes
	# Add custom logic here if needed
	pass
