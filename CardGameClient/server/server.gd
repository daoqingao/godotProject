extends Node2D

const MAX_CONNECTIONS = 20
const SERVER_ADDRESS = "127.0.0.1" # IPv4 localhost
const SERVER_PORT = 7000
func Client_Join_Server() -> void:
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	if peer.create_client(SERVER_ADDRESS, SERVER_PORT):
		printerr("Error creating the client")
	multiplayer.multiplayer_peer = peer 
func _ready():
	multiplayer.peer_connected.connect(_on_server_receive_client_connect)
	multiplayer.peer_disconnected.connect(_on_server_receive_client_disconnect)
	multiplayer.connected_to_server.connect(_on_client_success_connect_to_server)
	multiplayer.connection_failed.connect(_on_client_fail_connect_to_server)
	multiplayer.server_disconnected.connect(_on_client_disconnect_to_server)
	Client_Join_Server()

func _on_server_receive_client_connect(id):
	print("server signals to client: client connected from the server",id)
func _on_server_receive_client_disconnect(id):
	print("server signals to client: client disconnected from the server",id)
func _on_client_success_connect_to_server():
	print("client: successfully connect to server")
	SendClientDataToServer.rpc_id(1, multiplayer.get_unique_id())
func _on_client_fail_connect_to_server():
	print("client: unable to connect to server")
func _on_client_disconnect_to_server():
	print("client: disconnected to server")



func askServer():
	print("trying to call server to do this")
	SendClientDataToServer.rpc_id(1, {
		playerId = multiplayer.get_unique_id()
	},"connected")
	

#### 
# server calls the client.
@rpc()
func SendServerPlayerDataToClient(players):
	print("got data from server. ", players)
#########################################
#all server interface callable functions.
# this also represents the server schema....... bruh
@rpc()
func SendClientDataToServer(playerData,actionType):
	pass


