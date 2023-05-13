extends Area2D

@export_category("ProjectileSettings")
@export var projectile_speed := 1200.0

var damage

var initial_direction := Vector2.ZERO

@onready var lifespan := $Lifespan

func _ready():
	lifespan.timeout.connect(kill_projectile)

func _physics_process(delta):
	global_translate(initial_direction.normalized() * projectile_speed * delta)

func kill_projectile():
	queue_free()

func _on_area_entered(area):
	if area.is_in_group("hitable"):
		area.recive_hit(damage)
		for prticles in $Particulas.get_children():
			prticles.restart()
			$Icon.hide()
			$CollisionShape2D.set_disabled(true)



