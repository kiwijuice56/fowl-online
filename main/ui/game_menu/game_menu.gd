class_name GameMenu
extends Menu
# Manager for all submenus within regular gameplay, such as bidding menu

@export var bid_menu: BidMenu
@export var trump_menu: TrumpMenu
@export var info_overlay: InfoOverlay
@export var turn_label: Label

func _ready() -> void:
	visible = false
	modulate.a = 0

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

# Show a pop-up of the current player
func show_current_player(player_name: String) -> void:
	turn_label.text = player_name + "'s turn!"
	turn_label.modulate.a = 0
	
	$Sounds/NextTurn.play_sound()
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(turn_label, "modulate:a", 1.0, 0.1)
	await tween.finished
	
	await get_tree().create_timer(1.5).timeout
	
	tween = get_tree().create_tween()
	tween.tween_property(turn_label, "modulate:a", 0.0, 0.1)
	await tween.finished
