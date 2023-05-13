extends VisibleOnScreenNotifier2D

func _ready():
	get_parent().set_disabled(true)

func _on_screen_entered():
	get_parent().set_disabled(false)

func _on_screen_exited():
	get_parent().set_disabled(true)
