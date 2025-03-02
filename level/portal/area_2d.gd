extends Area2D

@export var victory_screen_scene: PackedScene

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Get the game instance
	var game = get_tree().current_scene
	game.hide_stopwatch_ui()
	get_tree().change_scene_to_file("res://gui/victory_screen.tscn")
	
