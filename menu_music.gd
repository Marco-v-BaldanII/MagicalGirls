extends Node2D


@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func play():
	audio_stream_player.play()
	
	
func stop():
	audio_stream_player.stop()
