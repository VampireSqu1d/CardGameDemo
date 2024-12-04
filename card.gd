class_name Card extends Button

@export_category("Textures")
@export var card_texture: Texture2D
@onready var card_texture_rect: TextureRect = %CardTexture
@onready var shadow_texture_rect: TextureRect = %ShadowTexture
@onready var back_texture: TextureRect = %BackTexture

@export_category("Card Values")
@export var face_card_down: bool = false
@export_range(0.0, 20.0) var angle_x_max: float = 10
@export_range(0.0, 20.0) var angle_y_max: float = 10
@export_range(0.0, 30.0) var max_offset_shadow: float = 10
@export_range(1.1, 2) var hover_scale: float = 1.2

var hover_tween: Tween
var movement_tween: Tween
var destroy_tween: Tween

var faced_down: bool = false:
	set(value):
		faced_down = value
		if faced_down:
			back_texture.show()
			card_texture_rect.hide()
		else:
			back_texture.hide()
			card_texture_rect.show()

var card_extended: = false
var is_being_dragged: = false
var can_get_dragged: = true
var dragged_from_pos: = Vector2.ZERO

func _ready() -> void:
	pivot_offset.x = size.x / 2.0
	pivot_offset.y = size.y / 2.0
	angle_x_max = deg_to_rad(angle_x_max)
	angle_y_max = deg_to_rad(angle_y_max)
	
	card_texture_rect.texture = card_texture
	faced_down = face_card_down
	handle_shadow()


func flip() -> void:
	faced_down = !faced_down


func _on_card_texture_mouse_entered() -> void:
	if hover_tween and hover_tween.is_running():
		hover_tween.kill()
	if is_being_dragged: return
	hover_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	hover_tween.tween_property(self, "scale", Vector2(hover_scale, hover_scale), 0.5)
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
	if can_get_dragged:
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
	
	var lerp_val_x: = remap(mouse_pos.x, 0.0, size.x, 0, 1)
	var lerp_val_y: = remap(mouse_pos.y, 0.0, size.y, 0, 1)
	
	var rot_x: float = rad_to_deg(lerp_angle(-angle_x_max, angle_x_max, lerp_val_x))
	var rot_y: float = rad_to_deg(lerp_angle(-angle_y_max, angle_y_max, lerp_val_y))
	
	card_texture_rect.material.set_shader_parameter("x_rot", rot_x)
	card_texture_rect.material.set_shader_parameter("y_rot", rot_y)


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


func destroy() -> void:
	card_texture_rect.use_parent_material = true
	back_texture.use_parent_material = true
	can_get_dragged = false
	if destroy_tween and destroy_tween.is_running():
		destroy_tween.kill()
	destroy_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	destroy_tween.tween_property(material, "shader_parameter/dissolve_value", 0.0, 2.0).from(1.0)
	destroy_tween.parallel().tween_property(shadow_texture_rect, "self_modulate:a", 0.0, 1.0)
	await  destroy_tween.finished
	queue_free()


func _get_drag_data(_at_position: Vector2) -> Variant:
	return self
