class_name MainMenu
extends Submenu

@export var title: Control
@export var join_button: Button
@export var create_button: Button
@export var profile_button: Button

signal profile_selected

func _ready() -> void:
	join_button.modulate.a = 0
	create_button.modulate.a = 0
	profile_button.modulate.a = 0
	
	profile_button.pressed.connect(emit_signal.bind("profile_selected"))
	
	toggle_input(false)

func enter() -> void:
	super.enter()
	
	var tween: Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(title, "custom_minimum_size:y", 0.0, 0.2)
	
	await tween.finished
	
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(join_button, "modulate:a", 1.0, 0.025)
	tween.tween_property(create_button, "modulate:a", 1.0, 0.025)
	tween.tween_property(profile_button, "modulate:a", 1.0, 0.025)
	
	await tween.finished
	toggle_input(true)

func exit() -> void:
	super.exit()
	toggle_input(false)
	
	var tween: Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN)
	
	tween.tween_property(join_button, "modulate:a", 0.0, 0.025)
	tween.tween_property(create_button, "modulate:a", 0.0, 0.025)
	tween.tween_property(profile_button, "modulate:a", 0.0, 0.025)
	tween.tween_property(title, "custom_minimum_size:y", 400.0, 0.2)
	
	await tween.finished

func toggle_input(input_enabled: bool) -> void:
	super.toggle_input(input_enabled)
	join_button.disabled = not input_enabled
	create_button.disabled = not input_enabled
	profile_button.disabled = not input_enabled
