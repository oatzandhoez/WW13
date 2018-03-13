///////////////////////////////////////////////Alchohol bottles! -Agouri //////////////////////////
//Functionally identical to regular drinks. The only difference is that the default bottle size is 100. - Darem
//Bottles now weaken and break when shattered on people's heads. - Giacom

/obj/item/weapon/reagent_containers/food/drinks/bottle
	amount_per_transfer_from_this = 10
	volume = 100
	item_state = "broken_beer" //Generic held-item sprite until unique ones are made.
	force = 5
	var/shatter_duration = 5 //Directly relates to the 'weaken' duration. Lowered by armor (i.e. helmets)
	var/isGlass = TRUE //Whether the 'bottle' is made of glass or not so that milk cartons dont shatter when someone gets hit by it

	var/obj/item/weapon/reagent_containers/glass/rag/rag = null
	var/rag_underlay = "rag"
	var/icon_state_full
	var/icon_state_empty

	dropsound = 'sound/effects/drop_glass.ogg'

/obj/item/weapon/reagent_containers/food/drinks/bottle/on_reagent_change()
	update_icon()

/obj/item/weapon/reagent_containers/food/drinks/bottle/New()
	..()
	icon_state_full = icon_state
	if (findtext(icon_state, "bottle"))
		icon_state_empty = icon_state
	else
		icon_state_empty = "[icon_state]_empty"

/obj/item/weapon/reagent_containers/food/drinks/bottle/Destroy()
	if(rag)
		rag.forceMove(loc)
	rag = null
	return ..()

//when thrown on impact, bottles shatter and spill their contents
/obj/item/weapon/reagent_containers/food/drinks/bottle/throw_impact(atom/hit_atom, var/speed)
	var/alcohol_power = calculate_alcohol_power()

	..()

	var/mob/M = thrower
	if(isGlass && istype(M))
		var/throw_dist = get_dist(throw_source, loc)
		if(shatter_check(throw_dist)) //not as reliable as shattering directly
			if(reagents)
				hit_atom.visible_message("<span class='notice'>The contents of \the [src] splash all over [hit_atom]!</span>")
				reagents.splash(hit_atom, reagents.total_volume)
			shatter(loc, hit_atom, alcohol_power)

/obj/item/weapon/reagent_containers/food/drinks/bottle/proc/calculate_alcohol_power()
	. = 0

	for (var/datum/reagent/R in reagents.reagent_list)
		if (istype(R, /datum/reagent/ethanol))
			var/datum/reagent/ethanol/E = R
			. += (min(max(E.strength, 25), 50) * E.volume)

	if (rag)
		for (var/datum/reagent/R in rag.reagents.reagent_list)
			if (istype(R, /datum/reagent/ethanol))
				var/datum/reagent/ethanol/E = R
				. += (min(max(E.strength, 25), 50) * E.volume)

/obj/item/weapon/reagent_containers/food/drinks/bottle/proc/shatter_check(var/distance)
	if(!isGlass || !shatter_duration)
		return FALSE

	var/list/chance_table = list(50, 75, 90, 95, 100, 100, 100) //starting from distance 0
	var/idx = max(distance + 1, 1) //since list indices start at 1
	if(idx > chance_table.len)
		return 0
	return prob(chance_table[idx])

/obj/item/weapon/reagent_containers/food/drinks/bottle/throw_at(atom/target, range, speed, thrower)
	..(target, range, speed, thrower)
	spawn (3)
		while (src && throwing)
			sleep(1)
		if (src && !throwing)
			if (loc == get_turf(target))
				Bump(target, TRUE)
			else
				var/area/src_area = get_area(src)
				if (map && map.prishtina_blocking_area_types.Find(src_area.type))
					Bump(loc, TRUE, FALSE)
				else
					Bump(loc, TRUE)

/obj/item/weapon/reagent_containers/food/drinks/bottle/Bump(atom/A, yes, explode = TRUE)
	if (src)
		if (isliving(A) || isturf(A) || (isobj(A) && A.density))
			shatter(get_turf(A), A, explode ? calculate_alcohol_power() : 0)
	..(A, yes)

//#define MOLOTOV_EXPLOSIONS
/obj/item/weapon/reagent_containers/food/drinks/bottle/proc/shatter(var/newloc, atom/against = null, var/alcohol_power = 0)

	if (!newloc)
		newloc = get_turf(src)

	if(rag && rag.on_fire && alcohol_power)

		forceMove(newloc)

		if (against && isliving(against))
			var/mob/living/L = against
			L.IgniteMob()

		var/explosion_power = alcohol_power/2.5

		 // plz fuck off rags - Kachnov
		rag.loc = null
		qdel(rag)
		rag = null

		if (explosion_power > 0)
			// by using this instead of rounded devrange, not all molotovs will be the same
			// raw_devrange may vary from 0.1 to 2.50 or more - Kachnov
			var/raw_devrange = explosion_power/1000
			var/devrange = min(round(raw_devrange), 1)
			var/heavyrange = max(1, round(raw_devrange*1))
			var/lightrange = max(1, round(raw_devrange*2))
			var/flashrange = max(1, round(raw_devrange*3))
			var/firerange = max(1, round(raw_devrange*4)) + 1
			firerange = min(firerange, 6) // removes crazy molotovs

			var/src_turf = get_turf(src)

			mainloop:
				for (var/turf/T in range(src_turf, firerange))
					if (prob(80) && !T.density)
						for (var/obj/structure/S in T)
							if (S.density && !S.low)
								break mainloop
						var/obj/fire/F = T.create_fire(temp = ceil(explosion_power/8))
						F.time_limit = pick(50, 60, 70)
						for (var/mob/living/L in T)
							L.fire_stacks += 5
							L.IgniteMob()
							L.adjustFireLoss(rand(30,40))
							if (ishuman(L))
								L.emote("scream")

			#ifdef MOLOTOV_EXPLOSIONS
			spawn (0.1)
				explosion(src_turf, devrange, heavyrange, lightrange, flashrange)
			#else
			pass(devrange, heavyrange, lightrange, flashrange)
			#endif

	if (src)
		if(ismob(loc))
			var/mob/M = loc
			M.drop_from_inventory(src)

		//Creates a shattering noise and replaces the bottle with a broken_bottle
		var/obj/item/weapon/broken_bottle/B = new /obj/item/weapon/broken_bottle(newloc)
		if(prob(33))
			new/obj/item/weapon/material/shard(newloc) // Create a glass shard at the target's location!

		B.icon_state = icon_state

		var/icon/I = new('icons/obj/drinks.dmi', icon_state)
		I.Blend(B.broken_outline, ICON_OVERLAY, rand(5), TRUE)
		I.SwapColor(rgb(255, FALSE, 220, 255), rgb(0, FALSE, FALSE, FALSE))
		B.icon = I

		playsound(src,'sound/effects/GLASS_Rattle_Many_Fragments_01_stereo.wav',100,1)
		transfer_fingerprints_to(B)

		qdel(src)
		return B

/obj/item/weapon/reagent_containers/food/drinks/bottle/attackby(obj/item/W, mob/user)
	if(!rag && istype(W, /obj/item/weapon/reagent_containers/glass/rag))
		insert_rag(W, user)
		update_icon()
		return
	else if(rag && (istype(W, /obj/item/weapon/flame) || istype(W, /obj/item/clothing/mask/smokable/cigarette) || (istype(W, /obj/item/device/flashlight/flare) && W:on) || (istype(W, /obj/item/weapon/weldingtool) && W:welding)))
		rag.attackby(W, user)
		update_icon()
		return
	else return ..()

/obj/item/weapon/reagent_containers/food/drinks/bottle/attack_self(mob/user)
	if(rag)
		remove_rag(user)
	else
		..()

/obj/item/weapon/reagent_containers/food/drinks/bottle/proc/insert_rag(obj/item/weapon/reagent_containers/glass/rag/R, mob/user)
	if(!isGlass || rag) return
	if(user.unEquip(R))
		user << "<span class='notice'>You stuff [R] into [src].</span>"
		rag = R
		rag.forceMove(src)
		flags &= ~OPENCONTAINER
		update_icon()

/obj/item/weapon/reagent_containers/food/drinks/bottle/proc/remove_rag(mob/user)
	if(!rag) return
	user.put_in_hands(rag)
	rag = null
	flags |= (initial(flags) & OPENCONTAINER)
	update_icon()
	user << "<span class='notice'>You remove the rag from [src].</span>"

/obj/item/weapon/reagent_containers/food/drinks/bottle/open(mob/user)
	if(rag) return
	..()

/obj/item/weapon/reagent_containers/food/drinks/bottle/update_icon()
	underlays.Cut()
	if(rag)
		var/underlay_image = image(icon='icons/obj/drinks.dmi', icon_state=rag.on_fire? "[rag_underlay]_lit" : rag_underlay)
		underlays += underlay_image
		if (rag.on_fire)
			set_light(2)
	else
		set_light(0)
		if(reagents.total_volume)
			icon_state = icon_state_full
		else
			icon_state = icon_state_empty

/obj/item/weapon/reagent_containers/food/drinks/bottle/apply_hit_effect(mob/living/target, mob/living/user, var/hit_zone)
	var/blocked = ..()

	if(user.a_intent != I_HURT)
		return
	if(!shatter_check(1))
		return //won't always break on the first hit

	// You are going to knock someone out for longer if they are not wearing a helmet.
	var/weaken_duration = FALSE
	if(blocked < 2)
		weaken_duration = shatter_duration + min(0, force - target.getarmor(hit_zone, "melee") + 10)

	var/mob/living/carbon/human/H = target
	if(istype(H) && H.headcheck(hit_zone))
		var/obj/item/organ/affecting = H.get_organ(hit_zone) //headcheck should ensure that affecting is not null
		user.visible_message("<span class='danger'>[user] shatters [src] into [H]'s [affecting.name]!</span>")
		if(weaken_duration)
			target.apply_effect(min(weaken_duration, 5), WEAKEN, blocked) // Never weaken more than a flash!
	else
		user.visible_message("<span class='danger'>\The [user] shatters [src] into [target]!</span>")

	//The reagents in the bottle splash all over the target, thanks for the idea Nodrak
	var/alcohol_power = calculate_alcohol_power()

	if(reagents)
		spawn (1) // wait until after our explosion, if we have one
			user.visible_message("<span class='notice'>The contents of \the [src] splash all over [target]!</span>")
			if (reagents) reagents.splash(target, reagents.total_volume)

	//Finally, shatter the bottle. This kills (qdel) the bottle.

	var/obj/item/weapon/broken_bottle/B = shatter(target.loc, target, alcohol_power)
	user.put_in_active_hand(B)

//Keeping this here for now, I'll ask if I should keep it here.
/obj/item/weapon/broken_bottle

	name = "Broken Bottle"
	desc = "A bottle with a sharp broken bottom."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "broken_bottle"
	force = 9
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	item_state = "beer"
	attack_verb = list("stabbed", "slashed", "attacked")
	sharp = TRUE
	edge = FALSE
	dropsound = 'sound/effects/drop_glass.ogg'
	var/icon/broken_outline = icon('icons/obj/drinks.dmi', "broken")

/obj/item/weapon/broken_bottle/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if (M != user || M.a_intent != I_HELP)
		playsound(loc, 'sound/weapons/bladeslice.ogg', 50, TRUE, -1)
	return ..()


/obj/item/weapon/reagent_containers/food/drinks/bottle/gin
	name = "Griffeater Gin"
	desc = "A bottle of high quality gin, produced in the New London Station."
	icon_state = "ginbottle"
	center_of_mass = list("x"=16, "y"=4)
	New()
		..()
		reagents.add_reagent("gin", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey
	name = "Uncle Git's Special Reserve"
	desc = "A premium single-malt whiskey, gently matured inside the tunnels of a nuclear shelter. TUNNEL WHISKEY RULES."
	icon_state = "whiskeybottle"
	center_of_mass = list("x"=16, "y"=3)
	New()
		..()
		reagents.add_reagent("whiskey", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/water
	name = "Bottle of Water"
	desc = "Just a bottle of drinking water."
	icon_state = "waterbottle"
	center_of_mass = list("x"=17, "y"=3)
	volume = 100 // this is kind of important for filling bottles from sinks
	New()
		..()
		// empty by default


/obj/item/weapon/reagent_containers/food/drinks/bottle/water/filled
	name = "Bottle of Water"
	desc = "Just a bottle of drinking water."
	icon_state = "waterbottle"
	center_of_mass = list("x"=17, "y"=3)
	New()
		..()
		reagents.add_reagent("water", 100)


/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka
	name = "Tunguska Triple Distilled"
	desc = "Aah, vodka. Prime choice of drink AND fuel by Russians worldwide."
	icon_state = "vodkabottle"
	center_of_mass = list("x"=17, "y"=3)
	New()
		..()
		reagents.add_reagent("vodka", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/tequilla
	name = "Caccavo Guaranteed Quality Tequilla"
	desc = "Made from premium petroleum distillates, pure thalidomide and other fine quality ingredients!"
	icon_state = "tequillabottle"
	center_of_mass = list("x"=16, "y"=3)
	New()
		..()
		reagents.add_reagent("tequilla", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing
	name = "Bottle of Nothing"
	desc = "A bottle filled with nothing"
	icon_state = "bottleofnothing"
	center_of_mass = list("x"=17, "y"=5)
	New()
		..()
		reagents.add_reagent("nothing", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/patron
	name = "Wrapp Artiste Patron"
	desc = "Silver laced tequilla, served in night clubs across the earth."
	icon_state = "patronbottle"
	center_of_mass = list("x"=16, "y"=6)
	New()
		..()
		reagents.add_reagent("patron", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/rum
	name = "Captain Pete's Cuban Spiced Rum"
	desc = "This isn't just rum, oh no. It's practically GRIFF in a bottle."
	icon_state = "rumbottle"
	center_of_mass = list("x"=16, "y"=8)
	New()
		..()
		reagents.add_reagent("rum", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater
	name = "Flask of Holy Water"
	desc = "A flask of the preacher's holy water."
	icon_state = "holyflask"
	center_of_mass = list("x"=17, "y"=10)
	New()
		..()
		reagents.add_reagent("holywater", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/vermouth
	name = "Goldeneye Vermouth"
	desc = "Sweet, sweet dryness~"
	icon_state = "vermouthbottle"
	center_of_mass = list("x"=17, "y"=3)
	New()
		..()
		reagents.add_reagent("vermouth", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/kahlua
	name = "Robert Robust's Coffee Liqueur"
	desc = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936, HONK"
	icon_state = "kahluabottle"
	center_of_mass = list("x"=17, "y"=3)
	New()
		..()
		reagents.add_reagent("kahlua", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/goldschlager
	name = "College Girl Goldschlager"
	desc = "Because they are the only ones who will drink 100 proof cinnamon schnapps."
	icon_state = "goldschlagerbottle"
	center_of_mass = list("x"=15, "y"=3)
	New()
		..()
		reagents.add_reagent("goldschlager", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/cognac
	name = "Chateau De Baton Premium Cognac"
	desc = "A sweet and strongly alchoholic drink, made after numerous distillations and years of maturing. You might as well not scream 'SHITCURITY' this time."
	icon_state = "cognacbottle"
	center_of_mass = list("x"=16, "y"=6)
	New()
		..()
		reagents.add_reagent("cognac", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/wine
	name = "Doublebeard Bearded Special Wine"
	desc = "A faint aura of unease and asspainery surrounds the bottle."
	icon_state = "winebottle"
	center_of_mass = list("x"=16, "y"=4)
	New()
		..()
		reagents.add_reagent("wine", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/absinthe
	name = "Jailbreaker Verte"
	desc = "One sip of this and you just know you're gonna have a good time."
	icon_state = "absinthebottle"
	center_of_mass = list("x"=16, "y"=6)
	New()
		..()
		reagents.add_reagent("absinthe", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/melonliquor
	name = "Emeraldine Melon Liquor"
	desc = "A bottle of 46 proof Emeraldine Melon Liquor. Sweet and light."
	icon_state = "alco-green" //Placeholder.
	center_of_mass = list("x"=16, "y"=6)
	New()
		..()
		reagents.add_reagent("melonliquor", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/bluecuracao
	name = "Miss Blue Curacao"
	desc = "A fruity, exceptionally azure drink. Does not allow the imbiber to use the fifth magic."
	icon_state = "alco-blue" //Placeholder.
	center_of_mass = list("x"=16, "y"=6)
	New()
		..()
		reagents.add_reagent("bluecuracao", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/grenadine
	name = "Briar Rose Grenadine Syrup"
	desc = "Sweet and tangy, a bar syrup used to add color or flavor to drinks."
	icon_state = "grenadinebottle"
	center_of_mass = list("x"=16, "y"=6)
	New()
		..()
		reagents.add_reagent("grenadine", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/cola
	name = "\improper Cola"
	desc = "Cola"
	icon_state = "colabottle"
	center_of_mass = list("x"=16, "y"=6)
	New()
		..()
		reagents.add_reagent("cola", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/space_up
	name = "\improper Space-Up"
	desc = "Tastes like a hull breach in your mouth."
	icon_state = "space-up_bottle"
	center_of_mass = list("x"=16, "y"=6)
	New()
		..()
		reagents.add_reagent("space_up", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/space_mountain_wind
	name = "\improper Mountain Wind"
	desc = "Blows right through you like a space wind."
	icon_state = "space_mountain_wind_bottle"
	center_of_mass = list("x"=16, "y"=6)
	New()
		..()
		reagents.add_reagent("spacemountainwind", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/pwine
	name = "Warlock's Velvet"
	desc = "What a delightful packaging for a surely high quality wine! The vintage must be amazing!"
	icon_state = "pwinebottle"
	center_of_mass = list("x"=16, "y"=4)
	New()
		..()
		reagents.add_reagent("pwine", 100)

//////////////////////////JUICES AND STUFF ///////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/orangejuice
	name = "Orange Juice"
	desc = "Full of vitamins and deliciousness!"
	icon_state = "orangejuice"
	item_state = "carton"
	center_of_mass = list("x"=16, "y"=7)
	isGlass = FALSE
	New()
		..()
		reagents.add_reagent("orangejuice", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/cream
	name = "Milk Cream"
	desc = "It's cream. Made from milk. What else did you think you'd find in there?"
	icon_state = "cream"
	item_state = "carton"
	center_of_mass = list("x"=16, "y"=8)
	isGlass = FALSE
	New()
		..()
		reagents.add_reagent("cream", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/tomatojuice
	name = "Tomato Juice"
	desc = "Well, at least it LOOKS like tomato juice. You can't tell with all that redness."
	icon_state = "tomatojuice"
	item_state = "carton"
	center_of_mass = list("x"=16, "y"=8)
	isGlass = FALSE
	New()
		..()
		reagents.add_reagent("tomatojuice", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/limejuice
	name = "Lime Juice"
	desc = "Sweet-sour goodness."
	icon_state = "limejuice"
	item_state = "carton"
	center_of_mass = list("x"=16, "y"=8)
	isGlass = FALSE
	New()
		..()
		reagents.add_reagent("limejuice", 100)

//Small bottles
/obj/item/weapon/reagent_containers/food/drinks/bottle/small
	volume = 50
	shatter_duration = TRUE
	flags = FALSE //starts closed
	rag_underlay = "rag_small"

/obj/item/weapon/reagent_containers/food/drinks/bottle/small/beer
	name = "beer"
	desc = "Contains only water, malt and hops."
	icon_state = "beer"
	center_of_mass = list("x"=16, "y"=12)
	New()
		..()
		reagents.add_reagent("beer", 30)

/obj/item/weapon/reagent_containers/food/drinks/bottle/small/ale
	name = "\improper Magm-Ale"
	desc = "A true dorf's drink of choice."
	icon_state = "alebottle"
	item_state = "beer"
	center_of_mass = list("x"=16, "y"=10)
	New()
		..()
		reagents.add_reagent("ale", 30)

/obj/item/weapon/reagent_containers/glass/bottle/urine
	name = "urine bottle"
	desc = "A small bottle. Contains urine."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle15"

	New()
		..()
		reagents.add_reagent("urine", 30)
