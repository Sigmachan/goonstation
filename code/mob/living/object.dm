/obj/item/attackdummy
	name = "attack dummy"
	damtype = "brute"
	force = 5
	throwforce = 5

/mob/living/object
	name = "living object"
	var/obj/item/item
	var/mob/owner
	var/obj/item/attackdummy/dummy
	var/obj/screen/release/release
	density = 0
	canmove = 1
	var/canattack = 0
	blinded = 0
	anchored = 0
	a_intent = "disarm" // todo: This should probably be selectable. Cyborg style - help/harm.
	health = 50
	max_health = 50

	New(var/atom/loc as mob|obj|turf, var/mob/controller)
		..()
		message_admins("[key_name(controller)] possessed [loc] at [showCoords(loc.x, loc.y, loc.z)].")
		var/obj/item/possessed
		if (!istype(loc, /obj/item))
			if (isobj(loc))
				possessed = loc
				set_loc(get_turf(possessed))
				canattack = 0
				dummy = new /obj/item/attackdummy(src)
				dummy.name = loc.name
			else
				possessed = new /obj/item/paper()
				logTheThing("admin", usr, null, "living object mob created with no item.")
				var/turf/T = get_turf(loc)
				if (!T)
					logTheThing("admin", usr, null, "additionally, no turf could be found at creation loc [loc]")
					var/ASLoc = pick(latejoin)
					if (ASLoc)
						src.set_loc(ASLoc)
					else
						src.set_loc(locate(1, 1, 1))
				else
					src.set_loc(T)
				canattack = 1
		else
			canattack = 1
			possessed = loc
			set_loc(get_turf(possessed))

		if (!src.canattack)
			src.density = 1
			src.opacity = possessed.opacity
		possessed.set_loc(src)
		src.name = "living [possessed.name]"
		src.real_name = src.name
		src.desc = "[possessed.desc]"
		src.icon = possessed.icon
		src.icon_state = possessed.icon_state
		src.pixel_x = possessed.pixel_x
		src.pixel_y = possessed.pixel_y
		src.dir = possessed.dir
		src.color = possessed.color
		src.overlays = possessed.overlays
		src.item = possessed
		src.sight |= SEE_SELF
		src.density = possessed.density
		src.opacity = possessed.opacity

		release = new()
		release.owner = src

		src.owner = controller
		if (src.owner)
			src.owner.set_loc(src)
			if (!src.owner.mind)
				src.owner.mind = new /datum/mind(  )
				src.owner.mind.key = src.owner.key
				src.owner.mind.current = src.owner
				ticker.minds += src.owner.mind
			//if (src.owner.client)
				// src.owner.client.mob = src
			src.owner.mind.transfer_to(src)

		src.visible_message("<span style=\"color:red\"><b>[possessed] comes to life!</b></span>") // was [src] but: "the living space thing comes alive!"
		animate_levitate(src, -1, 20, 1)

	equipped()
		if (canattack)
			return src.item
		else
			return src.dummy

	examine()
		..()
		boutput(usr, "<span style=\"color:red\">It seems to be alive.</span>")
		if (health < 25)
			boutput(usr, "<span style=\"color:blue\">The ethereal grip on this object appears to be weak.</span>")

	meteorhit(var/obj/O as obj)
		src.death(1)
		return

	restrained()
		return 0

	updatehealth()
		return

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1
		updatehealth()

		if (owner)
			if (owner.abilityHolder)
				if (owner.abilityHolder.usesPoints)
					owner.abilityHolder.generatePoints()

		weakened = 0
		paralysis = 0
		stunned = 0
		slowed = 0
		sleeping = 0
		change_misstep_chance(-INFINITY)
		drowsyness = 0.0
		dizziness = 0
		is_dizzy = 0
		is_jittery = 0
		jitteriness = 0

		if (!src.item)
			src.death(0)

		if (src.item.loc != src)
			if (isturf(src.item.loc))
				src.item.loc = src
			else
				src.death(0)

		for (var/atom/A as obj|mob in src)
			if (A != src.item && A != src.dummy && A != src.owner && !istype(A, /obj/screen) && !istype(A, /obj/hud))
				if (isobj(A) || ismob(A)) // what the heck else would this be?
					A:set_loc(src.loc)

		src.density = src.item.density
		src.item.dir = src.dir
		src.icon = src.item.icon
		src.icon_state = src.item.icon_state
		src.color = src.item.color
		src.overlays = src.item.overlays

	bullet_act(var/obj/projectile/P)
		var/damage = 0
		damage = round((P.power*P.proj_data.ks_ratio), 1.0)

		switch (P.proj_data.damage_type)
			if (D_KINETIC)
				src.TakeDamage(null, damage, 0)
			if (D_PIERCING)
				src.TakeDamage(null, damage / 2.0, 0)
			if (D_SLASHING)
				src.TakeDamage(null, damage, 0)
			if (D_BURNING)
				src.TakeDamage(null, 0, damage)
			if (D_ENERGY)
				src.TakeDamage(null, 0, damage)

		if(!P.proj_data.silentshot)
			src.visible_message("<span style=\"color:red\">[src] is hit by the [P]!</span>")

	attack_hand(mob/user as mob)
		if (user.a_intent == "help")
			user.visible_message("<span style=\"color:red\">[user] pets [src]!</span>")
		else
			user.visible_message("<span style=\"color:red\">[user] punches [src]!</span>")
			src.TakeDamage(null, rand(4, 7), 0)

	TakeDamage(zone, brute, burn)
		health -= burn
		health -= brute
		health = min(max_health, health)
		if (src.health <= 0)
			src.death(0)

	HealDamage(zone, brute, burn)
		TakeDamage(zone, -brute, -burn)

	change_eye_blurry(var/amount, var/cap = 0)
		if (amount < 0)
			return ..()
		else
			return 1

	take_eye_damage(var/amount, var/tempblind = 0)
		if (amount < 0)
			return ..()
		else
			return 1

	take_ear_damage(var/amount, var/tempdeaf = 0)
		if (amount < 0)
			return ..()
		else
			return 1

	click(atom/target, params)
		if (target == src)
			if (canattack)
				src.item.attack_self(src)
			else
				if(!istype(src.item, /obj/item))
					src.item.attack_hand(src)
				else //This shouldnt ever happen.
					src.item.attackby(src.item, src)
		else
			if(src.a_intent == INTENT_GRAB && istype(target, /atom/movable) && get_dist(src, target) <= 1)
				var/atom/movable/M = target
				if(ismob(target) || !M.anchored)
					src.visible_message("<span style=\"color:red\">[src] grabs [target]!</span>")
					M.set_loc(src.loc)
			else
				. = ..()
			if (src.item.loc != src)
				if (isturf(src.item.loc))
					src.item.loc = src
				else
					src.death(0)

		//To reflect updates of the items appearance etc caused by interactions.
		src.name = "living [src.item.name]"
		src.real_name = src.name
		src.desc = "[src.item.desc]"
		src.item.dir = src.dir
		src.icon = src.item.icon
		src.icon_state = src.item.icon_state
		//src.pixel_x = src.item.pixel_x
		//src.pixel_y = src.item.pixel_y
		src.color = src.item.color
		src.overlays = src.item.overlays
		src.density = src.item.density
		src.opacity = src.item.opacity

	death(gibbed)
		if (src.owner)
			src.owner.set_loc(get_turf(src))
			src.visible_message("<span style=\"color:red\"><b>[src] is no longer possessed.</b></span>")

			if (src.mind)
				mind.transfer_to(src.owner)
			else if (src.client)
				src.client.mob = src.owner
		else
			if(src.mind || src.client)
				var/mob/dead/observer/O = new/mob/dead/observer(get_turf(src))
				if (isrestrictedz(src.z) && !restricted_z_allowed(src, get_turf(src)) && !(src.client && src.client.holder))
					var/OS = observer_start.len ? pick(observer_start) : locate(1, 1, 1)
					if (OS)
						O.set_loc(OS)
					else
						O.z = 1
				if (src.client)
					src.client.mob = O
				O.name = src.name
				O.real_name = src.real_name
				if (src.mind)
					src.mind.transfer_to(O)

		if (src.item)
			if (!gibbed)
				src.item.dir = src.dir
				if (src.item.loc == src)
					src.item.set_loc(get_turf(src))
			else
				qdel(src.item)
		qdel(src)
		..(gibbed)

	movement_delay()
		return 4

	put_in_hand(obj/item/I, hand)
		return 0

	swap_hand()
		return 0

	drop_item_v()
		return 0

	item_attack_message(var/mob/T, var/obj/item/S, var/d_zone)
		if (d_zone)
			return "<span style=\"color:red\"><B>[src] attacks [T] in the [d_zone]!</B></span>"
		else
			return "<span style=\"color:red\"><B>[src] attacks [T]!</B></span>"