extends Control

var slot_scene:= load("res://src/gameplay/journal/journal_slot.gd")

@onready var titlelabel: Label = $center/panel/layout/titlelabel
@onready var moneylabel: Label = $center/panel/layout/moneylabel
@onready var incomelabel: Label = $center/panel/layout/incomelabel
@onready var tanks: HBoxContainer = $center/panel/layout/tanks
@onready var picker: VBoxContainer = $center/panel/layout/picker
@onready var grid: GridContainer = $center/panel/layout/picker/scroll/grid
@onready var emptylabel: Label = $center/panel/layout/picker/emptylabel
@onready var backbutton: Button = $center/panel/layout/picker/backbutton

var picking_slot := -1
var tank_slots: Array = []

func _ready() -> void:
	hide()
	tank_slots = tanks.get_children()
	for i in tank_slots.size():
		tank_slots[i].pressed.connect(on_tank_slot_pressed.bind(i))
	
	backbutton.pressed.connect(on_back_pressed)
	PlayerData.aquarium_changed.connect(refresh)
	PlayerData.inventory_changed.connect(on_inventory_changed)

func open() -> void:
	picking_slot = -1
	refresh()
	show()

func close() -> void:
	picking_slot = -1
	hide()

func _process(delta: float) -> void:
	if visible:
		update_labels()

func update_labels() -> void:
	moneylabel.text = "Money: %d" %int(PlayerData.money)
	incomelabel.text = "Earning %.0f / second" % PlayerData.get_income_per_second()

func refresh() -> void:
	var picking := picking_slot != -1
	tanks.visible = not picking
	picker.visible = picking
	titlelabel.text = "Choose a fish" if picking else "Aquarium"
	if picking:
		refresh_picker()
	else: 
		refresh_tanks()
	update_labels()

func refresh_tanks() -> void:
	for i in tank_slots.size():
		var slot = tank_slots[i]
		var item = PlayerData.aquarium[i]
		if item == null:
			slot.clear_slot()
			slot.disabled = false
			slot.label.text = "Empty \n(Click to add)"
		else:
			slot.setup(item.fish)
			slot.newbadge.visible = false
			slot.label.text = "%s\n+%.0f/s" % [item.fish.name, PlayerData.income_for(item)]

func refresh_picker() -> void:
	for c in grid.get_children():
		grid.remove_child(c)
		c.queue_free()
	
	for item in PlayerData.inventory:
		var slot = slot_scene.instantiate()
		grid.add_child(slot)
		slot.setup(item.fish)
		slot.newbadge.visible = false
		slot.fish_selected.connect(on_fish_picked.bind(item.id))
	
	emptylabel.visible = PlayerData.inventory.is_empty()

func on_tank_slot_pressed(index: int) -> void:
	if PlayerData.aquarium[index] == null:
		picking_slot = index
		refresh()
	else:
		PlayerData.remove_from_aquarium(index)

func on_fish_picked(fish: FishData, id: int) -> void:
	var slot := picking_slot
	picking_slot = -1
	PlayerData.add_to_aquarium(slot, id)
	refresh()

func on_back_pressed() -> void:
	picking_slot = -1
	refresh()

func on_inventory_changed() -> void:
	if visible and picking_slot != -1:
		refresh()
