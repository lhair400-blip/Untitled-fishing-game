extends Control

const slot_scene := preload("res://src/gameplay/journal/journal_slot.tscn")

var selected := {}

@onready var grid: GridContainer = $center/panel/layout/scroll/GridContainer
@onready var totallabel: Label = $center/panel/layout/footer/totallabel
@onready var confirmbutton: Button = $center/panel/layout/footer/confirmbutton

@onready var confirmpopup: Control = $confirmpopup
@onready var questionlabel: Label = $confirmpopup/center2/popuppanel/popuplayout/questionlabel
@onready var yesbutton: Button = $confirmpopup/center2/popuppanel/popuplayout/buttons/yesbutton
@onready var nobutton: Button = $confirmpopup/center2/popuppanel/popuplayout/buttons/nobutton

func _ready() -> void:
	hide()
	confirmpopup.hide()
	confirmbutton.pressed.connect(on_confirm_pressed)
	yesbutton.pressed.connect(on_yes_pressed)
	nobutton.pressed.connect(on_no_pressed)
	PlayerData.inventory_changed.connect(on_inventory_changed)

func open() -> void:
	selected.clear()
	confirmpopup.hide()
	refresh()
	show()

func close() -> void:
	confirmpopup.hide()
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
		if selected.has(item.id):
			slot.set_marked(true)
		
		slot.fish_selected.connect(on_slot_pressed.bind(item.id, slot))
	update_footer()

func on_slot_pressed(fish: FishData, id: int, slot: Button) -> void:
	if selected.has(id):
		selected.erase(id)
		slot.set_marked(false)
		slot.newbadge.visible = false
	else:
		selected[id] = true
		slot.set_marked(true)
	update_footer()

func get_selected_total() -> int:
	var total := 0 
	for id in selected:
		var item := PlayerData.get_item(id)
		if not item.is_empty():
			total += item.fish.get_price(item.weight)
	return total

func update_footer() -> void:
	totallabel.text = "Selected: %d | Value: $%d" % [selected.size(), get_selected_total()]
	confirmbutton.disabled = selected.is_empty()

func on_confirm_pressed() -> void:
	questionlabel.text = "Sell %d fish for $%d?" % [selected.size(), get_selected_total()]
	confirmpopup.show()

func on_yes_pressed() -> void:
	var total := get_selected_total()
	var ids := selected.keys()
	selected.clear()
	for id in ids:
		PlayerData.remove_item(id)
	PlayerData.add_money(total)
	confirmpopup.hide()
	refresh()

func on_no_pressed() -> void:
	confirmpopup.hide()
