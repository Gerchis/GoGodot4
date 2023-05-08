extends CharacterBody2D

const MAX_GRAVITY = 2000

@export_category("MovementSettings")
@export var max_speed := 500.0
@export var accel := 1500.0
@export var friction := 3000.0
@export_category("JumpSettings")
@export var gravity := 1700.0
@export var jump_force := 900.0
@export var jumps_availables := 1
@export_range(0, 1.0) var min_jump_force := 0.5
@export_category("ProjectileSettings")
@export var projectile_scene : PackedScene

var movement_direction := 0.0
var stored_jump := false
var is_jumping := false
var is_falling : bool :
	get: return velocity.y > 0
var jumps_done := 0
var enable_movement := true

@onready var jump_buffer_timer := $JumpBufferTimer
@onready var coyote_time := $CoyoteTime
@onready var shoot_point_right := $ShootPointRight
@onready var shoot_point_left := $ShootPointLeft
@onready var fire_rate := $FireRate
@onready var sprite := $CharacterSprite
@onready var animation_controller := $CharacterSprite/AnimationTree

func _ready():
	jump_buffer_timer.timeout.connect(discard_jump_input)
	coyote_time.timeout.connect(coyote_timeout)
	fire_rate.timeout.connect(unfreeze)

func _process(delta):
	movement_direction = 0.0 
	
	handle_animations()
	
	if enable_movement:
		get_movement_input()
		get_jump_input()
	
	if enable_movement:
		face_direction()
	
	shoot()

func _physics_process(delta):
	calculate_gravity(delta)
	
	calculate_movement(delta)
	
	apply_jump()
	
	jump_check()
	
	move_and_slide()

func get_movement_input():	
	if Input.is_action_pressed("right"):
		movement_direction += 1.0
	if Input.is_action_pressed("left"):
		movement_direction -= 1.0

func calculate_movement(_delta):
	var actual_accel = accel
	var target_speed = movement_direction * max_speed
	
	if target_speed == 0 or abs(velocity.x - target_speed) > abs(target_speed):
		actual_accel = friction
	
	var movement_velocity = move_toward(velocity.x, target_speed, actual_accel * _delta)
	
	velocity.x = movement_velocity

func calculate_gravity(_delta):
	velocity.y += gravity * _delta
	velocity.y = min(velocity.y, MAX_GRAVITY)

func get_jump_input():
	if Input.is_action_just_pressed("jump"):
		stored_jump = true
		jump_buffer_timer.start()

func apply_jump():
	if stored_jump and jumps_done < jumps_availables:
		is_jumping = true
		stored_jump = false
		jump_buffer_timer.stop()
		coyote_time.stop()
		jumps_done += 1
		velocity.y = -jump_force

func jump_check():
	if is_on_floor() and is_falling:
		is_jumping = false
		jumps_done = 0
		coyote_time.stop()
	
	if !is_on_floor() and jumps_done == 0 and coyote_time.is_stopped():
		coyote_time.start()
	
	if Input.is_action_just_released("jump") and velocity.y < -jump_force * min_jump_force:
		velocity.y = -jump_force * min_jump_force

func discard_jump_input():
	stored_jump = false

func coyote_timeout():
	jumps_done += 1

func shoot():
	if Input.is_action_pressed("shoot") and fire_rate.is_stopped() and is_on_floor():
		fire_rate.start()
		
		var origin_point = shoot_point_left.global_position if sprite.is_flipped_h()  else shoot_point_right.global_position
		var aim_point = get_viewport().get_mouse_position()
		
		var projectile_direction = (aim_point - origin_point).normalized()
		#projectile_direction.x = min(projectile_direction.x, 0) if sprite.is_flipped_h() else max(projectile_direction.x, 0)
		
		var projectile = projectile_scene.instantiate()
		projectile.set_as_top_level(true)
		projectile.global_position = origin_point
		projectile.initial_direction = projectile_direction
		add_child(projectile)
		
		enable_movement = false
		stored_jump = false

func face_direction():
	if movement_direction > 0:
		sprite.set_flip_h(false)
	if movement_direction < 0:
		sprite.set_flip_h(true)

func unfreeze():
	enable_movement = true

func handle_animations():
	animation_controller.set("parameters/conditions/jump",is_jumping)
	animation_controller.set("parameters/conditions/idle",!is_jumping)
