extends Control

signal finished(success: bool, perfect: bool)

const gravity := 300.0
const lift := 520.0
const fill_rate := 0.28
const drain_rate := 0.16
const grace_time := 0.6

@onready var track: ColorRect = $track
@onready var bar: ColorRect = $track/catchbar
@onready var fishicon: TextureRect = $track/fishicon
@onready var progress_bar: ProgressBar = $progress

var active := false
var bar_y := 0.0
var bar_vel := 0.0
var fish_y := 0.0
var fish_target := 0.0
var fish_speed := 60.0
var retarget_time := 0.0
var retarget_range := Vector2(0.5, 1.2)
var progress := 0.3
var grace := grace_time
var perfect := true

func start(fish:FishData) -> void:
	var d := fish.difficulty
	fishicon.texture = fish.sprite
	fish_speed = lerpf(40.0, 150.0, d)
	retarget_range = Vector2(lerpf(1.2, 0.3, d), lerpf(2.0, 0.8, d))
	bar.size.y = lerpf(36.0, 22.0, d)
	
	bar_y = track.size.y
	bar_vel = 0.0
	fish_y = bar_y + bar.size.y / 2.0
	fish_target = fish_y
	retarget_time = 0.5
	progress = 0.3
	grace = grace_time
	perfect = true
	active = true
	draw_positions()

func _process(delta: float) -> void:
	if not active:
		return
	
	if Input.is_action_just_pressed("Reel"):
		bar_vel -= lift * delta
	else:
		bar_vel += gravity * delta
	bar_vel = clampf(bar_vel, -200.0, 250.0)
	bar_y += bar_vel * delta
	
	var max_bar := track.size.y - bar.size.y
	if bar_y < 0.0:
		bar_y = 0.0
		bar_vel = 0.0
	elif bar_y > max_bar:
		bar_y = max_bar
		bar_vel = -bar_vel * 0.3
	
	retarget_time -= delta
	if retarget_time <= 0.0:
		fish_target = randf_range(0.0, track.size.y)
		retarget_time = randf_range(retarget_range.x, retarget_range.y)
	fish_y = move_toward(fish_y, fish_target, fish_speed * delta)
	
	grace = maxf(grace - delta, 0.0)
	var inside := fish_y >= bar_y and fish_y <= bar_y + bar.size.y
	if inside:
		progress += fill_rate * delta
	else:
		progress -= drain_rate * delta
		if grace <= 0.0:
			perfect = false
	
	draw_positions()
	
	if progress >= 1.0:
		finish(true)
	elif progress <= 0.0: 
		finish(false)

func draw_positions():
	bar.position = Vector2(0, roundf(bar_y))
	fishicon.position = Vector2(
		roundf((track.size.x - fishicon.size.x) / 2.0), 
		roundf(fish_y - fishicon.size.y / 2.0 ))
	progress_bar.value = progress * 100.0

func finish(success: bool) -> void:
	active = false
	finished.emit(success, perfect and success)
