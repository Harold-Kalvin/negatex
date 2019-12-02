extends Node2D

var cols = 7
var rows = 7
var x_start = 120
var y_start = 1160
var offset = 80
var grid = []
var possible_tiles = [
    preload("res://scenes/tiles/CircleTile.tscn"),
    preload("res://scenes/tiles/SquareTile.tscn"),
    preload("res://scenes/tiles/TriangleTile.tscn"),
]

func _ready():
    randomize()
    grid = init_grid()
    populate_grid()

func init_grid():
    var array = []
    for i in rows:
        array.append([])
        for j in cols:
            array[i].append(null)
    return array

func populate_grid():
    for i in rows:
        for j in cols:
            # choose random tile
            var rand = floor(rand_range(0, possible_tiles.size()))
            var tile = possible_tiles[rand].instance()
            # add it to grid
            add_child(tile)
            tile.position = get_tile_position(i, j)
            grid[i][j] = tile

func get_tile_position(row, col):
    var x = x_start + offset * col
    var y = y_start + -offset * row
    return Vector2(x, y)