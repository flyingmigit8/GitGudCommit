extends CharacterBody2D

enum State {
	WALKING,
}

const WALK_SPEED = 22.0
const KNOCKBACK_FORCE = 600  # Strength of the knockback
const PLAYER_BOUNCE_FORCE = -600  # Adjust bounce height

var _state := State.WALKING

@onready var gravity: int = ProjectSettings.get("physics/2d/default_gravity")
@onready var floor_detector_left := $FloorDetectorLeft as RayCast2D
@onready var floor_detector_right := $FloorDetectorRight as RayCast2D
@onready var collision_sound := $AudioStreamPlayer2D as AudioStreamPlayer2D

func _physics_process(delta: float) -> void:
	if _state == State.WALKING and velocity.is_zero_approx():
		velocity.x = WALK_SPEED
	velocity.y += gravity * delta

	# Enemy platform detection
	if not floor_detector_left.is_colliding():
		velocity.x = WALK_SPEED
	elif not floor_detector_right.is_colliding():
		velocity.x = -WALK_SPEED

	if is_on_wall():
		velocity.x = -velocity.x
		
	move_and_slide()
	
	# Check for collisions with player
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is Player:
			handle_player_collision(collider, collision.get_normal())

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
