# Greeting
name = input("What's your name?? ")
print("Hello,", name, ", we are going to play a game of Uno!")

# Initialise a deck
import random

deck = []
numbers = [0,1,2,3,4,5,6,7,8,9]
colours = ["red","blue","yellow","green"]
specials = ["Skip", "Reverse", "Draw Two"]

for colour in colours:
    for number in numbers:
        deck.append(f"{colour} {number}")
    for card in specials:
        deck.append(f"{colour} {card}")

# Add Wild cards
for _ in range(4):
    deck.append("Wild")
    deck.append("Wild Draw Four")

random.shuffle(deck)

# Deal 7 cards to both players
player1 = deck[:7]
player2 = deck[7:14]

# Draw first card for discard pile
discard_pile = [deck[14]]  # make it a list
deck = deck[15:]  # remaining cards

print("\nHere are your cards:", player1)
print("Player 2's cards:", player2)
print("Starting card:", discard_pile[-1])

# Helper function to draw a card
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
    # --- Player 1 turn ---
    print("\nYour cards:", player1)
    print("Top of discard pile:", discard_pile[-1])
    move = input("Play a card (e.g., 'red 5') or type 'draw': ")

    if move.lower() == "draw":
        new_card = draw_card(player1)
        print("You drew:", new_card)
    elif move in player1:
        top_card = discard_pile[-1]
        valid = False
        # check if card can be played
        if move in ["Wild", "Wild Draw Four"]:
            valid = True
        else:
            move_parts = move.split()
            top_parts = top_card.split()
            if len(move_parts) > 1 and len(top_parts) > 1:
                if move_parts[0] == top_parts[0] or move_parts[1] == top_parts[1]:
                    valid = True
        if valid:
            player1.remove(move)
            discard_pile.append(move)
            print("You played:", move)
        else:
            print("Invalid move! You must draw a card.")
            new_card = draw_card(player1)
            print("You drew:", new_card)
    else:
        print("Invalid move! You must draw a card.")
        new_card = draw_card(player1)
        print("You drew:", new_card)

    # Check if Player 1 won
    if len(player1) == 0:
        print("\n🎉 You win! UNO!")
        break
    elif len(player1) == 1:
        print("⚠️ UNO! You have 1 card left!")

    # --- Player 2 turn ---
    played = False
    top_card = discard_pile[-1]
    for card in player2:
        card_parts = card.split()
        top_parts = top_card.split()
        if (len(card_parts) > 1 and len(top_parts) > 1 and 
            (card_parts[0] == top_parts[0] or card_parts[1] == top_parts[1])) \
            or card in ["Wild", "Wild Draw Four"]:
            player2.remove(card)
            discard_pile.append(card)
            print("Player 2 played:", card)
            played = True
            break

    if not played:
        if deck:
            new_card = draw_card(player2)
            print("Player 2 drew a card.")
        else:
            print("Deck is empty. Player 2 cannot draw.")

    # Check if Player 2 won
    if len(player2) == 0:
        print("\n💻 Player 2 wins! UNO!")
        break
    elif len(player2) == 1:
        print("⚠️ Computer has UNO! 1 card left")
