class_name GameRoom
extends Node3D
# Top-level manager for the 3D gameplay, including the camera

@export var deck: GameDeck
@export var camera: PlayerCamera

var player_sprites: Array[PlayerSprite]
var lobby: Lobby

var player_idx: int:
	# Shift the array of player sprites to fit the client as the first player
	set(val):
		player_idx = val
		for i in range(player_idx):
			player_sprites.insert(0, player_sprites.pop_back())

func _ready() -> void:
	player_sprites = []
	for sprite in $Players.get_children():
		player_sprites.append(sprite)

func initialize_players(players: Array) -> void:
	for i in range(len(players)):
		player_sprites[i].initialize(players[i])
