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

var id = 0
var hostId:int
var peer = WebSocketMultiplayerPeer.new()
var rtcPeer:WebRTCMultiplayerPeer = WebRTCMultiplayerPeer.new() #this represents the multiplayer establishment and contains the peer we connected to
var currentLocalPlayersInLobby = {}

var lobbyValue
# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.connected_to_server.connect(RTCServerConnected)
	multiplayer.peer_connected.connect(RTCPeerConnected)
	multiplayer.peer_disconnected.connect(RTCPeerDisconnected)

func RTCServerConnected():
	print("client rtc connected")
func RTCPeerConnected(id):
	print("client rtc RTCPeerConnected", id)
func RTCPeerDisconnected(id):
	print("client rtc RTCPeerDisconnected", id)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func connected(id):
	rtcPeer.create_mesh(id)
	multiplayer.multiplayer_peer = rtcPeer
func _process(delta):
	peer.poll() #
	if peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		if packet != null:
			var dataString = packet.get_string_from_utf8()
			var data = JSON.parse_string(dataString)
			if data.message==Message.join:
				print("client: got data", data)
				self.id = data.id		
				connected(id)
			if data.message == Message.userConnected:
				#print("client: connected to lobby, current has this many plays in it", data.players.size())
				createPeer(data.id)

			if data.message == Message.lobby:
				#updates from the lobby
				hostId = data.hostId
				$LineEdit.text = str(data.lobbyId)
				lobbyValue = data.lobbyId
				
				currentLocalPlayersInLobby = JSON.parse_string(data.lobby)
				print("client localPlayer is: ", str(currentLocalPlayersInLobby))
			if data.message== Message.candidate:
				if rtcPeer.has_peer(data.orgPeer):
					print("got candidate:", data.orgPeer, "my id is ", str(id))
					rtcPeer.get_peer(data.orgPeer).connection.add_ice_candidate(data.mid,data.index,data.sdp)
			if data.message == Message.offer:
				if rtcPeer.has_peer(data.orgPeer):
					rtcPeer.get_peer(data.orgPeer).connection.set_remote_description("offer", data.data)
			if data.message == Message.answer:
				if rtcPeer.has_peer(data.orgPeer):
					rtcPeer.get_peer(data.orgPeer).connection.set_remote_description("offer", data.data)
				
func createPeer(id):
	if id != self.id:
		var peer: WebRTCPeerConnection = WebRTCPeerConnection.new()
		peer.initialize({
			"iceServers" : [{
				"urls": ["stun:stun.l.google.com:19302"]
			}]
		})
		
		print("binding id" + str(id) + "my id is ", str(self.id))
		
		peer.session_description_created.connect(self.offerCreated.bind(id))
		peer.ice_candidate_created.connect(self.iceCandidateCreated.bind(id))
		rtcPeer.add_peer(peer,id)
		
		
		if id < rtcPeer.get_unique_id():
			peer.create_offer() #the host should be the person that creates the offer , meaning establish connection
		pass

func offerCreated(type,data,id):
	if !rtcPeer.has_peer(id): #if the peer connection was not established
		return
	rtcPeer.get_peer(id).connection.set_local_description(type,data)	#both client and server makes a local description and sends to both side
	
	if type == "offer":
		sendOffer(id, data)
	else:
		sendAnswer(id, data)

func sendOffer(id, data): #offer is server reaching out to client to send their information
	var message = {
		"peer": id,
		"orgPeer": self.id,
		"message" : Message.offer,
		"data": data,
		"lobby": lobbyValue
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())
	
func sendAnswer(id, data): #send is the response
	var message = {
		"peer": id,
		"orgPeer": self.id,
		"message" : Message.answer,
		"data": data,
		"lobby": lobbyValue
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())

func iceCandidateCreated(midName, indexName, sdpName, id):
	print("iceCandidateCreated created")
	var message = {
		"peer": id,
		"orgPeer": self.id,
		"message" : Message.candidate,
		"mid": midName,
		"index": indexName,
		"sdp": sdpName,
		"lobby": lobbyValue
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())

func connectToServer(ip):
	peer.create_client("ws://127.0.0.1:8915")
	print("client: started")


func _on_start_client_pressed():
	connectToServer("")
	pass # Replace with function body.


@rpc("any_peer")
func ping():
	print("ping from@@"+ str(multiplayer.get_remote_sender_id()))

func _on_client_send_data_pressed():
	ping()
	var message = {
		message  = Message.join,
		data = "client data"
	}
	print("client: sends", str(message))
	var messageBytes = JSON.stringify(message).to_utf8_buffer()
	peer.put_packet(messageBytes)
	pass # Replace with function body.

func sendToAll(data):
	var messageBytes = JSON.stringify(data).to_utf8_buffer()
	peer.put_packet(messageBytes)
func _on_client_join_lobby_pressed():
	var message = {
		"id": id,
		"message": Message.lobby,
		"lobbyId": $LineEdit.text
	}
	sendToAll(message)
	pass # Replace with function body.
