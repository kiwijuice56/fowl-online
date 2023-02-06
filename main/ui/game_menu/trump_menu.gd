class_name TrumpMenu
extends Menu

@export var confirm_button: Button
@export var color_button_container: Container

var suit: Card.Suit

func _ready() -> void:
	for button in color_button_container.get_children():
		button.pressed.connect(select_color.bind(button.get_index()))
		button.modulate = StyleConstants.card_colors[button.get_index()]

func select_color(idx: int) -> void:
	for button in color_button_container.get_children():
		if button.get_index() != idx:
			button.button_pressed = false
	suit = Card.Suit.values()[idx]
	confirm_button.disabled = false

func get_player_trump() -> Card.Suit:
	confirm_button.disabled = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.1)
	visible = true
	
	await confirm_button.pressed
	
	tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.1)
	await tween.finished
	visible = false
	
	return suit
