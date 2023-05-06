extends CharacterBody2D

@export_category("movement_settings")
@export var max_speed := 300.0
@export var accel := 500.0
@export var friction := 700.0

var movement_direction := 0.0

func get_movement_input():
	movement_direction = 0.0 
	
	if Input.is_action_pressed("right"):
		movement_direction += 1.0
	if Input.is_action_pressed("left"):
		movement_direction -= 1.0

func calculate_movement():
	pass
