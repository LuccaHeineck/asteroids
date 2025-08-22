class_name Player extends CharacterBody2D

signal hit

@onready var muzzle := $Muzzle
@onready var animation_player := $AnimationPlayer
@onready var audio_player := $ShootPlayer
@onready var death_player := $DeathPlayer
@onready var gas_particles := $GasParticles

@export var laserScene : PackedScene
var initial_position : Vector2 = Vector2(640, 360)
var acceleration : float = 1000.0
var max_speed : float = 400.0
var rotation_speed : float = 4.0
var laser_cd = false
var iframe = false

func _ready() -> void:
	reset()
	animation_player.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	# Movement
	var direction : Vector2 = Vector2(0, Input.get_axis("ui_up", "ui_down"))
	velocity += direction.rotated(rotation) * delta * acceleration
	velocity = velocity.limit_length(max_speed)
	
	if direction != Vector2(0, 0):
		gas_particles.emitting = true
	else:
		gas_particles.emitting = false
			
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
			_shoot()


func _shoot():
	if !get_parent().game_is_over:
		laser_cd = true
		var laser = laserScene.instantiate()
		laser.global_position = muzzle.global_position
		laser.rotation = rotation
		get_parent().add_child(laser)
		audio_player.play()
		await get_tree().create_timer(0.2).timeout
		laser_cd = false


func reset():
	global_position = initial_position
	velocity = Vector2.ZERO


func get_hit():
	if !iframe:
		death_player.play()
		iframe = true
		await frame_freeze(0.05, 1.00)
		animation_player.play("player_hit")
		reset()
		hit.emit()


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "player_hit":
		iframe = false


func frame_freeze(time_scale, duration):
	Engine.time_scale = time_scale
	await get_tree().create_timer(duration * time_scale).timeout
	Engine.time_scale = 1


func deactivate():
	hide()
	$CollisionShape2D.disabled = true
	velocity = Vector2.ZERO
	set_process(false)
	set_physics_process(false)

func activate():
	show()
	$CollisionShape2D.disabled = false
	reset()
	set_process(true)
	set_physics_process(true)
