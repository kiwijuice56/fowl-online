class_name PlayerCamera
extends Camera3D

@export var hitbox: Area3D
@export var mouse_sensitivity = 0.002

var selected_card: Area3D

signal card_selected(card: MeshInstance3D)

func _ready() -> void:
	hitbox.area_entered.connect(_on_area_entered)
	hitbox.area_exited.connect(_on_area_exited)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event) -> void:
	if event is InputEventMouseMotion:
		get_parent().rotate_y(-event.relative.x * mouse_sensitivity)
		rotate_x(-event.relative.y * mouse_sensitivity)
		rotation.x = clamp(rotation.x, -1.1, 1.1)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and selected_card != null:
		select_card()

func _on_area_entered(area: Area3D) -> void:
	area.get_parent().select()
	if is_instance_valid(selected_card):
		selected_card.get_parent().deselect()
	selected_card = area

func _on_area_exited(area: Area3D) -> void:
	if area == selected_card:
		selected_card.get_parent().deselect()
		selected_card = null

func select_card() -> void:
	card_selected.emit(selected_card.get_parent())
	selected_card = null
