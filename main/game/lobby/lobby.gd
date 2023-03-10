class_name Lobby
extends Node
# Represents a lobby of players in a match

# This script contains the bulk of the networking code, as it handles both the client and authority

# References to UI and 3D visuals to handle game state
@onready var lobby_manager: LobbyManager = get_parent()
@onready var game_room: GameRoom = get_tree().get_root().get_node("Main/ViewportContainer/SubViewport/GameRoom")
@onready var main_menu: MainMenu = get_tree().get_root().get_node("Main/UI/MainMenu")
@onready var game_menu: GameMenu = get_tree().get_root().get_node("Main/UI/GameMenu")
@onready var results_menu: ResultsMenu = get_tree().get_root().get_node("Main/UI/ResultsMenu")

# Identification variables for each lobby
# local_player is null on the authority
var local_player: Player
var code: String

var synced_count: int = 0 # Used to track how many clients are up-to-date on the multiplayer authority
signal synced

# Game state variables
const SCORE_MAP: Dictionary = {5: 5, 10: 10, 14: 10, 1: 15, 0: 20}

# 3D array of card suits and numbers
# The deck at index 0 belongs to the host/dealer of a lobby
# Note that this is different from the GameDeck representation, which has the local player at index 0
var decks: Array
var current_player: int = -1 # The index of which player has their turn
var players: Array # Stores references to player nodes, host/dealer at index 0 and the other players in clockwise order
var tricks: Array[Array] # An array of two arrays, each containing another array for each trick gained per team
var scores: Array[int] # An array of two integers representing the scores for each team
var current_bid: int # The currently highest bid 
var bid_winner: int # The index of the player that gave the highest bid
var trump: Card.Suit # The trump suit of a round
var suit: Card.Suit # The leading suit of a play
var center_deck: Array[Array] # The cards at the center of the table
var center_swap: Array[int] # The extra card to be given to the bid winner
var discard: Array[int] # The card discarded by the bid winner

# Called by MainMenu to begin a game with the four players in this lobby
@rpc("any_peer", "call_local")
func start_game() -> void:
	# Due to the nature of RPC, this method is called for this lobby node on ALL clients, so we need
	# to ensure that we don't start a game for a client that isn't in this lobby
	if lobby_manager.local_id != get_multiplayer_authority() and lobby_manager.local_lobby_code != code:
		return
	
	players = get_children()
	players.remove_at(0) # This is a MultiplayerSpawner node, so remove it from the player list
	players.remove_at(0) # MultiplayerSynchronizer, remove as well
	
	tricks = [[], []]
	scores = [0, 0]
	
	if lobby_manager.local_id == get_multiplayer_authority():
		await sync_players(false)
		game_loop()
	else:
		# Initialize game data for all players
		local_player = get_node(str(multiplayer.get_unique_id()))
		game_room.lobby = self
		game_room.player_idx = local_player.get_index() - 2
		game_room.initialize_players(players)
		game_room.camera.unlock_movement()
		
		await main_menu.mini_lobby_menu.exit()
		await main_menu.exit()
		game_menu.info_overlay.set_bid_information(null, 0)
		game_menu.info_overlay.initialize_scoreboard(players)
		
		await game_menu.enter()
		rpc("increment_synced")

func game_loop() -> void:
	while scores[0] < 500 and scores[1] < 500:
		await play_hand()
		await get_tree().create_timer(4).timeout
	rpc("puppet_finish_game")

func play_hand() -> void:
	var passed_players: Dictionary = {}
	
	# Initialize hand data for all players
	initialize_decks()
	rpc("update_state", {"current_bid": 65, "bid_winner": -1, "decks": decks, "center_swap": center_swap, 
	"center_deck": [], "trump": -1, "suit": -1, "discard": []})
	await sync_players(true)
	
	rpc("puppet_take_deck")
	await sync_players(false)
	
	# Begin the bidding phase
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
	
	# Allow the bidder to take the center swap and declare the trump suit
	decks[bid_winner].append(center_swap)
	rpc("update_state", {"current_player": bid_winner, "decks": decks})
	await sync_players(true)
	
	rpc("puppet_take_center", players[bid_winner].id)
	await sync_players(false)
	
	rpc("puppet_other_place_card", players[bid_winner].id, discard, true)
	await sync_players(false)
	
	rpc("puppet_get_trump", players[bid_winner].id)
	await sync_players(true)
	
	# Begin the playing phase
	current_player = bid_winner
	for play in range(14):
		var winning_player: int = 0
		var highest_rank: int = -1
		for player in range(4):
			# A suit of -1 allows for the first player to place anything
			rpc("update_state", {"current_player": current_player, "suit": -1 if player == 0 else suit})
			await sync_players(true)
			
			rpc("puppet_place_card", players[current_player].id)
			await sync_players(true)
			
			if player == 0: # Declare the leading suit after the first player plays
				suit = center_deck.back()[0]
				if suit == 0:
					suit = trump # The rook will declare the suit as the current trump
			
			var placed_card_rank: int = rank(center_deck.back())
			if placed_card_rank > highest_rank:
				highest_rank = placed_card_rank
				winning_player = current_player
			
			rpc("puppet_other_place_card", players[current_player].id, center_deck.back(), false)
			await sync_players(false)
			
			current_player = (current_player + 1) % len(players)
		
		# Give the trick to the winning team
		var winning_team: int = winning_player % 2
		tricks[winning_team].append(center_deck.slice(len(center_deck) - 4))
		rpc("update_state", {"tricks": tricks})
		await sync_players(true)
		
		rpc("puppet_take_tricks", winning_team)
		await sync_players(false)
	
	# Scoring phase begins
	var new_scores: Array[int] = [0, 0]
	for team in range(2):
		for trick in tricks[team]:
			for card in trick:
				if card[1] in SCORE_MAP:
					new_scores[team] += SCORE_MAP[card[1]]
	
	if new_scores[bid_winner % 2] < current_bid:
		new_scores[bid_winner % 2] *= -1
	scores[0] += new_scores[0]
	scores[1] += new_scores[1]
	
	if len(tricks[0]) > len(tricks[1]):
		scores[0] += 20
	elif len(tricks[1]) > len(tricks[0]):
		scores[1] += 20
	tricks = [[], []]
	rpc("update_state", {"scores": scores, "tricks": tricks})
	await sync_players(true) 

## Puppet methods
# These are used to prompt game events on clients, such as getting a bid or playing a card

@rpc
func puppet_get_bid(id: int) -> void:
	if lobby_manager.local_lobby_code != code:
		return
	if id == lobby_manager.local_id:
		game_room.camera.lock_movement()
		rpc("update_state", {"current_bid": await game_menu.bid_menu.get_player_bid(current_bid)})
		game_room.camera.unlock_movement()

@rpc
func puppet_get_trump(id: int) -> void:
	if lobby_manager.local_lobby_code != code:
		return
	if id == lobby_manager.local_id:
		game_room.camera.lock_movement()
		rpc("update_state", {"trump": await game_menu.trump_menu.get_player_trump()})
		game_room.camera.unlock_movement()

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
	
	# Add the card model to the correct player, but only set the text if the client is the receiving player 
	if id == lobby_manager.local_id:
		game_room.deck.cards[0].set_text(center_swap[0], center_swap[1])
	game_room.deck.decks[translated_idx].append(game_room.deck.cards[0])
	await game_room.deck.deal_card(0, translated_idx, 0)
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
	if lobby_manager.local_lobby_code != code:
		return
	if id == lobby_manager.local_id:
		rpc("increment_synced") # The player presumably already placed a card on their client
		return
	var translated_idx: int = shift_index(get_node(str(id)).get_index() - 2)
	if not face_down: # Don't draw the text on face down cards to prevent glimpses of the front
		game_room.deck.decks[translated_idx][0].set_text(card[0], card[1])
	await game_room.deck.place_card(translated_idx, game_room.deck.decks[translated_idx][0], face_down)
	rpc("increment_synced")

@rpc
func puppet_take_tricks(winner: int) -> void:
	if lobby_manager.local_lobby_code != code:
		return
	await game_room.deck.stash_trick(winner)
	rpc("increment_synced")

@rpc
func puppet_finish_game() -> void:
	if lobby_manager.local_lobby_code != code:
		return
	if scores[(local_player.get_index() - 2) % 2] > scores[1 - (local_player.get_index() - 2) % 2]:
		results_menu.declare_winner()
	else:
		results_menu.declare_loser()

@rpc("any_peer", "call_local")
func update_state(info: Dictionary) -> void:
	if lobby_manager.local_id != get_multiplayer_authority() and lobby_manager.local_lobby_code != code:
		return
	rpc("increment_synced")
	
	var past_player: int = current_player
	
	for property in info.keys():
		set(property, info[property])
	
	# Place any UI updates here; The authority has no UI and thus does not need to update here
	if multiplayer.get_unique_id() != get_multiplayer_authority():
		if "bid_winner" in info: 
			game_menu.info_overlay.set_bid_information(players[info.bid_winner] if info.bid_winner != -1 else null, info.current_bid)
		if "current_player" in info:
			if past_player != -1:
				game_room.player_sprites[past_player].set_current_player(false)
			game_room.player_sprites[current_player].set_current_player(true)
			if past_player != current_player:
				game_menu.show_current_player(players[current_player].username)
		if "trump" in info:
			game_menu.info_overlay.set_trump(trump)
		if "scores" in info:
			game_menu.info_overlay.set_scores(scores)

## Authority helper methods

# Initialize the decks of each player by randomly dealing 56 cards 
func initialize_decks() -> void:
	var cards: Array = []
	
	for suit_idx in range(4):
		for card_idx in range(1, 15): 
			# Cards are represented through an array of [suit, number] because Objects are not easily sent over RPC
			var new_card: Array[int] = [0, 0]
			new_card[0] = Card.Suit.values()[suit_idx]
			new_card[1] = card_idx
			cards.append(new_card)
	cards.append([0, 0]) # The fowl card
	decks.clear()
	
	cards.shuffle()
	for player_idx in range(4):
		decks.append(cards.slice(player_idx * 14, (player_idx + 1) * 14))
	center_swap = cards[len(cards) - 1]

# Returns the relative rank of a card, depending on the trump and leading suit
func rank(card: Array) -> int:
	var initial_rank: int = [0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 1].find(card[1])
	if card[0] == trump:
		initial_rank += 32
	elif card[0] != suit and card[0] != trump:
		initial_rank -= 32
	return initial_rank

# Shift indices leftward, where 0 is the local player index
# Used to convert from arrays in this node to those in the GameDeck node
func shift_index(idx: int) -> int:
	# There are two children of the lobby scene that aren't players
	idx = idx - (local_player.get_index() - 2)
	if idx < 0:
		idx += 4
	return idx

# Called from puppets to the authority to notify that the client is synced
@rpc("any_peer", "call_local")
func increment_synced() -> void:
	if multiplayer.get_unique_id() != get_multiplayer_authority():
		return
	synced_count += 1
	synced.emit()

# Used on the multiplayer authority to wait for all players to confirm they received data
func sync_players(consider_authority: bool) -> void:
	while synced_count < (5 if consider_authority else 4):
		await synced
	synced_count = 0
