class_name LobbyManager
extends Node
# Handles lobbies for all clients on the server

# The LobbyManager works through the `run-server.bat` file, which runs the game with the "--server" flag. 
# The game instance created with the batch file becomes the multiplayer authority, allowing clients to 
# request to create and join lobbies. Lobby nodes are synced across all clients with the MultiplayerSpawner
# node, allowing clients to access lobby names and the player's connected to each.

# For clients connected to the server, the LobbyManager node is the interface to request tasks from 
# the authority.

# Note that this implementation is rather insecure and prone to hackers, but it's unlikely that much
# could be accomplished except messing with the game state for connected clients.

@export var lobby_scene: PackedScene
@export var player_scene: PackedScene

var code_words: PackedStringArray

# Information about the client
var local_id: int
var local_lobby_code: String
var local_username: String

signal player_joined_lobby(code, id, username, icon)
signal player_left_lobby(code, id)

func _enter_tree() -> void:
	code_words = ["aah", "aba", "abs", "ace", "ach", "act", "add", "ado", 
	"adz", "aft", "aga", "age", "ago", "aha", "ahi", "aid", "ail", "aim", 
	"ain", "air", "ait", "ala", "alb", "ale", "all", "alp", "alt", "amp", 
	"amu", "ana", "and", "ane", "ani", "ant", "any", "ape", "app", "apt", 
	"arb", "arc", "are", "arf", "ark", "arm", "art", "ash", "ask", "asp",
	"ate", "auk", "ave", "avo", "awe", "awl", "awn", "axe", "aye", "azo",
	"baa", "bad", "bag", "bah", "ban", "bap", "bar", "bat", "bay", "bed", 
	"bee", "beg", "bel", "ben", "bet", "bey", "bib", "bid", "big", "bin"]
	
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
		
		print("Server listening on 45.33.15.210 port 2004")
	else:
		peer.create_client("localhost", 2004)
	local_id = peer.get_unique_id()
	multiplayer.set_multiplayer_peer(peer)

@rpc("any_peer")
func create_lobby(code: String) -> void:
	if local_id != get_multiplayer_authority():
		return
	
	var new_lobby: Lobby = lobby_scene.instantiate()
	new_lobby.code = code
	new_lobby.name = code
	add_child(new_lobby)
	print(str(local_id) + ": Lobby " + code + " created")

@rpc("any_peer")
func delete_lobby(code: String) -> void:
	if local_id != get_multiplayer_authority():
		return
	
	for player in get_node(code).get_children():
		if not player is MultiplayerSpawner:
			leave_lobby(code, int(player.name))
	
	remove_child(get_node(code))
	print(str(local_id) + ": Lobby " + code + " deleted")

@rpc("any_peer", "call_local")
func join_lobby(code: String, player: int, username: String, icon: int) -> void:
	if local_id == get_multiplayer_authority():
		var new_player: Player = player_scene.instantiate()
		new_player.name = str(player)
		new_player.icon = icon
		new_player.username = username
		new_player.id = player
		get_node(code).add_child(new_player)
		print(str(local_id) + ": Player " + str(player) + " joined lobby " + code)
		# We need to update the UI for all clients only after the new player is added
		# Hence, this method is necessary to stop race conditions with the authority
		rpc("add_new_player", code, player, username, icon)

@rpc("any_peer", "call_local")
func add_new_player(code: String, player: int, username: String, icon: int) -> void:
	player_joined_lobby.emit(code, player, username, icon)

@rpc("any_peer", "call_local")
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
