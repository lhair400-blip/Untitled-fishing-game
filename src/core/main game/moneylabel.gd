extends Label

func _ready() -> void:
	update_text(PlayerData.money)
	PlayerData.money_changed.connect(update_text)

func update_text(amount: int) -> void:
	text = "$%d" % amount
