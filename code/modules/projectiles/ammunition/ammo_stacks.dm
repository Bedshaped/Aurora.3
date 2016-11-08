#define SHELL_BASE_COLOR rgb( 255, 255, 255)
#define SHELL_SEC_COLOR rgb( 214, 214, 214)

// Stacks or bunches of various types of ammunition

/obj/item/stack/ammunition
	throwforce = 1
	w_class = 2

	var/last_load = 0

	var/list/obj/item/ammo_casing/stored_ammo = list()

/obj/item/stack/ammunition/proc/update_stack_data()
	if (!stored_ammo.len)
		qdel(src)
		return 0
	if (!update_strings())
		var/old_loc = src.loc
		var/last_round = pop(stored_ammo)
		qdel(src)
		last_round.loc = old_loc
		return 0
	update_icons()
	return 1

/obj/item/stack/ammunition/proc/get_ammo_casing()
	if (isemptylist(stored_ammo))
		return 0
	return stored_ammo[1]

/obj/item/stack/ammunition/proc/get_ammo_caliber(var/obj/item/ammo_casing/ammo = null)
	if (!ammo)
		ammo = get_ammo_casing()
	return ammo.caliber

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
		var/obj/item/ammo_casing/ammo = stored_ammo[i]
		var/ammo_path = ammo.type // or else we add new overlays depending on ammo types
		var/icon/new_icon
		if (ammo_path == /obj/item/ammo_casing/c38)
			new_icon = image('icons/obj/ammo_stacks.dmi', icon_state = "casing", dir = pick(cardinal))
		else if (ammo_path == /obj/item/ammo_casing/c38r)
			new_icon = image('icons/obj/ammo_stacks.dmi', icon_state = "casing_r", dir = pick(cardinal))
		else if (ammo_path == /obj/item/ammo_casing/shotgun/stunshell)
			new_icon = image('icons/obj/ammo_stacks.dmi', icon_state = "shell_stun", dir = pick(cardinal))
		else if (ammo_path == /obj/item/ammo_casing/shotgun/flash)
			new_icon = image('icons/obj/ammo_stacks.dmi', icon_state = "shell_flash", dir = pick(cardinal))
		else if (ammo_path == /obj/item/ammo_casing/shotgun/incendiary)
			new_icon = image('icons/obj/ammo_stacks.dmi', icon_state = "shell_incend", dir = pick(cardinal))
		else if (istype(ammo_path, /obj/item/ammo_casing/shotgun))
			new_icon = image('icons/obj/ammo_stacks.dmi', icon_state = "shell", dir = pick(cardinal))
			switch (ammo_path)
				if (/obj/item/ammo_casing/shotgun) // shotgun slug is black
					new_icon.SwapColor(SHELL_BASE_COLOR, rgb(50, 50, 50))
					new_icon.SwapColor(SHELL_SEC_COLOR, rgb(87, 87, 87))
				if (/obj/item/ammo_casing/shotgun/pellet) // shotgun pellet is red
					new_icon.SwapColor(SHELL_BASE_COLOR, rgb(128, 0, 0))
					new_icon.SwapColor(SHELL_SEC_COLOR, rgb(153, 33, 33))
				if (/obj/item/ammo_casing/shotgun/beanbag) // shotgun beanbag is green
					new_icon.SwapColor(SHELL_BASE_COLOR, rgb(24, 123, 6))
					new_icon.SwapColor(SHELL_SEC_COLOR, rgb(30, 105, 3))
				if (/obj/item/projectile/bullet/shotgun/practice) // shotgun practice is white/red
					new_icon.SwapColor(SHELL_SEC_COLOR, rgb(153, 33, 33))
		if (prob(50))
			new_icon.Flip(pick(cardinal))
		overlays += new_icon.Shift(pick(all_dirs), rand(0, 8))

/obj/item/stack/ammunition/attackby(obj/item/I as obj, mob/user as mob)
	if (istype(I, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/C = I
		if (C.caliber == src.get_ammo_caliber())
			stored_ammo.Add(C)
			update_stack_data()
			if (src.loc == user)
				user << "<span class='notice'>You add \the [C.caliber] [C.stack_singular_name] to the pile.</span>"
			else
				user.visible_message("<span class='notice'>[user] adds \the [C.caliber] [C.stack_singular_name] a pile of [stack_plural_name].",
					                 "<span class='notice'>You add \the [C.caliber] [C.stack_singular_name] to the pile.</span>")
		else
			user << "<span class='warning'>You shouldn't mix different ammo caliber types!</span>"
	else if (istype(I, /obj/item/stack/ammunition)
		var/obj/item/stack/ammunition/S = I
		if (S.get_ammo_caliber() == get_ammo_caliber())
			stored_ammo.Add(S.stored_ammo)
			overlays.Cut()
			update_stack_data()
			if (src.loc == user)
				user << "<span class='notice'>You add \the [S.caliber] [S.stack_plural_name] to the pile.</span>"
			else
				user.visible_message("<span class='notice'>[user] adds \the [S.caliber] [S.stack_plural_name] a pile of [stack_plural_name].",
					                 "<span class='notice'>You add \the [S.caliber] [S.stack_plural_name] to the pile.</span>")
		else
			user << "<span class='warning'>You shouldn't mix different ammo caliber types!</span>"