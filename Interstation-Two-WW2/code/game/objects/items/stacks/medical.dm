/obj/item/stack/medical
	name = "medical pack"
	singular_name = "medical pack"
	icon = 'icons/obj/items.dmi'
	amount = 30
	max_amount = 30
	w_class = 2
	throw_speed = 4
	throw_range = 20
	var/heal_brute = FALSE
	var/heal_burn = FALSE

/obj/item/stack/medical/attack(mob/living/carbon/C as mob, mob/user as mob)
	if (!istype(C) )
		if (!istype(C, /mob/living/simple_animal))
			user << "<span class='warning'>\The [src] cannot be applied to [C]!</span>"
		return TRUE

	if (!istype(user, /mob/living/carbon/human))
		user << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return TRUE

	if (istype(C, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = C
		var/obj/item/organ/external/affecting = H.get_organ(user.targeted_organ)

		if(affecting.status & ORGAN_ROBOT)
			user << "<span class='warning'>This isn't useful at all on a robotic limb..</span>"
			return TRUE

		H.UpdateDamageIcon()

		H.updatehealth()

	else if (istype(C, /mob/living/carbon))
		C.heal_organ_damage((heal_brute/2), (heal_burn/2))
		user.visible_message( \
			"<span class='notice'>[C] has been applied with [src] by [user].</span>", \
			"<span class='notice'>You apply \the [src] to [C].</span>" \
		)
		use(1)

		C.updatehealth()

/obj/item/stack/medical/bruise_pack
	name = "roll of gauze"
	singular_name = "gauze length"
	desc = "Some sterile gauze to wrap around bloody stumps."
	icon_state = "brutepack"
//	origin_tech = list(TECH_BIO = TRUE)

/obj/item/stack/medical/bruise_pack/attack(mob/living/M as mob, mob/user as mob)
	if(..())
		return TRUE

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.targeted_organ)

		if(affecting.open == FALSE)
			if(affecting.is_bandaged())
				user << "<span class='warning'>The wounds on [M]'s [affecting.name] have already been bandaged.</span>"
				return TRUE
			else
				user.visible_message("<span class='notice'>\The [user] starts treating [M]'s [affecting.name].</span>", \
						             "<span class='notice'>You start treating [M]'s [affecting.name].</span>" )
				var/used = FALSE
				for (var/datum/wound/W in affecting.wounds)
					if (W.internal)
						continue
					if(W.bandaged)
						continue
					if(used == amount)
						break
					if(!do_mob(user, M, W.damage/5))
						user << "<span class='notice'>You must stand still to bandage wounds.</span>"
						break

					if (W.current_stage <= W.max_bleeding_stage)
						user.visible_message("<span class='notice'>\The [user] bandages \a [W.desc] on [M]'s [affecting.name].</span>", \
						                              "<span class='notice'>You bandage \a [W.desc] on [M]'s [affecting.name].</span>" )
						//H.add_side_effect("Itch")
					else if (W.damage_type == BRUISE)
						user.visible_message("<span class='notice'>\The [user] places a bruise patch over \a [W.desc] on [M]'s [affecting.name].</span>", \
						                              "<span class='notice'>You place a bruise patch over \a [W.desc] on [M]'s [affecting.name].</span>" )
					else
						user.visible_message("<span class='notice'>\The [user] places a bandaid over \a [W.desc] on [M]'s [affecting.name].</span>", \
						                              "<span class='notice'>You place a bandaid over \a [W.desc] on [M]'s [affecting.name].</span>" )
					W.bandage()
					used++
				affecting.update_damages()
				if(used == amount)
					if(affecting.is_bandaged())
						user << "<span class='warning'>\The [src] is used up.</span>"
					else
						user << "<span class='warning'>\The [src] is used up, but there are more wounds to treat on \the [affecting.name].</span>"
				use(used)
		else
			if (can_operate(H))        //Checks if mob is lying down on table for surgery
				if (do_surgery(H,user,src))
					return
			else
				user << "<span class='notice'>The [affecting.name] is cut open, you'll need more than a bandage!</span>"
/*	else if (istype(M, /mob/living/simple_animal/complex_animal))
		var/mob/living/simple_animal/complex_animal/C = M
		if(C.health >= C.maxHealth)
			user << "<span class='warning'>The wounds on \the [C] have already been treated.</span>"
			return TRUE
		else
			user.visible_message("<span class='notice'>\The [user] starts treating \the [C]'s wounds.</span>", \
					             "<span class='notice'>You start treating \the [C]'s wounds.</span>")
			C.adjustBruteLoss(-(C.maxHealth/3))
			if(amount == TRUE)
				if(C.health >= C.maxHealth)
					user << "<span class='warning'>\The [src] is used up.</span>"
				else
					user << "<span class='warning'>\The [src] is used up, but there are more wounds to treat on \the [C].</span>"
			use(1)
*/
/obj/item/stack/medical/ointment
	name = "ointment"
	desc = "Used to treat those nasty burns."
	gender = PLURAL
	singular_name = "ointment"
	icon_state = "ointment"
	heal_burn = TRUE
//	origin_tech = list(TECH_BIO = TRUE)

/obj/item/stack/medical/ointment/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(..())
		return TRUE

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.targeted_organ)

		if(affecting.open == FALSE)
			if(affecting.is_salved())
				user << "<span class='warning'>The wounds on [M]'s [affecting.name] have already been salved.</span>"
				return TRUE
			else
				user.visible_message("<span class='notice'>\The [user] starts salving wounds on [M]'s [affecting.name].</span>", \
						             "<span class='notice'>You start salving the wounds on [M]'s [affecting.name].</span>" )
				if(!do_mob(user, M, 10))
					user << "<span class='notice'>You must stand still to salve wounds.</span>"
					return TRUE
				user.visible_message("<span class='notice'>[user] salved wounds on [M]'s [affecting.name].</span>", \
				                         "<span class='notice'>You salved wounds on [M]'s [affecting.name].</span>" )
				use(1)
				affecting.salve()
		else
			if (can_operate(H))        //Checks if mob is lying down on table for surgery
				if (do_surgery(H,user,src))
					return
			else
				user << "<span class='notice'>The [affecting.name] is cut open, you'll need more than a bandage!</span>"

/obj/item/stack/medical/advanced/bruise_pack
	name = "advanced trauma kit"
	singular_name = "advanced trauma kit"
	desc = "An advanced trauma kit for severe injuries."
	icon_state = "traumakit"
	heal_brute = FALSE
//	origin_tech = list(TECH_BIO = TRUE)

/obj/item/stack/medical/advanced/bruise_pack/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(..())
		return TRUE

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.targeted_organ)

		if(affecting.open == FALSE)
			if(affecting.is_bandaged() && affecting.is_disinfected())
				user << "<span class='warning'>The wounds on [M]'s [affecting.name] have already been treated.</span>"
				return TRUE
			else
				user.visible_message("<span class='notice'>\The [user] starts treating [M]'s [affecting.name].</span>", \
						             "<span class='notice'>You start treating [M]'s [affecting.name].</span>" )
				var/used = FALSE
				for (var/datum/wound/W in affecting.wounds)
					if (W.internal)
						continue
					if (W.bandaged && W.disinfected)
						continue
					if(used == amount)
						break
					if(!do_mob(user, M, W.damage/5))
						user << "<span class='notice'>You must stand still to bandage wounds.</span>"
						break
					if (W.current_stage <= W.max_bleeding_stage)
						user.visible_message("<span class='notice'>\The [user] cleans \a [W.desc] on [M]'s [affecting.name] and seals the edges with bioglue.</span>", \
						                     "<span class='notice'>You clean and seal \a [W.desc] on [M]'s [affecting.name].</span>" )
					else if (W.damage_type == BRUISE)
						user.visible_message("<span class='notice'>\The [user] places a medical patch over \a [W.desc] on [M]'s [affecting.name].</span>", \
						                              "<span class='notice'>You place a medical patch over \a [W.desc] on [M]'s [affecting.name].</span>" )
					else
						user.visible_message("<span class='notice'>\The [user] smears some bioglue over \a [W.desc] on [M]'s [affecting.name].</span>", \
						                              "<span class='notice'>You smear some bioglue over \a [W.desc] on [M]'s [affecting.name].</span>" )
					W.bandage()
					W.disinfect()
					W.heal_damage(heal_brute)
					used++
				affecting.update_damages()
				if(used == amount)
					if(affecting.is_bandaged())
						user << "<span class='warning'>\The [src] is used up.</span>"
					else
						user << "<span class='warning'>\The [src] is used up, but there are more wounds to treat on \the [affecting.name].</span>"
				use(used)
		else
			if (can_operate(H))        //Checks if mob is lying down on table for surgery
				if (do_surgery(H,user,src))
					return
			else
				user << "<span class='notice'>The [affecting.name] is cut open, you'll need more than a bandage!</span>"

		if (affecting.open == FALSE)
			if (affecting.is_bandaged() && affecting.is_disinfected())
				affecting.wounds.Cut()
				H.bad_external_organs -= affecting

/obj/item/stack/medical/advanced/ointment
	name = "advanced burn kit"
	singular_name = "advanced burn kit"
	desc = "An advanced treatment kit for severe burns."
	icon_state = "burnkit"
	heal_burn = FALSE
//	origin_tech = list(TECH_BIO = TRUE)


/obj/item/stack/medical/advanced/ointment/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(..())
		return TRUE

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.targeted_organ)

		if(affecting.open == FALSE)
			if(affecting.is_salved())
				user << "<span class='warning'>The wounds on [M]'s [affecting.name] have already been salved.</span>"
				return TRUE
			else
				user.visible_message("<span class='notice'>\The [user] starts salving wounds on [M]'s [affecting.name].</span>", \
						             "<span class='notice'>You start salving the wounds on [M]'s [affecting.name].</span>" )
				if(!do_mob(user, M, 10))
					user << "<span class='notice'>You must stand still to salve wounds.</span>"
					return TRUE
				user.visible_message( 	"<span class='notice'>[user] covers wounds on [M]'s [affecting.name] with regenerative membrane.</span>", \
										"<span class='notice'>You cover wounds on [M]'s [affecting.name] with regenerative membrane.</span>" )
				affecting.heal_damage(0,heal_burn)
				use(1)
				affecting.salve()
		else
			if (can_operate(H))        //Checks if mob is lying down on table for surgery
				if (do_surgery(H,user,src))
					return
			else
				user << "<span class='notice'>The [affecting.name] is cut open, you'll need more than a bandage!</span>"

/obj/item/stack/medical/splint
	name = "medical splints"
	singular_name = "medical splint"
	icon_state = "splint"
	amount = 5
	max_amount = 5

/obj/item/stack/medical/splint/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(..())
		return TRUE

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.targeted_organ)
		var/limb = affecting.name
		if(!(affecting.limb_name in list("chest", "head", "groin", "l_arm","r_arm","l_leg","r_leg", "l_hand", "r_hand", "l_foot", "r_foot")))
			user << "<span class='danger'>You can't apply a splint there!</span>"
			return
		else if(affecting.status & ORGAN_SPLINTED)
			user << "<span class='danger'>[M]'s [limb] is already splinted!</span>"
			return
		else if (affecting.status == 0)
			user << "<span class='danger'>[M]'s [limb] does not need splinting.</span>"
			return
		if (M != user)
			user.visible_message("<span class='danger'>[user] starts to apply \the [src] to [M]'s [limb].</span>", "<span class='danger'>You start to apply \the [src] to [M]'s [limb].</span>", "<span class='danger'>You hear something being wrapped.</span>")
		else
			if((!user.hand && affecting.limb_name == "r_arm") || (user.hand && affecting.limb_name == "l_arm"))
				user << "<span class='danger'>You can't apply a splint to the arm you're using!</span>"
				return
			user.visible_message("<span class='danger'>[user] starts to apply \the [src] to their [limb].</span>", "<span class='danger'>You start to apply \the [src] to your [limb].</span>", "<span class='danger'>You hear something being wrapped.</span>")
		if(do_after(user, 50, M))
			if (M != user)
				user.visible_message("<span class='danger'>[user] finishes applying \the [src] to [M]'s [limb].</span>", "<span class='danger'>You finish applying \the [src] to [M]'s [limb].</span>", "<span class='danger'>You hear something being wrapped.</span>")
			else
				if(prob(40 * H.getStatCoeff("medical")))
					user.visible_message("<span class='danger'>[user] successfully applies \the [src] to their [limb].</span>", "<span class='danger'>You successfully apply \the [src] to your [limb].</span>", "<span class='danger'>You hear something being wrapped.</span>")
				else
					user.visible_message("<span class='danger'>[user] fumbles \the [src].</span>", "<span class='danger'>You fumble \the [src].</span>", "<span class='danger'>You hear something being wrapped.</span>")
					return
			affecting.status |= ORGAN_SPLINTED
			use(1)
		return
