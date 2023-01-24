class_name LobbyMenu
extends Submenu

@export var code_label: LineEdit
@export var start_button: Button
@export var leave_button: Button
@export var user_container: PanelContainer

var is_host: bool

signal game_abandoned

func _ready() -> void:
	toggle_input(false)
	leave_button.pressed.connect(emit_signal.bind("game_abandoned"))
	visible = false

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
	start_button.disabled = not input_enabled
	leave_button.disabled = not input_enabled
	
	var filter: int = Control.MOUSE_FILTER_STOP if input_enabled else Control.MOUSE_FILTER_IGNORE
	
	start_button.mouse_filter = filter
	leave_button.mouse_filter = filter
	
	super.toggle_input(input_enabled)
