class_name CharacterMenu
extends Submenu

@export var go_button: Button
@export var left_button: Button
@export var right_button: Button
@export var player_icon: TextureRect
@export var username: LineEdit

signal character_confirmed

func _ready() -> void:
	go_button.pressed.connect(emit_signal.bind("character_confirmed"))

func exit() -> void:
	super.exit()
	toggle_input(false)
	
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.025)
	
	await tween.finished
	visible = false

func enter() -> void:
	super.enter()
	visible = true
	
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.025)
	
	await tween.finished
	toggle_input(true)

func toggle_input(input_enabled: bool) -> void:
	go_button.disabled = not input_enabled
	left_button.disabled = not input_enabled
	right_button.disabled = not input_enabled
	username.editable = input_enabled
	
	var filter: int = Control.MOUSE_FILTER_STOP if input_enabled else Control.MOUSE_FILTER_IGNORE
	
	go_button.mouse_filter = filter
	left_button.mouse_filter = filter
	right_button.mouse_filter = filter
	username.mouse_filter = filter
	
	super.toggle_input(input_enabled)