class_name InfoOverlay
extends MarginContainer

@export var player_panel_scene: PackedScene

@export var scoreboard: PanelContainer
@export var score_label_a: Label
@export var score_label_b: Label

@export var bidder_container: VBoxContainer
@export var bid_container: VBoxContainer
@export var trump_icon: TextureRect

@export var container_a: VBoxContainer
@export var container_b: VBoxContainer

func _unhandled_input(event) -> void:
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

func set_trump(trump: Card.Suit) -> void:
	if trump == -1:
		trump_icon.modulate.a = 0
	else:
		trump_icon.modulate = StyleConstants.card_colors[trump - 1]

func set_scores(scores: Array) -> void:
	score_label_a.text = "Score: " + str(scores[0])
	score_label_b.text = "Score: " + str(scores[1])
