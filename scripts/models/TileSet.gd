var tiles = []


func to_string():
    var string = ""
    for tile in tiles:
        string = string + "[%s][%s]" % [tile.col, tile.row]
        if tile != tiles[-1]:
            string = string + " - "
    return string


func custom_hash():
    var custom_hash = 0
    for tile in tiles:
        custom_hash = custom_hash + hash(tile)
    return custom_hash if custom_hash != 0 else -1


func contains_all(other_tiles):
    var current_hashes = _tiles_hashes()
    for other_tile in other_tiles:
        if !current_hashes.has(hash(other_tile)):
            return false
    return true


func cols():
    var cols = []
    for tile in tiles:
        cols.append(tile.col)
    return cols


func rows():
    var rows = []
    for tile in tiles:
        rows.append(tile.row)
    return rows


func _tiles_hashes():
    var hashes = []
    for tile in tiles:
        hashes.append(hash(tile))
    return hashes