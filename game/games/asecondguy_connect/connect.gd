extends Node2D

const END_MESSAGES := [
	"Draw",
	"You won",
	"You lost",
]
const PLAYER_COLORS := [Color.yellow, Color.red]

var _last_chip: RigidBody2D
var _end_condition := 0
var _chips_played := 0
var _fallen_chips := []

onready var _play_area := $PlayArea
onready var _grid := $Grid
onready var _chips := $Chips
onready var _spawners := [$Spawner1, $Spawner2]


func _ready():
	_spawn_chip(0)
	# setup the code representation of all played chips
	for _x in range(7):
		var tmp := []
		for _y in range(6):
			tmp.push_back(null)
		_fallen_chips.push_back(tmp)


func _empty():
	$Bounds/Bottom.set_deferred("disabled", true)
	for c in _chips.get_children():
		# set all chips back to rigid mode
		c.set_deferred("mode", 0)


func _on_PlayArea_body_exited(_body):
	if _end_condition == -1:
		return
	if _play_area.get_overlapping_bodies().size() == 0:
		GameManager.end_game(END_MESSAGES[_end_condition])


func _on_chip_sleep(chip: RigidBody2D):
	var grid_pos: Vector2 = _grid.global_to_grid_pos(chip.position)
	if grid_pos.x >= 0:
		chip.set_deferred("mode", chip.MODE_STATIC)
		_chips_played += 1
		_fallen_chips[grid_pos.x][grid_pos.y] = chip.player_id
		_update_end_condition()
		# max number of chips is 42
		if _chips_played == 42 or _end_condition != 0:
			_empty()
		else:
			# [1, 0][last_id] ==> 0 -> 1, 1 -> 0
			_spawn_chip([1, 0][chip.player_id])


func _spawn_chip(player_id := 0):
	var chip: RigidBody2D = preload("res://games/asecondguy_connect/chip.tscn").instance()
	chip.player_id = player_id
	chip.color = PLAYER_COLORS[player_id]
	chip.global_position = _spawners[player_id].global_position
	if chip.connect("sleeping_state_changed", self, "_on_chip_sleep", [chip]) != OK:
		GameManager.end_game("A fatal error occured.")
	_chips.call_deferred("add_child", chip)


func _update_end_condition():
	pass


func _on_PlayArea_tree_exiting():
	_end_condition = -1
