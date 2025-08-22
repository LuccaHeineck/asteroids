extends Node2D

@export var asteroidScene : PackedScene
@onready var asteroids = $Asteroids
@onready var player = $Player
@onready var asteroidTimer = $AsteroidTimer
@onready var score_label = $UI/HUD/ScoreMargin/ScoreLabel
@onready var hp1 = $UI/HUD/HPMargin/HPContainer/HP1
@onready var hp2 = $UI/HUD/HPMargin/HPContainer/HP2
@onready var hp3 = $UI/HUD/HPMargin/HPContainer/HP3
@onready var ui = $UI
@onready var game_over_screen = $UI/GameOver
@onready var hud = $UI/HUD
@onready var final_score = $UI/GameOver/GameOverContainer/FinalScoreMargin/FinalScoreLabel
@onready var music_player = $MusicPlayer
@onready var explosion_player = $ExplosionPlayer
@onready var screen_cover_transition = $ScreenCoverTransition
@onready var screen_cover_text = $ScreenCoverTransition/ColorRect/Label
@onready var menu = $Menu
@onready var menu_highscore = $Menu/Control/HighscoreTitle

var game_is_over := false
var empty_hp_texture := preload("res://sprites/empty_health.png")
var full_hp_texture := preload("res://sprites/full_health.png")
var asteroid_size = Asteroid.Size
var screen_size : Vector2
var max_asteroids : int  = 10
var score : int = 0
var health : int = 3
var level : int = 0
var next_level_score : int = 1000
var highscore: int = 0


func _ready() -> void:
	player.hide()
	ui.hide()
	screen_size = get_viewport_rect().size
	music_player.connect("finished", _on_music_finished)
	music_player.play()
	load_highscore()
	menu_highscore.text = "HIGHSCORE: %s" % highscore

func new_game():
	ui.show()
	menu.hide()
	score_label.text = "SCORE: " + str(score)
	game_is_over = false
	score = 0
	level = 0
	next_level_score = 1000
	game_over_screen.hide()
	for asteroid in asteroids.get_children():
		asteroid.queue_free()
	hud.show()
	player.activate()
	health = 3
	asteroidTimer.start()
	hp1.texture = full_hp_texture
	hp2.texture = full_hp_texture
	hp3.texture = full_hp_texture
	await show_transition("LEVEL 0", 1.5, true)
	start_level()


func start_level() -> void:
	player.reset()
	player.global_position = screen_size / 2
	for asteroid in asteroids.get_children():
		asteroid.queue_free()
	max_asteroids = 10 + level * 1.5
	asteroidTimer.wait_time = max(0.5, 1.5 - level * 0.1)

	for i in range(level):  
		_generate_asteroid(_choose_asteroid_location(), Asteroid.Size.LARGE, 1)



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
	
	explosion_player.play()
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

	if score >= next_level_score:
		level += 1
		next_level_score += 1000
		
		if level == 4:
			await show_transition("YOU CAN KEEP GOING… BUT IT'S JUST MORE ASTEROIDS", 2.5, true)
		elif level == 5:
			await show_transition(". . .", 2.5, true)
		elif level == 6:
			await show_transition("IS THIS REALLY FUN?", 2.5, true)
		elif level == 7:
			await show_transition("ALRIGHT, GO SHOOT SOME MORE", 2.5, true)
		elif level == 8:
			await show_transition("FEELING ACCOMPLISHED YET?", 2.5, true)
		elif level == 10:
			await show_transition("LEVEL 10", 1.5, true)
			await show_transition("YOU CAN STOP PLAYING NOW", 2.5, true)
			await show_transition("SERIOUSLY, THERE IS NO POINT", 2.5, true)
			await show_transition("THERE IS NO REAL END", 2.5, true)
		elif level == 12:
			await show_transition("STILL HERE?", 2.5, true)
			await show_transition("ARE YOU ADDICTED TO POINTS?", 2.5, true)
			await show_transition("THEY MEAN NOTHING", 2.5, true)
		elif level == 13:
			await show_transition("LEVEL 13", 1.5, true)
			await show_transition("MAYBE IT'S TIME TO REFLECT?", 2.5, true)
		elif level == 14:
			await show_transition("WHY ARE YOU SHOOTING THE ASTEROIDS?", 2.5, true)
			await show_transition("DOES IT MATTER?", 2.5, true)
			await show_transition("AS LONG AS THE NUMBER GOES UP, RIGHT?", 2.5, true)
		elif level == 15:
			await show_transition("THIS IS THE LAST LEVEL", 2.5, true)
			await show_transition("I PROMISE", 2.5, true)
		elif level == 16:
			await show_transition("I LIED", 2.5, true)
			await show_transition("THIS IS ALL A LIE", 2.5, true)
			await show_transition("YOU ARE JUST AN ARRANGEMENT OF PIXELS", 2.5, true)
			await show_transition("HOW LONG WILL YOU STAY HERE FOR?", 2.5, true)
		elif level == 17:
			await show_transition("FOREVER", 2.5, true)
			await show_transition("THE ONLY SCAPE IS DEATH", 2.5, true)
		elif level == 20:
			await show_transition("CONGRATULATIONS", 2.5, true)
			await show_transition("YOU HAVE WON", 2.5, true)
			await show_transition("NOW GO OUTSIDE", 2.5, true)
			await show_transition("OR DON'T", 2.5, true)
			await show_transition("THERE WILL ALWAYS BE MORE ASTEROIDS WAITING FOR YOU", 2.5, true)
			music_player.stop()
		else:
			await show_transition("LEVEL " + str(level), 1.5, true)
			
		start_level()




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
	game_is_over = true
	hud.hide()
	game_over_screen.show()
	final_score.text = "FINAL SCORE: %s " % score
	
	if score > highscore:
		highscore = score
		save_highscore()
		final_score.text = "NEW HIGHSCORE! %s " % score

	player.deactivate()


func show_transition(text: String, duration, reset: bool = false) -> void:
	var should_pause = (level > 0)  # don't pause on LEVEL 0

	if should_pause:
		Engine.time_scale = 0.0  

	# Set text and show cover
	screen_cover_text.text = text
	screen_cover_transition.visible = true

	# Small wait so the cover is fully visible before we clear/spawn
	await get_tree().process_frame

	if reset:
		# Clear old asteroids and reset player while covered
		for asteroid in asteroids.get_children():
			asteroid.queue_free()
		player.reset()

	# Wait for 1.5s in real time while covered
	await get_tree().create_timer(duration, false, false, true).timeout

	# Hide the cover and resume gameplay
	screen_cover_transition.visible = false
	if should_pause:
		Engine.time_scale = 1.0


func _on_tryagain_button_pressed() -> void:
	new_game()


func _on_music_finished():
	music_player.play()


func frame_freeze(time_scale, duration):
	Engine.time_scale = time_scale
	await get_tree().create_timer(duration * time_scale).timeout
	Engine.time_scale = 1


func load_highscore() -> void:
	var file = FileAccess.open("user://highscore.save", FileAccess.READ)
	if file:
		highscore = file.get_32()
		file.close()


func save_highscore() -> void:
	var file = FileAccess.open("user://highscore.save", FileAccess.WRITE)
	if file:
		file.store_32(highscore)
		file.close()


func _on_start_button_pressed() -> void:
	new_game()
