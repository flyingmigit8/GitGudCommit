extends Area2D

@export var victory_screen_scene: PackedScene

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Get the game instance
	var game = get_tree().current_scene
	
	# Create the victory screen instance
	var victory_screen = victory_screen_scene.instantiate()
	
	# Get the final time before adding the victory screen
	var final_time = ""
	final_time = game.get_final_time()
	
	# Add the victory screen to the scene
	get_tree().current_scene.add_child(victory_screen)
	
	# Now set the final time AFTER it's added to the scene tree
	if final_time != "":
		victory_screen.set_final_time(final_time)
	
	game.hide_stopwatch_ui()
