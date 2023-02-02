class_name Submenu
extends Control

signal exited
signal entered

func enter() -> void:
	entered.emit()

func exit() -> void:
	exited.emit()

func toggle_input(_input_enabled: bool) -> void:
	# When changing mouse filter, buttons will still be shown as "mouse hovering"
	# This is a trick to refresh that... Probably not the best way
	visible = false
	visible = true
