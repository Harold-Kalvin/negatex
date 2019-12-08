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