extends Minigame

var items: Array[Node2D]
var held := false
var fuse_in_place := false
var fuse: Node2D

func _process(_delta):
	if fuse_in_place and Input.is_action_just_released("click"):
		fuse.set_visible(false)
		fuse.get_node("Hitbox").queue_free()
		$BreakerComplete.set_visible(true)
		$WinTimer.start()

func _on_pick_up_item_mouse_in_out(item: PickUpItem, in_out: bool):
	if in_out:
		items.append(item)
	else:
		items.erase(item)
	items.sort_custom(_sort_z_index)
	if in_out and items.size() and !held:
		items[0].set_mouse_inside(true)

func _sort_z_index(a, b):
	if a.get_z_index() > b.get_z_index():
		return true
	else:
		return false

func _on_pick_up_item_held_change(held: bool):
	self.held = held


func _on_fuse_slot_area_entered(area):
	if area.is_in_group("Fuse"):
		fuse_in_place = true
		fuse = area


func _on_fuse_slot_area_exited(area):
	if area.is_in_group("Fuse"):
		fuse_in_place = false
		fuse = null


func _on_win_timer_timeout():
	minigame_complete.emit()
	self.queue_free()
	
