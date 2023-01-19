class_name Lobby
extends Control

@export var character_menu: CharacterMenu
@export var main_menu: MainMenu

var rooms: Dictionary 

func _ready() -> void:
	character_menu.go_selected.connect(_on_go_selected)
	main_menu.profile_selected.connect(_on_profile_selected)

func _on_go_selected() -> void:
	await character_menu.exit()
	main_menu.enter()

func _on_profile_selected() -> void:
	await main_menu.exit()
	character_menu.enter()

func _enter_tree() -> void:
	pass

func _on_join_selected() -> void:
	pass

func _on_create_selected() -> void:
	pass

func _on_connected(id: int) -> void:
	pass

func _on_disconnected(id: int) -> void:
	pass

func start_network(is_server: bool) -> void:
	var peer = ENetMultiplayerPeer.new()
	if is_server:
		multiplayer.peer_connected.connect(_on_connected)
		multiplayer.peer_disconnected.connect(_on_disconnected)
		peer.create_server(2004)
		
		print("server listening on localhost 2004")
	else:
		peer.create_client("localhost", 2004)
	
	multiplayer.set_multiplayer_peer(peer)
