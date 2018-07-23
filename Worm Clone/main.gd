extends Node

var snake_class = preload("res://snake/Snake.tscn")
var food_class = preload("res://food/Food.tscn")
onready var viewport = get_viewport()
var snake = null
var tile_size = 0

func _ready():
	randomize()
	# Center Window
	var screen_size = OS.get_screen_size()
	var window_size = OS.get_window_size()
	OS.set_window_position(screen_size*0.5 - window_size*0.5)
	
	# Set up snake and start
	reset_snake()
	snake.is_moving = true
	tile_size = snake.snake_width
	
	drop_food()

func _process(delta):
	get_input()

func _on_game_over():
	snake.queue_free()
	print("Game Over")
	reset_snake()
	snake.is_moving=true

func reset_snake():
	snake = snake_class.instance()
	add_child(snake)
	
	snake.position = viewport.size / 2
	snake.generate_starting_snake()
	snake.is_moving = false
	
	# Connect snake signals
	snake.connect("game_over", self, "_on_game_over")
	snake.connect("eat_food", self, "drop_food")

# Snake Controls
func get_input():
	if(Input.is_action_pressed("up")):
		snake.change_direction(snake.d.NORTH)
	if(Input.is_action_pressed("down")):
		snake.change_direction(snake.d.SOUTH)
	if(Input.is_action_pressed("left")):
		snake.change_direction(snake.d.WEST)
	if(Input.is_action_pressed("right")):
		snake.change_direction(snake.d.EAST)
		
	# DEBUG Controls
	if(Input.is_action_just_pressed("debug_grow")):
		snake.grow()

func drop_food():
	# Determine which space is not yet occupied by snek
	var available_game_space = []
	var tiled_size = viewport.size / tile_size
	for y in range(tiled_size.y):
		for x in range(tiled_size.x):
			if !snake.snake_space.has(Vector2(x, y)):
				available_game_space.append(Vector2(x, y))
	
	# Randomize food in free areas
	var random_index = randi() % available_game_space.size()
	var drop_position = available_game_space[random_index]
	# Set-up Food
	var food = food_class.instance()
	food.add_to_group("food_group")
	food.position = drop_position * tile_size
	add_child(food)