extends Area2D

export (int) var speed = 300
export var up_control = ''
export var down_control = ''

onready var bound = get_viewport_rect()
onready var paddle_height = $Sprite.texture.get_height()
onready var reflection = $ReflectionBasis

func _ready():
	pass
	
func _process(delta):
	get_input(delta)

func get_input(delta):
	if Input.is_action_pressed(up_control):
		if position.y > paddle_height / 2:
			position.y -= speed * delta
	if Input.is_action_pressed(down_control):
		if position.y < bound.end.y - (paddle_height / 2):
			position.y += speed * delta


func _on_PlayerPaddle_area_shape_entered(area_id, object, area_shape, self_shape):
	# vector for bouncing
	var normal_vector = (object.global_position - reflection.global_position).normalized()
	#bounce
	object.velocity = object.velocity.bounce(normal_vector)
	object.current_bounce = 0
