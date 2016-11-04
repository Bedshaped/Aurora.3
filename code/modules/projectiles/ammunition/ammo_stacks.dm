#define SHELL_BASE_COLOR rgb( 255, 255, 255)
#define SHELL_SEC_COLOR rgb( 214, 214, 214)

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
	update_icons()

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

/obj/item/stack/ammunition/proc/update_icons()
	if (overlays.len == stored_ammo.len)
		return
	var/diff = stored_ammo.len - overlays.len
	for (var/i = stored_ammo.len, i != (overlays.len + Sign(diff)), i = i - Sign(diff)) // Will either add or subtract depending on the sign of diff
		if (diff < 0)
			overlays.len-- // delete our overlays one at a time
			continue
		var/ammo_path = stored_ammo[i].type // or else we add new overlays depending on ammo types
		var/icon/new_icon
		if (ammo_path == /obj/item/ammo_casing/c38)
			new_icon = image('icons/obj/ammo_stacks.dmi', icon_state = "casing", dir = pick(cardinal))
		else if (ammo_path == /obj/item/ammo_casing/c38r)
			new_icon = image('icons/obj/ammo_stacks.dmi', icon_state = "casing_r", dir = pick(cardinal))
		else if (ammo_path == /obj/item/ammo_casing/shotgun/stunshell)
			new_icon = image('icons/obj/ammo_stacks.dmi', icon_state = "shell_stun", dir = pick(cardinal))
		else if (ammo_path == /obj/item/ammo_casing/shotgun/flash)
			new_icon = image('icons/obj/ammo_stacks.dmi', icon_state = "shell_flash", dir = pick(cardinal))
		else if (istype(ammo_path, /obj/item/ammo_casing/shotgun)
			new_icon = image('icons/obj/ammo_stacks.dmi', icon_state = "shell", dir = pick(cardinal))
			switch (ammo_path)
				if (/obj/item/ammo_casing/shotgun)
					new_icon.SwapColor(SHELL_BASE_COLOR, rgb(50, 50, 50))
					new_icon.SwapColor(SHELL_SEC_COLOR, rgb(87, 87, 87))
				if (/obj/item/ammo_casing/shotgun/pellet)
					new_icon.SwapColor(SHELL_BASE_COLOR, rgb(128, 0, 0))
					new_icon.SwapColor(SHELL_SEC_COLOR, rgb(153, 33, 33))
				if (/obj/item/ammo_casing/shotgun/beanbag)
					new_icon.SwapColor(SHELL_BASE_COLOR, rgb(24, 123, 6))
					new_icon.SwapColor(SHELL_SEC_COLOR, rgb(30, 105, 3))
		if (prob(50))
			new_icon.Flip(pick(cardinal))
		overlays += new_icon.Shift(pick(all_dirs), rand(0, 8))