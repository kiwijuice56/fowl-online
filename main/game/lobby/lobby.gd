class_name Lobby
extends Node
# Represents a lobby of players in a match

@onready var lobby_manager: LobbyManager = get_parent()
@onready var game_room: GameRoom = get_tree().get_root().get_node("Main/ViewportContainer/SubViewport/GameRoom")
@onready var main_menu: MainMenu = get_tree().get_root().get_node("Main/UI/MainMenu")
@onready var game_menu: GameMenu = get_tree().get_root().get_node("Main/UI/GameMenu")
@onready var results_menu: ResultsMenu = get_tree().get_root().get_node("Main/UI/ResultsMenu")

var local_player: Player
var code: String
var synced_count: int = 0 # Used to track how many clients are up-to-date on the multiplayer authority

signal synced

## Game state variables

const SCORE_MAP: Dictionary = {5: 5, 10: 10, 14: 10, 1: 15, 0: 20}
var current_player: int = -1

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
	while scores[0] < 150 and scores[1] < 150:
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
	print(decks)
	rpc("update_state", {"current_player": bid_winner, "decks": decks})
	await sync_players(true)
	
	rpc("puppet_take_center", players[bid_winner].id)
	await sync_players(false)
	
	rpc("puppet_other_place_card", players[bid_winner].id, discard, true)
	await sync_players(false)
	
	rpc("puppet_get_trump", players[bid_winner].id)
	await sync_players(true)
	
	current_player = bid_winner
	for play in range(14):
		var winning_player: int = 0
		var highest_rank: int = -1
		for player in range(4):
			if player == 0: # No suit allows for the player to place anything
				rpc("update_state", {"current_player": current_player, "suit": -1})
			else:
				if player == 1: # Declare the leading suit
					suit = center_deck.back()[0]
					if suit == 0:
						suit = trump 
				rpc("update_state", {"current_player": current_player, "suit": suit})
			await sync_players(true)
			
			rpc("puppet_place_card", players[current_player].id)
			await sync_players(true)
			
			var placed_card_rank: int = rank(center_deck.back())
			if placed_card_rank > highest_rank:
				highest_rank = placed_card_rank
				winning_player = player
			
			rpc("puppet_other_place_card", players[current_player].id, center_deck.back(), false)
			await sync_players(false)
			
			current_player = (current_player + 1) % len(players)
		var winning_team: int = winning_player % 2
		tricks[winning_team].append(center_deck.slice(len(center_deck) - 5))
		
		var new_scores: Array[int] = [0, 0]
		
		if len(tricks[0]) > 0:
			for card in tricks[0].back():
				if card[0] in SCORE_MAP:
					new_scores[0] += SCORE_MAP[card[0]]
		if len(tricks[1]) > 0:
			for card in tricks[1].back():
				if card[0] in SCORE_MAP:
					new_scores[1] += SCORE_MAP[card[0]]
		
		if new_scores[bid_winner % 2] < current_bid:
			new_scores[bid_winner % 2] *= -1
		
		scores[0] += new_scores[0]
		scores[1] += new_scores[1]
		
		rpc("update_state", {"tricks": tricks})
		await sync_players(true)
		
		rpc("puppet_take_tricks", winning_team)
		await sync_players(false)
	if len(tricks[0]) > len(tricks[1]):
		scores[0] += 20
	elif len(tricks[1]) > len(tricks[0]):
		scores[1] += 20
	rpc("update_state", {"scores": scores})
	await sync_players(false) 

func initialize_decks() -> void:
	var cards: Array = []
	
	# Create the deck with every possible card
	for suit_idx in range(4):
		for card_idx in range(1, 16):
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
	center_swap = cards[0]

## Puppet methods
# These are used to prompt game events on clients, such as getting a bid or playing a card

@rpc
func puppet_get_bid(id: int) -> void:
	if id == lobby_manager.local_id:
		game_room.camera.lock_movement()
		rpc("update_state", {"current_bid": await game_menu.bid_menu.get_player_bid(current_bid)})
		game_room.camera.unlock_movement()

@rpc
func puppet_get_trump(id: int) -> void:
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
	if lobby_manager.local_lobby_code != code or multiplayer.get_unique_id() == get_multiplayer_authority():
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
	if lobby_manager.local_lobby_code != code or multiplayer.get_unique_id() == get_multiplayer_authority():
		return
	await game_room.deck.stash_trick(winner)
	rpc("increment_synced")

@rpc
func puppet_finish_game() -> void:
	if scores[(local_player.get_index() - 2) % 2] > scores[1 - (local_player.get_index() - 2) % 2]:
		results_menu.declare_winner()
	else:
		results_menu.declare_loser()

## State methods

@rpc("any_peer", "call_local")
func update_state(info: Dictionary) -> void:
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

@rpc("any_peer", "call_local")
func increment_synced() -> void:
	if multiplayer.get_unique_id() != get_multiplayer_authority():
		return
	synced_count += 1
	synced.emit()

func rank(card: Array) -> int:
	var initial_rank: int = [0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 1].find(card[1])
	if card[0] == trump:
		initial_rank *= 2
	elif card[0] != suit and card[0] != trump:
		initial_rank *= -1
	return initial_rank

# Shift indices leftward, where 0 is the local player index
func shift_index(idx: int) -> int:
	# There are two children of the lobby scene that aren't players
	idx = idx - (local_player.get_index() - 2)
	if idx < 0:
		idx += 4
	return idx

# Used on the multiplayer authority to wait for all players to confirm they received data
func sync_players(consider_authority: bool) -> void:
	while synced_count < (5 if consider_authority else 4):
		await synced
	synced_count = 0
