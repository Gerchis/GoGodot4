extends Area2D

@export var orb_life := 4

func recive_hit(dmg):
	orb_life -= 1
	if orb_life <= 0:
		queue_free()
