extends Node

enum Message{
	id,
	join,
	userConnected,
	userDisconnected,
	lobby,
	candidate,
	offer,
	answer,
	checkIn
}

var peer = WebSocketMultiplayerPeer.new()
var users = {}

var lobbies = {}
func _ready():
	#SERVER_ADDRESS = "150.136.95.172" # uncomment to connect to server
	#if("--server" in OS.get_cmdline_args()):
		##any thing that is for the oracle server
		#SERVER_ADDRESS = "0.0.0.0"
		#startServer()
	peer.peer_connected.connect(peer_connected)
	peer.peer_disconnected.connect(peer_disconnected)
func _process(delta):
	peer.poll() #
	if peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		if packet != null:
			var dataString = packet.get_string_from_utf8()
			var data = JSON.parse_string(dataString)
			print("server: got data",data)
			if data.message == Message.lobby:
				joinLobby(data.id,data.lobbyId)
			if data.message == Message.offer || data.message == Message.answer || data.message== Message.candidate:
				#need to pass the data to the other users.............................. ????????
				print("source id is "+ str(data.orgPeer) )
				sendToClient(data.peer,data)
func peer_connected(id):
	users[id] = {
		"id": id,
		"name": id,
		"message": Message.join
	}
	var messageBytes = JSON.stringify(users[id]).to_utf8_buffer()
	peer.get_peer(id).put_packet(messageBytes)
	print("server: client connected ",id )
func peer_disconnected(id):
	print("server: client connected ",id )
func startServer():
	peer.create_server(8915)
	print("server: started")

func generate_random_string() -> String:
	var n = 10 # size of the string
	var chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	var result = ""
	for i in range(n):
		var random_index = randi() % chars.length()
		result += chars[random_index]
	return result
	
func joinLobby(userId:int, lobbyId: String):
	print("usersId:", userId)
	print(str(users))
	print(str(users[userId]))
	
	var currentUser = users[userId]
	if lobbyId == "": #if no lobby, you create one
		lobbyId = generate_random_string()
		print("server: generated lobby of id: ", lobbyId)
		self.lobbies[lobbyId] = LobbyRtc.new(userId)
	else:
		print("server: joining lobby ", lobbyId)
	var player = lobbies[lobbyId].addPlayer(userId,currentUser)
	
	for p in lobbies[lobbyId].players:
		
		var data = { #triggering a userConnected both ways to make rtc
			"message" : Message.userConnected,
			"id": userId
		}
		sendToClient(p,data) #sending data to
		var data2 = {
			"message" : Message.userConnected,
			"id": p
		}
		sendToClient(userId,data2)
		var lobbyInfo = {
			"message": Message.lobby,
			"lobby": JSON.stringify(lobbies[lobbyId].players),
					"hostId": lobbies[lobbyId].hostId,
		"lobbyId": lobbyId,
		}
		sendToClient(p,lobbyInfo)
		
	var data = {
		"message": Message.userConnected,
		"id": userId,
		"hostId": lobbies[lobbyId].hostId,
		"lobbyId": lobbyId,
		"players": lobbies[lobbyId].players,
	}
	sendToClient(userId,data)
	
func sendToClient(clientId, data):
	var messageBytes = JSON.stringify(data).to_utf8_buffer()
	peer.get_peer(clientId).put_packet(messageBytes)
func _on_start_server_pressed():
	startServer()
	pass # Replace with function body.


func _on_server_send_data_pressed():
	var message = {
		message  = Message.id,
		data = "server data"
	}
	print("server: sends", str(message))
	var messageBytes = JSON.stringify(message).to_utf8_buffer()
	peer.put_packet(messageBytes) #broadcast data to all client!
	pass # Replace with function body.
