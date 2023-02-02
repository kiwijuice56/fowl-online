class_name UserPanel
extends HBoxContainer

@export var name_label: Label
@export var icon_rect: TextureRect

func initialize(player_name: String, icon: int, is_player: bool) -> void:
	name_label.text = player_name
	if is_player:
		name_label.text += " (me)"
	icon_rect.texture = ProfileImages.images[icon]

func set_blank() -> void:
	name_label.text = ""
	icon_rect.visible = false
