class_name Player
extends Node

var username: String
var icon: int

var deck: Array[Card]

@rpc("call_local")
func update_state(deck: Array[Card]) -> void:
	self.deck = deck
	if multiplayer.get_remote_sender_id() == multiplayer.get_unique_id():
		print(str(multiplayer.get_unique_id()) + " deck: ")
		for card in deck:
			print(str(card.number) + " " + str(card.suit))
		print()
