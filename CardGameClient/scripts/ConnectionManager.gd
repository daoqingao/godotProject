extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_server_do_something_pressed():
	server.askServer()
	return;


func _on_join_pressed():
	server.joinServer()
	pass # Replace with function body.


func _on_host_pressed():
	print("host button created, this instance is now the server and should not play")
	server.startServer()
	pass # Replace with function body.
