class_name GameRoom
extends Node3D
# Top-level manager for the 3D gameplay, including the camera

@export var deck: GameDeck
@export var camera: PlayerCamera

var player_sprites: Array[PlayerSprite]
var lobby: Lobby

var player_idx: int:
	set(val):
		player_idx = val
		for i in range(player_idx):
			player_sprites.insert(0, player_sprites.pop_back())

func _ready() -> void:
	camera.card_selected.connect(_on_card_selected)
	player_sprites = []
	for sprite in $Players.get_children():
		player_sprites.append(sprite)

func _on_card_selected(card: MeshInstance3D) -> void:
	deck.place_card(0, card)

func initialize_players(players: Array) -> void:
	for i in range(len(players)):
		player_sprites[i].initialize(players[i])
