extends Node

var player_name := ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  SilentWolf.configure({
	"api_key": "0nbZ3mHsGl7qdR6zF1Jy8a1BvOnRRr3B1UcfXvIS",
	"game_id": "bug-hunt12",
	"log_level": 1
  })

  SilentWolf.configure_scores({
	"open_scene_on_close": "res://gui/title/title.tscn"
  })
