# Greeting
name = input("What's your name?? ")
print("Hello,", name, ", we are going to play a game of Uno!")

# Initialise a deck
import random

deck = []
numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, "skip", "reverse", "draw two"]
colours = ["red", "blue", "yellow", "green"]
wilds = ["wild", "wild draw four"]

for colour in colours:
    for number in numbers:
        deck.append(f"{colour} {number}")

specials = ["Skip", "Reverse", "Draw Two"]
for colour in colours:
    for card in specials:
        deck.append(f"{colour} {card}")

# Wild cards (colorless)
for _ in range(4):
    deck.append("Wild")
    deck.append("Wild Draw Four")


random.shuffle(deck)  # shuffle cards

# Deal 7 cards to both players and draw first card for discard pile
player1 = deck[0:7]
player2 = deck[7:14]
discard_pile = [deck[14]]  # make it a list to avoid errors
deck = deck[15:]            # remaining cards

print("Here are your cards:")
print(player1)
print("This is the starting card:", discard_pile[-1])

# Helper: draw a card
def draw_card(player):
    if deck:
        card = deck.pop()
        player.append(card)
        return card
    else:
        print("Deck is empty!")
        return None

# --- Game loop ---
while True:
    print("Your cards:", player1)
    print("Top of discard pile:", discard_pile[-1])

    # Player 1 turn
    move = input("Play a card (e.g., 'red 5') or type 'draw': ")

    if move.lower() == "draw":
        new_card = draw_card(player1)
        print("You drew:", new_card)
    elif move in player1 and (move.split()[0] == discard_pile[-1].split()[0] or move.split()[1] == discard_pile[-1].split()[1]):
        player1.remove(move)
        discard_pile.append(move)
        print("You played:", move)
    else:
        print("Invalid move! You must draw a card.")
        new_card = draw_card(player1)
        print("You drew:", new_card)

    # Check if Player 1 won
    if len(player1) == 0:
        print("🎉 You win! UNO!")
        break
    elif len(player1) == 1:
        print("⚠️ UNO! You have 1 card left!")

    # Player 2 (computer auto play)
    top_card = discard_pile[-1]
    played = False
    for card in player2:
        if card.split()[0] == top_card.split()[0] or card.split()[1] == top_card.split()[1]:
            player2.remove(card)
            discard_pile.append(card)
            print("Computer played:", card)
            played = True
            break
    if not played:
        new_card = draw_card(player2)
        print("Computer drew a card.")

    # Check if Player 2 won
    if len(player2) == 0:
        print("💻 Computer wins! UNO!")
        break
    elif len(player2) == 1:
        print("⚠️ Computer has UNO! 1 card left")
