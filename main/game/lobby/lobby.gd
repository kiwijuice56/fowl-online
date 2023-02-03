class_name Lobby
extends Node
# Represents a lobby of players in a match

@onready var lobby_manager: LobbyManager = get_parent()

# We need this reference to handle the game visuals 
@onready var game_room: GameRoom = get_tree().get_root().get_node("Main/ViewportContainer/SubViewport/GameRoom")
# We need this reference to handle transitions when the game starts and ends
@onready var initial_menu: InitialMenu = get_tree().get_root().get_node("Main/UI/InitialMenu")
# We need this reference to handle transitions when the game starts and ends
@onready var game_menu: GameMenu = get_tree().get_root().get_node("Main/UI/GameMenu")

var local_player: Player
var code: String

# # # # # # # GAME STATE # # # # # # # # 

# Should store the dealer at index 0 and hold players in clockwise order
var players: Array

var tricks: Array[Array]
var scores: Array[int] 

var current_bid: int
var bid_winner: int
var trump: Card.Suit

var center_deck: Array[Array]

var center_swap: Array[int]
var discard: Array[int]

# # # # # # # # # # # # # # # # # # # # # 

@rpc("any_peer", "call_local")
func start_game(code: String) -> void:
	# Due to the nature of RPC, this method is called for this lobby node on ALL clients, so we need
	# to ensure that we don't start a game for a client that isn't in this lobby
	
	if lobby_manager.local_id != get_multiplayer_authority() and lobby_manager.local_lobby_code != code:
		return
	
	players = get_children()
	players.remove_at(0) # This is a MultiplayerSpawner node, so remove it from the player list
	players.remove_at(0) # MultiplayerSynchronizer
	
	if lobby_manager.local_id == get_multiplayer_authority():
		await sync_players()
		print(code + ": Game loop started")
		game_loop()
	else:
		game_room.player = get_node(str(multiplayer.get_unique_id()))
		local_player = game_room.player
		
		await initial_menu.mini_lobby_menu.exit()
		initial_menu.visible = false
		get_node(str(local_player.name)).rpc("set_synced", true)

func game_loop() -> void:
	while true:
		print(code + ": Hand started")
		await play_hand()

func play_hand() -> void:
	if lobby_manager.local_id != get_multiplayer_authority() and lobby_manager.local_lobby_code != code:
		return
	
	var passed_players: Dictionary
	
	current_bid = 70
	bid_winner = 0
	var bidder: int = 0
	
	rpc("puppet_update_state", 70)
	await sync_players()
	
	while current_bid < 200 and len(passed_players) < 3:
		if not bidder in passed_players:
			var previous_bid: int = current_bid
			rpc("puppet_get_bid", players[bidder].id)
			print(code + ": Getting bid from " + players[bidder].username)
			await sync_players()
			print(code + ": Bid gotten from " + players[bidder].username)
			
			if current_bid == previous_bid:
				passed_players[bidder] = true
			else:
				bid_winner = bidder
			# TODO: Play animations of the current bid
		bidder = (bidder + 1) % len(players)
		print(bidder, " ", current_bid)
	# TODO: Play animations for the bid winner, including giving the bid data again
	
	deal_cards()
	await sync_players()
	
	rpc("puppet_take_deck")
	await sync_players()

func deal_cards() -> void:
	var cards: Array = []
	
	# Create the deck with every possible card
	for suit_idx in range(4):
		for card_idx in range(1, 16):
			# Cards are represented through an array of [suit, number] 
			# for easier transmission
			var new_card: Array[int] = [0, 0]
			new_card[0] = Card.Suit.values()[suit_idx]
			new_card[1] = card_idx
			cards.append(new_card)
	cards.append([0, 16])
	
	cards.shuffle()
	for player_idx in range(4):
		players[player_idx].rpc("update_state", cards.slice(player_idx * 14, (player_idx + 1) * 14))
	center_swap = cards[0]

func sync_players() -> void:
	for player in players:
		if not player.is_synced:
			await player.synced
	for player in players:
		player.rpc("set_synced", false)

@rpc
func puppet_get_bid(id: int) -> void:
	if lobby_manager.local_lobby_code != code:
		return
	if id == lobby_manager.local_id:
		current_bid = await game_menu.bid_menu.get_player_bid()
		rpc("puppet_update_state", current_bid)
	else:
		game_menu.bid_menu.update_bid(current_bid)

@rpc
func puppet_take_deck() -> void:
	game_room.deck.create_stack()
	await game_room.deck.deal_stack()
	await game_room.deck.hold_hand()
	local_player.rpc("set_synced", true)

@rpc("any_peer", "call_local")
func puppet_update_state(bid: int) -> void:
	if multiplayer.get_unique_id() == get_multiplayer_authority():
		return
	
	current_bid = bid
	game_menu.bid_menu.update_bid(current_bid)
	local_player.rpc("set_synced", true)
