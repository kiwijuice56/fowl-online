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
	# This is much smaller than the original list of 1000 words, but my Linode server
	# seems unable to locate files... this will have to do!
	code_words = ['pun', 'roc', 'ugh', 'bob', 'yas', 'udo', 'her', 'yar', 'jee', 'tux', 'guy', 
	'sin', 'goy', 'don', 'saw', 'yob', 'tau', 'oak', 'cam', 'vex', 'met', 'big', 'she', 'pea', 
	'tom', 'wee', 'wok', 'tap', 'eld', 'roo', 'tee', 'kep', 'oft', 'zea', 'him', 'web', 'hap', 
	'tup', 'lea', 'fab', 'zax', 'wap', 'lob', 'sou', 'tog', 'aha', 'fop', 'gab', 'pah', 'zig', 
	'sup', 'cru', 'feu', 'saz', 'ted', 'tor', 'zap', 'upo', 'dak', 'cox', 'sos', 'mot', 'out', 
	'bit', 'joe', 'div', 'utu', 'aba', 'pro', 'zol', 'ash', 'del', 'meg', 'och', 'soh', 'cor', 
	'boo', 'nor', 'mar', 'gym', 'aye', 'pot', 'rap', 'ego', 'jot', 'poi', 'law', 'ilk', 'ell', 
	'sky', 'lit', 'pen', 'fie', 'jam', 'leg', 'ran', 'daw', 'tar', 'sed', 'tam']
	
	start_network("--server" in OS.get_cmdline_args())

func _on_connected(id: int) -> void:
	print("Client ", id, " connected to the server")

func _on_disconnected(id: int) -> void:
	print("Client ", id, " disconnected from the server")

func start_network(is_server: bool) -> void:
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	if is_server:
		multiplayer.peer_connected.connect(_on_connected)
		multiplayer.peer_disconnected.connect(_on_disconnected)
		peer.create_server(2004)
		
		print("Server listening on 45.33.15.210 port 2004")
	else:
		peer.create_client("45.33.15.210", 2004)
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
	print("Lobby ", code, " created")

@rpc("any_peer")
func delete_lobby(code: String) -> void:
	if local_id != get_multiplayer_authority():
		return
	
	for player in get_node(code).get_children():
		if not player is MultiplayerSpawner:
			leave_lobby(code, int(player.name))
	
	remove_child(get_node(code))
	print("Lobby ", code, " deleted")

@rpc("any_peer", "call_local")
func join_lobby(code: String, player: int, username: String, icon: int) -> void:
	if local_id == get_multiplayer_authority():
		var new_player: Player = player_scene.instantiate()
		new_player.name = str(player)
		new_player.icon = icon
		new_player.username = username
		new_player.id = player
		get_node(code).add_child(new_player)
		print("Player ", username, " (", player, ") joined lobby ", code)
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
		
		print("Player [username unknown] (", player, ") left lobby ", code)
		if get_node(code).get_child_count() <= 1:
			delete_lobby(code)
	player_left_lobby.emit(code, player)

func lobby_exists(code: String) -> bool:
	return has_node(code)

# Creates a 3-word code from the predefined list at the start of this file
func generate_code() -> String:
	var words: PackedStringArray = []
	for _i in range(3):
		words.append(code_words[randi() % len(code_words)].strip_edges())
	return " ".join(words)
