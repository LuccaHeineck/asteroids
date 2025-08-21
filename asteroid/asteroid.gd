class_name Asteroid extends Area2D

enum Size { SMALL, MEDIUM, LARGE }

signal exploded(pos, size)

@export var size: Size
var speed: float = 100.0
var direction: Vector2
var rotation_speed: float

const SIZE_DATA = {
	Size.SMALL: { "speed": 200.0, "scale": Vector2(1.5, 1.5), "points": 100 },
	Size.MEDIUM: { "speed": 150.0, "scale": Vector2(2, 2), "points": 50 },
	Size.LARGE: { "speed": 100.0, "scale": Vector2(3, 3), "points": 20 },
}

func _ready() -> void:
	# Scale asteroid depending on size
	var data = SIZE_DATA[size]
	scale = data.scale
	speed = data.speed

	# Random movement
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	rotation_speed = randf_range(-0.02, 0.02)

	# Speed depends on size
	match size:
		Size.SMALL: speed = 200.0
		Size.MEDIUM: speed = 150.0
		Size.LARGE: speed = 100.0
		_: speed = 0.0

		
	
func _physics_process(delta: float) -> void:
	# Movement
	position += direction * speed * delta
	rotate(rotation_speed)
	
	# Infinite edges
	var offset = $Sprite2D.get_rect().size.y * 2
	var screen_size = get_viewport_rect().size
	if global_position.y < 0 - offset:
		global_position.y = screen_size.y + offset
	if global_position.y > screen_size.y + offset:
		global_position.y = 0 - offset
	if global_position.x < 0 - offset:
		global_position.x = screen_size.x + offset
	if global_position.x > screen_size.x + offset:
		global_position.x = 0 - offset
	
		
func explode():
	exploded.emit(global_position, size)
	queue_free()


static func get_points(ast_size: Size) -> int:
	return SIZE_DATA[ast_size].points

static func get_speed(ast_size: Size) -> float:
	return SIZE_DATA[ast_size].speed


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var player = body
		player.get_hit()
