extends Projectile
class_name Missile


func _physics_process(delta: float) -> void:
	super(delta)
	
	speedY += 50
