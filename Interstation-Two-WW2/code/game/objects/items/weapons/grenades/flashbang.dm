/obj/item/weapon/grenade/flashbang
	name = "flashbang"
	icon_state = "flashbang"
	item_state = "flashbang"
//	origin_tech = list(TECH_MATERIAL = 2, TECH_COMBAT = TRUE)
	var/banglet = FALSE

	prime()
		..()
		for(var/obj/structure/closet/L in hear(7, get_turf(src)))
			if(locate(/mob/living/carbon/, L))
				for(var/mob/living/carbon/M in L)
					bang(get_turf(src), M)


		for(var/mob/living/carbon/M in hear(7, get_turf(src)))
			bang(get_turf(src), M)

		new/obj/effect/sparks(loc)
		new/obj/effect/effect/smoke/illumination(loc, brightness=15)
		qdel(src)
		return

	proc/bang(var/turf/T , var/mob/living/carbon/M)					// Added a new proc called 'bang' that takes a location and a person to be banged.
		M << "<span class='danger'>BANG</span>"						// Called during the loop that bangs people in lockers/containers and when banging
		playsound(loc, 'sound/effects/bang.ogg', 50, TRUE, 5)		// people in normal view.  Could theroetically be called during other explosions.
																	// -- Polymorph

//Checking for protections
		var/eye_safety = FALSE
		var/ear_safety = FALSE
		if(iscarbon(M))
			eye_safety = M.eyecheck()
			if(ishuman(M))
				if(istype(M:l_ear, /obj/item/clothing/ears/earmuffs) || istype(M:r_ear, /obj/item/clothing/ears/earmuffs))
					ear_safety += 2
				if(HULK in M.mutations)
					ear_safety += TRUE
				if(istype(M:head, /obj/item/clothing/head/helmet))
					ear_safety += TRUE

//Flashing everyone
		if(eye_safety < FLASH_PROTECTION_MODERATE)
			if (M.HUDtech.Find("flash"))
				flick("e_flash", M.HUDtech["flash"])
			M.Stun(2)
			M.Weaken(10)



//Now applying sound
		if((get_dist(M, T) <= 2 || loc == M.loc || loc == M))
			if(ear_safety > FALSE)
				M.Stun(2)
				M.Weaken(1)
			else
				M.Stun(10)
				M.Weaken(3)
				if ((prob(14) || (M == loc && prob(70))))
					M.ear_damage += rand(1, 10)
				else
					M.ear_damage += rand(0, 5)
					M.ear_deaf = max(M.ear_deaf,15)

		else if(get_dist(M, T) <= 5)
			if(!ear_safety)
				M.Stun(8)
				M.ear_damage += rand(0, 3)
				M.ear_deaf = max(M.ear_deaf,10)

		else if(!ear_safety)
			M.Stun(4)
			M.ear_damage += rand(0, TRUE)
			M.ear_deaf = max(M.ear_deaf,5)

//This really should be in mob not every check
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/organ/eyes/E = H.internal_organs_by_name["eyes"]
			if (E && E.damage >= E.min_bruised_damage)
				M << "<span class='danger'>Your eyes start to burn badly!</span>"
				if(!banglet && !(istype(src , /obj/item/weapon/grenade/flashbang/clusterbang)))
					if (E.damage >= E.min_broken_damage)
						M << "<span class='danger'>You can't see anything!</span>"
		if (M.ear_damage >= 15)
			M << "<span class='danger'>Your ears start to ring badly!</span>"
			if(!banglet && !(istype(src , /obj/item/weapon/grenade/flashbang/clusterbang)))
				if (prob(M.ear_damage - 10 + 5))
					M << "<span class='danger'>You can't hear anything!</span>"
					M.sdisabilities |= DEAF
		else
			if (M.ear_damage >= 5)
				M << "<span class='danger'>Your ears start to ring!</span>"
		M.update_icons()

/obj/item/weapon/grenade/flashbang/clusterbang//Created by Polymorph, fixed by Sieve
	desc = "Use of this weapon may constiute a war crime in your area, consult your local captain."
	name = "clusterbang"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "clusterbang"

/obj/item/weapon/grenade/flashbang/clusterbang/prime()
	var/numspawned = rand(4,8)
	var/again = FALSE
	for(var/more = numspawned,more > FALSE,more--)
		if(prob(35))
			again++
			numspawned --

	for(,numspawned > FALSE, numspawned--)
		spawn(0)
			new /obj/item/weapon/grenade/flashbang/cluster(loc)//Launches flashbangs
			playsound(loc, 'sound/weapons/armbomb.ogg', 75, TRUE, -3)

	for(,again > FALSE, again--)
		spawn(0)
			new /obj/item/weapon/grenade/flashbang/clusterbang/segment(loc)//Creates a 'segment' that launches a few more flashbangs
			playsound(loc, 'sound/weapons/armbomb.ogg', 75, TRUE, -3)
	qdel(src)
	return

/obj/item/weapon/grenade/flashbang/clusterbang/segment
	desc = "A smaller segment of a clusterbang. Better run."
	name = "clusterbang segment"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "clusterbang_segment"

/obj/item/weapon/grenade/flashbang/clusterbang/segment/New()//Segments should never exist except part of the clusterbang, since these immediately 'do their thing' and asplode
	icon_state = "clusterbang_segment_active"
	active = TRUE
	banglet = TRUE
	var/stepdist = rand(1,4)//How far to step
	var/temploc = loc//Saves the current location to know where to step away from
	walk_away(src,temploc,stepdist)//I must go, my people need me
	var/dettime = rand(15,60)
	spawn(dettime)
		prime()
	..()

/obj/item/weapon/grenade/flashbang/clusterbang/segment/prime()
	var/numspawned = rand(4,8)
	for(var/more = numspawned,more > FALSE,more--)
		if(prob(35))
			numspawned --

	for(,numspawned > FALSE, numspawned--)
		spawn(0)
			new /obj/item/weapon/grenade/flashbang/cluster(loc)
			playsound(loc, 'sound/weapons/armbomb.ogg', 75, TRUE, -3)
	qdel(src)
	return

/obj/item/weapon/grenade/flashbang/cluster/New()//Same concept as the segments, so that all of the parts don't become reliant on the clusterbang
	spawn(0)
		icon_state = "flashbang_active"
		active = TRUE
		banglet = TRUE
		var/stepdist = rand(1,3)
		var/temploc = loc
		walk_away(src,temploc,stepdist)
		var/dettime = rand(15,60)
		spawn(dettime)
		prime()
	..()
