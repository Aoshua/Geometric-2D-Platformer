extends CanvasLayer


var item_card_scene = preload("res://src/ui/item_card.tscn")
var shop_items = []


func _ready():
	set_coins_label()
	load_items()


func load_items():
	shop_items = [
		{
			"id": "shield",
			"name": "Shield", 
			"price": 200,
			"icon": preload("res://assets/force-field.png")
		}
	]
	
	# Blue Skin:
	var blueSkin = {
		"id": "blue-skin",
		"name": "Blue",
		"price": 800,
		"icon": preload("res://assets/player-blue.png"),
		"icon_size": 90
	}
	if (Global.unlocked_skins.has(Global.PlayerSkins.BLUE)):
		if (Global.current_skin == Global.PlayerSkins.BLUE):
			blueSkin["button_text"] = "Equipped"
			blueSkin["button_disabled"] = false
		else:
			blueSkin["button_text"] = "Equip"
	shop_items.push_back(blueSkin)
	
	# Pink Skin:
	var pinkSkin = {
		"id": "pink-skin",
		"name": "Pink",
		"price": 800,
		"icon": preload("res://assets/player-pink.png"),
		"icon_size": 90
	}
	if (Global.unlocked_skins.has(Global.PlayerSkins.PINK)):
		if (Global.current_skin == Global.PlayerSkins.PINK):
			pinkSkin["button_text"] = "Equipped"
			pinkSkin["button_disabled"] = true
		else:
			pinkSkin["button_text"] = "Equip"
	shop_items.push_back(pinkSkin)
	
	# Green (default) Skin:
	var greenSkin = {
		"id": "green-skin",
		"name": "Green",
		"price": 0,
		"icon": preload("res://assets/player.png"),
		"icon_size": 90
	}
	if (Global.current_skin == Global.PlayerSkins.GREEN):
		greenSkin["button_text"] = "Equipped"
		greenSkin["button_disabled"] = false
	else:
		greenSkin["button_text"] = "Equip"
	shop_items.push_back(greenSkin)
	
	render_item_cards()


func render_item_cards():
	var items_grid = $ShopContainer/ItemsContainer/ScrollContainer/MarginContainer/ItemsGrid
	
	# Clear out old cards
	for child in items_grid.get_children():
		child.queue_free()
	
	for item in shop_items:
		var card = item_card_scene.instantiate()
		card.item_id = item.id
		card.item_name = item.name
		card.item_price = item.price
		card.item_icon = item.icon
		if ("icon_size" in item):
			card.icon_size = item.icon_size
		if ("button_text" in item):
			card.button_text = item.button_text
		if ("button_disabled" in item):
			card.button_disabled = item.button_disabled
		card.connect("buy_pressed", _on_item_buy_pressed)
		items_grid.add_child(card)


func set_coins_label():
	%CurrentCoinsLabel.text = Formatters.format_number_with_commas(Global.coins)


func _on_item_buy_pressed(item_id: String):
	var item = find_item_by_id(item_id)
	if (!"button_text" in item):
		if Global.coins >= item.price:
			Global.remove_coins(item.price)
			SoundManager.play_sound("item-purchased")
			set_coins_label()
			if item_id == "shield":
				Global.add_shield()
			elif item_id == 'blue-skin':
				Global.unlock_skin(Global.PlayerSkins.BLUE) # Note that unlocking also equips
			elif item_id == 'pink-skin':
				Global.unlock_skin(Global.PlayerSkins.PINK)
			elif item_id == 'green-skin':
				Global.unlock_skin(Global.PlayerSkins.GREEN)
		else:
			var alert = load("res://src/ui/menus/alert_menu.tscn").instantiate()
			alert.label = "Insufficient coins!"
			alert.process_mode = Node.PROCESS_MODE_ALWAYS
			get_tree().root.add_child(alert)
	elif (item["button_text"] == "Equip"):
		if (item_id == "blue-skin"):
			Global.equip_skin(Global.PlayerSkins.BLUE)
		elif (item_id == "pink-skin"):
			Global.equip_skin(Global.PlayerSkins.PINK)
		elif (item_id == "green-skin"):
			Global.equip_skin(Global.PlayerSkins.GREEN)
	
	load_items()


func find_item_by_id(item_id: String):
	for item in shop_items:
		if item.id == item_id:
			return item
	return null


func _on_touch_screen_button_pressed():
	get_tree().change_scene_to_file("res://src/ui/menus/main_menu.tscn")
