
extends Node

signal inventory_changed
signal money_changed(amount: int)
signal aquarium_changed

const aquarium_slots = 2
const income_per_rarity := [1.0, 3.0, 8.0, 25.0]

var records := {}
var new_fish := {}

var money := 0 
var aquarium : Array = []

var inventory: Array[Dictionary] = []
var next_id := 0

func _ready() -> void:
	aquarium.resize(aquarium_slots)
	aquarium.fill(null)

func _process(delta: float) -> void:
	money += get_income_per_second() * delta

# Saves the amount of each fish caught, also saves the highest weight of each
func record_catch(fish: FishData, weight: float) -> void:
	if not records.has(fish.name):
		records[fish.name] = { "count": 0, "best_weight": 0.0}
		new_fish[fish.name] = true
	records[fish.name].count += 1
	records[fish.name].best_weight = maxf(records[fish.name].best_weight, weight)
	add_to_inventory(fish, weight)

func add_to_inventory(fish: FishData, weight: float) -> void:
	inventory.append({
		"id": next_id,
		"fish": fish, 
		"weight": weight, 
	})
	next_id += 1
	inventory_changed.emit()

func remove_item(id: int) -> void:
	for i in inventory.size():
		if inventory[i].id == id:
			inventory.remove_at(i)
			inventory_changed.emit()
			return

func get_item(id:int) -> Dictionary:
	for item in inventory:
		if item.id == id:
			return item
	return {}

# Checks if a fish has already been caught before
func is_discovered(fish: FishData) -> bool:
	return records.has(fish.name)

# Says its the first time a fish has been caught
func is_new(fish: FishData) -> bool:
	return new_fish.has(fish.name)

# Says the player has viewed the details of a fish
func mark_seen(fish: FishData) -> void:
	new_fish.erase(fish.name)

func add_money(amount: int) -> void:
	money += amount
	money_changed.emit(money)

func income_for(item: Dictionary) -> float:
	return income_per_rarity[item.fish.rarity]

func get_income_per_second() -> float:
	var total := 0.0
	for item in aquarium:
		if item != null:
			total += income_for(item)
	return total

func add_to_aquarium(slot: int, id: int) -> void:
	if aquarium[slot] != null:
		return
	var item := get_item(id)
	if item.is_empty():
		return
	remove_item(id)
	aquarium[slot] = item
	aquarium_changed.emit()

func remove_from_aquarium(slot: int) -> void:
	var item = aquarium[slot]
	if item == null:
		return
	aquarium[slot] = null
	inventory.append(item)
	aquarium_changed.emit()
	inventory_changed.emit()
