class_name ResultsMenu
extends Menu

func _ready() -> void:
	visible = false
	modulate.a = 0

func declare_winner() -> void:
	$VBoxContainer/TitleLabel.text = "You win!"
	enter()

func declare_loser() -> void:
	$VBoxContainer/TitleLabel.text = "You lose!"
	enter()

func enter() -> void:
	visible = true
	create_tween().tween_property(self, "modulate:a", 1.0, 0.5)
