class_name CardModel
extends MeshInstance3D

@export var colors: Array[Color]

func set_text(suit: Card.Suit, number: int) -> void:
	$MainNumber.text = str(number)
	
	var col_text: String
	match suit:
		1: col_text = "red"
		2: col_text = "yellow"
		3: col_text = "blue"
		4: col_text = "green"
	$HelpNumber1.text = str(number) + " " + col_text
	$HelpNumber2.text = str(number) + " " + col_text
	
	$MainNumber.modulate = colors[suit - 1]
	$HelpNumber1.modulate = colors[suit - 1]
	$HelpNumber2.modulate = colors[suit - 1]
