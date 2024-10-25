extends CanvasLayer


var admob = null
var rewarded_ad = null


func _on_reset_button_pressed():
	get_tree().reload_current_scene()
	queue_free()


func _on_revive_button_pressed():
	print("revive pressed")
	if admob and rewarded_ad:
		admob.show_rewarded_ad()


func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://src/ui/menus/main_menu.tscn")
	queue_free()


#region Ad Signals
func _on_rewarded_ad_loaded():
	print("Rewarded ad loaded")
	rewarded_ad = true


func _on_rewarded_ad_failed_to_load(error_code):
	print("Rewarded ad failed to load: ", error_code)
	rewarded_ad = false


func _on_rewarded_ad_failed_to_show(error_code):
	print("Rewarded ad failed to show: ", error_code)


func _on_rewarded_ad_closed():
	print("Rewarded ad closed")
	# Reload the ad for next time
	admob.load_rewarded_ad(Global.ad_id_revive)


func _on_rewarded_ad_opened():
	print("Rewarded ad opened")

func _on_reward_earned(currency, amount):
	print("Reward earned: ", currency, " ", amount)
	revive_player()
#endregion

func _ready():
	print("game_over > ready")
	if Engine.has_singleton("AdMob"):
		print("AdMob found")
		admob = Engine.get_singleton("AdMob")
		admob.initialize()
		admob.rewarded_ad_loaded.connect(_on_rewarded_ad_loaded)
		admob.rewarded_ad_failed_to_load.connect(_on_rewarded_ad_failed_to_load)
		admob.rewarded_ad_failed_to_show.connect(_on_rewarded_ad_failed_to_show)
		admob.rewarded_ad_closed.connect(_on_rewarded_ad_closed)
		admob.rewarded_ad_opened.connect(_on_rewarded_ad_opened)
		admob.rewarded_ad_recording_earned_reward.connect(_on_reward_earned)
		admob.load_rewarded_ad(Global.ad_id_revive)


func revive_player():
	return # todo
