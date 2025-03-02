class_name Player
extends CharacterBody2D

# Constants
const WALK_SPEED = 300.0
const ACCELERATION_SPEED = WALK_SPEED * 6.0
const JUMP_VELOCITY = -900.0
const MAX_CHARGE_TIME = 1.2
const MAX_POWER = 100
const MIN_JUMP_VELOCITY = -600.0
const TERMINAL_VELOCITY = 700
const STUN_DURATION := 0.5

# Exports
@export var action_suffix := ""

# Nodes
var gravity: int = ProjectSettings.get("physics/2d/default_gravity")
@onready var platform_detector := $PlatformDetector as RayCast2D
@onready var jump_sound := $Jump as AudioStreamPlayer2D
@onready var camera := $Camera as Camera2D
@onready var charge_bar := $UI/ChargeBar as TextureProgressBar
@onready var text_particles := $TextParticles as CPUParticles2D
@onready var particles_container := $ParticlesContainer as Control
@onready var current_i_label := $UI/CurrentILabel as Label
@onready var animated_sprite := $AnimatedDuck as AnimatedSprite2D

# Class Variables
var _is_charging_jump := false
var _charge_time := 0.0
var code_texts := ["printf()", "console.log()", "print()", "System.out.println()", "cout<<", "Debug.Log()", "echo", "fmt.Println()"]
var _stunned := false
var _stun_timer := 0.0

var initial_position : Vector2

func _ready() -> void:
	text_particles.emitting = false
	update_power_loop_label(0)
	initial_position = animated_sprite.position



func apply_bounce(bounce_force: float) -> void:
	velocity.y = bounce_force  # Apply upward force
	_stunned = true
	_stun_timer = 0.0
	move_and_slide()


func apply_knockback(force: Vector2) -> void:
	velocity = force
	_stunned = true
	_stun_timer = 0.0
	move_and_slide()


func _physics_process(delta: float) -> void:
	# Update stun timer if stunned
	if _stunned:
		_stun_timer += delta
		if _stun_timer >= STUN_DURATION:
			_stunned = false

	if Input.is_action_just_pressed("jump" + action_suffix) and not _stunned:
		_start_charging_jump()
	elif Input.is_action_just_released("jump" + action_suffix):
		_stop_charging_jump()

	if _is_charging_jump:
		_charge_time += delta
		_update_charge_bar()
		var charge_ratio: float = min(_charge_time / MAX_CHARGE_TIME, 1.0)
		
		# Calculate the new scale based on charge ratio
		var new_scale = 2 - (charge_ratio * (2 - 1))
		
		# Apply the scale
		animated_sprite.scale.y = new_scale
		
		# Adjust position to keep feet on the ground
		var height_offset = (1.0 - new_scale) * animated_sprite.get_sprite_frames().get_frame_texture("default", 0).get_height()
		animated_sprite.position.y = 0 + height_offset * 0.5
	else:
		animated_sprite.position = initial_position
		animated_sprite.scale.y = 2
		
	# Fall.
	velocity.y = minf(TERMINAL_VELOCITY, velocity.y + gravity * delta)

	# Only allow horizontal movement when not stunned
	if _stunned:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION_SPEED * 0.05 * delta)
	elif _is_charging_jump:
		velocity.x = 0
	else:
		var direction := Input.get_axis("move_left" + action_suffix, "move_right" + action_suffix) * WALK_SPEED
		velocity.x = move_toward(velocity.x, direction, ACCELERATION_SPEED * delta)

	if not is_zero_approx(velocity.x):
		if velocity.x > 0.0:
			animated_sprite.scale.x = 2.0
		else:
			animated_sprite.scale.x = -2.0

	floor_stop_on_slope = not platform_detector.is_colliding()
	move_and_slide()

	var animation := get_new_animation()
	if animation != animated_sprite.get_animation():
		animated_sprite.play(animation)


func get_new_animation() -> StringName:
	var animation_new: StringName
	if is_on_floor():
		if absf(velocity.x) > 0.1:
			animation_new = "run"
		elif _is_charging_jump:
			animation_new = "charge"
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


func _stop_charging_jump() -> void:
	if _is_charging_jump:
		_is_charging_jump = false
		try_jump()
		charge_bar.value = 0;
		update_power_loop_label(0)
		animated_sprite.scale.y = 2.0


func try_jump() -> void:
	if is_on_floor():
		jump_sound.pitch_scale = 1.0
	else:
		return 

	# Calculate jump velocity based on charge time
	var charge_ratio: float = min(_charge_time / MAX_CHARGE_TIME, 1.0)
	var jump_velocity: float = MIN_JUMP_VELOCITY + (JUMP_VELOCITY - MIN_JUMP_VELOCITY) * charge_ratio
	velocity.y = jump_velocity
	jump_sound.play()
	
	# increase particles per charge
	var num_particles : int = 1 + int(charge_ratio * 3)
	for i in range(num_particles):
		emit_text_particles(charge_ratio)


func _update_charge_bar() -> void:
	var charge_ratio : float = min(_charge_time / MAX_CHARGE_TIME, 1.0)
	charge_bar.value = charge_ratio * 100
	var current_i : int = floor(charge_ratio * MAX_POWER)
	update_power_loop_label(current_i)


func emit_text_particles(charge_ratio: float) -> void:
	# Create a label node
	var label_node: Label = get_random_text_node(charge_ratio)

	# Add to the particles container
	particles_container.add_child(label_node)

	# Set starting position (near player's feet with slight randomness)
	label_node.position = Vector2(randf_range(-20, 0), 10)

	# Apply propulsion effect
	animate_particle(label_node, charge_ratio)

func get_random_text_node(charge_ratio: float) -> Label:
	# Create a new Label node
	var label = Label.new()
	
	# Set up the label with random text
	label.text = code_texts[randi() % code_texts.size()]
	
	# Size based on charge (bigger text for stronger jumps)
	var font_size = 16 + int(charge_ratio * 8)  # 16-24 font size
	var font = label.get_theme_font("font")
	label.add_theme_font_size_override("font_size", font_size)
	
	return label

func animate_particle(label: Label, charge_ratio: float) -> void:
	# Calculate propulsion direction (opposite to jump)
	var propulsion_angle = randf_range(PI / 4, 3 * PI / 4)  # Spread downward
	var direction = Vector2(cos(propulsion_angle), sin(propulsion_angle)).normalized()

	# Speed based on charge ratio
	var speed = randf_range(100, 250) * (0.8 + charge_ratio * 0.5)

	# Set up animation for the label
	var tween = create_tween()
	tween.tween_property(label, "position", label.position + direction * speed, 0.8)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.8)

	# Remove label after animation
	var timer = get_tree().create_timer(1.0)
	timer.timeout.connect(func():
		if is_instance_valid(label):
			label.queue_free()
	)

	
	
func update_power_loop_label(current_i: int) -> void:
	current_i_label.text =  "i = " + str(current_i)
