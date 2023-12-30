
# <-------- v POISSON DISTRIBUTION METHODS - MOVE OUT INTO UTILS v -------->
enum ShapeType {CIRCLE, POLYGON}

static func generate_points_for_circle(circle_position: Vector2, circle_radius: float, poisson_radius: float, retries: int, start_point := Vector2.INF) -> PackedVector2Array:
	var sample_region_rect = Rect2(circle_position.x - circle_radius, circle_position.y - circle_radius, circle_radius * 2, circle_radius * 2)
	var shape_info: Dictionary = {}
	if start_point.x == INF:
		var angle: float = 2 * PI * randf()
		start_point = circle_position + Vector2(cos(angle), sin(angle)) * circle_radius * randf()
	elif not Geometry2D.is_point_in_circle(start_point, circle_position, circle_radius):
		push_error("Starting point ", start_point, " is not a valid point inside the circle!")
		return PackedVector2Array()
	shape_info[ShapeType.CIRCLE] = {
		"circle_position": circle_position,
		"circle_radius": circle_radius
	}
	return _generate_points(ShapeType.CIRCLE, sample_region_rect, poisson_radius, retries, start_point, shape_info)


static func _generate_points(shape: int, sample_region_rect: Rect2, poisson_radius: float, retries: int, start_pos: Vector2, shape_info: Dictionary) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	points.clear()
	var cell_size: float = poisson_radius / sqrt(2)
	var cols: int = max(floor(sample_region_rect.size.x / cell_size), 1)
	var rows: int = max(floor(sample_region_rect.size.y / cell_size), 1)
	
	# scale the cell size in each axis
	var cell_size_scaled: Vector2 = Vector2.ZERO
	cell_size_scaled.x = sample_region_rect.size.x / cols 
	cell_size_scaled.y = sample_region_rect.size.y / rows
	
	# use tranpose to map points starting from origin to calculate grid position
	var transpose = -sample_region_rect.position
	
	var grid: Array = []
	for i in cols:
		grid.append([])
		for j in rows:
			grid[i].append(-1)
	
	var spawn_points: Array = []
	spawn_points.append(start_pos)
	
	while spawn_points.size() > 0:
		var spawn_index: int = randi() % spawn_points.size()
		var spawn_centre: Vector2 = spawn_points[spawn_index]
		var sample_accepted: bool = false
		for i in retries:
			var angle: float = 2 * PI * randf()
			var sample: Vector2 = spawn_centre + Vector2(cos(angle), sin(angle)) * (poisson_radius + poisson_radius * randf())
			if _is_point_in_sample_region(sample, shape, shape_info):
				if _is_valid_sample(shape, sample, transpose, cell_size_scaled, cols, rows, grid, points, poisson_radius):
					grid[int((transpose.x + sample.x) / cell_size_scaled.x)][int((transpose.y + sample.y) / cell_size_scaled.y)] = points.size()
					points.append(sample)
					spawn_points.append(sample)
					sample_accepted = true
					break
		if not sample_accepted and points.size() > 0:
			spawn_points.remove_at(spawn_index)
	return points


static func _is_valid_sample(shape: int, sample: Vector2, transpose: Vector2, cell_size_scaled: Vector2, cols: int, rows: int, grid: Array, points: Array, poisson_radius: float) -> bool:
	var cell := Vector2(int((transpose.x + sample.x) / cell_size_scaled.x), int((transpose.y + sample.y) / cell_size_scaled.y))
	var cell_start := Vector2(max(0, cell.x - 2), max(0, cell.y - 2))
	var cell_end := Vector2(min(cell.x + 2, cols - 1), min(cell.y + 2, rows - 1))

	for i in range(cell_start.x, cell_end.x + 1):
		for j in range(cell_start.y, cell_end.y + 1):
			var search_index: int = grid[i][j]
			if search_index != -1:
				var dist: float = points[search_index].distance_to(sample)
				if dist < poisson_radius:
					return false
	return true


static func _is_point_in_sample_region(sample: Vector2, shape: int, shape_info: Dictionary) -> bool:
	if shape == ShapeType.POLYGON and Geometry2D.is_point_in_polygon(sample, shape_info[shape]["points"]):
			return true
	elif shape == ShapeType.CIRCLE and Geometry2D.is_point_in_circle(
		sample, 
		shape_info[shape]["circle_position"], 
		shape_info[shape]["circle_radius"]
	):
		return true
	else:
		return false

# <-------- ^ POISSON DISTRIBUTION METHODS - MOVE OUT INTO UTILS ^ -------->

# <-------- v DRAWING METHODS - MOVE OUT INTO UTILS v -------->

static func draw_circle_arc(obj_to_draw, center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PackedVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

	for index_point in range(nb_points):
		obj_to_draw.draw_line(points_arc[index_point], points_arc[index_point + 1], color)


static func draw_circle_donut_poly(obj_to_draw, center, inner_radius, outer_radius, angle_from, angle_to, color):  
	var nb_points = 64 
	var points_arc = PackedVector2Array()  
	var points_arc2 = PackedVector2Array()  
	var colors = PackedColorArray([color])  

	for i in range(nb_points+1):  
		var angle_point = angle_from + i * (angle_to - angle_from) / nb_points - 90  
		points_arc.push_back(center + Vector2(cos(deg_to_rad(angle_point)), sin(deg_to_rad(angle_point))) * outer_radius)  
	for i in range(nb_points,-1,-1):  
		var angle_point = angle_from + i * (angle_to - angle_from) / nb_points - 90  
		points_arc.push_back(center + Vector2(cos(deg_to_rad(angle_point)), sin(deg_to_rad(angle_point))) * inner_radius)  
	obj_to_draw.draw_polygon(points_arc, colors)  

# <-------- ^ DRAWING METHODS - MOVE OUT INTO UTILS ^ -------->