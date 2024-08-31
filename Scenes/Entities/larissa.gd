extends Player
class_name Larissa

func set_hitboxes(player_id : int):
	if player_num == 1:
		hit_box_1.set_collision_layer_value(2, true)
		hit_box_2.set_collision_layer_value(2, true)
		$hit_boxes/special_box.set_collision_layer_value(2, true)
		hurt_box.set_collision_mask_value(3, true)
		hurt_box.set_collision_layer_value(4,true)
		head_hurt_box.set_collision_mask_value(3,true)
		hurt_box_layer = 4

	else:
		hit_box_1.set_collision_layer_value(3, true)
		hit_box_2.set_collision_layer_value(3, true)
		$hit_boxes/special_box.set_collision_layer_value(3, true)
		hurt_box.set_collision_mask_value(2, true)
		hurt_box.set_collision_layer_value(5,true)
		head_hurt_box.set_collision_mask_value(2,true)
		hurt_box_layer = 5
