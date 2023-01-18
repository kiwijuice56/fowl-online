class_name CharacterMenu
extends Submenu

@export var go_button: Button
@export var left_button: Button
@export var right_button: Button
@export var player_icon: TextureRect
@export var username: LineEdit

func _ready() -> void:
	go_button.pressed.connect(exit)

func exit() -> void:
	super.exit()
	toggle_input(false)
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.1)

func toggle_input(input_enabled: bool) -> void:
	go_button.disabled = not input_enabled
	left_button.disabled = not input_enabled
	right_button.disabled = not input_enabled
	username.editable = input_enabled

