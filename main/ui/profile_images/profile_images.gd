extends Node

var images: Array[Texture2D]

func _ready() -> void:
	var dir: PackedStringArray = DirAccess.get_files_at("res://main/ui/profile_images/")
	for file in dir:
		if not file.ends_with(".png"):
			continue
		images.append(ResourceLoader.load("res://main/ui/profile_images/" + file))
