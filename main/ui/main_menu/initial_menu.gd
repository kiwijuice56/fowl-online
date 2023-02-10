class_name MainMenu
extends Menu
# This file should be called main_menu, but it created some serious errors trying to rename...

# Manager for all of the submenus seen at the start of the game, such as the lobby and character
# select screens

# Rreferences to each submenu
@export var lobby_manager: LobbyManager
@export var character_menu: CharacterMenu
@export var main_menu: NexusMenu
@export var join_menu: JoinMenu
@export var mini_lobby_menu: LobbyMenu

func _ready() -> void:
	# Connect to all of the exit/enter signals to handle transitions
	character_menu.character_confirmed.connect(_on_character_confirmed)
	
	main_menu.profile_selected.connect(_on_profile_selected)
	main_menu.join_selected.connect(_on_join_selected)
	main_menu.create_selected.connect(_on_create_selected)
	
	join_menu.game_joined.connect(_on_game_joined)
	join_menu.join_abandoned.connect(_on_join_abandoned)
	
	mini_lobby_menu.game_abandoned.connect(_on_game_abandoned)
	mini_lobby_menu.game_started.connect(_on_game_started)

# Called when the user clicks "Go!" in the character select menu
func _on_character_confirmed() -> void:
	await character_menu.exit()
	main_menu.enter()

# Called when the user clicks "Change User" in the main menu
func _on_profile_selected() -> void:
	await main_menu.exit()
	character_menu.enter()

# Called when the user enters a code and joins a game within the join menu
func _on_game_joined(code: String) -> void:
	if code.is_empty():
		join_menu.display_error(join_menu.empty_code_error)
	elif not lobby_manager.lobby_exists(code):
		join_menu.display_error(join_menu.no_matching_code_error)
	else:
		await join_menu.exit()
		lobby_manager.local_lobby_code = code
		mini_lobby_menu.code_label.text = code
		lobby_manager.rpc("join_lobby", code, lobby_manager.local_id, character_menu.selected_username, character_menu.selected_icon)
		mini_lobby_menu.is_host = false
		mini_lobby_menu.enter()

# Called when the user clicks "Back" from the join menu
func _on_join_abandoned() -> void:
	await join_menu.exit()
	main_menu.enter()

# Called when the host clicks "Start Game" from the lobby menu
func _on_game_started(code: String) -> void:
	lobby_manager.get_node(code).rpc("start_game")

# Called when the host/user clicks "Leave Game" from the lobby menu
func _on_game_abandoned() -> void:
	await mini_lobby_menu.exit()
	lobby_manager.rpc("leave_lobby", lobby_manager.local_lobby_code, lobby_manager.local_id)
	main_menu.enter()

# Called when the user clicks "Join Game" from the main menu
func _on_join_selected() -> void:
	main_menu.hide_title()
	await main_menu.exit()
	
	join_menu.enter()

# Called when the user clicks "Create Game" from the main menu
func _on_create_selected() -> void:
	main_menu.hide_title()
	await main_menu.exit()
	
	var code: String = lobby_manager.generate_code()
	lobby_manager.local_lobby_code = code
	mini_lobby_menu.code_label.text = code
	
	lobby_manager.rpc("create_lobby", code)
	
	# Wait until the RPC call goes through and spawns the new lobby node
	await lobby_manager.get_node("MultiplayerSpawner").spawned
	
	lobby_manager.rpc("join_lobby", code, lobby_manager.local_id, character_menu.selected_username, character_menu.selected_icon)
	
	mini_lobby_menu.is_host = true
	mini_lobby_menu.enter()

func exit() -> void:
	super.exit()
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.1)
	await tween.finished
	visible = false

func enter() -> void:
	super.enter()
	visible = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.1)
	await tween.finished
