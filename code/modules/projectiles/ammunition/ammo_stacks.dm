// Stacks or bunches of various types of ammunition

/obj/item/stack/ammunition
	throwforce = 1
	w_class = 2

	var/list/obj/item/ammo_casing/stored_ammo = list()

/obj/item/stack/ammunition/proc/update_stack_data()
	if (!stored_ammo.len)
		qdel(src)
	if (!update_strings())
		qdel(src)
	//update_icons()

/obj/item/stack/ammunition/proc/update_strings()
	if (stored_ammo.len > 1)
		var/obj/item/ammo_casing/A = get_ammo_casing()
		if (!A)
			world << "DEBUG: get_ammo_casing() returned null"
			return 0
		name = "[A.caliber] [A.stack_plural_name]"
		desc = "A handful of [stored_ammo.len] [A.caliber] [A.stack_plural_name]."
		gender = PLURAL
		return 1 // Should be a stack
	else
		return 0 // Shouldn't be a stack

/obj/item/stack/ammunition/proc/get_ammo_casing()
	if (!stored_ammo.len)
		return 0
	return stored_ammo[1]

