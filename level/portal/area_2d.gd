extends Area2D

@export var victory_screen_scene: PackedScene

func _ready() -> void:
	# Connect the signal to the function
	connect("body_entered", _on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	var victory_screen = victory_screen_scene.instantiate()
	# Add it to the current scene
	get_tree().current_scene.add_child(victory_screen)
