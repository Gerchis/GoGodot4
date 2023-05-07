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

var movement_direction := 0.0
var stored_jump := false
var is_jumping := false
var is_falling : bool :
	get: return velocity.y > 0
var jumps_done := 0

@onready var jump_buffer_timer := $JumpBufferTimer
@onready var coyote_time := $CoyoteTime

func _ready():
	jump_buffer_timer.timeout.connect(discard_jump_input)
	coyote_time.timeout.connect(coyote_timeout)

func _process(delta):
	get_movement_input()
	get_jump_input()

func _physics_process(delta):
	calculate_gravity(delta)
	
	calculate_movement(delta)
	
	jump()
	jump_check()
	
	move_and_slide()

func get_movement_input():
	movement_direction = 0.0 
	
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

func jump():
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
