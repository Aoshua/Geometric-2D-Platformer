extends CanvasLayer

var rewarded_ad : RewardedAd
var rewarded_ad_load_callback := RewardedAdLoadCallback.new()
var on_user_earned_reward_listener := OnUserEarnedRewardListener.new()
var full_screen_content_callback := FullScreenContentCallback.new()
var loading_overlay: CanvasLayer

var player_ref = null

func _on_reset_button_pressed():
	get_tree().reload_current_scene()
	queue_free()


func _on_revive_button_pressed():
	print("Revive button pressed")
	show_loading_overlay()
	# Load the ad when the revive button is pressed
	var unit_id : String
	if OS.get_name() == "Android":
		unit_id = "ca-app-pub-3940256099942544/5224354917"
	elif OS.get_name() == "iOS":
		unit_id = "ca-app-pub-3940256099942544/1712485313"

	# Set up the ad loader and callbacks
	var ad_loader = RewardedAdLoader.new()
	ad_loader.load(unit_id, AdRequest.new(), rewarded_ad_load_callback)

	# Define the callbacks for ad loading
	rewarded_ad_load_callback.on_ad_failed_to_load = on_rewarded_ad_failed_to_load
	rewarded_ad_load_callback.on_ad_loaded = on_rewarded_ad_loaded


func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://src/ui/menus/main_menu.tscn")
	queue_free()

func on_rewarded_ad_failed_to_load(adError : LoadAdError) -> void:
	print(adError.message)
	hide_loading_overlay()

func on_rewarded_ad_loaded(loaded_ad : RewardedAd) -> void:
	self.rewarded_ad = loaded_ad

	# Assign the FullScreenContentCallback here
	rewarded_ad.full_screen_content_callback = full_screen_content_callback

	# Set up the full screen content callback
	full_screen_content_callback.on_ad_dismissed_full_screen_content = revive_player

	# Show the ad once it's loaded
	if rewarded_ad:
		hide_loading_overlay()
		rewarded_ad.show(on_user_earned_reward_listener)


func set_player(player):
	player_ref = player


func revive_player():
	print("Reviving player...")
	if player_ref and player_ref.has_method("revive"):
		player_ref.revive()
		queue_free() # Remove game over screen
	else: # Fallback if no player reference (shouldn't happen, but just in case)
		print("ERROR: No player reference to revive!")
		get_tree().reload_current_scene()


func show_loading_overlay():
	if loading_overlay == null:
		var loading_scene = load("res://src/ui/loading_overlay.tscn")
		loading_overlay = loading_scene.instantiate()
		add_child(loading_overlay)


func hide_loading_overlay():
	if loading_overlay:
		loading_overlay.queue_free()
		loading_overlay = null
