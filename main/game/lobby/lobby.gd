class_name Lobby
extends Node

@onready var lobby_manager: LobbyManager = get_parent()
@onready var game_room: GameRoom = get_tree().get_root().get_node("Main/ViewportContainer/SubViewport/GameRoom")

var local_player: Player 

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

@rpc("any_peer", "call_local")
func start_game() -> void:
	players = get_children()
	players.remove_at(0) # MultiplayerSpawner node
	
	if lobby_manager.local_id == get_multiplayer_authority():
		deal_cards()
		await await_players_synced()
		
		rpc("play_hand")
		await await_players_synced()
		
	else:
		game_room.player = get_node(str(multiplayer.get_unique_id()))
		local_player = game_room.player
		play_hand()

func play_hand() -> void:
	game_room.deck.create_stack()
	await game_room.deck.deal_stack()
	await game_room.deck.hold_hand()
	local_player.is_synced = true

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
	
	cards.shuffle()
	for player_idx in range(2):
		players[player_idx].rpc("update_state", cards.slice(player_idx * 14, (player_idx + 1) * 14))

func await_players_synced() -> void:
	for player in players:
		if not player.is_synced:
			await player.synced
	desync_players()

func desync_players() -> void:
	for player in players:
		player.is_synced = false
