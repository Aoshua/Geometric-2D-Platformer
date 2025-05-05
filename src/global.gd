extends Node

enum PlayerSkins { GREEN, BLUE, PINK}

var unlocked_levels = 1
var coins = 0
var shields = 0
var current_skin = PlayerSkins.GREEN
var unlocked_skins = [PlayerSkins.GREEN]

signal coins_changed

# Path to the save file. For mobile and desktop, this saves to a user-specific directory.
const SAVE_PATH = "user://save_game.json"

func save_game():
	var save_data = {
		"unlocked_levels": unlocked_levels,
		"coins": coins,
		"shields": shields,
		"current_skin": current_skin,
		"unlocked_skins": unlocked_skins
	}

	# Open the file for writing
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		print("Failed to save game.")
		return
	
	file.store_line(JSON.stringify(save_data))  # Save data as JSON.
	file.close()


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
	
	# Set saved values, setting a default if no value found
	unlocked_levels = json.data.get("unlocked_levels", 1)
	coins = json.data.get("coins", 0)
	shields = json.data.get("shields", 0)
	current_skin = json.data.get("current_skin", PlayerSkins.GREEN)
	unlocked_skins = json.data.get("unlocked_skins", [PlayerSkins.GREEN])
	print("Unlocked levels loaded: " + str(unlocked_levels))
	print("Coins loaded: " + str(coins))
	print("Shields loaded: " + str(shields))


func reset_progress():
	unlocked_levels = 1
	coins = 0  # Reset coins too if desired
	save_game()  # Save the reset values


# Call whenever the user unlocks a new level.
func unlock_level(current_level: int):
	if current_level == unlocked_levels:
		unlocked_levels += 1
		save_game()


func navigate_to_current_level():
	var level_path = "res://src/levels/level_" + str(unlocked_levels) + ".tscn" 
	get_tree().change_scene_to_file(level_path)


func add_coins(level_coins: int):
	coins += level_coins
	save_game()


func remove_coins(coins_to_remove: int):
	coins -= coins_to_remove
	save_game


func add_shield():
	shields += 1
	save_game()


func use_shield():
	shields -= 1
	save_game()
	

#func unlock_skin(skin: PlayerSkins):
	#
