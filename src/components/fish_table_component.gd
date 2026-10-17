
extends Node

const fish_folder = "res://src/fish/"

const rarity_weights= {
	FishData.Rarity.COMMON: 60,
	FishData.Rarity.UNCOMMON: 25,
	FishData.Rarity.RARE: 10,
	FishData.Rarity.LEGENDARY: 5,
}

var fish_by_rarity := {}
var all_fish: Array[FishData] = []

func _ready() -> void:
	for rarity in rarity_weights:
		fish_by_rarity[rarity] = []
	_load_all_fish()

func _load_all_fish() -> void:
	var dir := DirAccess.open(fish_folder)
	if dir == null:
		print("Could not find fish folder")
		return

	for file in dir.get_files():
		file = file.trim_suffix(".remap")
		if not file.ends_with(".tres"):
			continue
		var fish := load(fish_folder + file) as FishData
		if fish:
			all_fish.append(fish)
			fish_by_rarity[fish.rarity].append(fish)

func roll_rarity() -> FishData.Rarity:
	var total := 0
	for w in rarity_weights.values():
		total += w

	var roll := randi_range(1, total)
	var running := 0
	for rarity in rarity_weights:
		running += rarity_weights[rarity]
		if roll <= running:
			return rarity
	return FishData.Rarity.COMMON

func catch_fish() -> Dictionary:
	var rarity := roll_rarity()
	var pool: Array = fish_by_rarity[rarity]

	# If a rarity has no fish yet, fall back to common
	if pool.is_empty():
		pool = fish_by_rarity[FishData.Rarity.COMMON]

	var fish: FishData = pool.pick_random()
	return {
		"fish": fish,
		"weight": snappedf(randf_range(fish.min_weight, fish.max_weight), 0.01),
	}
