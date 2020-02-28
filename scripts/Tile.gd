extends Node2D

export (String) var type

var col
var row
var selected = false

# nodes
var scale_tween;
var move_tween;


func _ready():
    scale_tween = $ScaleTween
    move_tween = $MoveTween


func init(new_col, new_row):
    col = new_col
    row = new_row


func select():
    selected = true
    print("select %s -> %s" % [self, type])
    
    
func deselect():
    selected = false
    print("deselect %s -> %s" % [self, type])


func remove():
    scale_tween.interpolate_property(self, "scale", self.scale, Vector2(0, 0), 0.5, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)
    scale_tween.start()
    yield(scale_tween, "tween_completed")
    self.queue_free()


func move(new_pos):
    move_tween.interpolate_property(self, "position", self.position, new_pos, 0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
    move_tween.start()
    yield(move_tween, "tween_completed")