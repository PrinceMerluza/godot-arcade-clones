extends Label


func _ready():
	var root_node = get_node("/root/Main")
	root_node.connect("player2_score_changed", self, "update_score")

func update_score(score):
	print(score)
	set_text(String(score))
	pass
