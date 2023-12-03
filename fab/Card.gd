extends Area2D

# Called when the node enters the scene tree for the first time.

# structure for the card class...
class_name Card
var cardType=""
var cardNum
var cardImg
var cardData
var selected = false
var newSnapPos = null;
var ownerId = 1;
var id = -1;

var isOwner = true

var flippedUp = true; #anything at card front z-index 6 is up, 4 is down
var restSnapPos:Vector2 = Vector2.ZERO;

func construct(cardData):
	position = cardData.cardPos
	self.restSnapPos = position
	self.cardType = cardData.cardType
	
	#make flip up first.
	flippedUp = true
	$CardFront.z_index = 6
	$CardBack.z_index = 5
	$MultiplayerSynchronizer.set_multiplayer_authority(cardData.ownerId)


func _physics_process(delta):
	isOwner = $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id()
	if(!isOwner):
		return
	if selected:
		position = lerp(position,get_global_mouse_position(),25 * delta)
	else:
		position = lerp(position,restSnapPos,25 * delta)
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Label.text = (cardType + str(position) + str(selected))
	pass



func flipCard():
	var animation = $FlipCardAnimation
	if(animation.is_playing()):
		return
	if(flippedUp):
		print("flipping down with")
		animation.play("card_flip_down")	
		flippedUp = false
	else:
		animation.play("card_flip_up")	
		flippedUp = true


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			selected = false
			if(newSnapPos!=null):
				restSnapPos = Vector2(newSnapPos.x,newSnapPos.y)
				newSnapPos = null
func _on_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("leftClick"):
		selected = true
	if event.is_action_pressed("rightClick"):
		flipCard()
