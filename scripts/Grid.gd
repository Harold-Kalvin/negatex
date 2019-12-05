extends Node2D

# grid size
var cols = 7
var rows = 7

# first tile's position (bottom left tile)
var x_start = 120
var y_start = 1160

# tile zone size
var offset = 80

# will contain all the tiles
var grid = []

# different types of tiles
var possible_tiles = [
    preload("res://scenes/tiles/CircleTile.tscn"),
    preload("res://scenes/tiles/SquareTile.tscn"),
    preload("res://scenes/tiles/TriangleTile.tscn"),
]

# input related vars
var grid_position_on_touch = null


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
    for i in cols:
        for j in rows:
            # generate random tile and make sure 3 tiles of the same type are not aligned
            var tile = get_random_tile()
            while chain_exists(i, j, tile.type):
                tile = get_random_tile()
            
            # add it to grid
            add_child(tile)
            tile.position = get_pixel_position(i, j)
            grid[i][j] = tile


func get_random_tile():
    var rand = floor(rand_range(0, possible_tiles.size()))
    return possible_tiles[rand].instance()


func chain_exists(col, row, type):
    if col > 1 && grid[col - 1][row].type == type && grid[col - 2][row].type == type:
        return true
    if row > 1 && grid[col][row - 1].type == type && grid[col][row - 2].type == type:
        return true
    return false


func get_pixel_position(col, row):
    var x = x_start + offset * col
    var y = y_start + -offset * row
    return Vector2(x, y)


func get_grid_position(x, y):
    var col = round((x - x_start) / offset)
    var row = round((y - y_start) / -offset)
    return Vector2(col, row)


func within_grid_range(col, row):
    if col >= 0 && col < cols && row >= 0 && row < rows:
        return true
    return false


func _input(event):
    if event is InputEventScreenTouch:
        var grid_position = get_grid_position(event.position.x, event.position.y)
        if within_grid_range(grid_position.x, grid_position.y):
            # on touch, keep grid_position in memory
            if event.pressed:
                grid_position_on_touch = grid_position
            # on release, check if grid_position is still the same
            if !event.pressed && grid_position == grid_position_on_touch:
                var tile = grid[grid_position.x][grid_position.y]
                tile.select() if !tile.selected else tile.deselect()