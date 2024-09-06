extends Projectile
class_name RitsuUlti

var growth_segments := 5
var current_growth_segment := 0
@export var frame_charge_time : float =  12
var current_frame : int = 0
const HADOKEN_RIGHT = preload("res://Scenes/projectiles/hadoken_right.tscn")

@export var points : Array[Node2D]

func _ready() -> void:
	GDSync.expose_node(self)
	set_physics_process(false)
	hide()
	instanciated.emit()

func _physics_process(delta: float) -> void:
	pass
func _process(delta: float) -> void:
	alive_time -= delta
	current_frame += 1
	
	if current_frame > frame_charge_time and current_growth_segment < growth_segments:

		var tween : Tween = create_tween()
		tween.tween_property(self,"scale",scale+Vector2(0.16,0.16),(1.0/60.0) * (frame_charge_time*0.6))
		tween.set_ease(Tween.EASE_IN_OUT)
		var tween2 : Tween = create_tween()
		tween2.tween_property(self,"rotation",rotation + randf_range(1.3,1.8),(1.0/60.0) * (frame_charge_time*0.6))
		tween2.set_ease(Tween.EASE_IN_OUT)

		current_growth_segment += 1
		current_frame = 0

	elif not current_growth_segment < growth_segments and current_growth_segment != 999:
		current_growth_segment = 999

		for i in points.size():
			
			var shot := HADOKEN_RIGHT.instantiate()
			get_parent().add_child(shot)
			shot.global_position = global_position
			shot.shoot(_layer, _mask, "none")
			var speed := global_position - points[i].global_position
			speed = speed.normalized()
			
			shot.speed = speed.x * 900
			shot.speedY = speed.y * 900
			

		await get_tree().create_timer(0.017).timeout

		
		var tween : Tween = create_tween()
		tween.tween_property(self,"scale",scale / 40, 0.30)
		tween.set_ease(Tween.EASE_IN_OUT)
		var tween2 : Tween = create_tween()
		tween2.tween_property(self,"rotation",rotation + 2,(1.0/60.0) * (frame_charge_time*0.6))
		tween2.set_ease(Tween.EASE_IN_OUT)
		
		await get_tree().create_timer((1.0/60.0) * (frame_charge_time*0.6)).timeout
		queue_free()
		pass

func online_synch(player_num : int):
	
	await  instanciated
	
	if player_num == 1:
		property_synchronizer.broadcast = 0
		property_synchronizer2.broadcast = 0
		property_synchronizer3.broadcast = 0
		
		
	else: 
		property_synchronizer.broadcast = 1
		property_synchronizer2.broadcast = 1
		property_synchronizer3.broadcast = 1
		
