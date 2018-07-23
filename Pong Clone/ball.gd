extends Area2D

onready var bounds = get_viewport_rect()
onready var sprite = $Sprite
onready var radius = sprite.get_texture().get_height() / 2

var direction = 0
var speed = 300 setget set_speed
var max_speed = 1000
var velocity = Vector2(0, 0) setget set_velocity
# Number of times ball could bounce in edges before changing angle
export (int) var bounce_threshold = 5
var current_bounce = 0

signal out_of_bounds(side)
signal max_bounce_reached

func _ready():
	pass

func _process(delta):
	# Bounce form edges
	if (position.y - radius <= 0) or (position.y + radius >= bounds.size.y):
		current_bounce += 1
		if(current_bounce >= bounce_threshold):
			current_bounce = 0
			emit_signal("max_bounce_reached")
		else:
			set_velocity(Vector2(velocity.x, -velocity.y))			
		
	# If ball goes out of bounds on players' side
	if (position.x - radius <= 0):
		emit_signal("out_of_bounds", 'left')
		current_bounce = 0
	if (position.x + radius >= bounds.size.x):
		emit_signal("out_of_bounds", 'right')
		current_bounce = 0
	position += velocity * delta

func set_velocity(new_value):
	velocity = new_value

# When setting speed also recall conversion to velocity
func set_speed(new_value):
	self.velocity = self.velocity.normalized() * new_value
	speed = clamp(new_value, 0, max_speed)
	print(speed)
	
# Convert angle and speed to velocity
func move_to_angle(angle, speed = self.speed):
	self.speed = speed
	self.velocity = Vector2(cos(angle) * speed, sin(angle) * speed)
