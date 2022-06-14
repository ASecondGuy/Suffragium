extends Node2D

onready var _play_area := $PlayArea
onready var _grid := $grid
onready var _chips := $chips

var _last_chip: RigidBody2D
var tmp := 0


func _ready():
	for c in _chips.get_children():
		c.connect("sleeping_state_changed", self, "_on_chip_sleep", [c])


func _empty():
	$bounds/bottom.set_deferred("disabled", true)
	for c in _chips.get_children():
		# set all chips back to rigid mode
		c.set_deferred("mode", 0)


func _on_PlayArea_body_exited(_body):
	if _play_area.get_overlapping_bodies().size() == 0:
		GameManager.end_game()


func _on_chip_sleep(chip: RigidBody2D):
	var i: Vector2 = _grid.global_to_grid_pos(chip.position)
	if i.x >= 0:
		chip.set_deferred("mode", chip.MODE_STATIC)
		tmp += 1
		if tmp > 3:
			_empty()
