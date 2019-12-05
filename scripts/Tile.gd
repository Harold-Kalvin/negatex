extends Node2D

export (String) var type

var selected = false


func _ready():
    pass # Replace with function body.


func select():
    selected = true
    print("select %s" % self)
    
    
func deselect():
    selected = false
    print("deselect %s" % self)