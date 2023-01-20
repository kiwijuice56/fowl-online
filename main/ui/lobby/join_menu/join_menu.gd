class_name JoinMenu
extends Submenu

@export var go_button: Button
@export var quit_button: Button
@export var code_line: LineEdit
@export var error_label: Label

@export_multiline var empty_code_error: String
@export_multiline var no_matching_code_error: String

signal game_joined(code: String)
signal join_abandoned

func _ready() -> void:
	toggle_input(false)
	
	error_label.text = ""
	go_button.modulate.a = 0
	code_line.modulate.a = 0
	quit_button.modulate.a = 0
	
	go_button.pressed.connect(_on_go_selected) 
	quit_button.pressed.connect(emit_signal.bind("join_abandoned"))

func _on_go_selected() -> void:
	game_joined.emit(code_line.text)

func display_error(error: String) -> void:
	error_label.text = error

func enter() -> void:
	super.enter()
	
	error_label.text = ""
	
	var tween: Tween = create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_IN)
	
	tween.tween_property(go_button, "modulate:a", 1.0, 0.05)
	tween.tween_property(quit_button, "modulate:a", 1.0, 0.05)
	tween.tween_property(code_line, "modulate:a", 1.0, 0.05)
	tween.tween_property(error_label, "modulate:a", 1.0, 0.05)
	
	await tween.finished
	toggle_input(true)

func exit() -> void:
	super.exit()
	toggle_input(false)
	
	var tween: Tween = create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_IN)
	
	tween.tween_property(go_button, "modulate:a", 0.0, 0.05)
	tween.tween_property(quit_button, "modulate:a", 0.0, 0.05)
	tween.tween_property(code_line, "modulate:a", 0.0, 0.05)
	tween.tween_property(error_label, "modulate:a", 0.0, 0.05)
	
	await tween.finished

func toggle_input(input_enabled: bool) -> void:
	code_line.editable = input_enabled
	go_button.disabled = not input_enabled
	
	var filter: int = Control.MOUSE_FILTER_STOP if input_enabled else Control.MOUSE_FILTER_IGNORE
	code_line.mouse_filter = filter
	go_button.mouse_filter = filter
	quit_button.mouse_filter = filter
	
	super.toggle_input(input_enabled)
