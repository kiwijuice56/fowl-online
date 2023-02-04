# Fowl Online
Fowl is an online recreation of the classic card game, Rook, using Godot 4. The server (to be configured later) runs on Linode to connect players and simulate the gameplay. Fowl is completely open-source and free. Contact the author (alfaroeric127@gmail.com) if you run into any issues or bugs.

## Creating a match
1. On the first screen, create a profile with your username (typed in the box) and a profile image (selected with the arrows). No data is stored for your player; Your profile is only a temporary visual representation of your user and it is deleted when the game is closed. Click "Go" when complete.

2. If you plan to invite your friends, click "Create Game". A three-word code will be automatically generated. Copy this code and send it to your friends! Instruct them to click "Join Game" from the main menu, paste the code into the box, and press "Go". When all four players are in the game, the host must press "Start Game".

## Overview
The goal of Fowl is to be the first team to reach 500 points winning tricks and bidding (see definitions below). Before the game starts, four players are split into two teams. 

The gameplay of Fowl is organized into rounds consisting of a bidding and playing stage. Points are earned by collecting counters within tricks in the playing stage.

### Bidding Stage
Before the round starts, each player receives  a hand of 14 cards that must be kept secret, even from their own team. Because the deck has 57 cards, the final card is placed face-down in the center of the table.

In the bidding stage, each player must make a wager of how many points their team can collect in the playing stage by assessing their hand. The player who offers the highest bid gets more power to strategically earn points, but risks losing score if they underperform in the playing stage. Players make sequentially higher bids, attempting to either force a risky bid on their opponents or take the bid for themselves.

Specifically, the first bid is made by the player left of the dealer (the host) and continues clockwise in a cycle. A bid must be in between 70 and 200 points while also being higher than the previous bid. If a player does not want to offer a higher bid, they can pass their turn to the next player. A player who passes their turn cannot bid again for the rest of the round.

The winner of the bid (the player with the highest bid) takes the center card and adds it to their deck. The winner must then discard any card (except a counter card), face-down next to them. Finally, the winner declares the color of the trump suit and the playing stage begins. 

### Playing Stage
A play consists of each player placing down a card, with the object of placing down the highest ranking card in order to "take the trick" and earn the sum of counter points for their team. The strategy is to place cards that win tricks with counters while conserving your powerful cards as the plays progress. 

The winner of the bid starts by placing any card face-up in the center of the table. Going clockwise, players follow suit by placing cards of the same color. If they can't follow suit, they must play cards of the trump suit. If the player has no cards of the trump suit either, they may play any card.

After all four players place a card, the player who placed the highest ranking card takes the trick for their own team to add to their score later. The playing stage continues, starting from the winner of the last play and stopping only once every player is out of cards.

The rankings of the cards go in the order of (from highest to lowest): `1 14 13 ... 3 2 fowl`. The trump suit follows the same rankings and is higher ranking than other suits by default. For example, if a player leads with a `red 1` while blue is trump, placing a `blue 7` would take the trick from that player. Note that the fowl card is colorless and thus always a trump, making it strategic to "fish it out" for more points.

Finally, the points earned by each team are counted by the number of counter cards in their respective tricks. If the bidding team did not fulfill their wager, the number of points bid is subtracted from their score. Otherwise, both teams add their earned points to their score. The team that takes the majority of tricks receives 20 bonus points. The bidding stage begins again, continuing in a cycle until any team reaches 500 points.

### Definitions
* Bid: The minimum number of points a bidder believes they can earn in  a round.
* Counter: Certain cards that have a point value. A 5 is worth 5 points, each 10 and 14 worth 10 points, aces are worth 15 points, and the Fowl is worth 20 points.
* Trick: A set of four cards, won by the team who placed the highest card in a play.
* Trump: The secondary suit color that may only be placed if a player has no cards to follow suit. Trump cards are ranked higher than cards of the suit in a play.
