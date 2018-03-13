/*****************************Shovel********************************/

/obj/item/weapon/shovel
	name = "shovel"
	desc = "A large tool for digging and moving dirt."
	icon = 'icons/obj/items.dmi'
	icon_state = "shovel"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 8.0
	throwforce = 4.0
	item_state = "shovel"
	w_class = 3.0
	matter = list(DEFAULT_WALL_MATERIAL = 50)
//	origin_tech = "materials=1;engineering=1"
	attack_verb = list("bashed", "bludgeoned", "thrashed", "whacked")
	sharp = FALSE
	edge = TRUE

/obj/item/weapon/shovel/spade
	name = "spade"
	desc = "A small tool for digging and moving dirt."
	icon_state = "spade"
	item_state = "spade"
	force = 15.0
	throwforce = 20.0
	w_class = 2.0

/obj/item/weapon/shovel/spade/russia
	name = "lopata"
	icon_state = "lopata"
	item_state = "lopata"

/obj/item/weapon/wirecutters/boltcutters
	name = "boltcutters"
	desc = "This cuts bolts and other things."
	icon_state = "boltcutters"

/obj/item/weapon/crowbar/prybar
	name = "prybar"
	icon_state = "prybar"

/obj/item/weapon/weldingtool/ww2
	name = "welding tool"
	icon_state = "ww2_welder_off"
	on_state = "ww2_welder_on"
	off_state = "ww2_welder_off"
/*
/obj/item/device/flashlight/ww2
	name = "flashlight"
	icon_state = "ww2_welder_off"
	on_state = "ww2_welder_on"
	off_state = "ww2_welder_off"*/