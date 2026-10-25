extends Node

signal fishing_started
signal fishing_ended
signal fish_caught(fish: FishData, weight: float, perfect: bool)
signal fish_escaped

enum State { Idle, Waiting, Bite, Reeling }

@export var alert: Control 
@export var minigame: Control
@export var min_wait := 2.0
@export var max_wait := 6.0

var state := State.Idle
var current: Dictionary = {}

@onready var bitetimer: Timer = $Bitetimer
@onready var hooktimer: Timer = $Hooktimer

@onready var message: Label = $"../Message"

func _ready() -> void:
	bitetimer.one_shot = true
	hooktimer.one_shot = true
	bitetimer.timeout.connect(on_bite)
	hooktimer.timeout.connect(on_hook_missed)
	minigame.finished.connect(on_minigame_finished)
	alert.hide()
	minigame.hide()

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("Reel"):
		return
	match state:
		State.Idle:
			cast()
		State.Waiting:
			cancel()
		State.Bite:
			hook()

func cast() -> void:
	message.text = "Casting"
	state = State.Waiting
	fishing_started.emit()
	bitetimer.start(randf_range(min_wait, max_wait))

func cancel() -> void:
	message.text = "Canceled"
	bitetimer.stop()
	end()

func on_bite() -> void:
	message.text = "BITE!"
	current = FishDataBase.catch_fish()
	state = State.Bite
	alert.show()
	hooktimer.start()

func hook() -> void:
	message.text = "Hooked"
	hooktimer.stop()
	alert.hide()
	state = State.Reeling
	minigame.show()
	minigame.start(current.fish)

func on_hook_missed() -> void:
	message.text = "Too slow"
	alert.hide()
	fish_escaped.emit()
	end()

func on_minigame_finished(success: bool, perfect: bool) -> void:
	message.text = "Caught fish"
	minigame.hide()
	if success:
		PlayerData.record_catch(current.fish, current.weight)
		fish_caught.emit(current.fish, current.weight, perfect)
	else:
		fish_escaped.emit()
	end()

func end() -> void:
	state = State.Idle
	current = {}
	fishing_ended.emit()
