/obj/item/device/igniter
	name = "igniter"
	desc = "A small electronic device able to ignite combustible substances."
	icon_state = "igniter"
	var/status = 1.0
	flags = FPRINT | TABLEPASS| CONDUCT
	item_state = "electronic"
	m_amt = 100
	throwforce = 5
	w_class = 1.0
	throw_speed = 3
	throw_range = 10
	mats = 2
	module_research = list("science" = 1, "miniaturization" = 5, "devices" = 3)

/obj/item/device/igniter/attack(mob/M as mob, mob/user as mob)
	if (ishuman(M))
		if (M:bleeding || (M:butt_op_stage == 4 && user.zone_sel.selecting == "chest"))
			if (!src.cautery_surgery(M, user, 15))
				return ..()
		else return ..()
	else return ..()

/obj/item/device/igniter/attackby(obj/item/W as obj, mob/user as mob)
	if ((istype(W, /obj/item/device/radio/signaler) && !( src.status )))
		var/obj/item/device/radio/signaler/S = W
		if (!( S.b_stat ))
			return
		var/obj/item/assembly/rad_ignite/R = new /obj/item/assembly/rad_ignite( user )
		S.set_loc(R)
		R.part1 = S
		S.layer = initial(S.layer)
		user.u_equip(S)
		user.put_in_hand_or_drop(R)
		S.master = R
		src.master = R
		src.layer = initial(src.layer)
		user.u_equip(src)
		src.set_loc(R)
		R.part2 = src
		src.add_fingerprint(user)

	else if ((istype(W, /obj/item/device/prox_sensor) && !( src.status )))

		var/obj/item/assembly/prox_ignite/R = new /obj/item/assembly/prox_ignite( user )
		W.set_loc(R)
		R.part1 = W
		W.layer = initial(W.layer)
		user.u_equip(W)
		user.put_in_hand_or_drop(R)
		W.master = R
		src.master = R
		src.layer = initial(src.layer)
		user.u_equip(src)
		src.set_loc(R)
		R.part2 = src
		src.add_fingerprint(user)

	else if ((istype(W, /obj/item/device/timer) && !( src.status )))

		var/obj/item/assembly/time_ignite/R = new /obj/item/assembly/time_ignite( user )
		W.set_loc(R)
		R.part1 = W
		W.layer = initial(W.layer)
		user.u_equip(W)
		user.put_in_hand_or_drop(R)
		W.master = R
		src.master = R
		src.layer = initial(src.layer)
		user.u_equip(src)
		src.set_loc(R)
		R.part2 = src
		src.add_fingerprint(user)
	else if ((istype(W, /obj/item/device/healthanalyzer) && !( src.status )))

		var/obj/item/assembly/anal_ignite/R = new /obj/item/assembly/anal_ignite( user ) // Hehehe anal
		W.set_loc(R)
		R.part1 = W
		W.layer = initial(W.layer)
		user.u_equip(W)
		user.put_in_hand_or_drop(R)
		W.master = R
		src.master = R
		src.layer = initial(src.layer)
		user.u_equip(src)
		src.set_loc(R)
		R.part2 = src
		src.add_fingerprint(user)
	else if ((istype(W, /obj/item/device/multitool) && !(src.status)))

		var/obj/item/assembly/detonator/R = new /obj/item/assembly/detonator(user);
		W.loc = R
		W.master = R
		W.layer = initial(W.layer)
		src.loc = R
		src.master = R
		src.layer = initial(src.layer)
		R.part_mt = W
		R.part_ig = src
		R.loc = user
		user.u_equip(src)
		user.u_equip(W)

		user.put_in_hand_or_drop(R)

		R.setDetState(0)
		src.add_fingerprint(user)
		user.show_message("<span style=\"color:blue\">You hook up the igniter to the multitool's panel.</span>")

	if (!( istype(W, /obj/item/screwdriver) ))
		return
	src.status = !( src.status )
	if (src.status)
		user.show_message("<span style=\"color:blue\">The igniter is ready!</span>")
	else
		user.show_message("<span style=\"color:blue\">The igniter can now be attached!</span>")
	src.add_fingerprint(user)
	return

/obj/item/device/igniter/attack_self(mob/user as mob)

	src.add_fingerprint(user)
	spawn( 5 )
		ignite()
		return
	return

/obj/item/device/igniter/afterattack(atom/target, mob/user as mob)
	if (!ismob(target) && target.reagents)
		boutput(usr, "<span style=\"color:blue\">You heat \the [target.name]</span>")
		target.reagents.temperature_reagents(20000,50)

/obj/item/device/igniter/proc/ignite()
	if (src.status)
		var/turf/location = src.loc

		if (src.master)
			location = src.master.loc

		location = get_turf(location)
		if(location)
			location.hotspot_expose((isturf(location) ? 3000 : 30000),2000)

	return

/obj/item/device/igniter/examine()
	set src in view()
	set category = "Local"

	..()
	if ((in_range(src, usr) || src.loc == usr))
		if (src.status)
			usr.show_message("The igniter is ready!")
		else
			usr.show_message("The igniter can be attached!")
	return
