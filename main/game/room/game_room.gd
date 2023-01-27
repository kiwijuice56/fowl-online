class_name GameRoom
extends Node3D

@export var markers: Node3D
@export var sounds: Node
@export var card_scene: PackedScene
@export var timer: Timer

@export var deck_offset: float = 0.0008
@export var rotation_random: float = 0.01
var cards: Array[MeshInstance3D]

func _ready() -> void:
	create_stack()

func create_stack() -> void:
	for i in range(56):
		var new_card: MeshInstance3D = card_scene.instantiate()
		cards.append(new_card)
		add_child(new_card)
		
		new_card.global_position = markers.get_node("DeckSpawn").global_position
		new_card.global_position.y += i * deck_offset
	cards.reverse()
	timer.start(5)
	await timer.timeout
	for i in range(56):
		timer.start(0.11)
		await timer.timeout
		deal_card(i, 1 + i % 4, 0.12, i / 4.0 * deck_offset)
		sounds.get_node("Deal").play_sound()

func deal_card(card_idx: int, spot: int, duration: float, offset: float) -> void:
	var tween: Tween = get_tree().create_tween()
	var new_pos: Vector3 = markers.get_node("Deal" + str(spot)).global_position
	new_pos.y += offset
	var new_rot: Vector3 =  markers.get_node("Deal" + str(spot)).rotation
	new_rot.y += randf_range(-rotation_random, rotation_random)
	tween.tween_property(cards[card_idx], "global_position", new_pos, duration)
	tween.parallel().tween_property(cards[card_idx], "rotation", new_rot, duration)
