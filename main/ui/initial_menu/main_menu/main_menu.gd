class_name MainMenu
extends Submenu

@export var title: Control
@export var join_button: Button
@export var create_button: Button
@export var profile_button: Button

signal profile_selected
signal join_selected
signal create_selected

func _ready() -> void:
	join_button.modulate.a = 0
	create_button.modulate.a = 0
	profile_button.modulate.a = 0
	
	profile_button.pressed.connect(emit_signal.bind("profile_selected"))
	join_button.pressed.connect(emit_signal.bind("join_selected"))
	create_button.pressed.connect(emit_signal.bind("create_selected"))
	
	toggle_input(false)

func enter() -> void:
	super.enter()
	
	var tween: Tween = create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(title, "custom_minimum_size:y", 0.0, 0.15)
	
	await tween.finished
	
	tween = create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(join_button, "modulate:a", 1.0, 0.025)
	tween.tween_property(create_button, "modulate:a", 1.0, 0.025)
	tween.tween_property(profile_button, "modulate:a", 1.0, 0.025)
	
	await tween.finished
	toggle_input(true)

func exit() -> void:
	super.exit()
	toggle_input(false)
	
	var tween: Tween = create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_IN)
	
	tween.tween_property(join_button, "modulate:a", 0.0, 0.025)
	tween.tween_property(create_button, "modulate:a", 0.0, 0.025)
	tween.tween_property(profile_button, "modulate:a", 0.0, 0.025)
	tween.tween_property(title, "custom_minimum_size:y", 350.0, 0.15)
	
	await tween.finished

func toggle_input(input_enabled: bool) -> void:
	join_button.disabled = not input_enabled
	create_button.disabled = not input_enabled
	profile_button.disabled = not input_enabled
	
	var filter: int = Control.MOUSE_FILTER_STOP if input_enabled else Control.MOUSE_FILTER_IGNORE
	
	join_button.mouse_filter = filter
	create_button.mouse_filter = filter
	profile_button.mouse_filter = filter
	
	super.toggle_input(input_enabled)
