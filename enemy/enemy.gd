extends CharacterBody2D

enum State {
	WALKING,
	FLYING,
	STATIC
}

const WALK_SPEED = 22.0
const FLY_SPEED = 22.0
const KNOCKBACK_FORCE = 600  # Strength of the knockback
const PLAYER_BOUNCE_FORCE = -600  # Adjust bounce height

@export var is_flying: bool = false 
@export var is_static: bool = false  
var _state: State

@onready var gravity: int = ProjectSettings.get("physics/2d/default_gravity")
@onready var floor_detector_left := $FloorDetectorLeft as RayCast2D
@onready var floor_detector_right := $FloorDetectorRight as RayCast2D
@onready var wall_detector_left := $WallDetectorLeft as RayCast2D
@onready var wall_detector_right := $WallDetectorRight as RayCast2D
@onready var collision_sound := $AudioStreamPlayer2D as AudioStreamPlayer2D

func _ready() -> void:
	if is_static:
		_state = State.STATIC
		MotionMode.MOTION_MODE_FLOATING
	elif is_flying:
		_state = State.FLYING
		MotionMode.MOTION_MODE_FLOATING
	else:
		_state = State.WALKING

func _physics_process(delta: float) -> void:
	match _state:
		State.WALKING:
			handle_walking(delta)
		State.FLYING:
			handle_flying(delta)
		State.STATIC:
			handle_static(delta)

	move_and_slide()

	# Check for collisions with player
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is Player:
			handle_player_collision(collider, collision.get_normal())

func handle_walking(delta: float) -> void:
	if velocity.is_zero_approx():
		velocity.x = WALK_SPEED

	velocity.y += gravity * delta

	# Enemy platform detection
	if not floor_detector_left.is_colliding():
		velocity.x = WALK_SPEED
	elif not floor_detector_right.is_colliding():
		velocity.x = -WALK_SPEED

	if is_on_wall():
		velocity.x = -velocity.x

func handle_flying(delta: float) -> void:
	if velocity.is_zero_approx():
		velocity.x = FLY_SPEED
		
	velocity.y = 0  # No vertical movement for flying enemy

	if wall_detector_left.is_colliding():
		velocity.x = FLY_SPEED
	elif wall_detector_right.is_colliding():
		velocity.x = -FLY_SPEED
		
func handle_static(delta: float) -> void:
	velocity = Vector2.ZERO

func handle_player_collision(player: CharacterBody2D, collision_normal: Vector2):
	collision_sound.play()
	if collision_normal.y > 0.5:
		player.apply_bounce(PLAYER_BOUNCE_FORCE)
	else:
		apply_knockback_to_player(player)

func apply_knockback_to_player(player: CharacterBody2D):
	var knockback_direction = (player.global_position - global_position).normalized()
	var knockback_force = Vector2(knockback_direction.x * KNOCKBACK_FORCE, -KNOCKBACK_FORCE)
	player.apply_knockback(knockback_force)
