class_name LobbyManager
extends Node

@export var lobby_scene: PackedScene
@export var player_scene: PackedScene

var code_words: PackedStringArray

var local_id: int
var local_lobby_code: String
var local_username: String

signal player_joined_lobby(code, id, username, icon)
signal player_left_lobby(code, id)

func _enter_tree() -> void:
	var file: FileAccess = FileAccess.open("res://main/game/lobby_manager/code_words.txt", FileAccess.READ)
	var content: String = file.get_as_text()
	code_words = content.split("\n")
	
	start_network("--server" in OS.get_cmdline_args())

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
		
		print("Server listening on localhost 2004")
	else:
		peer.create_client("localhost", 2004)
	local_id = peer.get_unique_id()
	multiplayer.set_multiplayer_peer(peer)

@rpc(any_peer)
func create_lobby(code: String) -> void:
	if local_id != get_multiplayer_authority():
		return
	
	var new_lobby: Lobby = lobby_scene.instantiate()
	new_lobby.name = code
	add_child(new_lobby)
	print(str(local_id) + ": Lobby " + code + " created")

@rpc(any_peer)
func delete_lobby(code: String) -> void:
	if local_id != get_multiplayer_authority():
		return
	
	for player in get_node(code).get_children():
		if not player is MultiplayerSpawner:
			leave_lobby(code, int(player.name))
	
	remove_child(get_node(code))
	print(str(local_id) + ": Lobby " + code + " deleted")

@rpc(any_peer, call_local)
func join_lobby(code: String, player: int, username: String, icon: int) -> void:
	if local_id == get_multiplayer_authority():
		var new_player: Player = player_scene.instantiate()
		new_player.name = str(player)
		new_player.icon = icon
		new_player.username = username
		get_node(code).add_child(new_player)
		print(str(local_id) + ": Player " + str(player) + " joined lobby " + code)
	player_joined_lobby.emit(code, player, username, icon)

@rpc(any_peer, call_local)
func leave_lobby(code: String, player: int) -> void:
	if local_id == get_multiplayer_authority():
		get_node(code).remove_child(get_node(code).get_node(str(player)))
		
		print(str(local_id) + ": Player " + str(player) + " left lobby " + code)
		if get_node(code).get_child_count() <= 1:
			delete_lobby(code)
	player_left_lobby.emit(code, player)

func lobby_exists(code: String) -> bool:
	return has_node(code)

func generate_code() -> String:
	var words: PackedStringArray = []
	for _i in range(3):
		words.append(code_words[randi() % len(code_words)].strip_edges())
	return "-".join(words)
