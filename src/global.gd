extends Node

var unlocked_levels = 1
#var ad_id_revive = "ca-app-pub-3572547557671280/9835166645" # Production ID
var ad_id_revive = "ca-app-pub-3940256099942544/1712485313" # Test ID

# Path to the save file. For mobile and desktop, this saves to a user-specific directory.
const SAVE_PATH = "user://save_game.json"

# Call this to save the unlocked levels.
func save_game():
	var save_data = {
		"unlocked_levels": unlocked_levels
	}

	# Open the file for writing
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		print("Failed to save game.")
		return
	
	file.store_line(JSON.stringify(save_data))  # Save data as JSON.
	file.close()

# Call this to load the unlocked levels when the game starts.
func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found.")
		return
	
	# Open the file for reading
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		print("Failed to load game.")
		return
	
	var json = JSON.new()
	var parse_result = json.parse(file.get_line())
	file.close()

	if not parse_result == OK:
		print("Failed to parse save file.")
		return
	
	# Set unlocked levels, defaulting to level 1 if not found
	var thing = json.data["unlocked_levels"] 
	unlocked_levels = thing

# Call whenever the user unlocks a new level.
func unlock_level():
	unlocked_levels += 1
	save_game()

func navigate_to_current_level():
	var level_path = "res://src/levels/level_" + str(unlocked_levels) + ".tscn" 
	get_tree().change_scene_to_file(level_path)
