
extends Node

signal inventory_changed

var records := {}
var new_fish := {}

var inventory: Array[Dictionary] = []
var next_id := 0

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
