class_name GameRoom
extends Node3D
# Manages the visuals of the game

@export var deck: GameDeck
@export var camera: PlayerCamera

func _ready() -> void:
	camera.card_selected.connect(_on_card_selected)
	
	deck.create_stack()
	
	await get_tree().create_timer(1)
	
	await deck.deal_stack()
	
	await get_tree().create_timer(1)
	
	await deck.hold_hand()

func _on_card_selected(card: MeshInstance3D) -> void:
	deck.place_card(0, card)
