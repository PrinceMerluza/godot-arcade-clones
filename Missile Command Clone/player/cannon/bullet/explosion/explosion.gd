extends Area2D

onready var base_size = $Sprite.texture.get_width()
var max_radius = 0 setget _set_max_radius
var growth_rate = 250
var decay_rate = 0.15

onready var decay_timer = $DecayTimer

func _ready():
	self.scale = Vector2(0, 0)
	decay_timer.wait_time = decay_rate
	pass

func _set_max_radius(new_radius):
	max_radius = new_radius

func _process(delta):
	# Make explosion grow until it matches max radius
	var current_size = self.scale * base_size
	if current_size.x < self.max_radius:
		var added_size = Vector2(growth_rate, growth_rate) * delta
		self.scale += (added_size / Vector2(max_radius, max_radius))
	else:
		if decay_timer.is_stopped():
			decay_timer.start()
	pass

func setup(position, max_radius):
	self.position = position
	self.max_radius = max_radius
	self.add_to_group("explosion")
	

func _on_DecayTimer_timeout():
	queue_free()
