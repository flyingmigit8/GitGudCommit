class_name Platform
extends AnimatableBody2D

@export var platform_text := "<platform/>"
@export var font_size := 24
@export var color := Color(0.2, 0.8, 0.2, 1.0)  # Default to a nice green
@export_enum("Normal", "Bouncy", "Moving", "Temporary") var platform_type := "Normal"
@export var bounce_strength := 1200.0
@export var move_distance_x := 0.0
@export var move_distance_y := 200.0
@export var move_speed := 2.0
@export var temp_duration := 1.0

@onready var label = $Label
@onready var collision_shape = $CollisionShape2D

var initial_position := Vector2.ZERO

func _ready():
	initial_position = global_position
	
	# Set up the label
	label.text = platform_text
	label.add_theme_font_size_override("font_size", font_size)
	label.modulate = color
	
	# Size the collision shape to match text
	var font = label.get_theme_font("font")
	var rect_size = Vector2(
		font.get_string_size(platform_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x,
		font_size
	)
	
	rect_size.y += 10

	# Update collision shape
	var shape = RectangleShape2D.new()
	shape.size = rect_size
	collision_shape.shape = shape
	collision_shape.position.y += rect_size.y * 0.35

	# Center the label on the platform
	label.position = -rect_size / 2
