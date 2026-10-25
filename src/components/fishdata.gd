class_name FishData
extends Resource

enum Rarity { COMMON, UNCOMMON, RARE, LEGENDARY }
enum Region {POND, RIVER, OCEAN, CAVE}

const Rarity_colors = [
	# Makes a set color for each rarity
	Color(0.85, 0.85, 0.85),
	Color(0.4, 0.85, 0.4),
	Color(0.35, 0.6, 1.0),
	Color(1.0, 0.8, 0.2),
]

# Gives variables for each fish
@export var name: String
@export_multiline var description: String
@export var rarity: Rarity = Rarity.COMMON
@export_range(0.0,1.0) var difficulty: float = 0.5
@export var region: Region = Region.POND
@export var sprite: Texture2D
@export var min_weight: float = 0.5  # kg
@export var max_weight: float = 2.0
