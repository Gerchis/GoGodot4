extends Area2D


func _on_body_entered(body):
	if body is CharacterController:
		var player = body as CharacterController
		player.touching_ladder = self

func _on_body_exited(body):
	if body is CharacterController:
		var player = body as CharacterController
		player.touching_ladder = null
