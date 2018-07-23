extends Area2D

var explosion_class = preload("res://player/cannon/bullet/explosion/explosion.tscn")

onready var viewport = get_viewport()

onready var trail = get_node("Trail/Line2D")
onready var main_node = get_node("/root/Main")

var velocity = Vector2(0, 0)
var speed = 0 setget _set_speed
var direction = Vector2(0, 0) setget _set_direction

func _ready():
	pass

func setup_enemy(position, speed, direction):
	self.position = position
	self.speed = speed
	self.direction = direction
	
	# Set ends of trail
	trail.add_point(position)
	trail.add_point(position)

func _set_direction(new_value):
	direction = new_value.normalized()
	_recompute_velocity()

func _set_speed(new_value):
	speed = new_value
	_recompute_velocity()
	
func _recompute_velocity():
	self.velocity = self.direction.normalized() * self.speed

func _process(delta):
	self.global_position += self.velocity * delta
	trail.set_point_position(1, position)
	
	# delete if out of bounds
	if self.global_position.y > viewport.size.y:
		queue_free()
	pass


func _on_Enemy_01_area_entered(area):
	if area.is_in_group("explosion"):
		self.monitoring = false
		self.monitorable = false
		var explosion = explosion_class.instance()
		explosion.setup(self.position, 100)
		main_node.add_child(explosion)
		queue_free()
		
