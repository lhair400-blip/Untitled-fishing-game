extends CharacterBody2D

@onready var input_component: My_input_Component = $"Components/Input"
@onready var movement_component: Movement_component = $"Components/Movement"
@onready var ui: CanvasLayer = $"../../UI"
@onready var sprite: Node = $Components/Sprite

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	Variable_linker()
	Component_updater()
	move_and_slide()

func Variable_linker():
	#Links variables together
	movement_component.horizontal_direction = input_component.horizontal_direction
	movement_component.vertical_direction = input_component.vertical_direction
	ui.toggle_journal = input_component.toggle_journal
	sprite.horiz_dir = movement_component.horizontal_direction
	sprite.vert_dir = movement_component.vertical_direction

func Component_updater():
	#updates each component
	movement_component.update()
	input_component.update()
	sprite.update()
	ui.update()
	
