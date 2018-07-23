extends Node2D

var direction = d.SOUTH
var speed = 4 # Tile per second
var snake_queue = []
var snake_width = 32
var is_moving = false setget _set_is_moving
# Collection of global coordinates that is occupied by snek
var snake_space = [] setget , _get_snake_space

onready var mover_timer = $MoverTimer
onready var viewport = get_viewport()

# Classes
var snake_body = preload("res://snake/components/Body.tscn") 
onready var head = $Head

# Direciton of the snake
const d = {
	EAST = Vector2(1, 0),
	SOUTH = Vector2(0, 1),
	WEST = Vector2(-1, 0),
	NORTH = Vector2(0, -1)
}

# Constants
const body_group = "snake_body"

# Signals
signal game_over
signal eat_food

func _ready():
	mover_timer.wait_time = 1.0 / speed
	mover_timer.start()
	self.connect("eat_food", self, "grow")

# Create the starting snake
func generate_starting_snake():
	# Reset values
	snake_queue = []
	get_tree().call_group(body_group, "destroy")
	
	# Set some body contents
	var starting_body = [Vector2(0,-1),Vector2(0,-2), Vector2(0,-3)]
	for body_position in starting_body:
		add_body(body_position)

# Add a body with the relative position to head
func add_body(position):
	var new_body = snake_body.instance()
	new_body.add_to_group(body_group)
	new_body.position += snake_width * position
	snake_queue.append(new_body)
	add_child(new_body)

func move_forward():
	if is_moving:
		# Get last body of snake and then switch it up wiith 
		# last position of head
		var head_position = head.global_position
		var new_head_position = head.global_position + (direction * snake_width)
		
		# Check bounds
		if new_head_position.x < 0:
			new_head_position.x = viewport.size.x - snake_width
		elif new_head_position.y < 0:
			new_head_position.y = viewport.size.y - snake_width
			
		elif new_head_position.x >= viewport.size.x:
			new_head_position.x = 0
		elif new_head_position.y >= viewport.size.y: 
			new_head_position.y = 0
		
		# Set head position
		head.global_position = new_head_position
		
		# Set tail position
		var tail_body = snake_queue.pop_back()
		snake_queue.push_front(tail_body)
		tail_body.global_position = head_position

func change_direction(new_direction):
	match direction:
		d.EAST:
			if(new_direction != d.WEST): direction = new_direction
		d.SOUTH:
			if(new_direction != d.NORTH): direction = new_direction
		d.WEST:
			if(new_direction != d.EAST): direction = new_direction
		d.NORTH:
			if(new_direction != d.SOUTH): direction = new_direction


func grow():
	add_body(snake_queue.back().position)
	
func _get_snake_space():
	snake_space = []
	snake_space.append(head.global_position / 32)
	for b in get_tree().get_nodes_in_group(body_group):
		snake_space.append(b.global_position / 32)
	return snake_space

func _set_is_moving(new_value):
	is_moving = new_value

func _on_MoverTimer_timeout():
	move_forward()
	pass

# If Head collides with anything
func _on_Head_area_entered(area):
	print("Collision")
	if area.is_in_group(body_group):
		emit_signal("game_over")
	elif area.is_in_group("food_group"):
		emit_signal("eat_food")
		area.queue_free()
	else:
		print("Unknown Object")
