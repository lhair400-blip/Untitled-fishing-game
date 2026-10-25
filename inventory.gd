extends Control

const slot_scene := preload("res://src/gameplay/journal/journal_slot.tscn")

@onready var grid: GridContainer = $center/panel/layout/scroll/GridContainer

func _ready() -> void:
	hide()
	PlayerData.inventory_changed.connect(on_inventory_changed)

func open() -> void:
	refresh()
	show()

func close() -> void:
	hide()

func on_inventory_changed() -> void:
	if visible:
		refresh()

func refresh() -> void:
	for c in grid.get_children():
		grid.remove_child(c)
		c.queue_free()
	
	for item in PlayerData.inventory:
		var slot = slot_scene.instantiate()
		grid.add_child(slot)
		slot.setup(item.fish)
		slot.newbadge.visible = false
