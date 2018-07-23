extends Node

func _ready():
	randomize()
	pass

# For version 3.0 no deep duplication for GDScript,
# this is a custom one
func deep_duplicate(old_array):
	var new_array = []
	for element in old_array:
		new_array.append(deep_duplicate(element) if typeof(element) == TYPE_ARRAY else element)
	return new_array

# Randomize indices of exisitng elemnts in an array
func randomize_array_values(target_array):
	var copy_of_target = target_array.duplicate()
	var result_array = []
	
	# Randomly take elements from array to new one
	while copy_of_target.size() > 0:
		var i = randi() % copy_of_target.size()
		result_array.append(copy_of_target[i])
		copy_of_target.remove(i)
	
	return result_array

# Returns BOolean. Compares 2 1d arrays if contents are the same.
# NOT DEEP
func arr_compare(array1, array2):
	for i in range(array1.size()):
		if array1[i] != array2[i]:
			return false
	return true
	
# Create 1d Array with default values
func generate_array(size, default_value = null):
	var return_array = []
	for i in range(size):
		return_array.append(default_value)
	return return_array

# ===============================================
# ========== 2D ARRAY UTILITIES =================
# ===============================================

# Create and returns a 2d array
# @dimensions - Vector2 to determine dimensions of 2d array
# @default_value - default value to fill array
func generate_2d_array(dimensions, default_value = null):
	# Create empty array with null values
	var new_array = []
	new_array.resize(dimensions.y)
	for y in range(dimensions.y):
		new_array[y] = []
		new_array[y].resize(dimensions.x)
	if default_value != null:
		fill_array(new_array, default_value)
	return new_array

# Fill a 2d array with a specific value
func fill_array(target_array, value):
	for y in range(target_array.size()):
		for x in range(target_array[y].size()):
			target_array[y][x] = value

# Fill a row of a 2 array with a specified value
# @target_array - array to be modified
# @row_index - 0 based index of 2d array row
# @value - value to fill the row with
func fill_2d_array_row(target_array, row_index, value):
	target_array[row_index] = generate_array(target_array[row_index].size(), value)

# Fills an array of row indices with specified value
func fill_2d_array_multirow(target_array, row_indices, value):
	for i in row_indices:
		fill_2d_array_row(target_array, i, value)

# Mostly for testing fill the array with random numbers
func random_fill_array(target_array, value_range = 10):
	for y in target_array.size():
		for x in target_array[y].size():
			target_array[y][x] = randi() % value_range

# Extract some Data
# @target_array - the 2d array to extract from
# @extract_rect - Rect2 to determine which section to extract
# @fill - elements to put to out of bound sections 
func extract_2d_array(target_array, extract_rect, fill = null):
	# Generate blank array for basis with optional default values
	var result = generate_2d_array(extract_rect.size, fill)
	
	# Get sizes of target 2d array
	# This assumes that the 2d array is rectangular
	var target_width = target_array[0].size()
	var target_height = target_array.size()
	
	for y in range(result.size()):
		for x in range(result[y].size()):
			# If inside 
			if ((extract_rect.position.x + x >= 0)
					and (extract_rect.position.x + x < target_width)
					and (extract_rect.position.y + y >= 0)
					and (extract_rect.position.y + y < target_height)):
				result[y][x] = (target_array \
						[extract_rect.position.y + y] \
						[extract_rect.position.x + x])
	return result

# Returns boolean if all values of both arrays are equal
# This assumes same dimensions for both arrays
# and both arrays are rectangular
func deep_compare(array1, array2):
	var array_h = array1.size()
	var array_w = array1[0].size()
	
	for y in range(array_h):
		for x in range(array_w):
			if array1[y][x] != array2[y][x]:
				return false
	return true
	
# ===============================================
# ================ 'BINARY' DATA 2D ARRAY =======
# ===============================================

# Returns boolean if there is collision between 2 arrays
# Elements are either 0 or 1 and 'collision' is 
# when both arrays have 1 in the same location
func is_binary_collision(array1, array2):
	# Assumption of rectangular and equal dimensioned arrays
	var array_h = array1.size()
	var array_w = array1[0].size()
	
	for y in range(array_h):
		for x in range(array_w):
			if (array1[y][x] * array2[y][x]) != 0:
				return true
	return false

# Apply the 1 values to the larger target array
# @target_array - 2d array that will be modified
# @payload - 2d Array will contain info about the payload
# @positino - Vector2 position offset of payload
func render_array(target_array, payload, position):
	for y in payload.size():
		for x in payload[y].size():
			if payload[y][x] == 1: 
				target_array[y + position.y][x + position.x] = 1  

# Move filled (1) values to fill up void space (0s)
# @force_fill - true if every 0 should be filled up or false 
# 				if only entire row is 0
func _compress_values_down(target_array, force_fill = false):
	# !!!DOES NOT WORK! Top-Most is retained alway will fix TODO
	var offset = 0
	for i in range(target_array.size() - 1, 1, -1):
		if arr_compare(
				target_array[i],
				generate_array(target_array[i].size(), 0)):
			offset += 1
		else:
			target_array[i + offset] = target_array[i].duplicate()
