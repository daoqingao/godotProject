extends Node2D

const Card = preload("res://fab/Card.tscn")

# Called when the node enters the scene tree for the first time.
var cardList = []
var playerList = []


func _ready():
	pass # Replace with function body.

func createCard(cardType = 'rock',pos = Vector2.ZERO,ownerId = 1):
	var card = Card.instantiate()
	card.construct({
		cardType = cardType,
		cardPos = pos,
		ownerId = ownerId
	})
	add_child(card)
	cardList.push_back(card)
	print("Card made ", cardType, card.position)
	return card
func startGame(): #init and show all cards
	var clientPlayers = server.localPlayers
	print("called to start game", str(clientPlayers))	
	var index = Vector2(100,100)
	for i in clientPlayers:
		print("what is this", i)
		createCard('paper',index,clientPlayers[i].playerId) #when we create a card, we make sure all the cards data are to a list
		index = index * 2
# Called every frame. 'delta' is the elapsed time since the previous frame.
func onPlayerJoined(id):
	#createCard('paper',Vector2(100,150),id) #when we create a card, we make sure all the cards data are to a list
	#createCard('paper',Vector2(200,150),id)
	#createCard('paper',Vector2(300,150),id)
	#createCard('paper',Vector2(100,-150),id) #when we create a card, we make sure all the cards data are to a list
	#createCard('paper',Vector2(200,-150),id)
	#createCard('paper',Vector2(300,-150),id)
	return

func _on_card_drop_area_2d_area_entered(area):
	if(not area is Card):
		return
	var card: Card = area
	card.newSnapPos = $CardDropArea2d/DropPosition.position
	print('in the area',card.newSnapPos)

func _on_card_drop_area_2d_area_exited(area):
	if(not area is Card):
		return
	var card: Card = area
	card.newSnapPos = null
