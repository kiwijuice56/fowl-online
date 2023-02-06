extends Node

var profile_images: Array[Texture2D]
var card_colors: Array[Color]

func _ready() -> void:
	var dir: PackedStringArray = DirAccess.get_files_at("res://main/ui/profile_images/")
	for file in dir:
		if not file.ends_with(".png"):
			continue
		profile_images.append(ResourceLoader.load("res://main/ui/profile_images/" + file))
	
	card_colors.append(Color("ff4596"))
	card_colors.append(Color("ffdb4a"))
	card_colors.append(Color("00c5cf"))
	card_colors.append(Color("7150d4"))
