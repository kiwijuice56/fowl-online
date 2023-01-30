extends Camera3D

@export var mouse_sensitivity = 0.002

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event) -> void:
	if event is InputEventMouseMotion:
		get_parent().rotate_y(-event.relative.x * mouse_sensitivity)
		rotate_x(-event.relative.y * mouse_sensitivity)
		rotation.x = clamp(rotation.x, -1.1, 1.1)
