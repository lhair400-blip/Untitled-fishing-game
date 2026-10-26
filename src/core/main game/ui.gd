extends Node

@onready var journal: Control = $journal
@onready var inventory: Control = $inventory
@onready var sellmenu: Control = $sellmenu

var toggle_journal: bool = false

func update():
	#If the journal visible then if the button is pressed again it will close
	if toggle_journal:
		if journal.visible:
			journal.close()
		else:
			inventory.close()
			sellmenu.close()
			journal.open()
		get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Toggle_inventory"):
		if inventory.visible:
			inventory.close()
		else:
			journal.close()
			sellmenu.close()
			inventory.open()
		get_viewport().set_input_as_handled()
	
	elif event.is_action_pressed("Sell_menu"):
		if sellmenu.visible:
			sellmenu.close()
		else:
			journal.close()
			inventory.close()
			sellmenu.open()
		get_viewport().set_input_as_handled()
