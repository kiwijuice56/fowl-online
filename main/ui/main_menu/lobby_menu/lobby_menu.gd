class_name LobbyMenu
extends Menu

@export var player_panel_scene: PackedScene
@export var lobby_manager: LobbyManager
@export var code_label: LineEdit
@export var start_button: Button
@export var leave_button: Button
@export var player_list: VBoxContainer

var is_host: bool

signal game_abandoned
signal game_started(lobby_code: String)

func _ready() -> void:
	lobby_manager.player_joined_lobby.connect(_on_player_joined)
	lobby_manager.player_left_lobby.connect(_on_player_left)
	
	toggle_input(false)
	leave_button.pressed.connect(emit_signal.bind("game_abandoned"))
	start_button.pressed.connect(_on_game_started)
	visible = false

func _on_player_joined(code: String, id: int, username: String, icon: int) -> void:
	if not code == lobby_manager.local_lobby_code:
		return
	for child in player_list.get_children():
		child.queue_free()
	for player in lobby_manager.get_node(code).get_children():
		if not player is Player:
			continue
		var new_panel: UserPanel = player_panel_scene.instantiate()
		new_panel.initialize(player.username, player.icon)
		player_list.add_child(new_panel)
		new_panel.name = str(id)

func _on_player_left(code: String, id: int) -> void:
	if not code == lobby_manager.local_lobby_code:
		return
	for child in player_list.get_children():
		child.queue_free()
	for player in lobby_manager.get_node(code).get_children():
		if not player is Player:
			continue
		var new_panel: UserPanel = player_panel_scene.instantiate()
		new_panel.initialize(player.username, player.icon)
		player_list.add_child(new_panel)
		new_panel.name = str(id)

func _on_game_started() -> void:
	if player_list.get_child_count() < 4:
		return
	game_started.emit(lobby_manager.local_lobby_code)

func exit() -> void:
	super.exit()
	toggle_input(false)
	
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.1)
	
	await tween.finished
	visible = false

func enter() -> void:
	super.enter()
	visible = true
	
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.1)
	
	await tween.finished
	toggle_input(true)

func toggle_input(input_enabled: bool) -> void:
	start_button.disabled = not is_host or not input_enabled
	start_button.visible = is_host
	leave_button.disabled = not input_enabled
	
	var filter: int = Control.MOUSE_FILTER_STOP if input_enabled else Control.MOUSE_FILTER_IGNORE
	
	start_button.mouse_filter = filter
	leave_button.mouse_filter = filter
	
	super.toggle_input(input_enabled)
