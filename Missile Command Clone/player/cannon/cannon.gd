extends Area2D

onready var viewport = get_viewport()
onready var shooter = $Shooter

const _player_bullet_class = preload("res://player/cannon/bullet/player_bullet.tscn")

export (float) var bullet_speed = 250 
export (String) var main_controller = "/root/Main"

func _ready():
	pass

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			var target = viewport.get_mouse_position()
			shoot_bullet(target, bullet_speed)
	pass

func shoot_bullet(target, speed):
	var bullet = _player_bullet_class.instance().constructor(
			target, speed, self.shooter.position)
	bullet.scale = Vector2(0.4, 0.4)
	bullet.connect(
			"explode", 
			get_node(main_controller), 
			"_on_player_bullet_explode")
	self.add_child(bullet)
	 
	
	
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
