class_name Player
extends Node

var username: String
var icon: int

@rpc
func request_bid(current: int) -> int:
	return 70

@rpc
func request_card() -> Card:
	return null
