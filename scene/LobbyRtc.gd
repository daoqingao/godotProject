extends Node

class_name LobbyRtc
var hostId: int
var players : Dictionary = {}

func _init(id):
	hostId = id
	
func addPlayer(id,name):
	players[id] = {
		"name": name,
		"id": id,
		"index": players.size() +1 
	}
	return players[id]
