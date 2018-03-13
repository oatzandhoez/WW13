/obj/structure/iv_drip
	name = "\improper IV drip"
	icon = 'icons/obj/iv_drip.dmi'
	anchored = FALSE
	density = TRUE
	var/mob/living/carbon/human/attached = null
	var/mode = TRUE // TRUE is injecting, FALSE is taking blood.
	var/obj/item/weapon/reagent_containers/beaker = null

/obj/structure/iv_drip/New()
	..()
	processing_objects += src

/obj/structure/iv_drip/Del()
	processing_objects -= src
	..()

/obj/structure/iv_drip/update_icon()
	if(attached)
		icon_state = "hooked"
	else
		icon_state = ""

	overlays = null

	if(beaker)
		var/datum/reagents/reagents = beaker.reagents
		if(reagents.total_volume)
			var/image/filling = image('icons/obj/iv_drip.dmi', src, "reagent")

			var/percent = round((reagents.total_volume / beaker.volume) * 100)
			switch(percent)
				if(0 to 9)		filling.icon_state = "reagent0"
				if(10 to 24) 	filling.icon_state = "reagent10"
				if(25 to 49)	filling.icon_state = "reagent25"
				if(50 to 74)	filling.icon_state = "reagent50"
				if(75 to 79)	filling.icon_state = "reagent75"
				if(80 to 90)	filling.icon_state = "reagent80"
				if(91 to INFINITY)	filling.icon_state = "reagent100"

			filling.icon += reagents.get_color()
			overlays += filling

/obj/structure/iv_drip/MouseDrop(over_object, src_location, over_location)
	..()

	if(attached)
		visible_message("[attached] is detached from \the [src]")
		attached = null
		update_icon()
		return

	if(in_range(src, usr) && ishuman(over_object) && get_dist(over_object, src) <= TRUE)
		visible_message("[usr] attaches \the [src] to \the [over_object].")
		attached = over_object
		update_icon()


/obj/structure/iv_drip/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/reagent_containers))
		if(!isnull(beaker))
			user << "There is already a reagent container loaded!"
			return

		user.drop_item()
		W.loc = src
		beaker = W
		user << "You attach \the [W] to \the [src]."
		update_icon()
		return
	else
		return ..()

/obj/structure/iv_drip/process()

	if(attached)

		if(!(get_dist(src, attached) <= TRUE && isturf(attached.loc)))
			visible_message("The needle is ripped out of [attached], doesn't that hurt?")
			attached:apply_damage(3, BRUTE, pick("r_arm", "l_arm"))
			attached = null
			update_icon()
			return

	if(attached && beaker)
		// Give blood
		if(mode)
			if(beaker.volume > FALSE)
				var/transfer_amount = REM
				if(istype(beaker, /obj/item/weapon/reagent_containers/blood))
					// speed up transfer on blood packs
					transfer_amount = 4
				beaker.reagents.trans_to_mob(attached, transfer_amount, CHEM_BLOOD)
				update_icon()

		// Take blood
		else
			var/amount = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			amount = min(amount, 4)
			// If the beaker is full, ping
			if(amount == FALSE)
				if(prob(5)) visible_message("\The [src] pings.")
				return

			var/mob/living/carbon/human/T = attached

			if(!istype(T)) return
			if(!T.dna)
				return
			if(NOCLONE in T.mutations)
				return

			if(T.species.flags & NO_BLOOD)
				return

			// If the human is losing too much blood, beep.
			if(((T.vessel.get_reagent_amount("blood")/T.species.blood_volume)*100) < BLOOD_VOLUME_SAFE)
				visible_message("\The [src] beeps loudly.")

			var/datum/reagent/B = T.take_blood(beaker,amount)

			if (B)
				beaker.reagents.reagent_list |= B
				beaker.reagents.update_total()
				beaker.on_reagent_change()
				beaker.reagents.handle_reactions()
				update_icon()

/obj/structure/iv_drip/attack_hand(mob/user as mob)
	if(beaker)
		beaker.loc = get_turf(src)
		beaker = null
		update_icon()
	else
		return ..()


/obj/structure/iv_drip/verb/toggle_mode()
	set category = "Object"
	set name = "Toggle Mode"
	set src in view(1)

	if(!istype(usr, /mob/living))
		usr << "<span class='warning'>You can't do that.</span>"
		return

	if(usr.stat)
		return

	mode = !mode
	usr << "The IV drip is now [mode ? "injecting" : "taking blood"]."

/obj/structure/iv_drip/examine(mob/user)
	..(user)
	if (!(user in view(2)) && user!=loc) return

	user << "The IV drip is [mode ? "injecting" : "taking blood"]."

	if(beaker)
		if(beaker.reagents && beaker.reagents.reagent_list.len)
			usr << "<span class='notice'>Attached is \a [beaker] with [beaker.reagents.total_volume] units of liquid.</span>"
		else
			usr << "<span class='notice'>Attached is an empty [beaker].</span>"
	else
		usr << "<span class='notice'>No chemicals are attached.</span>"

	usr << "<span class='notice'>[attached ? attached : "No one"] is attached.</span>"

/obj/structure/iv_drip/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(height && istype(mover) && mover.checkpass(PASSTABLE)) //allow bullets, beams, thrown objects, mice, drones, and the like through.
		return TRUE
	return ..()
