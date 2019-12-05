extends Node2D

export (String) var type

var selected = false


func _ready():
    pass # Replace with function body.


func select():
    selected = true
    print("select %s -> %s" % [self, type])
    
    
func deselect():
    selected = false
    print("deselect %s -> %s" % [self, type])