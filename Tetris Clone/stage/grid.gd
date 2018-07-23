extends Sprite

export var play_dimensions = Vector2(10, 22)
export var side_offset = 1
export var cell_size = 24

onready var tetromino_collection = $Tetrominos
onready var active_position2d = $ActiveMinoPosition
onready var main_node = get_node("/root/Main")
onready var tetromino_types = main_node.tetrominos

var MinoController = preload("res://tetrilito/active_mino_controller.gd")
var mino_controller

# Bags of tetrominoes to fall contains 2x max # of minos
var mino_bag = []

# The actual cell record of the entire grid
# 1 for filled, 0 for not
var tetris_grid = [];

# Generate the blank grid array
func generate_blank_grid():
	tetris_grid = util.generate_2d_array(play_dimensions, 0)

# Drop mino from the 7 bag queue
func drop_random_mino():
	var mino_pattern_name = mino_bag.pop_front()
	var mino_pattern = tetromino_types[mino_pattern_name]
	mino_controller.drop_tetromino(
			mino_pattern.pattern,
			mino_pattern.color,
			mino_pattern.wall_kick_data
			)
	
	# if bag is half empty, refill buffer
	if mino_bag.size() < tetromino_types.size():
		generate_bag()

func generate_bag():
	var buffer = util.randomize_array_values(tetromino_types.keys())
	mino_bag += buffer

# If allowance timer of mino controller has timeout
func _on_mino_controller_allowance_expired(mino_pattern, mino_position):
	util.render_array(tetris_grid, mino_pattern, mino_position)
	_check_filled_lines()
	
	drop_random_mino()

# Checks entire grid if there are any filled lines
func _check_filled_lines():
	var lines_to_be_deleted = []
	for i in range(tetris_grid.size()):
		if util.arr_compare(
				tetris_grid[i], 
				util.generate_array(tetris_grid[i].size(), 1)
				):
			lines_to_be_deleted.append(i)
	if lines_to_be_deleted.size() > 0:
		_delete_lines(lines_to_be_deleted)

# Remove the lines that are filled
# @lines_arr - array of the y-indices values to remove from the grid
func _delete_lines(lines_arr):
	util.fill_2d_array_multirow(tetris_grid, lines_arr, 0)
	_free_mino_nodes_multirow(lines_arr)
	_unfloat_minos()
	#util._compress_values_down(tetris_grid)
	_refresh_grid_from_nodes()
	
# Checks which nodes are on a row and deletes them
func _free_mino_nodes_row(row_index):
	for cell in tetromino_collection.get_children():
		if cell.grid_position.y == row_index:
			cell.queue_free()
			
# Free minos on specific array of row indices
func _free_mino_nodes_multirow(row_indices):
	for i in row_indices:
		_free_mino_nodes_row(i)

# Fix floating minos by dropping them appropriately after line clears
# This depends on the grid array not being updated yet,
# Might have better solution in the future that only depends on 
# node and no basing from the grid array
func _unfloat_minos():
	var offset = 0
	for i in range(tetris_grid.size() - 1, 1, -1):
		if util.arr_compare(
				tetris_grid[i],
				util.generate_array(tetris_grid[i].size(), 0)):
			offset += 1
		else:
			for cell in tetromino_collection.get_children():
				if cell.grid_position.y == i:
					cell.grid_position.y += offset

# Refresh the values of the tetris grid array by reading nodes
# in the Teromino container
func _refresh_grid_from_nodes():
	util.fill_array(tetris_grid, 0)
	for cell in tetromino_collection.get_children():
		if !cell.is_queued_for_deletion():
			tetris_grid[cell.grid_position.y][cell.grid_position.x] = 1

# Connect different signals on node ready
func _connect_signals():
	mino_controller.connect(
			"set_mino_down",
			self,
			"_on_mino_controller_allowance_expired")

func _ready():
	# Make sure that the children of Grid are positioned properly
	tetromino_collection.position.x = side_offset * cell_size
	active_position2d.position.x = side_offset * cell_size
	
	# Generate the blank grid
	generate_blank_grid()
	
	# Generate bag
	generate_bag()
	
	# Setup the Tetromino Controller
	mino_controller = MinoController.new(
			self,
			active_position2d,
			tetromino_collection)
	
	drop_random_mino()
	
	_connect_signals()
	

