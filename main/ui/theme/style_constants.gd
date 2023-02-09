extends Node

var profile_images: Array[Texture2D]
var card_colors: Array[Color]

func _ready() -> void:
	for i in range(1, 12):
		profile_images.append(ResourceLoader.load("res://main/ui/theme/profile_images/profile%d.png" % i))
	
	card_colors.append(Color("ff4596"))
	card_colors.append(Color("ffdb4a"))
	card_colors.append(Color("00c5cf"))
	card_colors.append(Color("7150d4"))
	card_colors.append(Color("000000"))
