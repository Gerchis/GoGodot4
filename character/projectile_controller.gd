extends Area2D

@export_category("ProjectileSettings")
@export var projectile_speed := 800.0

var initial_direction := Vector2.ZERO

@onready var lifespan := $Lifespan

func _ready():
	lifespan.timeout.connect(kill_projectile)

func _physics_process(delta):
	global_translate(initial_direction.normalized() * projectile_speed * delta)

func kill_projectile():
	queue_free()
