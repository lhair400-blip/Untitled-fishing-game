extends Node

@onready var journal: Control = $journal
@onready var inventory: Control = $inventory
@onready var sellmenu: Control = $sellmenu
@onready var aquarium: Control = $aquarium

var toggle_journal: bool = false

func update():
	#If the journal visible then if the button is pressed again it will close
	if toggle_journal:
		toggle_menu(journal)
		get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Toggle_inventory"):
		toggle_menu(inventory)
		get_viewport().set_input_as_handled()
	
	elif event.is_action_pressed("Sell_menu"):
		toggle_menu(sellmenu)
		get_viewport().set_input_as_handled()
	
	elif event.is_action_pressed("Toggle_aquarium"):
		toggle_menu(aquarium)
		get_viewport().set_input_as_handled()

func toggle_menu(menu: Control) -> void:
	if menu.visible:
		menu.close()
		return
	for other in [journal, inventory, aquarium, sellmenu]:
		if other != menu:
			other.close()
	menu.open()
