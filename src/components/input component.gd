class_name My_input_Component
extends Node

# character movement
var horizontal_direction: float = 0.0
var vertical_direction: float = 0.0
var reel: bool = false
# character actions
var action1_pressed: bool = false
var action2_pressed: bool = false
var toggle_journal: bool = false
var toggle_inventory: bool = false

func update() -> void:
	# character movement
	horizontal_direction = Input.get_axis("Left", "Right")
	vertical_direction = Input.get_axis("Up", "Down")
	reel = Input.is_action_just_pressed("Reel")
	
	#actions
	action1_pressed = Input.is_action_just_pressed("Action1")
	action2_pressed = Input.is_action_just_pressed("Action2")
	toggle_journal = Input.is_action_just_pressed("Toggle_journal")
	toggle_inventory = Input.is_action_just_pressed("Toggle_inventory")
