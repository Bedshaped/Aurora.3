/obj/item/ammo_casing
	name = "bullet casing"
	desc = "A bullet casing."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "s-casing"
	flags = CONDUCT
	slot_flags = SLOT_BELT | SLOT_EARS
	throwforce = 1
	w_class = 1

	var/leaves_residue = 1
	var/caliber = ""					//Which kind of guns it can be loaded into
	var/projectile_type					//The bullet type to create when New() is called
	var/obj/item/projectile/BB = null	//The loaded bullet - make it so that the projectiles are created only when needed?
	var/spent_icon = "s-casing-spent"

	var/stack_singular_name = "round"
	var/stack_plural_name = "rounds"

/obj/item/ammo_casing/New()
	..()
	if(ispath(projectile_type))
		BB = new projectile_type(src)
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)

//removes the projectile from the ammo casing
/obj/item/ammo_casing/proc/expend()
	. = BB
	BB = null
	set_dir(pick(cardinal)) //spin spent casings
	update_icon()

/obj/item/ammo_casing/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/screwdriver))
		if(!BB)
			user << "\blue There is no bullet in the casing to inscribe anything into."
			return

		var/tmp_label = ""
		var/label_text = sanitizeSafe(input(user, "Inscribe some text into \the [initial(BB.name)]","Inscription",tmp_label), MAX_NAME_LEN)
		if(length(label_text) > 20)
			user << "\red The inscription can be at most 20 characters long."
		else if(!label_text)
			user << "\blue You scratch the inscription off of [initial(BB)]."
			BB.name = initial(BB.name)
		else
			user << "\blue You inscribe \"[label_text]\" into \the [initial(BB.name)]."
			BB.name = "[initial(BB.name)] (\"[label_text]\")"

	else if (istype(I, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/C = I
		if (caliber == C.caliber)
			var/obj/item/stack/ammunition/S = new(src)
			S.stored_ammo.Insert(1, C)
			S.stored_ammo.Insert(1, src)
			qdel(C)
			qdel(src)
			S.update_stack_data()
		else
			user << "<span class='warning'>You shouldn't mix different ammo caliber types!</span>"
	else
		..()

/obj/item/ammo_casing/update_icon()
	if(spent_icon && !BB)
		icon_state = spent_icon

/obj/item/ammo_casing/examine(mob/user)
	..()
	if (!BB)
		user << "This one is spent."

//Gun loading types
#define SINGLE_CASING 	1	//The gun only accepts ammo_casings. ammo_magazines should never have this as their mag_type.
#define SPEEDLOADER 	2	//Transfers casings from the mag to the gun when used.
#define MAGAZINE 		4	//The magazine item itself goes inside the gun

#define MULTIPLE_SPRITES 1  // This defines are for update icons
#define OVERLAY_SPRITES 2   //to differentiate different ways icons are updates

//An item that holds casings and can be used to put them inside guns
/obj/item/ammo_magazine
	name = "magazine"
	desc = "A magazine for some kind of gun."
	icon_state = "357"
	icon = 'icons/obj/ammo.dmi'
	flags = CONDUCT
	slot_flags = SLOT_BELT
	item_state = "syringe_kit"
	matter = list(DEFAULT_WALL_MATERIAL = 500)
	throwforce = 5
	w_class = 2
	throw_speed = 4
	throw_range = 10

	var/list/stored_ammo = list()
	var/mag_type = SPEEDLOADER //ammo_magazines can only be used with compatible guns. This is not a bitflag, the load_method var on guns is.
	var/caliber = "357"
	var/max_ammo = 7

	var/ammo_type = /obj/item/ammo_casing //ammo type that is initially loaded
	var/initial_ammo = null

	var/icon_type = MULTIPLE_SPRITES
	//because BYOND doesn't support numbers as keys in associative lists
	var/list/icon_keys = list()		//keys
	var/list/ammo_states = list()	//values

/obj/item/ammo_magazine/New()
	if(icon_type == MULTIPLE_SPRITES)
		initialize_magazine_icondata(src)

	if(isnull(initial_ammo))
		initial_ammo = max_ammo

	if(initial_ammo)
		for(var/i in 1 to initial_ammo)
			stored_ammo += new ammo_type(src)
	update_icon()

/obj/item/ammo_magazine/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/C = W
		if(C.caliber != caliber)
			user << "<span class='warning'>[C] does not fit into [src].</span>"
			return
		if(stored_ammo.len >= max_ammo)
			user << "<span class='warning'>[src] is full!</span>"
			return
		user.remove_from_mob(C)
		C.loc = src
		stored_ammo.Insert(1, C) //add to the head of the list
		update_icon()

/obj/item/ammo_magazine/attack_self(mob/user)
	if(!stored_ammo.len)
		user << "<span class='notice'>[src] is already empty!</span>"
		return
	user << "<span class='notice'>You empty [src].</span>"
	for(var/obj/item/ammo_casing/C in stored_ammo)
		C.loc = user.loc
		C.set_dir(pick(cardinal))
	stored_ammo.Cut()
	update_icon()

/obj/item/ammo_magazine/verb/update_icons()
	overlays.Cut()
	update_icon(1)

/obj/item/ammo_magazine/update_icon(var/num = 0)

	switch (icon_type)

		if(MULTIPLE_SPRITES)
			//find the lowest key greater than or equal to stored_ammo.len
			var/new_state = null
			for(var/idx in 1 to icon_keys.len)
				var/ammo_count = icon_keys[idx]
				if (ammo_count >= stored_ammo.len)
					new_state = ammo_states[idx]
					break
			icon_state = (new_state)? new_state : initial(icon_state)
		if(OVERLAY_SPRITES)
			var/diff = stored_ammo.len - overlays.len
			if (Sign(diff) < 0)
				while (overlays.len != stored_ammo.len)
					overlays.len--
			for (var/i in 1 to diff)
				var/obj/item/ammo_casing/ammo = stored_ammo[1]
				var/icon/new_icon = icon('icons/obj/ammo.dmi', replacetext(path2text(ammo.type), path2text(ammo.parent_type) + "/", "") + "-overlay")
				switch (overlays.len + 1) // this expression is the position in the speedloader the next icon needs to be placed
					if (1)
						new_icon.Shift(WEST, 2)
						new_icon.Shift(NORTH, 5)
					if (2)
						new_icon.Shift(WEST, 4)
						new_icon.Shift(NORTH, 2)
					if (3)
						new_icon.Shift(WEST, 4)
						new_icon.Shift(SOUTH, 2)
					if (4)
						new_icon.Shift(WEST, 2)
						new_icon.Shift(SOUTH, 5)
					if (5)
						new_icon.Shift(SOUTH, 2)
					if (6)
						new_icon.Shift(NORTH, 2)
				overlays += new_icon

/obj/item/ammo_magazine/examine(mob/user)
	..()
	user << "There [(stored_ammo.len == 1)? "is" : "are"] [stored_ammo.len] round\s left!"

//magazine icon state caching
/var/global/list/magazine_icondata_keys = list()
/var/global/list/magazine_icondata_states = list()

/proc/initialize_magazine_icondata(var/obj/item/ammo_magazine/M)
	var/typestr = "[M.type]"
	if(!(typestr in magazine_icondata_keys) || !(typestr in magazine_icondata_states))
		magazine_icondata_cache_add(M)

	M.icon_keys = magazine_icondata_keys[typestr]
	M.ammo_states = magazine_icondata_states[typestr]

/proc/magazine_icondata_cache_add(var/obj/item/ammo_magazine/M)
	var/list/icon_keys = list()
	var/list/ammo_states = list()
	var/list/states = icon_states(M.icon)
	for(var/i = 0, i <= M.max_ammo, i++)
		var/ammo_state = "[M.icon_state]-[i]"
		if(ammo_state in states)
			icon_keys += i
			ammo_states += ammo_state

	magazine_icondata_keys["[M.type]"] = icon_keys
	magazine_icondata_states["[M.type]"] = ammo_states
