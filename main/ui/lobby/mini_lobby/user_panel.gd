class_name UserPanel
extends HBoxContainer

@export var name_label: Label
@export var icon: TextureRect

func initialize(name: String, icon: int, is_host: bool, is_player: bool) -> void:
	name_label.text = name
	if is_host and is_player:
		name_label.text += " (host, me)"
	elif is_host:
		name_label.text += " (host)"
	elif is_player:
		name_label.text += " (me)"

func set_blank() -> void:
	name_label.text = ""
	icon.visible = false
