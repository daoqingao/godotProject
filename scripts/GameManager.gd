extends Node2D

func _ready():
	return

func onPlayerJoined(id):
	$CardManager.onPlayerJoined(id)
