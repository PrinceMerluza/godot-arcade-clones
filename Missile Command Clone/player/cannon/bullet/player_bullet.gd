extends Area2D

signal explode(bullet_global_position)

var velocity = Vector2(0, 0)
var target = Vector2(0, 0) # Target in global coordinates 
var speed = 0


func _ready():
	self.velocity = (self.target - self.global_position).normalized() * self.speed
	pass

func _process(delta):
	self.global_position += self.velocity * delta
	_check_target_reached()
	pass

func _check_target_reached():
	if self.global_position.y < self.target.y:
		print("BOOM") 
		emit_signal("explode", self.global_position)
		print("bullet: " + String(self.global_position))
		velocity = Vector2(0, 0 )
		queue_free()
	pass

# Can't figure out a way to call a constructor from a PackedScene
# so this constructor needs to be manually called outside
func constructor(target, speed, starting_position):
	self.position = starting_position
	self.target = target
	self.speed = speed
	return self
	pass
