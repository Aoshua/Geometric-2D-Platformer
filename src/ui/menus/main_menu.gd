extends CanvasLayer

func _ready():
	Global.load_game()
	create_jump_animation()
	var anim_player = $ContentContainer/AnimationSpace/PlayerSprite/AnimationPlayer
	anim_player.play("triple_jump_spin")


func create_jump_animation():
	var anim_player = $ContentContainer/AnimationSpace/PlayerSprite/AnimationPlayer
	var sprite = $ContentContainer/AnimationSpace/PlayerSprite
	
	# Create a new animation
	var animation = Animation.new()
	animation.length = 4.0  # Total animation length in seconds
	animation.loop_mode = Animation.LOOP_LINEAR  # Loop indefinitely
	
	# Create position track (vertical movement)
	var pos_track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(pos_track_index, ".:position")
	animation.track_set_interpolation_type(pos_track_index, Animation.INTERPOLATION_CUBIC)
	
	var start_y = 253.0
	var jump_height = 100.0
	var x_pos = 200.0
	
	# Jump 1
	animation.track_insert_key(pos_track_index, 0.0, Vector2(x_pos, start_y))
	animation.track_insert_key(pos_track_index, 0.6, Vector2(x_pos, jump_height))
	animation.track_insert_key(pos_track_index, 0.9, Vector2(x_pos, start_y))
	
	# Jump 2
	animation.track_insert_key(pos_track_index, 1.2, Vector2(x_pos, jump_height))
	animation.track_insert_key(pos_track_index, 1.5, Vector2(x_pos, start_y))
	
	# Jump 3 (higher and longer for the spin)
	animation.track_insert_key(pos_track_index, 1.8, Vector2(x_pos, jump_height - 40))
	animation.track_insert_key(pos_track_index, 2.8, Vector2(x_pos, start_y))
	
	# Pause before looping
	animation.track_insert_key(pos_track_index, 2.81, Vector2(x_pos, start_y))
	animation.track_insert_key(pos_track_index, 4.0, Vector2(x_pos, start_y))
	
	# Create rotation track (for the spin on jump 3)
	var rot_track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(rot_track_index, ".:rotation")
	animation.track_set_interpolation_type(rot_track_index, Animation.INTERPOLATION_LINEAR)
	
	# No rotation for jumps 1 and 2
	animation.track_insert_key(rot_track_index, 0.0, 0.0)
	animation.track_insert_key(rot_track_index, 1.2, 0.0)
	
	# Spin during jump 3 (full 360 degree rotation = 2*PI radians)
	animation.track_insert_key(rot_track_index, 1.5, 0.0)
	animation.track_insert_key(rot_track_index, 2.5, TAU)  # TAU = 2*PI
	
	# Reset rotation after landing
	animation.track_insert_key(rot_track_index, 2.51, 0.0)
	animation.track_insert_key(rot_track_index, 4.0, 0.0)
	
	# Add the animation to the AnimationPlayer
	var anim_library = anim_player.get_animation_library("")
	if anim_library.has_animation("triple_jump_spin"):
		anim_library.remove_animation("triple_jump_spin")
	anim_library.add_animation("triple_jump_spin", animation)


func _on_continue_button_pressed():
	Global.navigate_to_current_level()


func _on_select_level_button_pressed():
	get_tree().change_scene_to_file("res://src/ui/menus/level_select.tscn")


func _on_shop_button_pressed():
	get_tree().change_scene_to_file("res://src/ui/menus/shop.tscn")


func _unhandled_input(event):
	if event is InputEventScreenTouch:
		print("Screen touched at position: ", event.position)


func _on_button_pressed():
	Global.reset_progress()
