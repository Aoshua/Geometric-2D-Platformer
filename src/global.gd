extends Node

signal coins_changed

enum PlayerSkins { GREEN, BLUE, PINK }

const TOTAL_LEVELS = 7
# Path to the save file. For mobile and desktop, this saves to a user-specific directory.
const SAVE_PATH = "user://save_game.json"
# Used to set the window size and appropriately scale screenshots for iOS
const RES_IOS = Vector2i(2796, 1290)

# Save Data:
var unlocked_levels = 1
var coins = 0
var shields = 0
var current_skin = PlayerSkins.GREEN
var unlocked_skins = [PlayerSkins.GREEN]

# Only needed when taking screenshots
# Also be sure to enable Project Settings > Display > Window :
# Stretch, Mode=viewport Aspect=expand
#func _ready():
	#get_window().size = RES_IOS
	#get_window().move_to_center()


func save_game():
	var save_data = {
		"unlocked_levels": unlocked_levels,
		"coins": coins,
		"shields": shields,
		"current_skin": PlayerSkins.keys()[current_skin],
		"unlocked_skins": unlocked_skins.map(func(skin): return PlayerSkins.keys()[skin])
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
	current_skin = PlayerSkins[json.data.get("current_skin", "GREEN")]
	
	# Convert array of string keys back to array of enum values
	var skin_keys = json.data.get("unlocked_skins", ["GREEN"])
	unlocked_skins = []
	for key in skin_keys:
		unlocked_skins.append(PlayerSkins[key])
	
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
	save_game()


func add_shield():
	shields += 1
	save_game()


func use_shield():
	shields -= 1
	save_game()
	


func unlock_skin(skin: PlayerSkins):
	if (unlocked_skins.has(skin) == false):
		unlocked_skins.push_back(skin)
		current_skin = skin
		save_game()
		


func equip_skin(skin: PlayerSkins):
	current_skin = skin
	save_game()


func _input(event):
	if event.is_pressed() and event is InputEventKey:
		if event.physical_keycode == KEY_P: # The 'P' key
			var img = get_viewport().get_texture().get_image()
			
			var current_size = img.get_size()
			# Scale to target size
			if current_size != RES_IOS:
				img.resize(RES_IOS.x, RES_IOS.y)
			
			var file_path = "res://publishing/screenshots/screenshot_%d.png" % Time.get_ticks_msec()
			var err = img.save_png(file_path)
			if err == OK:
				print("Screenshot saved to: ", file_path)
			else:
				print("Failed to save screenshot")
