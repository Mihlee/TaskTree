#greeting 

name = input("What's your name??")
print("Hello,", name,",we are going to play a game of Uno!")

#initalise a deck
import random

#create the deck of cards
deck = []      
numbers = [0,1,2,3,4,5,6,7,8,9,"skip","reverse","draw two"]
colours =["red", "blue", "yellow", "green"]
wilds = ["wild","Wild Draw Four"]
for colour in  colours:                       #use loops to create every card 
     for number in numbers:             # Runs through all numbers (0 to 9)and add them to deck 
         deck.append(f"{colour}{number}")
for i in range(4):
        deck.append(wilds[0])
        deck.append(wilds[1])
print(deck)

random.shuffle(deck)    #shuffle cards

#deal 7 cards to both players and draw first card for discard pile

print()
print("Here are your cards..")
player1 = deck[0:7]
print(player1)

print()
print("These are the player2's cards..")
player2 = deck[7:14]
print(player2)

print()
discard_pile =deck[0]
print(f"This is the starting card:{discard_pile}")

#player1 turn
def draw_from_deck():         #the last card from the deck is taken and added to player1's hdrawcard = deck.pop(-1)
    draw_card = deck.pop(-1)
    player1.append(draw_card)
    return draw_card
def game_play():       #player1 turn to play 
   player1_turn = input("Its your time to play. Play a vaild card or draw from the deck:")

   print(f"player1 has played:{player1_turn}")
   return player1_turn

def card_validation(player1_turn):    #vaildating if card player1 has played matches the discard pile
    last_card = discard_pile[-1]
    if player1_turn.split()[0]==discard_pile.split()[0] or player1_turn.split()[1]== discard_pile()[1]:
             discard_pile.append(player1_turn)

    else:
        player1,append(deck[-1])  

    #player 2 turn
def game_play():    #player 2 turn to play
    player2_turn = input("Its your turn to play. Play a vaild card or draw from the deck..")
    print(player2_turn)
    return player2_turn

def card_validation(player2_turn):      #validating if card player2has played matches the discard pile
    last_card = discard_pile[-1]
    if player2_turn.split()[0]== discard_pile.split()[0] or player2_turn.split()[1]== discard_pile.split()[1]:
         discard_pile.append(player2_turn)
    else:
         player2.append(deck[-1])


    # Check UNO
while True:
    print("Your cards:", player1)
    print("Top of discard pile:", discard_pile)

    # Player 1 turn
    move = input("Play a card (e.g., 'red 5') or type 'draw': ")

    if move.lower() == "draw":
        card = deck.pop()
        player1.append(card)
        print("You drew:", card)
    elif move in player1 and (move.split()[0] == discard_pile.split()[0]):
        player1.remove(move)
        discard_pile = move
        print("You played:", move)
    else:
        print("Invalid move! You must draw.")
        card = deck.pop()
        player1.append(card)

    # Check if Player 1 won
    if len(player1) == 0:
        print("🎉 Player 1 wins! UNO!")
        break

    # Player 2 (computer auto play)
    played = False
    for card in player2:
        if card.split()[0] == discard_pile.split()[0] or card.split()[-1] == discard_pile.split()[-1]:
            player2.remove(card)
            discard_pile = card
            print("Player 2 played:", card)
            played = True
            break
    if not played:
        card = deck.pop()
        player2.append(card)
        print("Player 2 draw a card.")



    if len(player2) == 0:
        print("\n💻 Computer wins! UNO!")
        break
    elif len(player2) == 1:
        print("⚠️ Computer has UNO! 1 card left")
 
 