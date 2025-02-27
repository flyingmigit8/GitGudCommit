class_name Player
extends CharacterBody2D

const WALK_SPEED = 300.0
const ACCELERATION_SPEED = WALK_SPEED * 6.0
const JUMP_VELOCITY = -950.0
const MAX_CHARGE_TIME = 1.0
const MAX_POWER = 100
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
@onready var text_particles := $TextParticles as CPUParticles2D
@onready var particles_container := $ParticlesContainer as Control
@onready var current_i_label := $UI/CurrentILabel as Label


var _is_charging_jump := false
var _charge_time := 0.0
var code_texts = ["printf()", "console.log()", "print()", "System.out.println()", "cout<<", "Debug.Log()", "echo", "fmt.Println()"]

func _ready() -> void:
	text_particles.emitting = false
	update_power_loop_label(0)


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("jump" + action_suffix):
		_start_charging_jump()
	elif Input.is_action_just_released("jump" + action_suffix):
		_stop_charging_jump()

	if _is_charging_jump:
		_charge_time += delta
		_update_charge_bar()

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

func _stop_charging_jump() -> void:
	if _is_charging_jump:
		_is_charging_jump = false
		try_jump()
		charge_bar.value = 0;
		update_power_loop_label(0)

func try_jump() -> void:
	if is_on_floor():
		jump_sound.pitch_scale = 1.0
	else:
		 # Only allow jumping when on the floor
		return 

	# Calculate jump velocity based on charge time
	var charge_ratio: float = min(_charge_time / MAX_CHARGE_TIME, 1.0)
	var jump_velocity: float = JUMP_VELOCITY * charge_ratio
	jump_velocity = max(jump_velocity, MIN_JUMP_VELOCITY)

	velocity.y = jump_velocity
	jump_sound.play()
	
	# increase particles per charge
	var num_particles = 1 + int(charge_ratio * 3)
	for i in range(num_particles):
		emit_text_particles(charge_ratio)

func _update_charge_bar() -> void:
	var charge_ratio : float = min(_charge_time / MAX_CHARGE_TIME, 1.0)
	charge_bar.value = charge_ratio * 100
	var current_i = floor(charge_ratio * MAX_POWER)
	update_power_loop_label(current_i)

func emit_text_particles(charge_ratio: float) -> void:
	# Create a label node
	var label_node = get_random_text_node(charge_ratio)
	
	# Add to the particles container
	particles_container.add_child(label_node)
	
	# Set starting position (at player's feet)
	var random_x_offset = randf_range(-30, 30)
	label_node.position = Vector2(random_x_offset, 10)  # Start below player's feet
	
	# Set up a timer to remove the label after a short time
	var timer = get_tree().create_timer(1.0)
	timer.timeout.connect(func(): label_node.queue_free())

func get_random_text_node(charge_ratio: float) -> Label:
	# Create a new Label node
	var label = Label.new()
	
	# Set up the label with random text
	label.text = code_texts[randi() % code_texts.size()]
	
	# Size based on charge (bigger text for stronger jumps)
	var font_size = 16 + int(charge_ratio * 8)  # 16-24 font size
	var font = label.get_theme_font("font")
	label.add_theme_font_size_override("font_size", font_size)
	
	# Random downward velocity (propulsion effect)
	var direction = Vector2(randf_range(-0.5, 0.5), randf_range(1.0, 2.0)).normalized()
	var speed = randf_range(100, 200) * (0.8 + charge_ratio * 0.5)  # Faster for stronger jumps
	var start_pos = label.position
	
	# Set up animation for the label
	var tween = create_tween()
	tween.tween_property(label, "position", start_pos + direction * speed, 0.8)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.8)
	
	return label
	
func update_power_loop_label(current_i: int) -> void:
	current_i_label.text =  "i = " + str(current_i)
