extends Node2D

@onready var progress_bar: ProgressBar = $ProgressBar

func _ready() -> void:
	visible = false
	progress_bar.value = 30

func update():
	#progress_bar.value -= 0.5
	pass
