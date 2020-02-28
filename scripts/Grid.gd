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
    preload("res://scenes/tiles/DiamondTile.tscn"),
    preload("res://scenes/tiles/SquareTile.tscn"),
    preload("res://scenes/tiles/TriangleTile.tscn"),
]

# will contain all the tiles
var grid = []

# will contain the positions (Vector2) of the tiles above the grid
var grid_above = []

# unique hash as key / combination object as value
var combinations = {}

# list of selected tiles (that are part of a combination)
var selected_tiles = []

# list of tiles that were removed
var removed_tiles = []

# list of tiles that were moved
var moved_tiles = []

# input related vars
var grid_position_on_touch = null

# animation related
var is_animating = false


func _ready():
    randomize()
    grid = init_grid()
    shuffle()
    display_tiles()


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
                tile.init(i, j)
                tile.position = get_pixel_position(i, j)
                grid[i][j] = tile
                # added tiles will be returned
                added_tiles.append(tile)
    return added_tiles


func shuffle():
    var current_grid = clone_grid(grid)
    var added_tiles = []
    combinations = {}
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


func display_tiles():
    for col in grid:
        for tile in col:
            add_child(tile)


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
        if !is_animating && within_grid_range(grid_position.x, grid_position.y):
            # on touch, keep grid_position in memory
            if event.pressed:
                grid_position_on_touch = grid_position
            # on release, check if grid_position is still the same
            if !event.pressed && grid_position == grid_position_on_touch:
                # select the tile
                var tile = grid[grid_position.x][grid_position.y]
                select_tile(tile)
                # check if a combination has been selected (4 tiles)
                if len(selected_tiles) == 4:
                    # process grid (remove tiles etc.)
                    remove_combination_tiles()
                    move_existing_tiles()
                    generate_new_tiles()
                    # animate the whole process
                    start_animations()


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


func remove_combination_tiles():
    var comb_key = hash(selected_tiles[0]) + hash(selected_tiles[1]) + hash(selected_tiles[2]) + hash(selected_tiles[3])
    var combination = combinations[comb_key]
    selected_tiles.clear()

    # remove the tiles from the grid
    for col in range(combination.get_min_col(), combination.get_max_col() + 1):
        for row in range(combination.get_min_row(), combination.get_max_row() + 1):
            var tile = grid[col][row]
            grid[col][row] = null
            removed_tiles.append(tile)


func move_existing_tiles():
    grid_above = []
    var i = 0
    for col in grid:
        var j = 0
        var empty = []
        for tile in col:
            # keep empty tile in memory
            if tile == null:
                empty.append(Vector2(i, j))
            # drop next non empty tile
            else:
                if !empty.empty():
                    # get first (from bottom) empty tile position
                    var new_col = empty[0].x
                    var new_row = empty[0].y
                    # update non empty tile position in grid
                    tile.col = new_col
                    tile.row = new_row
                    grid[new_col][new_row] = tile
                    grid[i][j] = null
                    empty.remove(0)
                    empty.append(Vector2(i, j))
                    moved_tiles.append(tile)

            j = j + 1
        i = i + 1
        grid_above.append(empty)


func generate_new_tiles():
    # generate the new tiles
    shuffle()

    # display those tiles above the grid
    for col in grid_above:
        if !col.empty():
            var j = 0
            for grid_pos in col:
                var tile = grid[grid_pos.x][grid_pos.y]
                tile.position = get_pixel_position(grid_pos.x, rows + j)
                moved_tiles.append(tile)
                j = j + 1

    display_tiles()


func start_animations():
    # animations starting
    is_animating = true

    # tiles removal animation
    var last_tile = removed_tiles.pop_back()
    for tile in removed_tiles:
        tile.remove()
    
    # wait until last animation has completed
    yield(last_tile.remove(), "completed")
    removed_tiles.clear()
    
    # tiles moving animation
    last_tile = moved_tiles.pop_back()
    for tile in moved_tiles:
        tile.move(get_pixel_position(tile.col, tile.row))
    
    # wait until last animation has completed
    yield(last_tile.move(get_pixel_position(last_tile.col, last_tile.row)), "completed")
    moved_tiles.clear()
    
    # animations ending
    is_animating = false


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


func dump_grid():
    print("\n")
    for col in grid:
        var arr = []
        for tile in col:
            if tile:
                arr.append(tile.type)
            else:
                arr.append(tile)
        print(arr)
    print("\n")