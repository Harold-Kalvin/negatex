extends Node2D

var cols = 7
var rows = 7
var x_start = 120
var y_start = 1160
var offset = 80
var grid = []
var tiles = [
	preload("res://scenes/tiles/CircleTile.tscn"),
	preload("res://scenes/tiles/SquareTile.tscn"),
	preload("res://scenes/tiles/TriangleTile.tscn"),
]

func _ready():
	grid = init_grid()
	print(grid)

func init_grid():
	var array = []
	for i in rows:
		array.append([])
		for j in cols:
			array[i].append(null)
	return array

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
