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
            # generate random tile and make sure 3 tiles of the same type are not aligned
            var tile = get_random_tile()
            while chain_exists(i, j, tile.type):
                tile = get_random_tile()
            
            # add it to grid
            add_child(tile)
            tile.position = get_tile_position(i, j)
            grid[i][j] = tile


func get_random_tile():
    var rand = floor(rand_range(0, possible_tiles.size()))
    return possible_tiles[rand].instance()


func chain_exists(row, col, type):
    if row > 1 && grid[row - 1][col].type == type && grid[row - 2][col].type == type:
        return true
    if col > 1 && grid[row][col - 1].type == type && grid[row][col - 2].type == type:
        return true
    return false


func get_tile_position(row, col):
    var x = x_start + offset * col
    var y = y_start + -offset * row
    return Vector2(x, y)