extends CanvasLayer

var rewarded_ad : RewardedAd
var rewarded_ad_load_callback := RewardedAdLoadCallback.new()
var on_user_earned_reward_listener := OnUserEarnedRewardListener.new()
var full_screen_content_callback := FullScreenContentCallback.new()

func _on_reset_button_pressed():
	get_tree().reload_current_scene()
	queue_free()

func _on_revive_button_pressed():
	print("Revive button pressed")
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
	on_user_earned_reward_listener.on_user_earned_reward = on_user_earned_reward

func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://src/ui/menus/main_menu.tscn")
	queue_free()

func on_rewarded_ad_failed_to_load(adError : LoadAdError) -> void:
	print(adError.message)

func on_rewarded_ad_loaded(loaded_ad : RewardedAd) -> void:
	self.rewarded_ad = loaded_ad

	# Assign the FullScreenContentCallback here
	rewarded_ad.full_screen_content_callback = full_screen_content_callback

	# Set up the full screen content callback
	full_screen_content_callback.on_ad_dismissed_full_screen_content = func() -> void:
		print("Ad dismissed, cleaning up")
		revive_player()  # Revive the player here when ad is dismissed

	# Show the ad once it's loaded
	if rewarded_ad:
		rewarded_ad.show(on_user_earned_reward_listener)

func on_user_earned_reward(rewarded_item : RewardedItem) -> void:
	# This function is called once the ad is successfully watched
	print("User earned reward...")

func revive_player():
	print("Reviving player...")
	# Your revival logic here
