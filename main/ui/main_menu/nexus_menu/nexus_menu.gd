class_name NexusMenu
extends Menu

@export var title: Control
@export var join_button: Button
@export var create_button: Button
@export var profile_button: Button
@export var music_button: Button
@export var gfx_button: Button

signal profile_selected
signal join_selected
signal create_selected

func _ready() -> void:
	join_button.modulate.a = 0
	create_button.modulate.a = 0
	profile_button.modulate.a = 0
	gfx_button.modulate.a = 0
	music_button.modulate.a = 0
	
	profile_button.pressed.connect(emit_signal.bind("profile_selected"))
	join_button.pressed.connect(emit_signal.bind("join_selected"))
	create_button.pressed.connect(emit_signal.bind("create_selected"))
	gfx_button.pressed.connect(_gfx_selected)
	music_button.pressed.connect(_music_selected)
	toggle_input(false)

func _music_selected() -> void:
	var music: AudioStreamPlayer = get_tree().get_root().get_node("Main/Music")
	music.playing = not music.playing

func _gfx_selected() -> void:
	var container: SubViewportContainer = get_tree().get_root().get_node("Main/ViewportContainer")
	container.stretch_shrink = 4 if container.stretch_shrink == 1 else 1

func enter() -> void:
	super.enter()
	
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(join_button, "modulate:a", 1.0, 0.1)
	tween.tween_property(create_button, "modulate:a", 1.0, 0.1)
	tween.tween_property(profile_button, "modulate:a", 1.0, 0.1)
	tween.tween_property(music_button, "modulate:a", 1.0, 0.1)
	tween.tween_property(gfx_button, "modulate:a", 1.0, 0.1)
	show_title()
	
	await tween.finished
	toggle_input(true)

func exit() -> void:
	super.exit()
	toggle_input(false)
	
	var tween: Tween = create_tween().set_parallel(true)
	
	tween.tween_property(join_button, "modulate:a", 0.0, 0.1)
	tween.tween_property(create_button, "modulate:a", 0.0, 0.1)
	tween.tween_property(profile_button, "modulate:a", 0.0, 0.1)
	tween.tween_property(gfx_button, "modulate:a", 0.0, 0.1)
	tween.tween_property(music_button, "modulate:a", 0.0, 0.1)
	
	await tween.finished

func toggle_input(input_enabled: bool) -> void:
	join_button.disabled = not input_enabled
	create_button.disabled = not input_enabled
	profile_button.disabled = not input_enabled
	
	var filter: int = Control.MOUSE_FILTER_STOP if input_enabled else Control.MOUSE_FILTER_IGNORE
	
	join_button.mouse_filter = filter
	create_button.mouse_filter = filter
	profile_button.mouse_filter = filter
	music_button.mouse_filter = filter
	gfx_button.mouse_filter = filter
	
	super.toggle_input(input_enabled)

func hide_title() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(title, "modulate:a", 0.0, 0.1)

func show_title() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(title, "modulate:a", 1.0, 0.1)
