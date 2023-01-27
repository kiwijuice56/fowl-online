class_name Lobby
extends Node

@onready var lobby_manager: LobbyManager = get_parent()

# Should store dealer as 0 and players in clockwise order
var players: Array

var tricks: Array[Array]
var scores: Array[int] 

var current_bid: int
var bid_winner: int
var trump: Card.Suit

var center_deck: Array[Array]

var center_swap: Array[int]
var discard: Array[int]

@rpc(any_peer)
func start_game() -> void:
	if lobby_manager.local_id == get_multiplayer_authority():
		pass
	play_hand()

func play_hand() -> void:
	deal_cards()

@rpc(any_peer)
func deal_cards() -> void:
	if multiplayer.get_unique_id() != get_multiplayer_authority():
		return
	players = get_children()
	players.remove_at(0) # MultiplayerSpawner node
	
	var cards: Array[Card] = []
	
	# Create the deck with every possible card
	for suit_idx in range(4):
		for card_idx in range(1, 16):
			# Cards are represented through an array of [suit, number] 
			# for easier transmission
			var new_card: Card = Card.new()
			new_card.suit = Card.Suit.values()[suit_idx]
			new_card.number = card_idx
			cards.append(new_card)
	
	cards.shuffle()
	for player_idx in range(4):
		players[player_idx].rpc("update_state", cards.slice(player_idx * 14, (player_idx + 1) * 14))
