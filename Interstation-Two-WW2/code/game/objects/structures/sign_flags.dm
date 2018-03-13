/obj/structure/sign/flag
	var/ripped = FALSE

/obj/structure/sign/flag/attack_hand(mob/user as mob)
	if(!ripped)
		playsound(loc, 'sound/items/poster_ripped.ogg', 100, TRUE)
		for(var/i = FALSE to 3)
			if(do_after(user, 10))
				playsound(loc, 'sound/items/poster_ripped.ogg', 100, TRUE)
			else
				return
		visible_message("<span class='warning'>[user] rips [src]!</span>" )
		icon_state += "_ripped"
		ripped = TRUE

/obj/structure/sign/flag/russian
	name = "\improper Russian flag"
	desc = "Just like new and very dense. Holds a point blank pistol shot "
	icon_state = "ru_flag"

/obj/structure/sign/flag/usa
	name = "\improper USA flag"
	desc = "Democracy! Freedom! U! S! A!"
	icon_state = "usa_flag"

/obj/structure/sign/flag/local
	name = "\improper Local flag"
	desc = "I don't even remember to which country Slatino belongs."
	icon_state = "local_flag"

/obj/structure/sign/clock
	name = "\improper Broken clock"
	desc = "Stopped at 5 o'clock."
	icon_state = "clock"

/obj/structure/sign/wide
	icon = 'icons/obj/decals_wide.dmi'
	bound_x = 32

/obj/structure/sign/wide/carpet
	name = "\improper Carpet"
	desc = "A low quality carpet dangling on the wall."
	icon = 'icons/obj/decals_wide.dmi'
	icon_state = "carpet"
	layer = OBJ_LAYER - 0.1

/obj/structure/sign/wide/loc_name_sign
	name = "Slatino sign"
	desc = "Heeey! That's not Prishtina! That's Slatino!"
	icon_state = "slatino"
	density = TRUE

/obj/structure/sign/flag/germany
	name = "Third Reich flag"
	desc = "Ein Volk, ein Reich, ein Fuhrer!"
	icon_state = "ger_flag"

/obj/structure/sign/flag/soviet
	name = "Soviet Union flag"
	desc = "Soyuz nerushimy respublik svobodnyh!"
	icon_state = "sov_flag"