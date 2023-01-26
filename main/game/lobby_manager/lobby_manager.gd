class_name LobbyManager
extends Node

@export var lobby_scene: PackedScene
@export var player_scene: PackedScene

var code_words: PackedStringArray

var local_player_id: int
var local_lobby_code: String

func _enter_tree() -> void:
	var file: FileAccess = FileAccess.open("res://main/game/lobby_manager/code_words.txt", FileAccess.READ)
	var content: String = file.get_as_text()
	code_words = content.split("\n")
	
	if "--server" in OS.get_cmdline_args():
		start_network(true)
	else:
		start_network(false)

func _on_connected(id: int) -> void:
	print(id, " connected")

func _on_disconnected(id: int) -> void:
	print(id, " disconnected")

func start_network(is_server: bool) -> void:
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	if is_server:
		multiplayer.peer_connected.connect(_on_connected)
		multiplayer.peer_disconnected.connect(_on_disconnected)
		peer.create_server(2004)
		
		print("server listening on localhost 2004")
	else:
		peer.create_client("localhost", 2004)
	local_player_id = peer.get_unique_id()
	multiplayer.set_multiplayer_peer(peer)

func generate_code() -> String:
	var words: PackedStringArray = []
	for _i in range(3):
		words.append(code_words[randi() % len(code_words)].strip_edges())
	print("-".join(words))
	return "-".join(words)

@rpc(any_peer)
func create_lobby(code: String) -> void:
	# Only the server creates new lobbies
	if local_player_id != get_multiplayer_authority():
		return
	
	var new_lobby: Lobby = lobby_scene.instantiate()
	new_lobby.name = code
	add_child(new_lobby)
	print(str(local_player_id) + ": Lobby created")

@rpc(any_peer)
func delete_lobby(code: String) -> void:
	# Only the server deletes lobbies
	if local_player_id != get_multiplayer_authority():
		return

@rpc(any_peer)
func join_lobby(code: String, player: int) -> void:
	# Only the server adds new players
	if local_player_id != get_multiplayer_authority():
		return
	var new_player: Player = player_scene.instantiate()
	new_player.name = str(player)
	get_node(code).add_child(new_player)
	print(str(local_player_id) + ": Player " + str(player) + " joined lobby " + code)

@rpc(any_peer)
func leave_lobby() -> void:
	# Only the server kicks players
	if local_player_id != get_multiplayer_authority():
		return
	get_node(local_lobby_code).remove_child(get_node(local_lobby_code).get_node(str(local_player_id)))

func lobby_exists(code: String) -> bool:
	return has_node(code)
