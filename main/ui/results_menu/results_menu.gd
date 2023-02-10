class_name ResultsMenu
extends Menu
# Manager for the results menus and animations

# TODO: add animations and other result screen fun things

func _ready() -> void:
	visible = false
	modulate.a = 0

# Called for clients who won the game
func declare_winner() -> void:
	$VBoxContainer/TitleLabel.text = "You win!"
	enter()

# Called for clients who lost the game
func declare_loser() -> void:
	$VBoxContainer/TitleLabel.text = "You lose!"
	enter()

func enter() -> void:
	visible = true
	create_tween().tween_property(self, "modulate:a", 1.0, 0.5)
