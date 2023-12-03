extends Node2D
const MAX_CONNECTIONS = 20
const SERVER_ADDRESS = "127.0.0.1" # IPv4 localhost
const SERVER_PORT = 7000

var serverPlayers = {}
var connectedPlayers = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	startServer()
func startServer():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(SERVER_PORT, MAX_CONNECTIONS)
	if(error):
		print("server: server was not able to start successfully", str(error))
	multiplayer.multiplayer_peer = peer #means that we make the 
	multiplayer.peer_connected.connect(_on_server_receive_client_connect)
	multiplayer.peer_disconnected.connect(_on_server_receive_client_disconnect)
	print("server: server started")

func _on_server_receive_client_connect(id):
	print("server: client connected from the server",id)
func _on_server_receive_client_disconnect(id):
	print("server: client disconnected from the server",id)
	
	




	




##functinos that can be called by the client
#any_peer specify that the client can call these functions
@rpc("any_peer")
func SendClientDataToServer(playerData,actionType):
	if actionType=="connected":
		var playerId = playerData
		print("the server should be getting this. ", playerId)
		if !serverPlayers.has(playerId):
			serverPlayers[playerId] = {
				playerId = playerId
			}
		SendServerPlayerDataToClient.rpc(serverPlayers)





######################
## client schema.
@rpc()
func SendServerPlayerDataToClient(players):
	pass
