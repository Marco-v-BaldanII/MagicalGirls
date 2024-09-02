extends Node2D

var cooldown : float = 0
@onready var label = $Label
@onready var color_rect = $TextureRect/ColorRect

@onready var cpu_particles_2d = $CPUParticles2D3
@onready var cpu_particles_2d_2 = $CPUParticles2D4

var flash_duration : float = 0.5 
var flash_intensity : float = 1.0 
# Called when the node enters the scene tree for the first time.
func _ready():
	color_rect.color.a = 0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	cooldown += delta
	if(cooldown > 2.2):
		color_rect.color.a = flash_intensity

		flash_intensity -= delta / flash_duration
		flash_intensity = clamp(flash_intensity, 0, 1)
		color_rect.color.a = flash_intensity
	if(cooldown > 2.5):
		cpu_particles_2d.emitting = true
		cpu_particles_2d_2.emitting = true
	if(cooldown > 4):
		label.visible = true
		if Input.is_anything_pressed():
			get_tree().change_scene_to_file("res://Scenes/menu_scenes/menu.tscn")
	
	
	pass
