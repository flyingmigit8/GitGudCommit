class_name Player
extends CharacterBody2D

const WALK_SPEED = 300.0
const ACCELERATION_SPEED = WALK_SPEED * 6.0
const JUMP_VELOCITY = -950.0
const MAX_CHARGE_TIME = 1.0
const MIN_JUMP_VELOCITY = -750.0
const TERMINAL_VELOCITY = 700

@export var action_suffix := ""

var gravity: int = ProjectSettings.get("physics/2d/default_gravity")
@onready var platform_detector := $PlatformDetector as RayCast2D
@onready var animation_player := $AnimationPlayer as AnimationPlayer
@onready var sprite := $Sprite2D as Sprite2D
@onready var jump_sound := $Jump as AudioStreamPlayer2D
@onready var camera := $Camera as Camera2D
@onready var charge_bar := $UI/ChargeBar as TextureProgressBar

var _is_charging_jump := false
var _charge_time := 0.0

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("jump" + action_suffix):
		_start_charging_jump()
	elif Input.is_action_just_released("jump" + action_suffix):
		_stop_charging_jump()

	if _is_charging_jump:
		_charge_time += delta
		_update_charge_bar()  # Update the charge bar while charging
	else:
		_hide_charge_bar()  # Hide the charge bar when not charging

	# Fall.
	velocity.y = minf(TERMINAL_VELOCITY, velocity.y + gravity * delta)

	var direction := Input.get_axis("move_left" + action_suffix, "move_right" + action_suffix) * WALK_SPEED
	velocity.x = move_toward(velocity.x, direction, ACCELERATION_SPEED * delta)

	if not is_zero_approx(velocity.x):
		if velocity.x > 0.0:
			sprite.scale.x = 1.0
		else:
			sprite.scale.x = -1.0

	floor_stop_on_slope = not platform_detector.is_colliding()
	move_and_slide()

	var animation := get_new_animation()
	if animation != animation_player.current_animation:
		animation_player.play(animation)

func get_new_animation() -> String:
	var animation_new: String
	if is_on_floor():
		if absf(velocity.x) > 0.1:
			animation_new = "run"
		else:
			animation_new = "idle"
	else:
		if velocity.y > 0.0:
			animation_new = "falling"
		else:
			animation_new = "jumping"
	return animation_new

func _start_charging_jump() -> void:
	if is_on_floor():
		_is_charging_jump = true
		_charge_time = 0.0
		charge_bar.visible = true  # Show the charge bar when charging starts

func _stop_charging_jump() -> void:
	if _is_charging_jump:
		_is_charging_jump = false
		try_jump()
		#_hide_charge_bar()  # Hide the charge bar when charging stops

func try_jump() -> void:
	if is_on_floor():
		jump_sound.pitch_scale = 1.0
	else:
		return  # Only allow jumping when on the floor

	# Calculate jump velocity based on charge time
	var charge_ratio: float = min(_charge_time / MAX_CHARGE_TIME, 1.0)
	var jump_velocity: float = JUMP_VELOCITY * charge_ratio
	jump_velocity = max(jump_velocity, MIN_JUMP_VELOCITY)  # Ensure minimum jump height

	velocity.y = jump_velocity
	jump_sound.play()

func _update_charge_bar() -> void:
	var charge_ratio : float = min(_charge_time / MAX_CHARGE_TIME, 1.0)
	charge_bar.value = charge_ratio * 100

func _hide_charge_bar() -> void:
	charge_bar.visible = false
