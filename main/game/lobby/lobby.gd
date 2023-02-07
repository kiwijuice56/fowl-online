class_name Lobby
extends Node
# Represents a lobby of players in a match

@onready var lobby_manager: LobbyManager = get_parent()
@onready var game_room: GameRoom = get_tree().get_root().get_node("Main/ViewportContainer/SubViewport/GameRoom")
@onready var main_menu: MainMenu = get_tree().get_root().get_node("Main/UI/MainMenu")
@onready var game_menu: GameMenu = get_tree().get_root().get_node("Main/UI/GameMenu")

var local_player: Player
var code: String
var synced_count: int = 0 # Used to track how many clients are up-to-date on the multiplayer authority

signal synced

## Game state variables

var current_player: int = 0

# Should store the host/dealer at index 0 and the other players in clockwise order
var players: Array

# 3D array of card suits and numbers
# The deck at index 0 belongs to the host/dealer of a lobby
# Note that this is different from the GameDeck representation, which has the local player at index 0
var decks: Array

var tricks: Array[Array]
var scores: Array[int] 

var current_bid: int
var bid_winner: int
var trump: Card.Suit
var suit: Card.Suit

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
		game_loop()
	else:
		# Initialize game data for all players
		local_player = get_node(str(multiplayer.get_unique_id()))
		game_room.lobby = self
		game_room.player_idx = local_player.get_index() - 2
		game_room.initialize_players(players)
		
		await main_menu.mini_lobby_menu.exit()
		await main_menu.exit()
		game_menu.info_overlay.set_bid_information(null, 0)
		game_menu.info_overlay.initialize_scoreboard(players)
		tricks = [[], []]
		scores = []
		await game_menu.enter()
		rpc("increment_synced")

func game_loop() -> void:
	await play_hand()

func play_hand() -> void:
	var passed_players: Dictionary = {}
	
	# Initialize hand data for all players
	initialize_decks()
	rpc("update_state", {"current_bid": 65, "bid_winner": -1, "decks": decks, "center_swap": center_swap, "center_deck": [], "trump": -1, 
	"suit": -1, "discard": []})
	await sync_players(true)
	
	rpc("puppet_take_deck")
	await sync_players(false)
	
	current_player = 0
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
			
			rpc("update_state", {"current_bid": current_bid, "bid_winner": bid_winner})
			await sync_players(true)
		current_player = (current_player + 1) % len(players)
	decks[bid_winner].append(center_swap)
	rpc("update_state", {"current_player": bid_winner, "decks": decks})
	await sync_players(true)
	
	rpc("puppet_take_center", players[bid_winner].id)
	await sync_players(false)
	
	rpc("puppet_other_place_card", players[bid_winner].id, discard, true)
	await sync_players(false)
	
	rpc("puppet_get_trump", players[bid_winner].id)
	await sync_players(true)
	
	current_player = bid_winner
	for _i in range(14):
		for j in range(4):
			if j != 0:
				rpc("update_state", {"current_player": current_player, "suit": center_deck[len(center_deck) - 1][0]})
			else:
				rpc("update_state", {"current_player": current_player, "suit": -1})
			await sync_players(true)
			
			rpc("puppet_place_card", players[current_player].id)
			await sync_players(true)
			
			rpc("puppet_other_place_card", players[current_player].id, center_deck[len(center_deck) - 1], false)
			await sync_players(false)
			
			current_player = (current_player + 1) % len(players)
		# Get the winner of the trick, move the cards, continue

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
	cards.append([0, 0])
	
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
		rpc("update_state", {"current_bid": current_bid})

@rpc
func puppet_get_trump(id: int) -> void:
	if lobby_manager.local_lobby_code != code:
		return
	if id == lobby_manager.local_id:
		trump = await game_menu.trump_menu.get_player_trump()
		rpc("update_state", {"trump": trump})

@rpc
func puppet_take_deck() -> void:
	if lobby_manager.local_lobby_code != code:
		return
	game_room.deck.create_stack()
	await game_room.deck.deal_stack()
	await game_room.deck.hold_hand()
	rpc("increment_synced")

@rpc
func puppet_take_center(id: int) -> void:
	if lobby_manager.local_lobby_code != code:
		return
		
	var translated_idx: int = shift_index(bid_winner)
	
	# Add the card model to the correct player
	if id == lobby_manager.local_id:
		game_room.deck.cards[0].set_text(center_swap[0], center_swap[1])
	game_room.deck.decks[translated_idx].append(game_room.deck.cards[0])
	await game_room.deck.update_hand(translated_idx)
	
	if id == lobby_manager.local_id:
		# The lobby has two children that aren't players, so we must offset
		decks[local_player.get_index() - 2].append(center_swap)
		var discard_data: Array = await game_room.camera.select_card(-1, -1, false)
		await game_room.deck.place_card(0, discard_data[0], true)
		decks[bid_winner].remove_at(decks[bid_winner].find(discard_data[1]))
		rpc("update_state", {"discard": discard_data[1], "decks": decks})

@rpc
func puppet_place_card(id: int) -> void:
	if lobby_manager.local_lobby_code != code:
		return
	if id == lobby_manager.local_id:
		var card_data: Array = await game_room.camera.select_card(suit, trump, true)
		await game_room.deck.place_card(0, card_data[0], false)
		decks[local_player.get_index() - 2].remove_at(decks[local_player.get_index() - 2].find(card_data[1]))
		center_deck.append(card_data[1])
		rpc("update_state", {"decks": decks, "center_deck": center_deck})

# Places down a random card model from the id player, drawing the card data onto it 
# This is used so that other players can see another player place a card
# The id player will have to find the actual selected card to place it, but the specific card doesn't matter
# for other players because they never see the decks of other players
@rpc
func puppet_other_place_card(id: int, card: Array, face_down: bool) -> void:
	if lobby_manager.local_lobby_code != code or multiplayer.get_unique_id() == get_multiplayer_authority():
		return
	if id == lobby_manager.local_id:
		rpc("increment_synced")
		return
	var translated_idx: int = shift_index(get_node(str(id)).get_index() - 2)
	if not face_down:
		game_room.deck.decks[translated_idx][0].set_text(card[0], card[1])
	await game_room.deck.place_card(translated_idx, game_room.deck.decks[translated_idx][0], face_down)
	rpc("increment_synced")

@rpc("any_peer", "call_local")
func update_state(info: Dictionary) -> void:
	rpc("increment_synced")
	
	var past_player: int = current_player
	
	for property in info.keys():
		set(property, info[property])
	
	if multiplayer.get_unique_id() != get_multiplayer_authority():
		if "bid_winner" in info: 
			game_menu.info_overlay.set_bid_information(players[info.bid_winner] if info.bid_winner != -1 else null, info.current_bid)
		if "current_player" in info:
			if past_player != -1:
				game_room.player_sprites[past_player].set_current_player(false)
			game_room.player_sprites[current_player].set_current_player(true)
		if "trump" in info:
			game_menu.info_overlay.set_trump(trump)
		# Other UI updates would go here

@rpc("any_peer", "call_local")
func increment_synced() -> void:
	if multiplayer.get_unique_id() != get_multiplayer_authority():
		return
	synced_count += 1
	synced.emit()

func rank(card: Array) -> int:
	# TODO
	return 0

# Shift indices leftward, where 0 is the local player index
func shift_index(idx: int) -> int:
	idx = idx - (local_player.get_index() - 2)
	if idx < 0:
		idx += 4
	return idx

func sync_players(consider_authority: bool) -> void:
	while synced_count < (5 if consider_authority else 4):
		await synced
	synced_count = 0
