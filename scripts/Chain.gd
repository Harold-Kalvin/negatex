enum CHAIN_TYPE {NONE, HORIZONTAL, VERTICAL, COMBINED}

var tiles = []
var type = CHAIN_TYPE.NONE setget set_type


func get_custom_hash():
    var custom_hash = 0
    for tile in tiles:
        custom_hash = custom_hash + hash(tile)
    return custom_hash if custom_hash != 0 else -1


func to_string():
    var string = ""
    for tile in tiles:
        string = string + "[%s][%s]" % [tile.col, tile.row]
        if tile != tiles[-1]:
            string = string + " - "
    return string


func set_type(value):
    if value in CHAIN_TYPE.values():
        type = value