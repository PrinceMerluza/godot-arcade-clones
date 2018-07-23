extends Node2D

# Their position relative to a grid array
var grid_position = Vector2(0, 0) setget _set_grid_position
var cell_size = 0

# If they are on the grid and inactive and is a result of playing.
var dropped = false

func _set_grid_position(new_value):
	grid_position = new_value
	self.position = new_value * cell_size

func _ready():
	pass