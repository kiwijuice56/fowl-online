class_name Lobby
extends Control

@export var character_menu: CharacterMenu
@export var main_menu: MainMenu
@export var join_menu: JoinMenu
@export var mini_lobby_menu: MiniLobbyMenu

var rooms: Dictionary 

func _enter_tree() -> void:
	if "--server" in OS.get_cmdline_args():
		start_network(true)
	else:
		start_network(false)

func _ready() -> void:
	character_menu.character_confirmed.connect(_on_character_confirmed)
	
	main_menu.profile_selected.connect(_on_profile_selected)
	main_menu.join_selected.connect(_on_join_selected)
	main_menu.create_selected.connect(_on_create_selected)
	
	join_menu.game_joined.connect(_on_game_joined)
	join_menu.join_abandoned.connect(_on_join_abandoned)
	
	mini_lobby_menu.game_abandoned.connect(_on_game_abandoned)

func _on_character_confirmed() -> void:
	await character_menu.exit()
	main_menu.enter()

func _on_profile_selected() -> void:
	await main_menu.exit()
	character_menu.enter()

func _on_game_joined(code: String) -> void:
	if code.is_empty():
		join_menu.display_error(join_menu.empty_code_error)
	elif false: # TODO: error when entering invalid lobby code
		join_menu.display_error(join_menu.no_matching_code_error)
	else:
		await join_menu.exit()
		# TODO: mini lobby screen
		mini_lobby_menu.enter()

func _on_join_abandoned() -> void:
	await join_menu.exit()
	main_menu.enter()

func _on_game_abandoned() -> void:
	await mini_lobby_menu.exit()
	main_menu.enter()

func _on_join_selected() -> void:
	await main_menu.exit()
	join_menu.enter()

func _on_create_selected() -> void:
	await main_menu.exit()
	mini_lobby_menu.enter()

func _on_connected(id: int) -> void:
	print(id, " connected")

func _on_disconnected(id: int) -> void:
	print(id, " disconnected")

func start_network(is_server: bool) -> void:
	var peer = ENetMultiplayerPeer.new()
	if is_server:
		multiplayer.peer_connected.connect(_on_connected)
		multiplayer.peer_disconnected.connect(_on_disconnected)
		peer.create_server(2004)
		
		print("server listening on 2600:1700:22b3:9010:8499:2545:3e20:d578 2004")
	else:
		peer.create_client("2600:1700:22b3:9010:8499:2545:3e20:d578", 2004)
	
	multiplayer.set_multiplayer_peer(peer)
