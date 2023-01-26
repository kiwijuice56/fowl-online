class_name Lobby
extends Node

# Should store dealer as 0 and players in clockwise order
var players: Array[Player]

var decks: Dictionary
var tricks: Array[Array]
var scores: Array[int] 

var current_bid: int
var bid_winner: int
var trump: Card.Suit

var center_deck: Array[Array]

var center_swap: Array[int]
var discard: Array[int]

func start_game() -> void:
	play_hand()

func play_hand() -> void:
	deal_cards()
	take_bid()
	deal_center()
	# start loop of tricks

func deal_cards() -> void:
	var cards: Array[Array] = []
	
	# Create the deck with every possible card
	for suit_idx in range(1, 5):
		for card_idx in range(1, 16):
			# Cards are represented through an array of [suit, number] 
			# for easier transmission
			var new_card: Array[int] = [0, 0]
			new_card[0] = Card.Suit.values()[suit_idx]
			new_card[1] = card_idx
			cards.append(new_card)
	
	# Deal it randomly among the players
	decks.clear()
	cards.shuffle()
	for player_idx in range(4):
		var player: Player = players[player_idx]
		decks[player.name] = cards.slice(player_idx * 14, (player_idx + 1) * 14)
	
	# Keep the last card in the middle of the table
	center_swap = cards[56]
	
	await send_decks() 

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
		
		await send_bid()

func deal_center() -> void:
	decks[players[bid_winner]].append(center_swap)
	
	await send_center()
	
	discard = await players[bid_winner].request_card()
	remove_card(decks[players[bid_winner].name], discard)
	
	await send_discard()

func remove_card(deck: Array[Array], to_remove: Array[int]) -> void:
	for i in range(len(deck)):
		if deck[i] == to_remove:
			deck.pop_at(i)
			return

# Send the data to the players

func send_decks() -> void: 
	print("Decks are being sent ... ")
	var awaiting: Array[Callable] = []
	for player in players:
		awaiting.append(player.receive_deck.bind(decks[player.name]))
	var promise: Promise = Promise.new()
	await promise.all(awaiting)
	print("Every player has their deck!")

func send_bid() -> void:
	print("The bid is being sent ... ")
	var awaiting: Array[Callable] = []
	for player in players:
		awaiting.append(player.receive_bid.bind(current_bid, bid_winner))
	var promise: Promise = Promise.new()
	await promise.all(awaiting)
	print("Every player has the bid!")

func send_center() -> void:
	print("Giving the center card to the bidder ... ")
	var awaiting: Array[Callable] = []
	for i in range(len(players)):
		if i == bid_winner:
			awaiting.append(players[i].receive_center.bind(center_swap))
		else:
			awaiting.append(players[i].remove_center)
	var promise: Promise = Promise.new()
	await promise.all(awaiting)
	print("The bidder has the center")

func send_discard() -> void:
	print("Notifying each player of the discard ... ")
	var awaiting: Array[Callable] = []
	for i in range(len(players)):
		awaiting.append(players[i].remove_discard)
	var promise: Promise = Promise.new()
	await promise.all(awaiting)
	print("Each player knows the discard is gone!")
