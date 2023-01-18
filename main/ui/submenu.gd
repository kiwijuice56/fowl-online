class_name Submenu
extends Control

signal exited
signal entered

func enter() -> void:
	entered.emit()

func exit() -> void:
	exited.emit()

func toggle_input(input_enabled: bool) -> void:
	pass
