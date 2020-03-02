var tile1 
var tile2
var tile3
var tile4
var custom_hash


func init(new_tile1, new_tile2, new_tile3, new_tile4):
    tile1 = new_tile1
    tile2 = new_tile2
    tile3 = new_tile3
    tile4 = new_tile4
    custom_hash = hash(tile1) + hash(tile2) + hash(tile3) + hash(tile4)


func to_string():
    return "[%s][%s] - [%s][%s] - [%s][%s] - [%s][%s]" % [
        tile1.col, tile1.row,
        tile2.col, tile2.row,
        tile3.col, tile3.row,
        tile4.col, tile4.row
    ]


func contains_all(tiles):
    var hashes = [hash(tile1), hash(tile2), hash(tile3), hash(tile4)]
    for tile in tiles:
        if !hashes.has(hash(tile)):
            return false
    return true


func get_min_col():
    return _min_arr([tile1.col, tile2.col, tile3.col, tile4.col])


func get_max_col():
    return _max_arr([tile1.col, tile2.col, tile3.col, tile4.col])


func get_min_row():
    return _min_arr([tile1.row, tile2.row, tile3.row, tile4.row])


func get_max_row():
    return _max_arr([tile1.row, tile2.row, tile3.row, tile4.row])


func _min_arr(arr):
    var min_val = arr[0]

    for i in range(1, arr.size()):
        min_val = min(min_val, arr[i])

    return min_val


func _max_arr(arr):
    var max_val = arr[0]

    for i in range(1, arr.size()):
        max_val = max(max_val, arr[i])

    return max_val