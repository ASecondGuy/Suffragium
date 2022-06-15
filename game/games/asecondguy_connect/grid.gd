tool
extends StaticBody2D

export var tile_size := Vector2(25, 25) setget set_tile_size
export var grid_size := Vector2(7, 6) setget set_grid_size
export var grid_color := Color.black setget set_grid_color

# helper for global_to_grid_pos()
var _bounds := Rect2(Vector2(), grid_size)


func _ready():
	var shape := RectangleShape2D.new()
	shape.extents.x = 1
	shape.extents.y = grid_size.y * tile_size.y / 2
	for x in range(grid_size.x + 1):
		var node := CollisionShape2D.new()
		node.shape = shape
		node.position.x = x * tile_size.x
		node.position.y = shape.extents.y
		add_child(node)


func set_tile_size(val: Vector2):
	tile_size = val
	update()


func set_grid_size(val: Vector2):
	grid_size = val
	_bounds = Rect2(Vector2(), grid_size)
	update()


func set_grid_color(val: Color):
	grid_color = val
	update()


func _draw():
	for x in range(grid_size.x + 1):
		for y in range(grid_size.y + 1):
			draw_line(
				Vector2(x * tile_size.x, 0),
				Vector2(x * tile_size.x, grid_size.y * tile_size.y),
				grid_color,
				2
			)
			draw_line(
				Vector2(0, y * tile_size.y),
				Vector2(x * tile_size.x, y * tile_size.y),
				grid_color,
				2
			)


func global_to_grid_pos(pos: Vector2):
	var floored := ((pos - global_position) / tile_size).floor()
	if is_in_grid(floored):
		return floored
	return Vector2(-1, -1)

func is_in_grid(pos:Vector2)->bool:
	return _bounds.has_point(pos)
