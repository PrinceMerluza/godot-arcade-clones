# Controller for the Active Mino
extends Node

# Sprite class of each tetrimino cell
var tetrilito_class = preload("res://tetrilito/tetrilito.tscn") 

# Contains the node which will also be the basis of the coordinates
var grid_node
var tetris_grid
var position2d_node
var tetrominos_node
var cell_size

# Details about the active tetromino
var active_pattern = []
var active_color = Color(1.0, 1.0, 1.0, 1.0)
var active_kick_data = {}
# Active Rotation type assumes 4 ways to rotate mino
# 0 - spawn state
# 1 - CW rotation from spawn
# 2 - two successive rotations from spawn (180)
# 3 - CCW rotation from spawn
# Not coupled with actual pattern of mino, might have TODO a refactor later.
# Have to be tracked independently and manually.
var active_rotation_state = 0

# Local Group for cells in the active tetromino
# contains tetrilito nodes
var active_array = []

# Timer for movement allowance when it hits an obstacle
var allowance_timer = Timer.new()

# Signals
signal set_mino_down(mino_pattern, mino_position)

func drop_tetromino(pattern, color, kick_data):
	_set_mino_position(Vector2(4, 0))
	_generate_tetromino(pattern, color, kick_data)

# Rotates the active tetromino counter-clockwise
func rotate_tetromino_ccw():
	var old_rotation_state = active_rotation_state
	var new_rotation_state = (active_rotation_state + 3) % 4
	if _wall_kick(
			old_rotation_state, 
			new_rotation_state, 
			_rotate_tetromino("ccw")):
		active_rotation_state = new_rotation_state

# Rotates the active tetromino clockwise
func rotate_tetromino_cw():
	var old_rotation_state = active_rotation_state
	var new_rotation_state = (active_rotation_state + 1) % 4
	if _wall_kick(
			old_rotation_state, 
			new_rotation_state, 
			_rotate_tetromino("cw")):
		active_rotation_state = new_rotation_state

func move_mino_left():
	_translate_mino_move_validation(Vector2(-1, 0))
	
func move_mino_right():
	_translate_mino_move_validation(Vector2(1, 0))
	
func move_mino_down():
	# If mino hits obstacle from below
	# start move allowance timer
	if !_translate_mino_move_validation(Vector2(0, 1)):
		_start_allowance_timer()

# Create a new tetromino of String type
# @pattern- n-dimension array
# @color- color of the tetromino
func _generate_tetromino(pattern, color, kick_data):
	# Get the pattern and color of the tetromino
	active_pattern = util.deep_duplicate(pattern)
	active_color = color
	active_rotation_state = 0
	active_kick_data = kick_data
	_redraw_active_tetromino()

# Called everytime a change in the active tetromino happens
func _redraw_active_tetromino():
	_draw_tetromino(
				active_pattern,
				active_color,
				position2d_node.position)

# Draw a specific tetromino with 2d array pattern, color, and position
func _draw_tetromino(pattern, color, position):
	# Erase current active cells
	for c in active_array:
		c.queue_free()
	active_array.clear()
	
	# Build the tetromino cell by cell
	for y in range(pattern.size()):
		for x in pattern[y].size():
			if pattern[y][x]:
				# Add tetromino to scene
				var new_cell = tetrilito_class.instance()
				tetrominos_node.add_child(new_cell)
				active_array.append(new_cell)
				new_cell.modulate = color
				new_cell.cell_size = cell_size
				new_cell.grid_position = _get_mino_position() + Vector2(x, y)

# Translate the active mino by the given vector
# Not this does NOT check move legality
# Validation should be done before this 
# @translate_vector - vector for translation
func _translate_mino(translate_vector):
	_set_mino_position(_get_mino_position() + translate_vector)

# Translate active mino only if move is valid
# returns boolean if move was done
func _translate_mino_move_validation(translate_vector):
	var new_position = _get_mino_position() + translate_vector
	if _is_move_legal(new_position, active_pattern):
		_set_mino_position(new_position)
		return true
	return false

# ROtate tetromino
# @style - string of cw, ccw, 180
func _rotate_tetromino(style):
	var rotated_pattern = util.deep_duplicate(active_pattern)
	var pattern_size = active_pattern.size()
	
	# Rotate based on different type of rotation
	for y in range(pattern_size):
		for x in range(pattern_size):
			match style:
				"cw":
					rotated_pattern[x][pattern_size - y - 1] = active_pattern[y][x]
				"ccw":
					rotated_pattern[pattern_size - x - 1][y] = active_pattern[y][x]
				"180":
					pass #TODO
				_:
					print("Invalid Rotate Direction")
	return rotated_pattern

# Will loop through the kick data test cases to check if one is valid.
# Will do the rotation and tranlastion on first valid test case.
# Retunrs boolan if a movement was successfully done.
# @before (int) - rotation state it was before
# @after (int) - rotation state desired
# @rotated_pattern - pattern as a result of the rotation
func _wall_kick(before, after, rotated_pattern):
	var reverse_wallkick = false
	
	# ex: 0.1
	var rotate_key = String(before) + "." + String(after)
	var reverse_rotate_key_arr = rotate_key.to_ascii()
	reverse_rotate_key_arr.invert()
	var reverse_rotate_key = reverse_rotate_key_arr.get_string_from_ascii()
	
	print("key: " + rotate_key)
	print("reverse key: " + reverse_rotate_key)
	var test_cases_arr = []
	
	# Find the proper test cases to use
	if active_kick_data.has(rotate_key):
		print("1")
		reverse_wallkick = false
		test_cases_arr = active_kick_data[rotate_key]
	elif active_kick_data.has(reverse_rotate_key):
		print("2")
		reverse_wallkick = true
		test_cases_arr = active_kick_data[reverse_rotate_key]
	else:
		return false
	
	for test_case in test_cases_arr:
		test_case = test_case * -1 if reverse_wallkick else test_case
		var prospect_position = _get_mino_position() + test_case
		if _is_move_legal(prospect_position, rotated_pattern):
			_translate_mino(test_case)
			_set_mino_pattern(rotated_pattern)
			return true
	
	return false

# Sets the mino position local to Grid
func _set_mino_position(local_position):
	position2d_node.position = local_position * cell_size
	_redraw_active_tetromino()

# Gets the mino position local to Grid
func _get_mino_position():
	return position2d_node.position / cell_size

func _set_mino_pattern(new_pattern):
	active_pattern = new_pattern
	_redraw_active_tetromino()

func _get_mino_pattern():
	return active_pattern

# Check if tetromino can move/rotated to desired direction
# @check_position - grid position to be checked
# @check_patter - patter of mino to be checked
func _is_move_legal(check_position, check_pattern):
	var tetro_size = Vector2(1, 1) * check_pattern.size() 
	var prospect_grid = util.extract_2d_array(
			tetris_grid, 
			Rect2(check_position,tetro_size),
			1)

	# Check if there is collision
	if util.is_binary_collision(prospect_grid, check_pattern):
		return false
	else:
		return true
		
# Sets the active mino in its position
func _set_mino_down():
	# Make sure it's as moved down as it gets
	# Make sure tetrilitos are inactive
	for tetrilito in active_array:
		tetrilito.dropped = true
	active_array.clear()
	
func _start_allowance_timer():
	if allowance_timer.is_stopped():
		allowance_timer.start()

# Initialize timer values and add to Grid Node
func _initialize_allowance_timer():
	allowance_timer.wait_time = 0.5
	allowance_timer.autostart = false
	allowance_timer.one_shot = true
	allowance_timer.connect("timeout", self, "_on_allowance_timeout")
	grid_node.add_child(allowance_timer)

# TODO might have to find better place for actual array rendering
func _on_allowance_timeout():
	# TODO Create better allowancec checking
	if _is_move_legal(
			_get_mino_position() + Vector2(0, 1), 
			_get_mino_pattern()) and _is_move_legal(
			_get_mino_position() + Vector2(0, 2), 
			_get_mino_pattern()):
		allowance_timer.stop()
		# Remove current active mino from active_array so it would stay on tree
	else:
		_set_mino_down()
		emit_signal("set_mino_down", active_pattern, _get_mino_position())

func _init(grid, position2d, tetrominos_collection):
	self.grid_node = grid
	self.cell_size = grid_node.cell_size
	self.tetris_grid = grid_node.tetris_grid
	self.position2d_node = position2d
	self.tetrominos_node = tetrominos_collection
	_initialize_allowance_timer()