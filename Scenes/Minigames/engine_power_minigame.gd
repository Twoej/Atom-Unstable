extends Minigame

var items: Array[Node2D]
var held := false

var block_held: PickUpItem = null
var prev_block_held: PickUpItem = null

var mouse_in_zone = [false, false, false, false, false]
@onready var block_for_zone = [$Block1, $Block2, $Block3, $Block4, $Block5]
@onready var locked_in_blocks = [$FinalPositions/Sprite2D, $FinalPositions/Sprite2D2, $FinalPositions/Sprite2D3, $FinalPositions/Sprite2D4, $FinalPositions/Sprite2D5]
var complete_blocks = [false, false, false, false, false]

func _process(delta):
	if Input.is_action_just_released("click"):
		for i in 5:
			if mouse_in_zone[i] and (block_for_zone[i] == prev_block_held):
				block_for_zone[i].set_visible(false)
				block_for_zone[i].get_node("Collision").set_disabled(true)
				locked_in_blocks[i].set_visible(true)
				complete_blocks[i] = true
	if held:
		prev_block_held = block_held
	else:
		prev_block_held = null
	if complete_blocks == [true, true, true, true, true] and $WinTimer.is_stopped():
		minigame_complete.emit()
		$WinTimer.start()

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


func _on_block_1_pos_mouse_entered():
	mouse_in_zone[0] = true


func _on_block_1_pos_mouse_exited():
	mouse_in_zone[0] = false


func _on_block_2_pos_mouse_entered():
	mouse_in_zone[1] = true


func _on_block_2_pos_mouse_exited():
	mouse_in_zone[1] = false


func _on_block_3_pos_mouse_entered():
	mouse_in_zone[2] = true


func _on_block_3_pos_mouse_exited():
	mouse_in_zone[2] = false


func _on_block_4_pos_mouse_entered():
	mouse_in_zone[3] = true


func _on_block_4_pos_mouse_exited():
	mouse_in_zone[3] = false


func _on_block_5_pos_mouse_entered():
	mouse_in_zone[4] = true


func _on_block_5_pos_mouse_exited():
	mouse_in_zone[4] = false


func _on_win_timer_timeout():
	self.queue_free()
