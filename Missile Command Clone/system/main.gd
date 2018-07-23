extends Node

# References
onready var viewport = get_viewport()

# Timers
onready var enemy_spawner = $EnemySpawner
onready var difficulty_timer = $DifficultyScaler

# Resources
var cursor_image = preload("res://sprites/cursor.png")

# Scenes
var explosion_class = preload("res://player/cannon/bullet/explosion/explosion.tscn")
var enemy_01_class = preload("res://enemy/enemy_01/enemy_01.tscn")


func _ready():
	randomize()
	
	# Center window
	var screen_size = OS.get_screen_size()
	var window_size = OS.get_window_size()
	OS.set_window_position(screen_size*0.5 - window_size*0.5)
	
	Input.set_custom_mouse_cursor(cursor_image, Input.CURSOR_ARROW, Vector2(16, 16))
	
	enemy_spawner.start()
	difficulty_timer.start()
	pass
	
# Ugly connected from a child cannon
func _on_player_bullet_explode(bullet_position):
	# Set Expxlosion properties
	var explosion = explosion_class.instance()
	explosion.setup(bullet_position, 128)
	add_child(explosion)
	pass

func _on_EnemySpawner_timeout():
	var start_position = Vector2(randf() * viewport.size.x, 0)
	var target_location = Vector2(randf() * viewport.size.x, viewport.size.y)
	
	var new_enemy = enemy_01_class.instance()
	new_enemy.scale = Vector2(0.5, 0.5)
	add_child(new_enemy)
	new_enemy.setup_enemy(start_position, 100, target_location - start_position)


func _on_DifficultyScaler_timeout():
	enemy_spawner.wait_time -= 0.1
