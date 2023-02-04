class_name GameDeck
extends Node3D
# Manages the visual representation of the player decks

@onready var game_room: GameRoom = get_parent()

@export var sounds: Node
@export var timer: Timer

@export var card_scene: PackedScene

@export var deck_offset: Vector2 = Vector2(0.01, 0.0018)
@export var deck_imperfection: float = 0.01
@export var deal_duration: float = 0.3
@export var deal_delay: float = 0.06

@export var hand_span: float = PI / 1.8
@export var hand_radius: float = 0.5
@export var other_hand_radius: float = 0.3
@export var other_hand_span: float = PI / 4
@export var hand_duration: float = 0.3
@export var hand_delay: float = 0.03

@export var place_duration: float = 0.3
@export var reposition_duration: float = 0.12

var cards: Array[MeshInstance3D]
var decks: Array[Array]

# Create all of the cards in the center of the table
func create_stack() -> void:
	for i in range(56):
		var new_card: MeshInstance3D = card_scene.instantiate()
		cards.append(new_card)
		add_child(new_card)
		
		new_card.global_position = get_node("DeckSpawn").global_position
		new_card.global_position.y += i * deck_offset.y
	cards.reverse()

# Deal the cards to each player
func deal_stack():
	for _i in range(4):
		decks.append([])
	for i in range(56):
		# Only the player cards should have text on them
		if i % 4 == 0:
			var card: Array = game_room.lobby.decks[game_room.player_idx][len(decks[i % 4])]
			cards[i].set_text(card[0], card[1])
		
		timer.start(deal_delay)
		await timer.timeout
		decks[i % 4].append(cards[i])
		deal_card(i)
		sounds.get_node("Deal").play_sound()

func hold_hand() -> void:
	for i in range(56):
		timer.start(hand_delay)
		await timer.timeout
		hold_card(int(i / 14.0), i % 14, hand_duration)
	cards.clear()

func update_hand(deck: int) -> void:
	for i in range(len(decks[deck])):
		hold_card(deck, i, reposition_duration)

func deal_card(card_idx: int) -> void:
	var deal_marker: Marker3D = get_node("Deal" + str(card_idx % 4 + 1))
	
	var new_pos: Vector3 = deal_marker.global_position
	var new_rot: Vector3 = deal_marker.rotation
	new_pos.y += card_idx / 4.0 * deck_offset.y
	new_rot.y += randf_range(-deck_imperfection, deck_imperfection)
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(cards[card_idx], "global_position", new_pos, deal_duration)
	tween.parallel().tween_property(cards[card_idx], "rotation", new_rot, deal_duration)

# Return the global position that a card would be in within hand
func get_held_card_position(deck: int, deck_idx: int) -> Vector3:
	var hand_marker: Marker3D = get_node("Hand" + str(deck + 1))
	# We fill cards from left to right, but need to mirror the transforms to have a centered deck
	var left_side: bool = deck_idx < len(decks[deck]) / 2
	
	# Fix deck index to fit the mirrored model
	if not left_side:
		deck_idx -= len(decks[deck]) / 2
	else:
		deck_idx = len(decks[deck]) / 2 - deck_idx
	
	# Project the card into surface of a sphere with an origin at the marker
	var angle_change: float = ((hand_span if deck == 0 else other_hand_span) / 14) * deck_idx
	var initial_ray: Vector3 = hand_marker.get_global_transform().basis.y * (hand_radius if deck == 0 else other_hand_radius)
	initial_ray = initial_ray.rotated(Vector3.UP, 2 * angle_change * (-1 if left_side else 1))
	return hand_marker.global_position + initial_ray

func hold_card(deck: int, deck_idx: int, duration: float) -> void:
	var hand_marker: Marker3D = get_node("Hand" + str(deck + 1))
	
	# Save the state of the new and old transforms so we can tween over it
	var old_pos: Vector3 = decks[deck][deck_idx].global_position 
	var old_rot: Vector3 = decks[deck][deck_idx].rotation
	decks[deck][deck_idx].global_position = get_held_card_position(deck, deck_idx)
	decks[deck][deck_idx].look_at(hand_marker.global_position, Vector3.UP)
	decks[deck][deck_idx].rotate(decks[deck][deck_idx].global_transform.basis.x.normalized(), PI / 2.5)
	var new_pos: Vector3 = decks[deck][deck_idx].global_position
	var new_rot: Vector3 = decks[deck][deck_idx].rotation
	decks[deck][deck_idx].global_position = old_pos
	decks[deck][deck_idx].rotation = old_rot
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(decks[deck][deck_idx], "global_position", new_pos, duration)
	tween.parallel().tween_property(decks[deck][deck_idx], "rotation", new_rot, duration)

func place_card(deck: int, card: MeshInstance3D) -> void:
	var card_idx: int = decks[deck].find(card)
	sounds.get_node("Deal").play_sound()
	
	var new_pos: Vector3 = get_node("DeckSpawn").global_position
	new_pos.y += len(cards) * deck_offset.y
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(decks[deck][card_idx], "global_position", new_pos, place_duration)
	tween.parallel().tween_property(decks[deck][card_idx], "rotation", Vector3(), place_duration)
	
	decks[deck].remove_at(card_idx)
	await tween.finished
	update_hand(deck)
