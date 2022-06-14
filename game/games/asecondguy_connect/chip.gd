extends RigidBody2D

var color := Color.green
var player_id := -1

var picked := false


func _integrate_forces(state):
	if picked:
		var move: Vector2 = get_global_mouse_position() - global_position

		var result := Physics2DTestMotionResult.new()
		if !test_motion(move, true, 0.08, result):
			state.linear_velocity = move / state.step
		else:
			state.linear_velocity = move / state.step * result.collision_safe_fraction
			state.angular_velocity = 0


func _on_chip_input_event(_viewport, event, _shape_idx):
	if !event is InputEventMouseButton:
		return
	if event.pressed:
		_pick()
	else:
		_unpick()


func _input(event):
	if mode == MODE_STATIC:
		return
	if !event is InputEventMouseButton:
		return
	if !event.pressed:
		_unpick()


func _draw():
	var radius: float = $CollisionShape2D.shape.radius
	draw_circle(Vector2(), radius, color)
	draw_circle(Vector2(), radius - 2, color.darkened(0.5))


func _pick():
	picked = true
	inertia = 1
	sleeping = false


func _unpick():
	picked = false
	sleeping = false
