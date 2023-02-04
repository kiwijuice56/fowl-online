class_name Lobby
extends Node
# Represents a lobby of players in a match

@onready var lobby_manager: LobbyManager = get_parent()
@onready var game_room: GameRoom = get_tree().get_root().get_node("Main/ViewportContainer/SubViewport/GameRoom")
@onready var main_menu: MainMenu = get_tree().get_root().get_node("Main/UI/MainMenu")
@onready var game_menu: GameMenu = get_tree().get_root().get_node("Main/UI/GameMenu")

var local_player: Player
var code: String
var synced_count: int = 0

signal synced

## Game state variables

var current_player: int = -1

# Should store the dealer at index 0 and hold players in clockwise order
var players: Array
var decks: Array

var tricks: Array[Array]
var scores: Array[int] 

var current_bid: int
var bid_winner: int
var trump: Card.Suit

var center_deck: Array[Array]

var center_swap: Array[int]
var discard: Array[int]

@rpc("any_peer", "call_local")
func start_game(code: String) -> void:
	# Due to the nature of RPC, this method is called for this lobby node on ALL clients, so we need
	# to ensure that we don't start a game for a client that isn't in this lobby
	
	if lobby_manager.local_id != get_multiplayer_authority() and lobby_manager.local_lobby_code != code:
		return
	
	players = get_children()
	players.remove_at(0) # This is a MultiplayerSpawner node, so remove it from the player list
	players.remove_at(0) # MultiplayerSynchronizer, remove as well
	
	if lobby_manager.local_id == get_multiplayer_authority():
		await sync_players(false)
		print(code + ": Game loop started")
		game_loop()
	else:
		local_player = get_node(str(multiplayer.get_unique_id()))
		game_room.lobby = self
		game_room.player_idx = local_player.get_index() - 2
		game_room.initialize_players(players)
		
		await main_menu.mini_lobby_menu.exit()
		await main_menu.exit()
		game_menu.info_overlay.set_bid_information(null, 0)
		game_menu.info_overlay.initialize_scoreboard(players)
		await game_menu.enter()
		rpc("increment_synced")

func game_loop() -> void:
	while true:
		print(code + ": Hand started")
		await play_hand()

func play_hand() -> void:
	var passed_players: Dictionary = {}
	
	current_bid = 65
	bid_winner = 0
	current_player = 0
	initialize_decks()
	rpc("update_state", {"bid": 65, "bid_winner": -1, "decks": decks})
	await sync_players(true)
	
	rpc("puppet_take_deck")
	await sync_players(false)
	
	while current_bid < 200 and len(passed_players) < 3:
		if not current_player in passed_players:
			rpc("update_state", {"current_player": current_player})
			await sync_players(true)
			
			var previous_bid: int = current_bid
			rpc("puppet_get_bid", players[current_player].id)
			await sync_players(true)
			
			if current_bid == previous_bid:
				passed_players[current_player] = true
			else:
				bid_winner = current_player
			
			rpc("update_state", {"bid": current_bid, "bid_winner": bid_winner})
			await sync_players(true)
			# TODO: Play animations of the current bid
		current_player = (current_player + 1) % len(players)
		print(current_player, " ", current_bid)
	

func initialize_decks() -> void:
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
		decks.append(cards.slice(player_idx * 14, (player_idx + 1) * 14))
	center_swap = cards[0]

@rpc
func puppet_get_bid(id: int) -> void:
	if lobby_manager.local_lobby_code != code:
		return
	if id == lobby_manager.local_id:
		current_bid = await game_menu.bid_menu.get_player_bid(current_bid)
		rpc("update_state", {"bid": current_bid})

@rpc
func puppet_take_deck() -> void:
	game_room.deck.create_stack()
	await game_room.deck.deal_stack()
	await game_room.deck.hold_hand()
	rpc("increment_synced")

@rpc("any_peer", "call_local")
func update_state(info: Dictionary) -> void:
	rpc("increment_synced")
	
	if "bid" in info:
		current_bid = info.bid
	if "decks" in info:
		decks = info.decks
	
	if multiplayer.get_unique_id() != get_multiplayer_authority():
		if "bid_winner" in info: 
			game_menu.info_overlay.set_bid_information(players[info.bid_winner] if info.bid_winner != -1 else null, info.bid)
		if "current_player" in info:
			if current_player != -1:
				game_room.player_sprites[current_player].set_current_player(false)
			current_player = info.current_player
			game_room.player_sprites[current_player].set_current_player(true)
		# other ui things here

@rpc("any_peer", "call_local")
func increment_synced() -> void:
	if multiplayer.get_unique_id() != get_multiplayer_authority():
		return
	synced_count += 1
	synced.emit()

func sync_players(consider_authority: bool) -> void:
	while synced_count < (5 if consider_authority else 4):
		await synced
	synced_count = 0
