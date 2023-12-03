extends Node2D
##################SHARED SCHEMAS>?

const MAX_CONNECTIONS = 20
const SERVER_ADDRESS = "127.0.0.1" # IPv4 localhost
const SERVER_PORT = 7000
func _ready():
	#deployed server would only just call
	#startServer() #immediately on run
	return
	
#server and client
func _on_server_receive_client_connect(id):
	print("server signals to client: client connected from the server",id)
func _on_server_receive_client_disconnect(id):
	print("server signals to client: client disconnected from the server",id)


enum ActionTypes {
	STARTGAME,
	CONNECT,
}

#class Player:
	#var id: int
	#var peerId: int
	#var name: String
	#func _to_string():
		#return str(peerId)

###################################### SERVER ONLY
##<PlayerId, PlayerData> some terrible dynamic bruh
var serverPlayers = {} #pretend this to be just a dictionary of players i cant set types...

func startServer():
	print("this instance is now the server. and should not be playing ")
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(SERVER_PORT, MAX_CONNECTIONS)
	if(error):
		print("server: server was not able to start successfully", str(error))
	multiplayer.multiplayer_peer = peer #means that we make the 
	multiplayer.peer_connected.connect(_on_server_receive_client_connect)
	multiplayer.peer_disconnected.connect(_on_server_receive_client_disconnect)
	print("server: server started")

# server calls the client.
#any peer can send data to server
@rpc("any_peer","call_remote")
func SendClientDataToServer(actionType: ActionTypes,data):
	if actionType==ActionTypes.CONNECT:
		var playerData = data
		var playerId = playerData.playerId#type should then be peerId..
		print("the server should be getting this. ", )
		if !serverPlayers.has(playerId):
			serverPlayers[playerId] = playerData
		SendServerPlayerDataToClient.rpc(actionType,serverPlayers)
	if actionType==ActionTypes.STARTGAME:
		print("server: one client asked to start game, propagating to everyone")
		SendServerPlayerDataToClient.rpc(actionType,null)
		

	
	
##################################### client

var localPlayers = {}
func _on_client_success_connect_to_server():
	print("client: successfully connect to server")
	registerPlayer()
func _on_client_fail_connect_to_server():
	print("client: unable to connect to server")
func _on_client_disconnect_to_server():
	print("client: disconnected to server")
	
func joinServer():
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	if peer.create_client(SERVER_ADDRESS, SERVER_PORT):
		printerr("Error creating the client")
	multiplayer.multiplayer_peer = peer 
	multiplayer.peer_connected.connect(_on_server_receive_client_connect)
	multiplayer.peer_disconnected.connect(_on_server_receive_client_disconnect)
	multiplayer.connected_to_server.connect(_on_client_success_connect_to_server)
	multiplayer.connection_failed.connect(_on_client_fail_connect_to_server)
	multiplayer.server_disconnected.connect(_on_client_disconnect_to_server)
	return

func registerPlayer():
	SendClientDataToServer.rpc_id(1, ActionTypes.CONNECT, {
		playerId = multiplayer.get_unique_id(),
		peerId = multiplayer.get_unique_id()
	})

func askServer():
	print("trying to call server to do this")

func askServerToStartGame():
	print("asked server to start a game")
	SendClientDataToServer.rpc_id(1, ActionTypes.STARTGAME, null)
#authority means the server sends data back to
@rpc("authority","call_remote")
func SendServerPlayerDataToClient(actionType,data):
	if(actionType== ActionTypes.CONNECT):
		print("client: got player data:", data)
		localPlayers = data
	if(actionType== ActionTypes.STARTGAME):
		print("client: asked to start game")
		CardManager.startGame()
		
	pass





