class_name UserPanel
extends HBoxContainer

@export var name_label: Label
@export var icon_rect: TextureRect

func initialize(player_name: String, icon: int) -> void:
	name_label.text = player_name
	icon_rect.texture = StyleConstants.profile_images[icon]

func set_blank() -> void:
	name_label.text = ""
	icon_rect.visible = false
