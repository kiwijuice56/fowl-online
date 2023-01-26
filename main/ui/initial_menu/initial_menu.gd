class_name InitialMenu
extends Control

@export var lobby_manager: LobbyManager

@export var character_menu: CharacterMenu
@export var main_menu: MainMenu
@export var join_menu: JoinMenu
@export var mini_lobby_menu: LobbyMenu

var rooms: Dictionary 

func _ready() -> void:
	character_menu.character_confirmed.connect(_on_character_confirmed)
	
	main_menu.profile_selected.connect(_on_profile_selected)
	main_menu.join_selected.connect(_on_join_selected)
	main_menu.create_selected.connect(_on_create_selected)
	
	join_menu.game_joined.connect(_on_game_joined)
	join_menu.join_abandoned.connect(_on_join_abandoned)
	
	mini_lobby_menu.game_abandoned.connect(_on_game_abandoned)
	mini_lobby_menu.game_started.connect(_on_game_started)

func _on_character_confirmed() -> void:
	await character_menu.exit()
	main_menu.enter()

func _on_profile_selected() -> void:
	await main_menu.exit()
	character_menu.enter()

func _on_game_joined(code: String) -> void:
	if code.is_empty():
		join_menu.display_error(join_menu.empty_code_error)
	elif not lobby_manager.lobby_exists(code):
		join_menu.display_error(join_menu.no_matching_code_error)
	else:
		await join_menu.exit()
		lobby_manager.rpc("join_lobby", code, lobby_manager.local_id, character_menu.selected_username, character_menu.selected_icon)
		lobby_manager.local_lobby_code = code
		mini_lobby_menu.enter()

func _on_join_abandoned() -> void:
	await join_menu.exit()
	main_menu.enter()

func _on_game_started() -> void:
	await mini_lobby_menu.exit()
	lobby_manager.get_child(1).rpc("deal_cards")

func _on_game_abandoned() -> void:
	await mini_lobby_menu.exit()
	lobby_manager.rpc("leave_lobby", lobby_manager.local_lobby_code, lobby_manager.local_id)
	main_menu.enter()

func _on_join_selected() -> void:
	await main_menu.exit()
	join_menu.enter()

func _on_create_selected() -> void:
	await main_menu.exit()
	var code: String = lobby_manager.generate_code()
	lobby_manager.rpc("create_lobby", code)
	await lobby_manager.get_node("MultiplayerSpawner").spawned
	lobby_manager.rpc("join_lobby", code, lobby_manager.local_id, character_menu.selected_username, character_menu.selected_icon)
	lobby_manager.local_lobby_code = code
	
	mini_lobby_menu.code_label.text = code
	mini_lobby_menu.enter()
