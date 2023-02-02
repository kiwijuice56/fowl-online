class_name Player
extends Node

var username: String
var icon: int

var deck: Array
var is_synced: bool = false:
	set(val):
		is_synced = val
		if is_synced:
			synced.emit()

signal synced

@rpc("call_local")
func update_state(new_deck: Array) -> void:
	self.deck = new_deck
	if str(multiplayer.get_unique_id()) == str(name):
		rpc("set_synced", true)

@rpc("call_local", "any_peer")
func set_synced(val) -> void:
	self.is_synced = val

