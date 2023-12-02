extends Node2D

const Card = preload("res://fab/Card.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	createCard('paper',Vector2(100,150))
	createCard('paper',Vector2(200,150))
	createCard('paper',Vector2(300,150))
	pass # Replace with function body.

func createCard(cardType = 'rock',pos = Vector2.ZERO):
	var card = Card.instantiate()
	card.construct({
		cardType = cardType,
		cardPos = pos
	})
	add_child(card)
	print("Card made ", cardType, card.position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

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
