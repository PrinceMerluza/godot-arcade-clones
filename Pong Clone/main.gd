extends Node

# Object References
onready var player = $PlayerPaddle
onready var ball = $Ball
onready var viewport = get_viewport()

# Initial Ball Movement
export (float) var initial_force = 400
export (float) var initial_angle_allowance = PI/4


# Scores
var player1_score = 0 setget set_player1_score
var player2_score = 0 setget set_player2_score
signal player1_score_changed(new_score)
signal player2_score_changed(new_score)


func _ready():
	# Ccenter window
	var screen_size = OS.get_screen_size()
	var window_size = OS.get_window_size()
	OS.set_window_position(screen_size*0.5 - window_size*0.5)
	
	randomize()
	ball.connect("out_of_bounds", self, "_on_ball_out_of_bounds")
	ball.connect("max_bounce_reached", self, "_on_ball_max_bounce_reached")
	reset_ball()

func _process(delta):
	if Input.is_action_pressed('debug_reset_ball'):
		reset_ball()

# Reset ball in the center and start randomly
# param: force(optional) set speed of ball
func reset_ball(angle_allowance = initial_angle_allowance, force = initial_force):
	ball.position = Vector2(viewport.size.x / 2, viewport.size.y / 2)
	ball.move_to_angle(generate_angle(angle_allowance), force)
	ball.current_bounce = 0
	$BallSpeedTimer.start()

func set_player1_score(new_value):
	player1_score = new_value
	emit_signal("player1_score_changed", player1_score)
	
func set_player2_score(new_value):
	player2_score = new_value
	emit_signal("player2_score_changed", player2_score)

func generate_angle(angle_range):
	# Generate random angle
	var angle = randf() * (angle_range)
	# split to have equal parts in the y sections
	angle -= angle_range / 2
	# Ranomdize to flip horizontally
	angle -= (PI * round(randf()))
	return angle 

# When ball goes out of bounds, update scores accordingly
func _on_ball_out_of_bounds(side):
	reset_ball()
	match side:
		'left':
			self.player2_score += 1
		'right':
			self.player1_score += 1
		_: 
			print("Invalid argument from out of bounds signal.")
	
# Angle allowance is lower for max bounce reset to make it fairer
func _on_ball_max_bounce_reached():
	reset_ball(PI / 5.5, ball.speed)
	
func _on_BallSpeedTimer_timeout():
	ball.speed += 25
