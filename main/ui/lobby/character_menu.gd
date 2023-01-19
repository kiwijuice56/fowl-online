class_name CharacterMenu
extends Submenu

@export var go_button: Button
@export var left_button: Button
@export var right_button: Button
@export var player_icon: TextureRect
@export var username: LineEdit

signal go_selected

func _ready() -> void:
	go_button.pressed.connect(emit_signal.bind("go_selected"))

func exit() -> void:
	super.exit()
	toggle_input(false)
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.025)

func enter() -> void:
	super.enter()
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.025)
	
	await tween.finished
	toggle_input(true)

func toggle_input(input_enabled: bool) -> void:
	super.toggle_input(input_enabled)
	
	go_button.disabled = not input_enabled
	left_button.disabled = not input_enabled
	right_button.disabled = not input_enabled
	username.editable = input_enabled
