class_name Laser extends Area2D

var direction = Vector2(0, -1)
@export var SPEED = 2000.0

func _physics_process(delta: float) -> void:
	position += direction.rotated(rotation) * SPEED * delta
	

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area is Asteroid:
		var asteroid = area
		asteroid.explode()
		queue_free()
