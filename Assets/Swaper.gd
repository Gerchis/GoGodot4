extends Area2D

@export var new_room : RoomData
@export var new_spawn : Marker2D

@onready var camera := get_viewport().get_camera_2d()

var player : CharacterController
var transition : Sprite2D

func _on_body_entered(body):
	if body is CharacterController:
		player = body as CharacterController
		transition = player.get_node("Camera2D/Transition") as Sprite2D
		
		create_tween().tween_property(transition, "modulate",Color("#000000",1), 0.5).finished.connect(set_new_room_settings)

func set_new_room_settings():
	camera.limit_top = new_room.top_limit
	camera.limit_bottom = new_room.bot_limit
	camera.limit_left = new_room.left_limit
	camera.limit_right = new_room.right_limit
	
	player.global_position = new_spawn.global_position
	
	revert_tween()

func revert_tween():
	create_tween().tween_property(transition, "modulate",Color("#000000",0), 0.3)
