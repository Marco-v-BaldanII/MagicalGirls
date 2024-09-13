extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	DiscordRPC.app_id = 1284067432369098848
	DiscordRPC.state = "Playing"
	DiscordRPC.details = "Fighting magical girls as a magical girl"
	DiscordRPC.large_image = "title_big"
	DiscordRPC.refresh()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
