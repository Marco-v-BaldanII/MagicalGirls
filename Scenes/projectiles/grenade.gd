extends Projectile
class_name Grenade

var my_player : Player

var power : int = 0
@export var frame_charge_time : float =  100
var current_frame : int = 0

var power_multiply : float
var explode_timer : float = 3.0
@onready var animation_tree: AnimationTree = $AnimationTree

var og_speedY = -600
var og_speedX = -500
var num_bounce = 2
@export var speedY = -600
@export var gravity = 15

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GDSync.expose_node(self)
	dmg = 10

	set_physics_process(false)
	pass # Replace with function body.


func charge(_position : Vector2):
	#GDSync.call_func(charge,[position])
	alive_time -= 0.01667
	global_position = _position
	if explode_timer < 0:
		animation_tree["parameters/conditions/explode"] = true
		
	pass
		


func shoot(layer : int , mask : int, dir : String, player : Player = null):
	#GDSync.call_func(assign_phys_layer,[layer,mask])
	set_physics_process(true)
	#assign_phys_layer(layer, mask)
	my_player = player
	if dir == "right":
		speed *= -1
	if player:
		var lag = current_frame*0.7
		player.add_lag(clamp(lag,30,50))

func destroy_projectile():
	#my_player.oponent.add_lag(4)

	if current_frame < 20 and my_player: my_player.oponent.weak_knock = true
	await  get_tree().create_timer(0.017).timeout
	queue_free()
	
func _physics_process(delta: float) -> void:
	
	alive_time -= delta
	
	if alive_time < 0:
		animation_tree["parameters/conditions/explode"] = true
		assign_phys_layer(2,5)
		assign_phys_layer(3,4)
		
		
	position.x += speed * delta
	position.y += speedY * delta
	speedY += 15
	#fall faster
	if speedY > 0:speedY += 20


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	queue_free()
	pass # Replace with function body.


func _on_area_2d_area_entered(area: Area2D) -> void:
	
	pass # Replace with function body.


func _on_area_2d_body_entered(body: Node2D) -> void:
	speedY = og_speedY/num_bounce
	speed = og_speedX/num_bounce
	num_bounce += 1
	pass # Replace with function body.
