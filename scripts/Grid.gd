extends Node2D

# custom classes
var Combination = load("res://scripts/Combination.gd")

# grid size
var cols = 7
var rows = 7

# first tile's position (bottom left tile)
var x_start = 120
var y_start = 1160

# tile zone size
var offset = 80

# different types of tiles
var possible_tiles = [
    preload("res://scenes/tiles/CircleTile.tscn"),
    preload("res://scenes/tiles/SquareTile.tscn"),
    preload("res://scenes/tiles/TriangleTile.tscn"),
]

# will contain all the tiles
var grid = []

# unique hash as key / combination object as value
var combinations = {}

# list of selected tiles (that are part of a combination)
var selected_tiles = []

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
    shuffle()


func init_grid():
    var array = []
    for i in rows:
        array.append([])
        for j in cols:
            array[i].append(null)
    return array


func clone_grid(to_clone):
    var array = []
    var i = 0
    for items in to_clone:
        array.append([])
        for item in items:
            array[i].append(item)
        i+=1
    return array


func populate_grid():
    var added_tiles = []
    for i in cols:
        for j in rows:
            # if grid cell is null
            if !grid[i][j]:
                # generate random tile and make sure 3 tiles of the same type are not aligned
                var tile = get_random_tile()
                while chain_exists(i, j, tile.type):
                    tile = get_random_tile()
                # add it to grid
                add_child(tile)
                tile.init(i, j)
                tile.position = get_pixel_position(i, j)
                grid[i][j] = tile
                # added tiles will be returned
                added_tiles.append(tile)
    return added_tiles


func shuffle():
    var current_grid = clone_grid(grid)
    var added_tiles = []
    # make sure there are at least 5 combinations in the grid
    while combinations.size() < 5:
        # free tiles added in the previous iteration and restore current grid state
        if !added_tiles.empty():
            for added in added_tiles:
                added.queue_free()
            grid = clone_grid(current_grid)

        # populate grid and check for combinations
        added_tiles = populate_grid()
        identify_combinations()


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
                # select the tile
                var tile = grid[grid_position.x][grid_position.y]
                select_tile(tile)


func select_tile(tile):
    # if already selected
    if tile.selected && selected_tiles.has(tile):
        tile.deselect()
        selected_tiles.erase(tile)
    # if not selected
    else:
        var selected_tiles_clone = [] + selected_tiles
        tile.select()
        selected_tiles.append(tile)
        
        # check if a combination is still possible
        var combination_possible = false
        for combination in combinations.values():
            if combination.contains_all(selected_tiles):
                combination_possible = true
                break
        
        # if combination not possible, deselect all previous tiles
        if !combination_possible:
            for selected in selected_tiles_clone:
                selected.deselect()
                selected_tiles.erase(selected)


func identify_combinations():
    combinations = {}
    # for each tiles
    for cols in grid:
        for tile in cols:
            # check identical tiles at the top side
            var same_top = same_type_top(tile)
            for tile_top in same_top:
                # check identical tiles at the right side
                var same_right = same_type_right(tile_top)
                for tile_right in same_right:
                    # check identical tiles at the bottom side
                    var same_bottom = same_type_bottom(tile_right)
                    for tile_bottom in same_bottom:
                        if tile_bottom.row == tile.row:
                            # create a combination with the 4 identical tiles
                            var combination = Combination.new()
                            combination.init(tile, tile_top, tile_right, tile_bottom)
                            if !combinations.has(combination.custom_hash):
                                combinations[combination.custom_hash] = combination


func same_type_top(tile):
    var tiles = []
    if tile && tile.row < rows -1:
        for i in range(tile.row + 1, rows):
            if grid[tile.col][i] && grid[tile.col][i].type == tile.type:
                tiles.append(grid[tile.col][i])
    return tiles


func same_type_bottom(tile):
    var tiles = []
    if tile && tile.row > 0:
        for i in range(tile.row - 1, -1, -1):
            if grid[tile.col][i] && grid[tile.col][i].type == tile.type:
                tiles.append(grid[tile.col][i])
    return tiles


func same_type_right(tile):
    var tiles = []
    if tile && tile.col < cols - 1:
        for i in range(tile.col + 1, cols):
            if grid[i][tile.row] && grid[i][tile.row].type == tile.type:
                tiles.append(grid[i][tile.row])
    return tiles