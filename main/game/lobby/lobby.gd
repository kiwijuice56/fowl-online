class_name Lobby
extends Node

# const suits: Array[Card.Suit] = [Card.Suit.RED, Card.Suit.YELLOW, Card.Suit.BLUE, Card.Suit.GREEN]

# Should store dealer as 0 and players in clockwise order
var players: Array[Player]

var decks: Dictionary
var tricks: Array[Card]
var scores: Array[int] 

var current_bid: int
var bid_winner: int
var trump: Card.Suit

var center_deck: Array[Card]

var center_swap: Card
var discard: Card

func start_game() -> void:
	play_hand()

func play_hand() -> void:
	deal_cards()
	take_bid()
	deal_center()
	# start loop of tricks

func deal_cards() -> void:
	var cards: Array[Card] = []
	
	# Create the deck with every possible card
	for suit_idx in range(1, 5):
		for card_idx in range(1, 16):
			var new_card: Card = Card.new()
			new_card.suit = Card.Suit.values()[suit_idx]
			new_card.number = card_idx
			cards.append(new_card)
	
	# Deal it randomly among the players
	decks.clear()
	cards.shuffle()
	for player_idx in range(4):
		var player: Player = players[player_idx]
		decks[player.name] = cards.slice(player_idx * 14, (player_idx + 1) * 14)
	center_swap = cards[56]
	
	await remote_deal_cards()

func take_bid() -> void:
	var passed_players: Dictionary = {}
	var bidding_idx: int = 0
	bid_winner = 0
	current_bid = 70
	
	while current_bid < 200 and len(passed_players) < 4:
		bidding_idx = (bidding_idx + 1) % len(players)
		
		var bidding_player = players[bidding_idx]
		if bidding_player.name in passed_players:
			continue
		
		var next_bid: int = await bidding_player.request_bid(current_bid)
		
		if next_bid == -1:
			passed_players[bidding_player.name] = true
			continue
		
		bid_winner = bidding_idx
		current_bid = clamp(next_bid, current_bid + 5, 200)
		
		await remote_update_bid()

func deal_center() -> void:
	decks[players[bid_winner]].append(center_swap)
	
	await remote_update_center()
	
	discard = await players[bid_winner].request_card()
	remove_card(decks[players[bid_winner].name], discard)
	
	await remote_update_discard()

func remove_card(deck: Array[Card], to_remove: Card) -> void:
	for i in range(len(deck)):
		if deck[i].equals(to_remove):
			deck.pop_at(i)
			return

# Interfacing the data with the players

func remote_deal_cards() -> void:
	print("Cards are being dealt ... ")

func remote_update_bid() -> void:
	print("Giving bid to all players")

func remote_update_center() -> void:
	print("Updating center for all players")

func remote_update_discard() -> void:
	print("Updating discard for all players")
