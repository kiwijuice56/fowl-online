extends SubViewportContainer

@export var game_room: GameRoom
func _ready():
	set_process_unhandled_input(true)

func _input(event):
	# fix by ArdaE https://github.com/godotengine/godot/issues/17326#issuecomment-431186323
	if event is InputEventMouse:
		var mouse_event: InputEventMouse = event.duplicate()
		mouse_event.position = get_global_transform_with_canvas().affine_inverse() * event.position
		game_room.camera._unhandled_input(mouse_event)
