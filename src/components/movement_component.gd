class_name Movement_component
extends Node

@export var body: CharacterBody2D

var walk_speed = 20
var horizontal_direction: float = 0.0
var vertical_direction: float = 0.0

func update():
	body.velocity.x = lerp(body.velocity.x, horizontal_direction * walk_speed, 0.2)
	body.velocity.y = lerp(body.velocity.y, vertical_direction * walk_speed, 0.2)
