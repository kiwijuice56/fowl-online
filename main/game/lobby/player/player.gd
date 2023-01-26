class_name Player
extends Node

var username: String
var icon: int

@rpc
func request_bid(current: int) -> int:
	return 70

@rpc
func request_card() -> Array[int]:
	return null

# # # #

@rpc
func receive_deck(deck: Array[int]) -> void:
	pass

@rpc
func receive_bid(bid: int, bid_winner: int) -> void:
	pass

@rpc
func receive_center(center: Array[int]) -> void:
	pass

@rpc
func remove_center() -> void:
	pass

@rpc
func remove_discard() -> void:
	pass
