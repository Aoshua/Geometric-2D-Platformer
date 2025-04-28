extends CanvasLayer


var item_card_scene = preload("res://src/ui/item_card.tscn")
var shop_items = [
	{
		"id": "shield",
		"name": "Shield", 
		"price": 500,
		"icon": preload("res://assets/force-field.png")
	},
	{
		"id": "shield2",
		"name": "Shield 2", 
		"price": 500,
		"icon": preload("res://assets/force-field.png")
	},
		{
		"id": "shield",
		"name": "Shield", 
		"price": 500,
		"icon": preload("res://assets/force-field.png")
	},
	{
		"id": "shield2",
		"name": "Shield 2", 
		"price": 500,
		"icon": preload("res://assets/force-field.png")
	},
		{
		"id": "shield",
		"name": "Shield", 
		"price": 500,
		"icon": preload("res://assets/force-field.png")
	},
	{
		"id": "shield2",
		"name": "Shield 2", 
		"price": 500,
		"icon": preload("res://assets/force-field.png")
	},
]


func _ready():
	%CurrentCoinsLabel.text = Formatters.format_number_with_commas(Global.coins)
	var items_grid = $ShopContainer/ItemsContainer/ScrollContainer/MarginContainer/ItemsGrid
	
	for item in shop_items:
		var card = item_card_scene.instantiate()
		card.item_id = item.id
		card.item_name = item.name
		card.item_price = item.price
		card.item_icon = item.icon
		card.connect("buy_pressed", _on_item_buy_pressed)
		items_grid.add_child(card)


func _on_item_buy_pressed(item_id):
	print("Bought item: " + item_id)
	# Check if player has enough coins
	# Deduct coins
	# Add item to inventory


func _on_touch_screen_button_pressed():
	get_tree().change_scene_to_file("res://src/ui/menus/main_menu.tscn")
	queue_free()
