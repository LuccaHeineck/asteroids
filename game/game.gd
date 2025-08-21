extends Node2D

@export var asteroidScene : PackedScene
@onready var asteroids = $Asteroids
@onready var player = $Player
@onready var asteroidTimer = $AsteroidTimer
@onready var score_label = $UI/HUD/ScoreMargin/ScoreLabel
@onready var hp1 = $UI/HUD/HPMargin/HPContainer/HP1
@onready var hp2 = $UI/HUD/HPMargin/HPContainer/HP2
@onready var hp3 = $UI/HUD/HPMargin/HPContainer/HP3
@onready var game_over_screen = $UI/GameOver
@onready var hud = $UI/HUD

var empty_hp_texture = preload("res://sprites/empty_health.png")
var full_hp_texture = preload("res://sprites/full_health.png")

var asteroid_size = Asteroid.Size
var screen_size : Vector2
var max_asteroids : int  = 10
var score : int = 0
var health : int = 3


func _ready() -> void:
	screen_size = get_viewport_rect().size
	new_game()


func new_game():
	game_over_screen.hide()
	hud.show()
	player.show()
	score = 0
	health = 3
	asteroidTimer.start()
	hp1.texture = full_hp_texture
	hp2.texture = full_hp_texture
	hp3.texture = full_hp_texture


func _generate_new_asteroids() -> void:
	var quantity = 1
	_generate_asteroid(_choose_asteroid_location(), Asteroid.Size.LARGE, quantity)


func _generate_asteroid(asteroid_pos, ast_size, quantity) -> void:
	for i in range(quantity):
		var asteroid = asteroidScene.instantiate()
		asteroid.global_position = asteroid_pos
		asteroid.size = ast_size
		asteroid.connect("exploded", _on_asteroid_exploded)
		asteroids.add_child(asteroid)


func _on_asteroid_exploded(pos, size) -> void:
	var quantity = 2

	match size:
		Asteroid.Size.SMALL:
			score += Asteroid.get_points(asteroid_size.SMALL)
		Asteroid.Size.MEDIUM:
			score += Asteroid.get_points(asteroid_size.MEDIUM)
			call_deferred("_generate_asteroid", pos, Asteroid.Size.SMALL, quantity)
		Asteroid.Size.LARGE:
			score += Asteroid.get_points(asteroid_size.LARGE)
			call_deferred("_generate_asteroid", pos, Asteroid.Size.MEDIUM, quantity)

	score_label.text = "SCORE: " + str(score)


func _on_asteroid_timer_timeout() -> void:
	if asteroids.get_children().size() < max_asteroids:
		_generate_new_asteroids()


func _choose_asteroid_location() -> Vector2:
	var edge = randi_range(1, 4)
	var spawn_coordinates = Vector2.ZERO
	if edge == 1:
		spawn_coordinates = Vector2(0, randf_range(0.0, screen_size.y))
	if edge == 2:
		spawn_coordinates = Vector2(randf_range(0.0, screen_size.x), 0)
	if edge == 3:
		spawn_coordinates = Vector2(randf_range(0.0, screen_size.x), screen_size.y)
	if edge == 4:
		spawn_coordinates = Vector2(screen_size.x, randf_range(0.0, screen_size.y))

	
	return spawn_coordinates


func _on_player_hit() -> void:
	if health <= 1:
		game_over()
		return
	
	match health:
		3:
			hp3.texture = empty_hp_texture
		2:
			hp2.texture = empty_hp_texture
		1:
			hp1.texture = empty_hp_texture
	health -= 1
	

func game_over():
	hud.hide()
	game_over_screen.show()
	player.hide()


func _on_tryagain_button_pressed() -> void:
	new_game()
