/obj/structure
	icon = 'icons/obj/structures.dmi'
	w_class = 10

	var/climbable = FALSE
	var/breakable = FALSE
	var/parts
	var/list/climbers = list()
	var/low = FALSE

/obj/structure/Destroy()
	if(parts)
		new parts(loc)
	..()

/obj/structure/attack_hand(mob/user)
	if(breakable)
		if(HULK in user.mutations)
			user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
			attack_generic(user,1,"smashes")
		else if(istype(user,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = user
			if(H.species.can_shred(user))
				attack_generic(user,1,"slices")

	if(climbers.len && !(user in climbers))
		user.visible_message("<span class='warning'>[user.name] shakes \the [src].</span>", \
					"<span class='notice'>You shake \the [src].</span>")
		structure_shaken()

	return ..()

/obj/structure/attack_tk()
	return

/obj/structure/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				qdel(src)
				return
		if(3.0)
			return

/obj/structure/MouseDrop_T(mob/target, mob/user)

	var/mob/living/H = user
	if(istype(H) && can_climb(H) && target == user)
		do_climb(target)
	else
		return ..()

/obj/structure/proc/can_climb(var/mob/living/user, post_climb_check=0)
	if (!climbable || !can_touch(user) || (!post_climb_check && (user in climbers)))
		return FALSE

	if (!user.Adjacent(src))
		user << "<span class='danger'>You can't climb there, the way is blocked.</span>"
		return FALSE

	var/obj/occupied = turf_is_crowded()
	if(occupied)
		user << "<span class='danger'>There's \a [occupied] in the way.</span>"
		return FALSE
	return TRUE

/obj/structure/proc/turf_is_crowded()
	var/turf/T = get_turf(src)
	if(!T || !istype(T))
		return FALSE
	for(var/obj/O in T.contents)
		if(istype(O,/obj/structure))
			var/obj/structure/S = O
			if(S.climbable) continue
		if(O && O.density && !(O.flags & ON_BORDER)) //ON_BORDER structures are handled by the Adjacent() check.
			return O
	return FALSE

/obj/structure/proc/neighbor_turf_passable()
	var/turf/T = get_step(src, dir)
	if(!T || !istype(T))
		return FALSE
	if(T.density == TRUE)
		return FALSE
	for(var/obj/O in T.contents)
		if(istype(O,/obj/structure))
			if(istype(O,/obj/structure/railing))
				return TRUE
			else if(O.density == TRUE)
				return FALSE
	return TRUE

/obj/structure/proc/do_climb(var/mob/living/user)
	if (!can_climb(user))
		return

	user.face_atom(src)

	var/turf/target = null

	if (istype(src, /obj/structure/window/sandbag))
		target = get_step(src, user.dir)
	else
		target = get_turf(src)

	if (!target || target.density)
		return

	for (var/obj/structure/S in target)
		if (S != src && S.density)
			return

	usr.visible_message("<span class='warning'>[user] starts climbing onto \the [src]!</span>")
	climbers |= user

	if(!do_after(user,(issmall(user) ? 20 : 34)))
		climbers -= user
		return

	if (!can_climb(user, post_climb_check=1))
		climbers -= user
		return

	if (!target || target.density)
		return

	for (var/obj/structure/S in target)
		if (S != src && S.density)
			return

	usr.forceMove(target)

	if (get_turf(user) == get_turf(src))
		usr.visible_message("<span class='warning'>[user] climbs onto \the [src]!</span>")
	climbers -= user

/obj/structure/proc/structure_shaken()
	for(var/mob/living/M in climbers)
		M.Weaken(1)
		M << "<span class='danger'>You topple as you are shaken off \the [src]!</span>"
		climbers.Cut(1,2)

	for(var/mob/living/M in get_turf(src))
		if(M.lying) return //No spamming this on people.

		M.Weaken(3)
		M << "<span class='danger'>You topple as \the [src] moves under you!</span>"

		if(prob(25))

			var/damage = rand(15,30)
			var/mob/living/carbon/human/H = M
			if(!istype(H))
				H << "<span class='danger'>You land heavily!</span>"
				M.adjustBruteLoss(damage)
				return

			var/obj/item/organ/external/affecting

			switch(pick(list("ankle","wrist","head","knee","elbow")))
				if("ankle")
					affecting = H.get_organ(pick("l_foot", "r_foot"))
				if("knee")
					affecting = H.get_organ(pick("l_leg", "r_leg"))
				if("wrist")
					affecting = H.get_organ(pick("l_hand", "r_hand"))
				if("elbow")
					affecting = H.get_organ(pick("l_arm", "r_arm"))
				if("head")
					affecting = H.get_organ("head")

			if(affecting)
				M << "<span class='danger'>You land heavily on your [affecting.name]!</span>"
				affecting.take_damage(damage, FALSE)
				if(affecting.parent)
					affecting.parent.add_autopsy_data("Misadventure", damage)
			else
				H << "<span class='danger'>You land heavily!</span>"
				H.adjustBruteLoss(damage)

			H.UpdateDamageIcon()
			H.updatehealth()
	return

/obj/structure/proc/can_touch(var/mob/user)
	if (!user)
		return FALSE
	if(!Adjacent(user))
		return FALSE
	if (user.restrained() || user.buckled)
		user << "<span class='notice'>You need your hands and legs free for this.</span>"
		return FALSE
	if (user.stat || user.paralysis || user.sleeping || user.lying || user.weakened)
		return FALSE
	if (issilicon(user))
		user << "<span class='notice'>You need hands for this.</span>"
		return FALSE
	return TRUE

/obj/structure/attack_generic(var/mob/user, var/damage, var/attack_verb, var/wallbreaker)
	if(!breakable || !damage || !wallbreaker)
		return FALSE
	visible_message("<span class='danger'>[user] [attack_verb] the [src] apart!</span>")
	attack_animation(user)
	spawn(1) qdel(src)
	return TRUE
