extends Node2D

export (String) var type

var col
var row
var selected = false


func _ready():
    pass # Replace with function body.


func init(new_col, new_row):
    col = new_col
    row = new_row


func select():
    selected = true
    print("select %s -> %s" % [self, type])
    
    
func deselect():
    selected = false
    print("deselect %s -> %s" % [self, type])