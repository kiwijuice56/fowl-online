class_name CardModel
extends MeshInstance3D

@export var select_time: float = 0.1

var selected: bool = false

func set_text(suit: Card.Suit, number: int) -> void:
	$MainNumber.text = str(number)
	
	var col_text: String
	match suit:
		1: col_text = "pink"
		2: col_text = "yellow"
		3: col_text = "blue"
		4: col_text = "violet"
	if suit == 0:
		$HelpNumber1.text = "fowl"
		$HelpNumber2.text = "fowl"
		$MainNumber.modulate = StyleConstants.card_colors[4]
		$HelpNumber1.modulate = StyleConstants.card_colors[4]
		$HelpNumber2.modulate = StyleConstants.card_colors[4]
	else:
		$HelpNumber1.text = str(number) + " " + col_text
		$HelpNumber2.text = str(number) + " " + col_text
		
		$MainNumber.modulate = StyleConstants.card_colors[suit - 1]
		$HelpNumber1.modulate = StyleConstants.card_colors[suit - 1]
		$HelpNumber2.modulate = StyleConstants.card_colors[suit - 1]

func select() -> void:
	if selected:
		return
	selected = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector3(0.0625, 0.0625, 0.0625), select_time)

func deselect() -> void:
	selected = false
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector3(0.055, 0.055, 0.055), select_time)
