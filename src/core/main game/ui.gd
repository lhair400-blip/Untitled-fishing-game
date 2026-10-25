extends Node

@onready var journal: Control = $journal

var toggle_journal: bool = false

func update():
	#If the journal visible then if the button is pressed again it will close
	if toggle_journal:
		if journal.visible:
			journal.close()
		else:
			journal.open()
		get_viewport().set_input_as_handled()
