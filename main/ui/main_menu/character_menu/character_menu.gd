class_name CharacterMenu
extends Menu

@export var go_button: Button
@export var left_button: Button
@export var right_button: Button
@export var player_icon: TextureRect
@export var username: LineEdit

var selected_icon: int = 0
var selected_username: String = "player"

signal character_confirmed

func _ready() -> void:
	go_button.pressed.connect(emit_signal.bind("character_confirmed"))
	left_button.pressed.connect(shift_icon.bind(-1))
	right_button.pressed.connect(shift_icon.bind(1))

func shift_icon(shift: int) -> void:
	selected_icon = (selected_icon + shift) % len(StyleConstants.profile_images)
	player_icon.texture = StyleConstants.profile_images[selected_icon]

func exit() -> void:
	super.exit()
	toggle_input(false)
	
	if len(username.text) == 0:
		selected_username = "p" + str(randi() % 100)
	else:
		selected_username = username.text.substr(0, 4)
	
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.1)
	
	await tween.finished
	visible = false

func enter() -> void:
	super.enter()
	visible = true
	
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.1)
	
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
