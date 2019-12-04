extends Node2D

# grid size
var cols = 7
var rows = 7

# first tile's position (bottom left tile)
var x_start = 120
var y_start = 1160

# tile zone size
var offset = 80

# grid's top left corner position 
var top = 640
var left = 80

# will contain all the tiles
var grid = []

# different types of tiles
var possible_tiles = [
    preload("res://scenes/tiles/CircleTile.tscn"),
    preload("res://scenes/tiles/SquareTile.tscn"),
    preload("res://scenes/tiles/TriangleTile.tscn"),
]

# input related vars
var row_col_on_touch = null


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


func _input(event):
    if event is InputEventScreenTouch:
        # get row and col from pixel position
        var row_col = get_row_col_from_position(event.position)
        if row_col:
            # on touch, keep row_col in memory
            if event.pressed:
                row_col_on_touch = row_col
            # on release, check if row_col is still the same
            if !event.pressed && row_col == row_col_on_touch:
                print(row_col)


func get_row_col_from_position(position):
    var tile_top = position.y - top
    var tile_left = position.x - left
    var float_row = rows - (tile_top / offset)
    var float_col = tile_left / offset
    var row = int(float_row)
    var col = int(float_col)
    # row and col are within grid's range 
    if float_row >= 0 && float_col >= 0 && row < rows && col < cols:
        return [row, col]
    return null