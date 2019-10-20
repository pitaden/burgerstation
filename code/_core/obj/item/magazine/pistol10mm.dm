/obj/item/magazine/pistol_10mm
	name = "\improper 10mm auto pistol magazine"
	bullet_type = "10mm_auto"
	icon = 'icons/obj/items/magazine/10mmpistol.dmi'
	icon_state = "10mmpistol"
	bullet_count_max = 8

	weapon_whitelist = list(
		/obj/item/weapon/ranged/bullet/magazine/pistol
	)

/obj/item/magazine/pistol_10mm/on_spawn()
	for(var/i=1, i <= bullet_count_max, i++)
		stored_bullets += new /obj/item/bullet/pistol_10mm(src)
	update_icon()

/obj/item/magazine/pistol_10mm/update_icon()
	if(length(stored_bullets))
		icon_state = "[initial(icon_state)]_1"
	else
		icon_state = "[initial(icon_state)]"

	..()


/obj/item/magazine/pistol_10mm/surplus
	name = "\improper surplus 10mm auto pistol magazine"


/obj/item/magazine/pistol_10mm/surplus/on_spawn()
	for(var/i=1, i <= bullet_count_max, i++)
		stored_bullets += new /obj/item/bullet/pistol_10mm/surplus(src)
	update_icon()