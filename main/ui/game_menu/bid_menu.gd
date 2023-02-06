class_name BidMenu
extends Menu

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
	current_bid = min(200, max(max(70, last_bid), current_bid))
	bid_label.text = str(current_bid)
	
	if current_bid == last_bid:
		confirm_button.text = "Pass..."
		subtract_button.disabled = true
		add_button.disabled = false
	else:
		confirm_button.text = "Bid it!"
		subtract_button.disabled = current_bid == 70
		add_button.disabled = current_bid == 200

func get_player_bid(bid: int) -> int:
	last_bid = bid
	current_bid = max(70, bid)
	bid_label.text = str(current_bid)
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.1)
	visible = true
	
	# All players get the chance to pass except the first bidder, which must at least bid 70
	confirm_button.text = "Pass..." if last_bid != 65 else "Bid it!"
	
	subtract_button.disabled = true
	add_button.disabled = false
	confirm_button.disabled = false
	
	await confirm_button.pressed
	
	tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.1)
	await tween.finished
	visible = false
	
	return current_bid
