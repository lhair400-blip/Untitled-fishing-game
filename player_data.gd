
extends Node

var records := {}
var new_fish := {}

# Saves the amount of each fish caught, also saves the highest weight of each
func record_catch(fish: FishData, weight: float) -> void:
	if not records.has(fish.name):
		records[fish.name] = { "count": 0, "best_weight": 0.0}
		new_fish[fish.name] = true
	records[fish.name].count += 1
	records[fish.name].best_weight = maxf(records[fish.name].best_weight, weight)

# Checks if a fish has already been caught before
func is_discovered(fish: FishData) -> bool:
	return records.has(fish.name)

# Says its the first time a fish has been caught
func is_new(fish: FishData) -> bool:
	return new_fish.has(fish.name)

# Says the player has viewed the details of a fish
func mark_seen(fish: FishData) -> void:
	new_fish.erase(fish.name)
