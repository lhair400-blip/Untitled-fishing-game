extends Control

const Slot_scene := preload("res://src/gameplay/journal/journal_slot.tscn")
const Per_page := 9
const Per_spread := 18

enum SortMode { Rarity, Region }

const rarity_names = ["Common", "Uncommon", "Rare", "Legendary"]
const region_names = ["Pond", "River", "Ocean", "Cave"]

var sort_mode := SortMode.Rarity
var entries: Array = []
var page_titles: Array[String] = []
var spread := 0
var slots: Array = []

@onready var left_grid: GridContainer = $Center/Layout/Stack/book/leftpage/content/GridContainer
@onready var right_grid: GridContainer = $Center/Layout/Stack/book/rightpage/content/GridContainer

@onready var left_title: Label = $Center/Layout/Stack/book/leftpage/content/titlelabel
@onready var left_number: Label = $Center/Layout/Stack/book/leftpage/content/numberlabel
@onready var right_title: Label = $Center/Layout/Stack/book/rightpage/content/titlelabel
@onready var right_number: Label = $Center/Layout/Stack/book/rightpage/content/numberlabel


@onready var detail: PanelContainer = $Center/Layout/Stack/detail
@onready var book: HBoxContainer = $Center/Layout/Stack/book
@onready var controls: HBoxContainer = $Center/Layout/controls
@onready var stack: MarginContainer = $Center/Layout/Stack

@onready var prevbutton: Button = $Center/Layout/controls/prevbutton
@onready var nextbutton: Button = $Center/Layout/controls/nextbutton
@onready var sortbutton: Button = $Center/Layout/controls/sortbutton

@onready var descriptionlabel: Label = $Center/Layout/Stack/detail/leftdetailpage/top/VBoxContainer/descriptionlabel
@onready var backbutton: Button = $Center/Layout/Stack/detail/leftdetailpage/top/VBoxContainer/backbutton

@onready var detailsprite: TextureRect = $Center/Layout/Stack/detail/leftdetailpage/top/detailsprite
@onready var namelabel: Label = $Center/Layout/Stack/detail/leftdetailpage/top/infobox/namelabel
@onready var raritylabel: Label = $Center/Layout/Stack/detail/leftdetailpage/top/infobox/raritylabel
@onready var regionlabel: Label = $Center/Layout/Stack/detail/leftdetailpage/top/infobox/regionlabel
@onready var weightlabel: Label = $Center/Layout/Stack/detail/leftdetailpage/top/infobox/weightlabel


func _ready() -> void:
	hide()
	for i in Per_spread:
		var slot = Slot_scene.instantiate()
		if i < Per_page:
			left_grid.add_child(slot)
		else:
			right_grid.add_child(slot)
		slot.fish_selected.connect(open_detail)
		slots.append(slot)
	
	prevbutton.pressed.connect(_on_prevbutton_pressed)
	nextbutton.pressed.connect(_on_nextbutton_pressed)
	sortbutton.pressed.connect(toggle_sort)
	backbutton.pressed.connect(close_detail)
	
	rebuild()

func show_detail(on: bool) -> void:
	if on:
		stack.custom_minimum_size = book.size
	book.visible = not on
	detail.visible = on
	controls.visible = not on
	
	await get_tree().process_frame
	var target: Control = detail if on else book
	target.pivot_offset = target.size / 2.0
	target.scale.x = 0.0
	create_tween().tween_property(target, "scale:x", 1.0, 0.15)

func open() -> void:
	show_detail(false)
	rebuild()
	show()

func close() -> void:
	hide()

func group_name(f: FishData) -> String:
	if sort_mode == SortMode.Rarity:
		return rarity_names[f.rarity]
	return region_names[f.region]

func build_page_titles() -> void:
	page_titles.clear()
	var page_count := ceili(entries.size() / float(Per_page))
	var last_name := ""
	
	for p in page_count:
		var group_name := ""
		for i in Per_page:
			var index := p * Per_page + i
			if index < entries.size() and entries[index] != null:
				group_name = group_name(entries[index])
				break
	
		if group_name != "" and group_name == last_name:
			page_titles.append(group_name + " (cont.)")
		else:
			page_titles.append(group_name)
		last_name = group_name

func sort_by_rarity(a: FishData, b: FishData) -> bool:
	if a.rarity != b.rarity:
		return a.rarity < b.rarity
	return a.name < b.name

func sort_by_region(a: FishData, b: FishData) -> bool:
	if a.region != b.region:
		return a.region < b.region
	if a.rarity != b.rarity:
		return a.rarity < b.rarity
	return a.name < b.name

func pad_by_group(list:Array, group_of: Callable) -> Array:
	var padded: Array = []
	var last_group = null
	for f in list:
		var group = group_of.call(f)
		if last_group != null and group != last_group:
			while padded.size() % Per_page != 0:
				padded.append(null)
		padded.append(f)
		last_group = group
	return padded

func group_by_rarity(f: FishData) -> int:
	return f.rarity

func group_by_region(f: FishData) -> int:
	return f.region

func rebuild() -> void:
	entries = FishDataBase.all_fish.duplicate()
	
	if sort_mode == SortMode.Rarity:
		entries.sort_custom(sort_by_rarity)
		entries = pad_by_group(entries, Callable(self, "group_by_rarity"))
		sortbutton.text = "Sort: Rarity"
	else:
		entries.sort_custom(sort_by_region)
		entries = pad_by_group(entries, Callable(self, "group_by_region"))
		sortbutton.text = "Sort: Region"
	
	build_page_titles()
	spread = 0
	show_spread()

func show_spread() -> void:
	for i in Per_spread:
		var index := spread * Per_spread + i
		var entry = null
		if index < entries.size():
			entry = entries[index]
	
		if entry == null:
			slots[i].clear_slot()
		else:
			slots[i].setup(entry)
	
	var left_index := spread * 2
	var right_index := left_index + 1
	
	left_number.text = str(left_index + 1)
	right_number.text = str(right_index + 1)
	left_title.text = page_titles[left_index] if left_index < page_titles.size() else ""
	right_title.text = page_titles[right_index] if right_index < page_titles.size() else ""
	
	
	var last_spread := maxi(0, ceili(entries.size() / float(Per_spread)) -1)
	prevbutton.disabled = spread <= 0
	nextbutton.disabled = spread >= last_spread

func _on_prevbutton_pressed() -> void:
	spread -= 1
	show_spread()

func _on_nextbutton_pressed() -> void:
	spread += 1
	show_spread()

func toggle_sort() -> void:
	if sort_mode == SortMode.Rarity:
		sort_mode = SortMode.Region
	else:
		sort_mode = SortMode.Rarity
	rebuild()

func close_detail() -> void:
	show_detail(false)
	show_spread()

func open_detail(fish: FishData) -> void:
	var found: bool= PlayerData.is_discovered(fish)
	
	detailsprite.texture = fish.sprite

	if found:
		var rec = PlayerData.records[fish.name]
		detailsprite.modulate = Color.WHITE
		namelabel.text = fish.name
		raritylabel.text = "Rarity: " + rarity_names[fish.rarity]
		regionlabel.text = "Region: " + region_names[fish.region]
		weightlabel.text = "Best: %.2f kg | Caught: %d" % [rec.best_weight, rec.count]
		descriptionlabel.text = fish.description
		PlayerData.mark_seen(fish)
		var rarity_color: Color = FishData.Rarity_colors[fish.rarity]
		namelabel.add_theme_color_override("font_color", rarity_color)
		raritylabel.add_theme_color_override("font_color", rarity_color)
	else:
		namelabel.text = "???"
		raritylabel.text = "Rarity: ???" 
		regionlabel.text = "Region: " + region_names[fish.region]
		weightlabel.text = ""
		descriptionlabel.text = "You haven't caought this fish yet."
		namelabel.remove_theme_color_override("font_color")
		raritylabel.remove_theme_color_override("font_color")
	
	show_detail(true)
