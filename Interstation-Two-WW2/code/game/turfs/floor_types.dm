/turf/shuttle
	name = "shuttle"
	icon = 'icons/turf/shuttle.dmi'
	thermal_conductivity = 0.05
	heat_capacity = FALSE
	layer = 2

/turf/shuttle/floor
	name = "floor"
	icon_state = "floor"

/turf/shuttle/floor/mining
	icon_state = "6,19"
	icon = 'icons/turf/shuttlemining.dmi'

/turf/shuttle/plating
	name = "plating"
	icon = 'icons/turf/flooring/plating.dmi'
	icon_state = "plating"
	level = TRUE

/turf/shuttle/plating/is_plating()
	return TRUE

/turf/floor/plating/under
	name = "underplating"
	icon_state = "un"
	icon = 'icons/turf/un.dmi'
	var/icon_base = "un"
	flags = TURF_HAS_EDGES | TURF_HAS_CORNERS
	var/has_base_range = null
	//style = "underplating"

/turf/floor/plating/under/update_icon(var/update_neighbors)
	// Set initial icon and strings.
	if(!isnull(set_update_icon) && istext(set_update_icon))
		icon_state = set_update_icon
	else if(flooring_override)
		icon_state = flooring_override
	else
		icon_state = icon_base
		if(has_base_range)
			icon_state = "[icon_state][rand(0,has_base_range)]"
			flooring_override = icon_state
	// Apply edges, corners, and inner corners.
	overlays.Cut()
	var/has_border = FALSE
	if(isnull(set_update_icon) && (flags & TURF_HAS_EDGES))
		for(var/step_dir in cardinal)
			var/turf/floor/T = get_step(src, step_dir)
			if((!istype(T) || !T || T.name != name) && !istype(T, /turf/open) && !istype(T, /turf/space))
				has_border |= step_dir
				overlays |= get_flooring_overlayu("[icon_base]-edge-[step_dir]", "[icon_base]_edges", step_dir)
		if ((flags & TURF_USE0ICON) && has_border)
			icon_state = icon_base+"0"

		// There has to be a concise numerical way to do this but I am too noob.
		if((has_border & NORTH) && (has_border & EAST))
			overlays |= get_flooring_overlayu("[icon_base]-edge-[NORTHEAST]", "[icon_base]_edges", NORTHEAST)
		if((has_border & NORTH) && (has_border & WEST))
			overlays |= get_flooring_overlayu("[icon_base]-edge-[NORTHWEST]", "[icon_base]_edges", NORTHWEST)
		if((has_border & SOUTH) && (has_border & EAST))
			overlays |= get_flooring_overlayu("[icon_base]-edge-[SOUTHEAST]", "[icon_base]_edges", SOUTHEAST)
		if((has_border & SOUTH) && (has_border & WEST))
			overlays |= get_flooring_overlayu("[icon_base]-edge-[SOUTHWEST]", "[icon_base]_edges", SOUTHWEST)

		if(flags & TURF_HAS_CORNERS)
			// As above re: concise numerical way to do this.
			if(!(has_border & NORTH))
				if(!(has_border & EAST))
					var/turf/floor/T = get_step(src, NORTHEAST)
					if((!istype(T) || !T || T.name != name) && !istype(T, /turf/open) && !istype(T, /turf/space))
						overlays |= get_flooring_overlayu("[icon_base]-corner-[NORTHEAST]", "[icon_base]_corners", NORTHEAST)
				if(!(has_border & WEST))
					var/turf/floor/T = get_step(src, NORTHWEST)
					if((!istype(T) || !T || T.name != name) && !istype(T, /turf/open) && !istype(T, /turf/space))
						overlays |= get_flooring_overlayu("[icon_base]-corner-[NORTHWEST]", "[icon_base]_corners", NORTHWEST)
			if(!(has_border & SOUTH))
				if(!(has_border & EAST))
					var/turf/floor/T = get_step(src, SOUTHEAST)
					if((!istype(T) || !T || T.name != name) && !istype(T, /turf/open) && !istype(T, /turf/space))
						overlays |= get_flooring_overlayu("[icon_base]-corner-[SOUTHEAST]", "[icon_base]_corners", SOUTHEAST)
				if(!(has_border & WEST))
					var/turf/floor/T = get_step(src, SOUTHWEST)
					if((!istype(T) || !T || T.name != name) && !istype(T, /turf/open) && !istype(T, /turf/space))
						overlays |= get_flooring_overlayu("[icon_base]-corner-[SOUTHWEST]", "[icon_base]_corners", SOUTHWEST)

	if(decals && decals.len)
		overlays |= decals

	if(is_plating() && !(isnull(broken) && isnull(burnt))) //temp, todo
		icon = 'icons/turf/floors.dmi'
		icon_state = "dmg[rand(1,4)]"
	else
		if(!isnull(broken) && (flags & TURF_CAN_BREAK))
			overlays |= get_flooring_overlayu("[icon_base]-broken-[broken]", "broken[broken]")
		if(!isnull(burnt) && (flags & TURF_CAN_BURN))
			overlays |= get_flooring_overlayu("[icon_base]-burned-[burnt]", "burned[burnt]")
	if(update_neighbors)
		for(var/turf/floor/F in range(src, TRUE))
			if(F == src)
				continue
			F.update_icon()

/turf/floor/plating/under/proc/get_flooring_overlayu(var/cache_key, var/icon_base, var/icon_dir = FALSE)
	if(!flooring_cache[cache_key])
		var/image/I = image(icon = icon, icon_state = icon_base, dir = icon_dir)
		I.layer = layer
		flooring_cache[cache_key] = I
	return flooring_cache[cache_key]


/turf/floor/plating/under/New()
	..()
	update_icon(1)

/turf/floor/plating/under/Entered(mob/living/M as mob)
	..()
	for(var/obj/structure/catwalk/C in get_turf(src))
		return

	if(!ishuman(M) || !has_gravity(src))
		return
	if(M.m_intent == "run")
		if(prob(75))
			M.adjustBruteLoss(5)
			M.weakened += 3
			playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
			M << "<span class='warning'>You tripped over!</span>"
			return

/turf/floor/plating/under/attackby(obj/item/C as obj, mob/user as mob)
	if (istype(C, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = C
		if(R.amount <= 2)
			return
		else
			R.use(2)
			user << "<span class='notice'>You start connecting [R.name]s to [name], creating catwalk ...</span>"
			if(do_after(user,50))
				alpha = FALSE
				var/obj/structure/catwalk/CT = new /obj/structure/catwalk(loc)
				contents += CT
			return
	return

/turf/shuttle/plating/vox //Skipjack plating
//	oxygen = FALSE
//	nitrogen = MOLES_N2STANDARD + MOLES_O2STANDARD

/turf/shuttle/floor4 // Added this floor tile so that I have a seperate turf to check in the shuttle -- Polymorph
	name = "Brig floor"        // Also added it into the 2x3 brig area of the shuttle.
	icon_state = "floor4"

/turf/shuttle/floor4/vox //skipjack floors
	name = "skipjack floor"
//	oxygen = FALSE
//	nitrogen = MOLES_N2STANDARD + MOLES_O2STANDARD

/turf/floor/airless
	icon_state = "floor"
	name = "airless floor"
//	oxygen = FALSE
//	nitrogen = FALSE
	temperature = TCMB

	New()
		..()
		name = "floor"

/turf/floor/airless/ceiling
	icon_state = "rockvault"

/turf/floor/light
	name = "Light floor"
	light_range = 5
	icon_state = "light_on"
	floor_type = /obj/item/stack/tile/light

	New()
		var/n = name //just in case commands rename it in the ..() call
		..()
		spawn(4)
			if(src)
				update_icon()
				name = n

/turf/floor/wood
	name = "floor"
	icon_state = "wood"
	floor_type = /obj/item/stack/tile/wood
	stepsound = "wood"

/* when this is a subtype of /turf/floor/wood, it doesn't get the right icon.
 * not sure why right now - kachnov */

/turf/floor/wood_broken
	name = "floor"
	icon = 'icons/turf/flooring/wood.dmi'
	icon_state = "broken0"
	floor_type = /obj/item/stack/tile/wood
	stepsound = "wood"

/turf/floor/wood_broken/New()
	..()
	icon_state = "broken[rand(0,6)]"

/turf/floor/vault
	icon_state = "rockvault"

	New(location,type)
		..()
		icon_state = "[type]vault"

/turf/wall/vault
	icon_state = "rockvault"

	New(location,type)
		..()
		icon_state = "[type]vault"

/turf/floor/engine
	name = "reinforced floor"
	icon_state = "engine"
	thermal_conductivity = 0.025
	heat_capacity = 325000
	intact = FALSE

/turf/floor/engine/nitrogen
//	oxygen = FALSE

/turf/floor/engine/attackby(obj/item/weapon/C as obj, mob/user as mob)
	if(!C)
		return
	if(!user)
		return
	if(istype(C, /obj/item/weapon/wrench))
		user << "<span class = 'notice'>Removing rods...</span>"
		playsound(src, 'sound/items/Ratchet.ogg', 80, TRUE)
		if(do_after(user, 30))
			PoolOrNew(/obj/item/stack/rods, list(loc, 2))
			ChangeTurf(/turf/floor)
			var/turf/floor/F = src
			F.make_plating()
			return

/turf/floor/engine/cult
	name = "engraved floor"
	icon_state = "cult"

/turf/floor/engine/n20
	New()
		. = ..()
	//	assume_gas("sleeping_agent", 2000)

/turf/floor/engine/vacuum
	name = "vacuum floor"
	icon_state = "engine"
//	oxygen = FALSE
//	nitrogen = FALSE
	temperature = TCMB

/turf/floor/plating
	name = "plating"
	icon_state = "plating"
	floor_type = null
	intact = FALSE

/turf/floor/plating/ex_act(severity)
		//set src in oview(1)
	switch(severity)
		if(1.0)
			ChangeTurf(world.turf)
		if(2.0)
			if(prob(40))
				ChangeTurf(world.turf)
	return

/turf/floor/plating/airless
	icon_state = "plating"
	name = "airless plating"
//	oxygen = FALSE
//	nitrogen = FALSE
	temperature = TCMB

	New()
		..()
		name = "plating"

/turf/floor/bluegrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "bcircuit"

/turf/floor/greengrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "gcircuit"


/turf/shuttle
	name = "shuttle"
	icon = 'icons/turf/shuttle.dmi'
	thermal_conductivity = 0.05
	heat_capacity = FALSE
	layer = TURF_LAYER

/turf/shuttle/wall
	name = "wall"
	icon_state = "wall1"
	opacity = TRUE
	density = TRUE
//	blocks_air = TRUE

/turf/shuttle/floor
	name = "floor"
	icon_state = "floor"

/turf/shuttle/plating
	name = "plating"
	icon = 'icons/turf/floors.dmi'
	icon_state = "plating"

/turf/shuttle/plating/vox	//Skipjack plating
//	oxygen = FALSE
//	nitrogen = MOLES_N2STANDARD + MOLES_O2STANDARD

/turf/shuttle/floor4 // Added this floor tile so that I have a seperate turf to check in the shuttle -- Polymorph
	name = "Brig floor"        // Also added it into the 2x3 brig area of the shuttle.
	icon_state = "floor4"

/turf/shuttle/floor4/vox	//skipjack floors
	name = "skipjack floor"
//	oxygen = FALSE
//	nitrogen = MOLES_N2STANDARD + MOLES_O2STANDARD


/turf/floor/grass
	name = "Grass patch"
	icon_state = "grass1"
	floor_type = /obj/item/stack/tile/grass

	New()
		icon_state = "grass[pick("1","2","3","4")]"
		..()
		spawn(4)
			if(src)
				update_icon()
				for(var/direction in cardinal)
					if(istype(get_step(src,direction),/turf/floor))
						var/turf/floor/FF = get_step(src,direction)
						FF.update_icon() //so siding get updated properly

/turf/floor/carpet
	name = "Carpet"
	icon_state = "carpet"
	floor_type = /obj/item/stack/tile/carpet

	New()
		if(!icon_state)
			icon_state = "carpet"
		..()
		spawn(4)
			if(src)
				update_icon()
				for(var/direction in list(1,2,4,8,5,6,9,10))
					if(istype(get_step(src,direction),/turf/floor))
						var/turf/floor/FF = get_step(src,direction)
						FF.update_icon() //so siding get updated properly



/turf/floor/plating/ironsand/New()
	..()
	icon = 'icons/turf/floors.dmi'
	name = "Iron Sand"
	icon_state = "ironsand[rand(1,15)]"

/turf/floor/plating/snow
	name = "snow"
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"

/turf/floor/plating/snow/ex_act(severity)
	return

/turf/floor/plating/grass
	name = "grass"
	icon = 'icons/turf/floors.dmi'
	icon_state = "grass_dark"
	interior = FALSE
	stepsound = "dirt"
	uses_winter_overlay = TRUE
	var/obj/structure/wild/wild = null

/turf/floor/plating/grass/New()
	..()
	grass_turf_list += src

/turf/floor/plating/grass/proc/plant()
	// 3x3 clumps of grass - original code
	if (prob(1))
		if (!locate(/obj/structure/wild/bush) in range(3, src))
			if (!locate(/obj/item) in range(3, src))
				for (var/turf/floor/plating/grass/G in range(3, src))
					if (!locate(/obj/structure) in G)
						var/dist = get_dist(src, G)
						if (prob(100-(dist*5)))
							G.wild = new/obj/structure/wild/bush(G)
	// huge grassy areas - adapted from Drymouth Gulch
	else
		if (locate(/obj/structure) in src)
			return
		if (locate(/obj/item) in src)
			return
		if(prob(0.1)) // default is 0.1
			wild = new/obj/structure/wild/bush(src)
		else
			var/chance = FALSE
			for(var/turf/floor/plating/grass/T in range(1,src))
				if(T.wild)
					chance += 40 // default is 40
			if(prob(chance))
				wild = new/obj/structure/wild/bush(src)

/turf/floor/plating/grass/wild
	name = "wild grass"

/turf/floor/plating/grass/wild/New()
	..()
	icon = 'icons/turf/flooring/grass.dmi'
	icon_state = "grass[rand(0,3)]"

/turf/floor/plating/beach
	name = "Beach"
	icon = 'icons/misc/beach.dmi'

/turf/floor/plating/beach/sand
	name = "Sand"
	icon_state = "sand"

/turf/floor/plating/beach/coastline
	name = "Coastline"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "sandwater"

/turf/floor/plating/beach/water
	name = "Water"
	icon_state = "seashallow"
	move_delay = 3

/turf/floor/plating/beach/water/get_move_delay()
	if (locate(/obj/structure/catwalk) in contents)
		return 0
	return move_delay

/turf/floor/plating/beach/water/sewage
	name = "Sewage Water"
	move_delay = 3
	color = "#94B21C"

/turf/floor/plating/beach/water/proc/Extinguish(var/mob/living/L)
	if (istype(L))
		L.ExtinguishMob()
		L.fire_stacks = FALSE

/turf/floor/plating/beach/water/ex_act(severity)
	return

/turf/floor/plating/beach/water/New()
	..()
	if (!istype(src, /turf/floor/plating/beach/water/ice))
		if (!istype(src, /turf/floor/plating/beach/water/sewage))
			overlays += image("icon"='icons/misc/beach.dmi',"icon_state"="water5","layer"=layer+0.1)
		else
			var/image/I = image("icon"='icons/misc/beach.dmi',"icon_state"="water5","layer"=layer+0.1)
			I.color = color
			I.alpha = 155
			overlays += I
			alpha = 155
			I = image("icon"='icons/misc/beach.dmi',"icon_state"="plating","layer"=layer-0.1)
			underlays += I

/turf/floor/plating/beach/water/ice
	name = "Ice"
	icon_state = "seashallow_frozen"
	move_delay = 0

/turf/floor/plating/dirt
	name = "dirt"
	icon = 'icons/turf/floors.dmi'
	icon_state = "dirt"
	interior = FALSE
	stepsound = "dirt"
	uses_winter_overlay = TRUE

/turf/floor/plating/sand
	name = "sand"
	icon = 'icons/turf/floors.dmi'
	icon_state = "sand1"
	interior = FALSE
	stepsound = "dirt"

/turf/floor/plating/sand/New()
	..()
	icon_state = "sand[rand(1, 3)]"

/turf/floor/plating/concrete
	name = "concrete"
	icon = 'icons/turf/floors.dmi'
	icon_state = "concrete6"
	interior = FALSE

/turf/floor/plating/concrete/New()
	..()
	if(icon_state == "concrete2")
		icon_state = pick("concrete2", "concrete3")
		return
	if(icon_state == "concrete6")
		icon_state = pick("concrete6", "concrete7")
		return
	if(icon_state == "concrete10")
		icon_state = pick("concrete10", "concrete11")
		return

/turf/floor/plating/road
	name = "road"
	icon = 'icons/turf/floors.dmi'
	icon_state = "road_1"
	interior = FALSE
	var/icon_mode = ""

/turf/floor/plating/road/New()
	..()
	icon_state = "road_[icon_mode][rand(1, 3)]"

/turf/floor/plating/cobblestone
	name = "road"
	icon = 'icons/turf/floors.dmi'
	icon_state = "cobble_horizontal"
	interior = FALSE

/turf/floor/plating/cobblestone/dark
	name = "road"
	icon = 'icons/turf/floors.dmi'
	icon_state = "cobble_horizontal_dark"
	interior = FALSE

/turf/floor/plating/cobblestone/vertical
	name = "road"
	icon = 'icons/turf/floors.dmi'
	icon_state = "cobble_vertical"
	interior = FALSE

/turf/floor/plating/cobblestone/vertical/dark
	name = "road"
	icon = 'icons/turf/floors.dmi'
	icon_state = "cobble_vertical_dark"
	interior = FALSE

turf/air
	icon_state = "air"
	name = "air"
	icon = 'icons/WW2/ju57.dmi'

turf/junkers
	icon = 'icons/WW2/ju57.dmi'
	name = "Ju-52 cassis"

