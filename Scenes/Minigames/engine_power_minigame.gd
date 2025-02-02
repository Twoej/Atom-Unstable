extends Minigame

var items: Array[Node2D]
var held := false

var block_held: PickUpItem = null

func _on_pick_up_item_mouse_in_out(item: PickUpItem, in_out: bool):
	if in_out:
		items.append(item)
	else:
		items.erase(item)
	items.sort_custom(_sort_z_index)
	if in_out and items.size() and !held:
		items[0].set_mouse_inside(true)

func _on_pick_up_item_held_change(held: bool):
	self.held = held


func _sort_z_index(a, b):
	if a.get_z_index() > b.get_z_index():
		return true
	else:
		return false

func _on_block_held_unheld(is_held: bool, block: PickUpItem):
	if is_held:
		block_held = block
	else:
		block_held = null


func _on_block_1_pos_mouse_entered():
	pass # Replace with function body.


func _on_block_1_pos_mouse_exited():
	pass # Replace with function body.


func _on_block_2_pos_mouse_entered():
	pass # Replace with function body.


func _on_block_2_pos_mouse_exited():
	pass # Replace with function body.


func _on_block_3_pos_mouse_entered():
	pass # Replace with function body.


func _on_block_3_pos_mouse_exited():
	pass # Replace with function body.


func _on_block_4_pos_mouse_entered():
	pass # Replace with function body.


func _on_block_4_pos_mouse_exited():
	pass # Replace with function body.


func _on_block_5_pos_mouse_entered():
	pass # Replace with function body.


func _on_block_5_pos_mouse_exited():
	pass # Replace with function body.
