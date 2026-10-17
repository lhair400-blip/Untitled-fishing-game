class_name Fishing_component
extends Node

@onready var fishdatabase: Node = $"../Fishdatabase"
@onready var input: My_input_Component = $"../Input"
@onready var fishing_minigame: Node2D = $"../../Fishing minigame"

var start_fishing: bool = false
var fishing: bool = false
var success: bool = false
var fail: bool = false


func update():
	fishing_minigame.update()
	if start_fishing == true:
		fishing_minigame.visible = true
	
	if fishing_minigame.visible == true:
		if fishing == true:
			fishing_minigame.visible = true
			fishing_minigame.progress_bar.value += 20
	
	if fishing_minigame.progress_bar.value == 100:
		success = true
	elif fishing_minigame.progress_bar.value == 0:
		fail = true
	
	if success == true or fail == true:
		fishing_minigame._ready()
		if success == true:
			reel_in()
		success = false
		fail = false

func reel_in() -> void:
	var result = fishdatabase.catch_fish()
	var fish: FishData = result.fish
	var weight: float = result.weight

	PlayerData.record_catch(result.fish, result.weight)

	print("You caught a %s! (%.2f kg)" % [fish.name, weight])
	print(fish.description)
