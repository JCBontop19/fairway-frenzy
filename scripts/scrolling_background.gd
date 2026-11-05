extends Node2D 

@export var scroll_speed := 200 
@export var scroll_direction := Vector2.LEFT 

var tex_width := 0 

func _ready(): 
	var sprite := $Sprite2D 
	
	if sprite.texture: 
		tex_width = sprite.texture.get_width() 
	else: push_error("ScrollingBackground has no texture!") 

func _process(delta): 
	position += scroll_direction * scroll_speed * delta 
	
	if scroll_direction.x < 0: 
		if position.x <= -tex_width: 
			position.x += tex_width 
	elif scroll_direction.x > 0: 
		if position.x >= tex_width: position.x -= tex_width
