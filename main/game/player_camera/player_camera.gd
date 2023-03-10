class_name PlayerCamera
extends Camera3D

@export var game_room: GameRoom
@export var hitbox: Area3D
@export var mouse_sensitivity = 0.002

@onready var cursor: Control = get_tree().get_root().get_node("Main/UI/CursorMenu")

var selected_card: Area3D
var locked: bool = true

signal card_selected(card: MeshInstance3D)

func _ready() -> void:
	hitbox.area_entered.connect(_on_area_entered)
	hitbox.area_exited.connect(_on_area_exited)

func _unhandled_input(event) -> void:
	if not locked and event is InputEventMouseMotion:
		get_parent().rotate_y(-event.relative.x * mouse_sensitivity)
		rotate_x(-event.relative.y * mouse_sensitivity)
		rotation.x = clamp(rotation.x, -1.1, 1.1)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and selected_card != null:
		_on_card_selected()
	if event.is_action_pressed("lock", false):
		if locked:
			unlock_movement()
		else:
			lock_movement()

func _on_area_entered(area: Area3D) -> void:
	area.get_parent().select()
	if is_instance_valid(selected_card):
		selected_card.get_parent().deselect()
	selected_card = area

func _on_area_exited(area: Area3D) -> void:
	if area == selected_card:
		selected_card.get_parent().deselect()
		selected_card = null

func _on_card_selected() -> void:
	card_selected.emit(selected_card.get_parent())
	selected_card.get_parent().deselect()
	selected_card = null

func unlock_movement() -> void:
	locked = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(cursor, "modulate:a", 0.5, 0.1)

func lock_movement() -> void:
	locked = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(cursor, "modulate:a", 0.0, 0.1)

# Returns the first card selected by the player that follows the argument restrictions
# Output value is an array of a reference to the card model and the card data itself
func select_card(suit: Card.Suit, trump: Card.Suit, counter_allowed: bool) -> Array:
	var card: Array
	var card_model: MeshInstance3D
	while true:
		card_model = await card_selected
		card = [card_model.suit, card_model.number]
		
		var valid_suit: bool = true
		
		if card[0] == suit or suit == -1:
			pass
		# If a trump is played, ensure that no cards of the main suit exist in the deck
		elif card[0] == trump or card[0] == 0:
			for player_card in game_room.lobby.decks[game_room.player_idx]:
				if player_card == card:
					continue
				if player_card[0] == suit:
					valid_suit = false
					break
		# If a non-suit and non-trump is played, ensure that there are no cards of the trump or main suit in the deck
		else:
			for player_card in game_room.lobby.decks[game_room.player_idx]:
				if player_card == card:
					continue
				if player_card[0] == suit or player_card[0] == trump or player_card[0] == 0:
					valid_suit = false
					break
		
		if valid_suit and (counter_allowed or not card[1] in [5, 10, 14, 1, 0]):
			break
	return [card_model, card]
