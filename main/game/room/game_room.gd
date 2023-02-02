class_name GameRoom
extends Node3D
# Top-level manager for the 3D gameplay, including the camera

@export var deck: GameDeck
@export var camera: PlayerCamera

var player: Player

func _ready() -> void:
	camera.card_selected.connect(_on_card_selected)

func _on_card_selected(card: MeshInstance3D) -> void:
	deck.place_card(0, card)
