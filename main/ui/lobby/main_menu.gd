class_name MainMenu
extends Submenu

@export var title: Control
@export var join_button: Button
@export var create_button: Button

func _ready() -> void:
	join_button.modulate.a = 0
	create_button.modulate.a = 0
	
	toggle_input(false)

func enter() -> void:
	super.enter()
	
	var tween: Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(title, "custom_minimum_size:y", 0.0, 0.2)
	
	await tween.finished
	
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(join_button, "modulate:a", 1.0, 0.1)
	tween.tween_property(create_button, "modulate:a", 1.0, 0.15)
	
	toggle_input(true)

func toggle_input(input_enabled: bool) -> void:
	super.toggle_input(input_enabled)
	join_button.disabled = not input_enabled
	create_button.disabled = not input_enabled
