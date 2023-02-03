class_name BidMenu
extends Submenu

@export var bid_label: Label

@export var add_button: Button
@export var subtract_button: Button
@export var confirm_button: Button

var last_bid: int = 70
var current_bid: int = 70

func _ready() -> void:
	add_button.pressed.connect(change_bid.bind(5))
	subtract_button.pressed.connect(change_bid.bind(-5))

func change_bid(amount: int) -> void:
	current_bid += amount
	current_bid = min(200, max(last_bid, current_bid))
	bid_label.text = str(current_bid)
	
	if current_bid == last_bid:
		confirm_button.text = "Pass..."
		subtract_button.disabled = true
		add_button.disabled = false
	else:
		confirm_button.text = "Bid it!"
		subtract_button.disabled = false
		add_button.disabled = current_bid == 200

func get_player_bid() -> int:
	var tween: Tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.1)
	
	confirm_button.text = "Pass..."
	
	subtract_button.disabled = true
	add_button.disabled = false
	confirm_button.disabled = false
	
	await confirm_button.pressed
	
	tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.1)
	return current_bid

func update_bid(bid: int) -> void:
	current_bid = bid
	bid_label.text = str(current_bid)
