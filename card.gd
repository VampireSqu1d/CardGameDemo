class_name Card extends Button

@export_category("Textures")
@export var card_texture: Texture2D
@onready var card_texture_rect: TextureRect = %CardTexture
@onready var shadow_texture_rect: TextureRect = %ShadowTexture

@export_category("Card Values")
@export_range(0.0, 20.0) var angle_x_max: = 10
@export_range(0.0, 20.0) var angle_y_max: = 10
@export_range(0.0, 30.0) var max_offset_shadow: = 10

var hover_tween: Tween
var movement_tween: Tween

var card_extended: = false
var is_being_dragged: = false
var dragged_from_pos: = Vector2.ZERO

func _ready() -> void:
	card_texture_rect.texture = card_texture
	handle_shadow()


func _on_card_texture_mouse_entered() -> void:
	if hover_tween and hover_tween.is_running():
		hover_tween.kill()
	if is_being_dragged: return
	hover_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	hover_tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.5)
	card_extended = true


func _on_card_texture_mouse_exited() -> void:
	if hover_tween and hover_tween.is_running():
		hover_tween.kill()
	if is_being_dragged: return
	hover_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	hover_tween.tween_property(self, "scale", Vector2.ONE, 0.5)
	card_extended = false
	card_texture_rect.material.set_shader_parameter("x_rot", 0)
	card_texture_rect.material.set_shader_parameter("y_rot", 0)


func _on_card_texture_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.is_pressed():
			_on_mouse_button_down()
		else:
			_on_mouse_button_up()
	
	if is_being_dragged:
		var card_offset = size * 0.5
		global_position = lerp(global_position, get_global_mouse_position() - card_offset, 0.5)
		handle_shadow()
	if not event is InputEventMouseMotion and card_extended or is_being_dragged:
		return
	
	var mouse_pos: Vector2 = get_local_mouse_position()
	#var diff: Vector2 = (position + size) - mouse_pos
	
	var lerp_val_x: = remap(mouse_pos.x, 0.0, size.x, 0, 1)
	var lerp_val_y: = remap(mouse_pos.y, 0.0, size.y, 0, 1)
	
	var rot_x: float = rad_to_deg(lerp_angle(-angle_x_max, angle_x_max, lerp_val_x))
	var rot_y: float = rad_to_deg(lerp_angle(-angle_y_max, angle_y_max, lerp_val_y))
	
	card_texture_rect.material.set_shader_parameter("x_rot", rot_x)
	card_texture_rect.material.set_shader_parameter("y_rot", rot_y)

var dissolve_tween: Tween
func _on_mouse_button_down() -> void:
	z_index += 10
	is_being_dragged = true
	card_texture_rect.material.set_shader_parameter("x_rot", 0)
	card_texture_rect.material.set_shader_parameter("y_rot", 0)
	card_texture_rect.use_parent_material = true


func _on_mouse_button_up() -> void:
	z_index -= 10
	is_being_dragged = false
	card_texture_rect.use_parent_material = false


func revert_pos() -> void:
	move_to_pos(dragged_from_pos)


func move_to_pos(move_to: Vector2):
	if movement_tween and movement_tween.is_running():
		movement_tween.kill()
	movement_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BOUNCE)
	movement_tween.tween_property(self, "global_position", move_to, 0.5)


func handle_shadow() -> void:
	var center: = get_viewport_rect().size * 0.5
	var distance: = global_position.x - center.x
	shadow_texture_rect.position.x = lerp(0.0, -sign(distance) * max_offset_shadow, abs(distance/ center.x))
