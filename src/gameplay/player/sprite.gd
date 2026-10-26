extends Node

@onready var player_sprite: AnimatedSprite2D = $"../../Player sprite"
@onready var hand: AnimatedSprite2D = $"../../Hand"


var horiz_dir: float = 0.0
var vert_dir: float = 0.0

func update():
	if horiz_dir == 0:
		player_sprite.play("Idle")
		hand.play("Idle")
	
	if horiz_dir == -1:
		player_sprite.play("Walk")
		hand.play("Walk")
		player_sprite.flip_h = true
		hand.flip_h = true
	elif horiz_dir == 1:
		player_sprite.play("Walk")
		hand.play("Walk")
		player_sprite.flip_h = false
		hand.flip_h = false
