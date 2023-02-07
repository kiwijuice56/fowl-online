class_name GameDeck
extends Node3D
# Manages the visual representation of the player decks

@onready var game_room: GameRoom = get_parent()

@export var sounds: Node
@export var timer: Timer

@export var card_scene: PackedScene

@export var deck_offset: Vector2 = Vector2(0.01, 0.0045)
@export var deck_imperfection: float = 0.01
@export var deal_duration: float = 0.3
@export var deal_delay: float = 0.06

@export var hand_span: float = PI / 1.8
@export var hand_radius: float = 0.5
@export var other_hand_radius: float = 0.3
@export var other_hand_span: float = PI / 4
@export var hand_duration: float = 0.55
@export var hand_delay: float = 0.01

@export var place_duration: float = 0.3
@export var reposition_duration: float = 0.05

@export var trick_duration: float = 0.3
@export var trick_delay: float = 0.02

var cards: Array[MeshInstance3D]

# 2D array containing references to the CardModels for each player's deck
# The deck at index 0 belongs to the local player
var decks: Array[Array]

var tricks: Array[Array]

# Create all of the cards in the center of the table
func create_stack() -> void:
	for i in range(57):
		var new_card: MeshInstance3D = card_scene.instantiate()
		cards.append(new_card)
		add_child(new_card)
		
		new_card.global_position = get_node("DeckSpawn").global_position
		new_card.global_position.y += i * deck_offset.y

# Deal the cards to each player's spot on the table, called after create_stack()
func deal_stack():
	for _i in range(4):
		decks.append([])
		
	var player_deck: Array = game_room.lobby.decks[game_room.player_idx]
	for i in range(56, 0, -1):
		# Only the player cards should have text on them
		if i % 4 == 0:
			var card: Array = player_deck[len(decks[0])]
			cards[i].set_text(card[0], card[1])
		
		timer.start(deal_delay)
		await timer.timeout
		decks[i % 4].append(cards[i])
		deal_card(i)
		sounds.get_node("Deal").play_sound()

# Put the cards in the hands of each player
func hold_hand() -> void:
	for i in range(56, 0, -1):
		timer.start(hand_delay)
		await timer.timeout
		hold_card(int((i - 1) / 14.0), (i - 1) % 14, hand_duration)
	var temp: MeshInstance3D = cards[0]
	cards.clear()
	cards.append(temp) # Keep the center card at the very bottom!

# Update the positions of each card in a player's hand, usually after they play or get a card
# Unlike hold_hand(), there isn't a delay between each card moving
func update_hand(deck: int) -> void:
	for i in range(len(decks[deck])):
		hold_card(deck, i, reposition_duration)

# Place a card in a player's deck on the table
func deal_card(card_idx: int) -> void:
	var deal_marker: Marker3D = get_node("Deal" + str(card_idx % 4 + 1))
	
	var new_pos: Vector3 = deal_marker.global_position
	var new_rot: Vector3 = deal_marker.rotation
	
	new_pos.y += (56 - card_idx) / 4.0 * deck_offset.y
	new_rot.y += randf_range(-deck_imperfection, deck_imperfection)
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(cards[card_idx], "global_position", new_pos, deal_duration)
	tween.parallel().tween_property(cards[card_idx], "rotation", new_rot, deal_duration)

# Return the global position that a card would be in within its hand
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

# Hold a card in a player's hand based on its index in the deck
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

# Place a card in a player's hand 
func place_card(deck: int, card: MeshInstance3D, face_down: bool) -> void:
	var card_idx: int = decks[deck].find(card)
	sounds.get_node("Deal").play_sound()
	
	var new_pos: Vector3 = get_node("DeckSpawn").global_position
	new_pos.y += len(cards) * deck_offset.y
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(decks[deck][card_idx], "global_position", new_pos, place_duration)
	tween.parallel().tween_property(decks[deck][card_idx], "rotation", Vector3(0, 0, 0.0 if face_down else PI), place_duration)
	
	cards.append(decks[deck][card_idx])
	decks[deck].remove_at(card_idx)
	await tween.finished
	update_hand(deck)

func get_card(card: MeshInstance3D) -> Array:
	return game_room.lobby.decks[game_room.player_idx][decks[0].find(card)]

func stash_trick(winner: int) -> void:
	var trick_marker: Marker3D = get_node("Trick" + str(winner + 1))
	for card in cards:
		var new_pos: Vector3 = trick_marker.global_position
		new_pos.y += len(tricks[winner]) * deck_offset.y
		tricks[winner].append(card)
		
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(card, "global_position", new_pos, trick_duration)
		
		timer.start(trick_delay)
		await timer.timeout
