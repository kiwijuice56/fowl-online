class_name InfoOverlay
extends MarginContainer

@export var player_panel_scene: PackedScene

@export var scoreboard: PanelContainer

@export var bidder_container: VBoxContainer
@export var bid_container: VBoxContainer
@export var trump_container: VBoxContainer

@export var container_a: VBoxContainer
@export var container_b: VBoxContainer

func _input(event) -> void:
	if event.is_action_pressed("hide", false):
		scoreboard.visible = !scoreboard.visible

func initialize_scoreboard(players: Array):
	for child in container_a.get_children():
		if child is Label:
			continue
		child.queue_free()
	for child in container_b.get_children():
		if child is Label:
			continue
		child.queue_free()
	
	var panels: Array[UserPanel] = []
	for player in players:
		var new_panel: UserPanel = player_panel_scene.instantiate()
		new_panel.initialize(player.username, player.icon)
		panels.append(new_panel)
	
	container_a.add_child(panels.pop_front())
	container_b.add_child(panels.pop_front())
	container_a.add_child(panels.pop_front())
	container_b.add_child(panels.pop_front())

func set_bid_information(bid_winner: Player, bid: int) -> void:
	bid_container.get_child(1).text = str(bid) if bid >= 70 else ""
	if bidder_container.get_child_count() == 2:
		bidder_container.get_child(1).queue_free()
	if bid_winner != null:
		var new_panel: UserPanel = player_panel_scene.instantiate()
		new_panel.initialize(bid_winner.username, bid_winner.icon)
		bidder_container.add_child(new_panel)
