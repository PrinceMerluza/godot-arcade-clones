extends Node

onready var play_grid = get_node("Grid")
onready var active_mino = get_node("Grid/ActiveMinoPosition")
onready var dropper_timer = $DropperTimer
onready var mino_container = get_node("Grid/Tetrominos")

var debug_pause = false

# Patterns for all the tetrominos
var tetrominos = {
	I_shape = {
		pattern = [
			[0, 0, 0, 0],
			[1, 1, 1, 1],
			[0, 0, 0, 0],
			[0, 0, 0, 0]],
		color = Color(0, 1, 1, 1),
		wall_kick_data = {
			"0.1": [
				Vector2(0, 0),
				Vector2(-2, 0),
				Vector2(1, 0),
				Vector2(-2, 1),
				Vector2(1, -2)
			],
			"1.2": [
				Vector2(0, 0),
				Vector2(-1, 0),
				Vector2(2, 0),
				Vector2(-1, -2),
				Vector2(2, 1)
			],
			"2.3": [
				Vector2(0, 0),
				Vector2(2, 0),
				Vector2(-1, 0),
				Vector2(2, -	1),
				Vector2(-1, 2)
			],
			"0.3": [
				Vector2(0, 0),
				Vector2(-1, 0),
				Vector2(2, 0),
				Vector2(-1, -2),
				Vector2(2, 1)
			]
		}
	},
	J_shape = {
		pattern = [
			[1, 0, 0],
			[1, 1, 1],
			[0, 0, 0]],
		color = Color(0, 0, 1, 1),
		wall_kick_data = {
			"0.1": [
				Vector2(0, 0),
				Vector2(-1, 0),
				Vector2(-1, -1),
				Vector2(0, 2),
				Vector2(-1, 2)
			],
			"1.2": [
				Vector2(0, 0),
				Vector2(1, 0),
				Vector2(1, 1),
				Vector2(0, -2),
				Vector2(1, -2)
			],
			"2.3": [
				Vector2(0, 0),
				Vector2(1, 0),
				Vector2(1, -1),
				Vector2(0, 2),
				Vector2(1, 2)
			],
			"0.3": [
				Vector2(0, 0),
				Vector2(1, 0),
				Vector2(1, -1),
				Vector2(0, 2),
				Vector2(1, 2)
			]
		}
	},
	L_shape = {
		pattern = [
			[0, 0, 1],
			[1, 1, 1],
			[0, 0, 0]],
		color = Color(1, 0.5, 0, 1),
		wall_kick_data = {
			"0.1": [
				Vector2(0, 0),
				Vector2(-1, 0),
				Vector2(-1, -1),
				Vector2(0, 2),
				Vector2(-1, 2)
			],
			"1.2": [
				Vector2(0, 0),
				Vector2(1, 0),
				Vector2(1, 1),
				Vector2(0, -2),
				Vector2(1, -2)
			],
			"2.3": [
				Vector2(0, 0),
				Vector2(1, 0),
				Vector2(1, -1),
				Vector2(0, 2),
				Vector2(1, 2)
			],
			"0.3": [
				Vector2(0, 0),
				Vector2(1, 0),
				Vector2(1, -1),
				Vector2(0, 2),
				Vector2(1, 2)
			]
		}
	},
	O_shape = {
		pattern = [
			[1, 1],
			[1, 1]],
		color = Color(1, 1, 0, 1),
			wall_kick_data = {
			"0.1": [
				Vector2(0, 0),
				Vector2(-1, 0),
				Vector2(-1, -1),
				Vector2(0, 2),
				Vector2(-1, 2)
			],
			"1.2": [
				Vector2(0, 0),
				Vector2(1, 0),
				Vector2(1, 1),
				Vector2(0, -2),
				Vector2(1, -2)
			],
			"2.3": [
				Vector2(0, 0),
				Vector2(1, 0),
				Vector2(1, -1),
				Vector2(0, 2),
				Vector2(1, 2)
			],
			"0.3": [
				Vector2(0, 0),
				Vector2(1, 0),
				Vector2(1, -1),
				Vector2(0, 2),
				Vector2(1, 2)
			]
		}
	},
	S_shape = {
		pattern = [
			[0, 1, 1],
			[1, 1, 0],
			[0, 0, 0]],
		color = Color(0, 1, 0, 1),
		wall_kick_data = {
			"0.1": [
				Vector2(0, 0),
				Vector2(-1, 0),
				Vector2(-1, -1),
				Vector2(0, 2),
				Vector2(-1, 2)
			],
			"1.2": [
				Vector2(0, 0),
				Vector2(1, 0),
				Vector2(1, 1),
				Vector2(0, -2),
				Vector2(1, -2)
			],
			"2.3": [
				Vector2(0, 0),
				Vector2(1, 0),
				Vector2(1, -1),
				Vector2(0, 2),
				Vector2(1, 2)
			],
			"0.3": [
				Vector2(0, 0),
				Vector2(1, 0),
				Vector2(1, -1),
				Vector2(0, 2),
				Vector2(1, 2)
			]
		}
	},
	Z_shape = {
		pattern = [
			[1, 1, 0],
			[0, 1, 1],
			[0, 0, 0]],
		color = Color(1, 0, 1, 1),
		wall_kick_data = {
			"0.1": [
				Vector2(0, 0),
				Vector2(-1, 0),
				Vector2(-1, -1),
				Vector2(0, 2),
				Vector2(-1, 2)
			],
			"1.2": [
				Vector2(0, 0),
				Vector2(1, 0),
				Vector2(1, 1),
				Vector2(0, -2),
				Vector2(1, -2)
			],
			"2.3": [
				Vector2(0, 0),
				Vector2(1, 0),
				Vector2(1, -1),
				Vector2(0, 2),
				Vector2(1, 2)
			],
			"0.3": [
				Vector2(0, 0),
				Vector2(1, 0),
				Vector2(1, -1),
				Vector2(0, 2),
				Vector2(1, 2)
			]
		}
	},
	T_shape = {
		pattern = [
			[0, 1, 0],
			[1, 1, 1],
			[0, 0, 0]],
		color = Color(1, 0, 0, 1),
		wall_kick_data = {
			"0.1": [
				Vector2(0, 0),
				Vector2(-1, 0),
				Vector2(-1, -1),
				Vector2(0, 2),
				Vector2(-1, 2)
			],
			"1.2": [
				Vector2(0, 0),
				Vector2(1, 0),
				Vector2(1, 1),
				Vector2(0, -2),
				Vector2(1, -2)
			],
			"2.3": [
				Vector2(0, 0),
				Vector2(1, 0),
				Vector2(1, -1),
				Vector2(0, 2),
				Vector2(1, 2)
			],
			"0.3": [
				Vector2(0, 0),
				Vector2(1, 0),
				Vector2(1, -1),
				Vector2(0, 2),
				Vector2(1, 2)
			]
		}
	}
}

func get_input():
	if Input.is_action_just_pressed("rotate_ccw"):
		play_grid.mino_controller.rotate_tetromino_ccw()
	if Input.is_action_just_pressed("rotate_cw"):
		play_grid.mino_controller.rotate_tetromino_cw()
	if Input.is_action_just_pressed("left"):
		play_grid.mino_controller.move_mino_left()
	if Input.is_action_just_pressed("right"):
		play_grid.mino_controller.move_mino_right()
	if Input.is_action_pressed("soft_drop"):
		play_grid.mino_controller.move_mino_down()
	if Input.is_action_just_pressed("debug_pause"):
		if debug_pause:
			dropper_timer.start()
		else: 
			dropper_timer.stop()
		debug_pause = !debug_pause
		

func _on_DropperTimer_timeout():
	play_grid.mino_controller.move_mino_down()

func _center_window():
	var screen_size = OS.get_screen_size()
	var window_size = OS.get_window_size()
	OS.set_window_position(screen_size*0.5 - window_size*0.5)

func _ready():
	var x = "Hello World!"
	var x_arr = x.to_ascii()
	print("x_arr: " + String(x_arr))
	x_arr.invert()
	var y = x_arr.get_string_from_ascii()
	print(y)
	
	randomize()
	_center_window()	
	dropper_timer.start()

func _process(delta):
	get_input()