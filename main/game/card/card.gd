class_name Card
extends Node

enum Suit { RED = 1, YELLOW = 2, BLUE = 3, GREEN = 4 }

var suit: Suit = Suit.RED
var number: int = 1

func equals(other: Card) -> bool:
	return other.suit == suit and other.number == number
