class_name Player extends CharacterBody2D

signal hit

@export var laserScene : PackedScene
var initial_position : Vector2 = Vector2(640, 360)
var acceleration : float = 1000.0
var max_speed : float = 400.0
var rotation_speed : float = 4.0
var laser_cd = false

func _ready() -> void:
	reset()

func _physics_process(delta: float) -> void:
	# Movement
	var direction : Vector2 = Vector2(0, Input.get_axis("ui_up", "ui_down"))
	velocity += direction.rotated(rotation) * delta * acceleration
	velocity = velocity.limit_length(max_speed)
	
	if direction.y == 0:
		velocity = velocity.move_toward(Vector2.ZERO, 3)
	
	rotate(Input.get_axis("ui_left", "ui_right") * delta * rotation_speed)
	move_and_slide()
	
	# Infinite edges
	var screen_size = get_viewport_rect().size
	if global_position.y < 0:
		global_position.y = screen_size.y
	if global_position.y > screen_size.y:
		global_position.y = 0	
	if global_position.x < 0:
		global_position.x = screen_size.x
	if global_position.x > screen_size.x:
		global_position.x = 0
	
	
func _process(_delta: float) -> void:
	if Input.is_action_pressed("ui_accept"):
		if !laser_cd:
			laser_cd = true
			var laser = laserScene.instantiate()
			laser.global_position = $Muzzle.global_position
			laser.rotation = rotation
			get_parent().add_child(laser)
			await get_tree().create_timer(0.2).timeout
			laser_cd = false


func reset():
	global_position = initial_position
	velocity = Vector2.ZERO


func get_hit():
	reset()
	hit.emit()
