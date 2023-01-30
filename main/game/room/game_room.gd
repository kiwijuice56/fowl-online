class_name GameRoom
extends Node3D

@export var markers: Node3D
@export var sounds: Node
@export var timer: Timer

@export var card_scene: PackedScene

@export var deck_offset: Vector2 = Vector2(0.01, 0.0008)
@export var deck_imperfection: float = 0.01
@export var deal_duration: float = 0.03

@export var hand_radius: float = 0.3

var cards: Array[MeshInstance3D]
var decks: Array[Array]

func _ready() -> void:
	create_stack()
	timer.start(1)
	await timer.timeout
	deal_stack()

func create_stack() -> void:
	for i in range(56):
		var new_card: MeshInstance3D = card_scene.instantiate()
		cards.append(new_card)
		add_child(new_card)
		
		new_card.global_position = markers.get_node("DeckSpawn").global_position
		new_card.global_position.y += i * deck_offset.y
	cards.reverse()

func deal_stack():
	for _i in range(4):
		decks.append([])
	for i in range(56):
		timer.start(0.03)
		await timer.timeout
		decks[i % 4].append(cards[i])
		deal_card(i)
		sounds.get_node("Deal").play_sound()
	
	await timer.start(1)
	for i in range(56):
		timer.start(0.03)
		await timer.timeout
		hold_card(int(i / 14.0), i % 14)

func deal_card(card_idx: int) -> void:
	var deal_marker: Marker3D = markers.get_node("Deal" + str(card_idx % 4 + 1))
	
	var new_pos: Vector3 = deal_marker.global_position
	new_pos.y += card_idx / 4.0 * deck_offset.y
	
	var new_rot: Vector3 = deal_marker.rotation
	new_rot.y += randf_range(-deck_imperfection, deck_imperfection)
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(cards[card_idx], "global_position", new_pos, deal_duration)
	tween.parallel().tween_property(cards[card_idx], "rotation", new_rot, deal_duration)

func get_held_card_position(deck: int, deck_idx: int) -> Vector3:
	var hand_marker: Marker3D = markers.get_node("Hand" + str(deck + 1))
	var left_side: bool = deck_idx <= len(decks[deck]) / 2
	if not left_side:
		deck_idx -= 7
	var angle_change: float = (PI / 2 / len(decks[deck])) * deck_idx
	var initial_ray: Vector3 = hand_marker.get_global_transform().basis.y * hand_radius
	initial_ray = initial_ray.rotated(Vector3.UP, 2 * angle_change * (-1 if left_side else 1))
	return hand_marker.global_position + initial_ray

func hold_card(deck: int, deck_idx: int) -> void:
	var hand_marker: Marker3D = markers.get_node("Hand" + str(deck + 1))
	
	var old_trans: Transform3D = decks[deck][deck_idx].global_transform
	decks[deck][deck_idx].global_position = get_held_card_position(deck, deck_idx)
#	if deck == 0:
#		decks[deck][deck_idx].look_at(get_viewport().get_camera_3d().global_position, Vector3.UP)
	#else:
	decks[deck][deck_idx].look_at(hand_marker.global_position, Vector3.UP)
	decks[deck][deck_idx].rotate(decks[deck][deck_idx].global_transform.basis.x.normalized(), PI / 2.5)
	var new_trans: Transform3D = decks[deck][deck_idx].global_transform
	
	decks[deck][deck_idx].global_transform = old_trans
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(decks[deck][deck_idx], "global_transform", new_trans, deal_duration)

func denote_cards(data: Array[Card]) -> void:
	pass
