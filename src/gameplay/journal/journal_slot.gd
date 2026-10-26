extends Button

@onready var sprite: TextureRect = $VBoxContainer/sprite
@onready var label: Label = $VBoxContainer/Label
@onready var newbadge: Label = $newbadge

signal fish_selected(fish:FishData)

var fish: FishData

func setup(f:FishData) -> void:
	fish = f
	visible = true
	disabled = false
	sprite.texture = f.sprite
	
	if PlayerData.is_discovered(f):
		var color: Color = FishData.Rarity_colors[f.rarity]
		sprite.modulate = Color.WHITE
		label.text = f.name
		label.add_theme_color_override("font_color", color)
		newbadge.visible = PlayerData.is_new(f)
		apply_style(color, true)
	else:
		sprite.modulate = Color.BLACK
		label.text = "???"
		label.remove_theme_color_override("font_color")
		apply_style(Color(0.4, 0.4, 0.4), false)

func clear_slot() -> void:
	fish = null
	visible = true
	disabled = true
	sprite.texture = null
	label.text = ""
	label.remove_theme_color_override("font_color")
	newbadge.visible = false
	apply_style(Color(0.25, 0.25, 0.25), false)

func make_style(color: Color, bg_alpha: float, glow: bool, brighten: float = 0.0) -> StyleBoxFlat:
	var c := color.lightened(brighten)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(c.r, c.g, c.b, bg_alpha)
	sb.border_color = c
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(0)
	if glow:
		sb.shadow_color = Color(c.r, c.g, c.b, 0.25)
		sb.shadow_size = 5
		sb.shadow_offset = Vector2.ZERO
	return sb

func apply_style(color: Color, discovered: bool) -> void:
	var bg := 0.18 if discovered else 0.08
	add_theme_stylebox_override("normal", make_style(color, bg, discovered))
	add_theme_stylebox_override("hover", make_style(color, bg + 0.1, discovered, 0.25))
	add_theme_stylebox_override("pressed", make_style(color, bg + 0.2, discovered, 0.1))
	add_theme_stylebox_override("disabled", make_style(color, bg, false))
	add_theme_stylebox_override("focus", make_style(color, bg, discovered, 0.4))


func _pressed() -> void:
	if fish:
		fish_selected.emit(fish)

func set_marked(marked: bool) -> void:
	if marked:
		label.add_theme_color_override("font_color", Color.RED)
		apply_style(Color.RED, true)
	else:
		setup(fish)
