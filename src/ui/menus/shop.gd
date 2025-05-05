extends CanvasLayer


var item_card_scene = preload("res://src/ui/item_card.tscn")
var shop_items = [
	{
		"id": "shield",
		"name": "Shield", 
		"price": 200,
		"icon": preload("res://assets/force-field.png")
	},
	{
		"id": "shield2",
		"name": "Shield 2", 
		"price": 500,
		"icon": preload("res://assets/force-field.png")
	},
		{
		"id": "shield3",
		"name": "Shield", 
		"price": 500,
		"icon": preload("res://assets/force-field.png")
	},
	{
		"id": "shield4",
		"name": "Shield 2", 
		"price": 500,
		"icon": preload("res://assets/force-field.png")
	},
		{
		"id": "shiel5",
		"name": "Shield", 
		"price": 500,
		"icon": preload("res://assets/force-field.png")
	},
	{
		"id": "shield6",
		"name": "Shield 2", 
		"price": 500,
		"icon": preload("res://assets/force-field.png")
	},
]


func _ready():
	set_coins_label()
	var items_grid = $ShopContainer/ItemsContainer/ScrollContainer/MarginContainer/ItemsGrid
	
	for item in shop_items:
		var card = item_card_scene.instantiate()
		card.item_id = item.id
		card.item_name = item.name
		card.item_price = item.price
		card.item_icon = item.icon
		card.connect("buy_pressed", _on_item_buy_pressed)
		items_grid.add_child(card)


func set_coins_label():
	%CurrentCoinsLabel.text = Formatters.format_number_with_commas(Global.coins)


func _on_item_buy_pressed(item_id: String):
	print("Bought item: " + item_id)
	var item = find_item_by_id(item_id)
	if Global.coins >= item.price:
		Global.remove_coins(item.price)
		set_coins_label()
		if item_id == "shield":
			Global.add_shield()


func find_item_by_id(item_id: String):
	for item in shop_items:
		if item.id == item_id:
			return item
	return null


func _on_touch_screen_button_pressed():
	get_tree().change_scene_to_file("res://src/ui/menus/main_menu.tscn")
