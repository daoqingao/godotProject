extends Node2D

const MAX_CONNECTIONS = 20
const SERVER_ADDRESS = "127.0.0.1" # IPv4 localhost
const SERVER_PORT = 7000
func Client_Join_Server() -> void:
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	if peer.create_client(SERVER_ADDRESS, SERVER_PORT):
		printerr("Error creating the client")
	multiplayer.multiplayer_peer = peer 

func Server_Create_Server():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(SERVER_PORT, MAX_CONNECTIONS)
	multiplayer.multiplayer_peer = peer #means that we make the 
	
func _ready():
	#note: peer_conencted is when server receives a connection
	#note: peer_disconnected is when serve3r receives a disconnect from a client
	#below .connect is just signals... being forwarded to their respective functions
	#these 2 are only called by server and clients? not sure
	multiplayer.peer_connected.connect(_on_server_receive_client_connect)
	multiplayer.peer_disconnected.connect(_on_server_receive_client_disconnect)
	#below are only called by client
	multiplayer.connected_to_server.connect(_on_client_success_connect_to_server)
	multiplayer.connection_failed.connect(_on_client_fail_connect_to_server)
	multiplayer.server_disconnected.connect(_on_client_disconnect_to_server)


func _on_host_pressed():
	Server_Create_Server()
	print("host pressewd")
	#SendClientPlayerIdToServer.rpc_id(1, 1)	
func _on_join_pressed():
	Client_Join_Server()
	
#host functions and clients call this?
func _on_server_receive_client_connect(id):
	print("server: client connected from the server",id)
	SendClientPlayerIdToServer.rpc_id(1, multiplayer.get_unique_id())	
func _on_server_receive_client_disconnect(id):
	print("server: client disconnected from the server",id)
#clients function
func _on_client_success_connect_to_server():
	print("client: successfully connect to server")
	#SendClientPlayerIdToServer.rpc_id(1, multiplayer.get_unique_id())
func _on_client_fail_connect_to_server():
	print("client: unable to connect to server")
func _on_client_disconnect_to_server():
	print("client: disconnected to server")

#everyone and self
@rpc("any_peer","call_local")
func startGame():
	CardManager.startGame()

@rpc("any_peer","call_local")
func SendServerPlayerInfoToClient(players):
	CardManager.players = players #update. 
# send data to server only.
@rpc("any_peer","call_local")
func SendClientPlayerIdToServer(playerId):
	print("the server should be getting this. ", playerId)
	if multiplayer.is_server():	
		if !CardManager.players.has(playerId):
			CardManager.players[playerId] = {
				playerId = playerId
			}
			SendServerPlayerInfoToClient.rpc(CardManager.players)
		#get_tree().current_scene.onPlayerJoined(multiplayer.get_unique_id())
	return

func _on_server_do_something_pressed():
	startGame.rpc() #everyone
	print("clint was asked to do something")
	



