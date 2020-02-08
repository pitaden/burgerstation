/ai/advanced/ranged/

	left_click_chance = 100

	distance_target_min = 4
	distance_target_max = 8

/ai/advanced/ranged/handle_movement()

	if(objective_attack)
		if(get_dist(owner,objective_attack) > distance_target_max)
			owner.move_dir = get_dir(owner,objective_attack)
		else if(get_dist(owner,objective_attack) <= distance_target_min)
			owner.move_dir = get_dir(objective_attack,owner)
		else
			owner.move_dir = 0

	else if(get_dist(owner,start_turf) >= 5)
		owner.move_dir = get_dir(owner,start_turf)
	else if(stationary)
		owner.move_dir = 0
	else
		owner.move_dir = pick(list(0,0,0,0,NORTH,EAST,SOUTH,WEST))
