class_name UserPanel
extends HBoxContainer

@export var name_label: Label
@export var icon: TextureRect

func initialize(name: String, icon: int, is_player: bool) -> void:
	name_label.text = name
	if is_player:
		name_label.text += " (me)"

func set_blank() -> void:
	name_label.text = ""
	icon.visible = false
