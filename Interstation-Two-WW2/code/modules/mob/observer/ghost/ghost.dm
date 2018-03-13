var/global/list/image/ghost_darkness_images = list() //this is a list of images for things ghosts should still be able to see when they toggle darkness
var/global/list/image/ghost_sightless_images = list() //this is a list of images for things ghosts should still be able to see even without ghost sight

/mob/observer/ghost
	name = "ghost"
	desc = "It's a g-g-g-g-ghooooost!" //jinkies!
	icon = 'icons/mob/mob.dmi'
	icon_state = "ghost"
	canmove = FALSE
	blinded = FALSE
	anchored = TRUE	//  don't get pushed around
	var/can_reenter_corpse
	var/datum/hud/living/carbon/hud = null // hud
	var/bootime = FALSE
	var/started_as_observer //This variable is set to TRUE when you enter the game as an observer.
							//If you died in the game and are a ghsot - this will remain as null.
							//Note that this is not a reliable way to determine if admins started as observers, since they change mobs a lot.
	var/has_enabled_antagHUD = FALSE
	var/medHUD = FALSE
	var/antagHUD = FALSE
	universal_speak = TRUE
	var/atom/movable/following = null
	var/admin_ghosted = FALSE
	var/anonsay = FALSE
	var/ghostvision = TRUE //is the ghost able to see things humans can't?
	var/seedarkness = TRUE

	var/obj/item/device/multitool/ghost_multitool
	incorporeal_move = TRUE

	var/list/original_overlays = list()
	var/original_icon_state = null

/mob/observer/ghost/New(mob/body)
	see_in_dark = 100
	verbs += /mob/observer/ghost/proc/dead_tele

	var/turf/T
	if(ismob(body))
		T = get_turf(body)				//Where is the body located?
		attack_log = body.attack_log	//preserve our attack logs by copying them to our ghost

		if (ishuman(body))
			var/mob/living/carbon/human/H = body
			icon = H.stand_icon
			overlays = H.overlays_standing
		else
			icon = body.icon
			icon_state = body.icon_state
			overlays = body.overlays

		alpha = 127

		gender = body.gender
		if(body.mind && body.mind.name)
			name = body.mind.name
		else
			if(body.real_name)
				name = body.real_name
			else
				if(gender == MALE)
					name = capitalize(pick(first_names_male)) + " " + capitalize(pick(last_names))
				else
					name = capitalize(pick(first_names_female)) + " " + capitalize(pick(last_names))

		mind = body.mind	//we don't transfer the mind but we keep a reference to it.

	if(!T)	T = pick(latejoin_turfs["Ghost"])			//Safety in case we cannot find the body's position
	forceMove(T)

	if(!name)							//To prevent nameless ghosts
		name = capitalize(pick(first_names_male)) + " " + capitalize(pick(last_names))
	real_name = name

//	ghost_multitool = new(src)

	// when you gib, you have no icon state.
	// now you get a default ghost icon
	// - Kachnov

	if (!icon_state)
		icon = initial(icon)
		icon_state = initial(icon_state)

	..()

/mob/observer/ghost/Destroy()
	stop_following()
//	qdel(ghost_multitool)
//	ghost_multitool = null
	return ..()

/mob/observer/ghost/Topic(href, href_list)
	if (href_list["track"])
		if(istype(href_list["track"],/mob))
			var/mob/target = locate(href_list["track"]) in mob_list
			if (target)
				if (target.real_name == "Supply Announcement System")
					follow_supplytrain_proc()
				else
					ManualFollow(target)
		else
			var/atom/target = locate(href_list["track"])
			if(istype(target))
				ManualFollow(target)

/mob/observer/ghost/attackby(obj/item/W, mob/user)
	return FALSE
/*
Transfer_mind is there to check if mob is being deleted/not going to have a body.
Works together with spawning an observer, noted above.
*/

/mob/observer/ghost/Life()
	..()
	if(!loc) return
	if(!client) return FALSE

	if(client.images.len)
		for(var/image/hud in client.images)
			if(copytext(hud.icon_state,1,4) == "hud")
				client.images.Remove(hud)

	if(antagHUD)
		var/list/target_list = list()
		for(var/mob/living/target in oview(src, 14))
			if(target.mind && target.mind.special_role)
				target_list += target
		if(target_list.len)
			assess_targets(target_list, src)
	if(medHUD)
		process_medHUD(src)


/mob/observer/ghost/proc/process_medHUD(var/mob/M)
	var/client/C = M.client
	for(var/mob/living/carbon/human/patient in oview(M, 14))
		C.images += patient.hud_list[HEALTH_HUD]
		C.images += patient.hud_list[STATUS_HUD_OOC]

/mob/observer/ghost/proc/assess_targets(list/target_list, mob/observer/ghost/U)
	var/client/C = U.client
	for(var/mob/living/carbon/human/target in target_list)
		C.images += target.hud_list[SPECIALROLE_HUD]
	return TRUE

/mob/proc/ghostize(var/can_reenter_corpse = TRUE)
	// remove weather sounds
	src << sound(null, channel = 777)
	if(key)
		var/mob/observer/ghost/ghost = new(src)	//Transfer safety to observer spawning proc.
		ghost.can_reenter_corpse = can_reenter_corpse
		ghost.timeofdeath = stat == DEAD ? timeofdeath : world.time
		ghost.key = key
		if (ishuman(src))
			if (human_clients_mob_list.Find(src))
				human_clients_mob_list -= src
		return ghost

/*
This is the proc mobs get to turn into a ghost. Forked from ghostize due to compatibility issues.
*/
/mob/living/verb/ghost()
	set category = "OOC"
	set name = "Ghost"
	set desc = "Relinquish your life and enter the land of the dead."

	if(stat == DEAD)
		if (client)
			client.next_normal_respawn = world.realtime + (map ? map.respawn_delay : 3000)
			client << "<span class = 'good'>You can respawn with the 'Respawn' verb in the IC tab.</span>"
		if (ishuman(src))
			var/mob/living/carbon/human/H = src
			H.handle_zoom_stuff(TRUE)
		announce_ghost_joinleave(ghostize(1))
	else
		var/response
		if(client && client.holder)
			response = alert(src, "You have the ability to Admin-Ghost. The regular Ghost verb will announce your presence to dead chat. Both variants will allow you to return to your body using 'aghost'.\n\nWhat do you wish to do?", "Are you sure you want to ghost?", "Ghost", "Admin Ghost", "Stay in body")
			if(response == "Admin Ghost")
				if(!client)
					return
				if (ishuman(src))
					var/mob/living/carbon/human/H = src
					H.handle_zoom_stuff(TRUE)
				client.admin_ghost()
		else
			response = alert(src, "Are you sure you want to ghost?\n(You may respawn with the 'Respawn' verb in the IC tab)", "Are you sure you want to ghost?", "Ghost", "Stay in body")
		if(response != "Ghost")
			return
		if (getTotalLoss() < 100 || restrained())
			src << "<span class = 'warning'>You can't ghost right now.</span>"
			return
		resting = TRUE
		var/turf/location = get_turf(src)
		if (ishuman(src))
			var/mob/living/carbon/human/H = src
			H.handle_zoom_stuff(TRUE)
		if (client)
			client.next_normal_respawn = world.realtime + (map ? map.respawn_delay : 3000)
			client << "<span class = 'good'>You can respawn with the 'Respawn' verb in the IC tab.</span>"
		message_admins("[key_name_admin(usr)] has ghosted. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[location.x];Y=[location.y];Z=[location.z]'>JMP</a>)")
		log_game("[key_name_admin(usr)] has ghosted.")
		var/mob/observer/ghost/ghost = ghostize(0)	//0 parameter is so we can never re-enter our body, "Charlie, you can never come baaaack~" :3
		ghost.timeofdeath = world.time // Because the living mob won't have a time of death and we want the respawn timer to work properly.
		announce_ghost_joinleave(ghost)

/mob/observer/ghost/can_use_hands()	return FALSE
/mob/observer/ghost/is_active()		return FALSE

/mob/observer/ghost/verb/reenter_corpse()
	set category = "Ghost"
	set name = "Re-enter Corpse"
	if(!client)	return
	if(!(mind && mind.current && can_reenter_corpse))
		src << "<span class='warning'>You have no body.</span>"
		return
	if(mind.current.key && copytext(mind.current.key,1,2)!="@")	//makes sure we don't accidentally kick any clients
		usr << "<span class='warning'>Another consciousness is in your body... it is resisting you.</span>"
		return

	client.remove_ghost_only_admin_verbs()

	stop_following()
	mind.current.ajourn=0
	mind.current.key = key
	mind.current.teleop = null

	if(!admin_ghosted)
		announce_ghost_joinleave(mind, FALSE, "They now occupy their body again.")

	mind.current.regenerate_icons()

	// workaround for language bug that happens when you're spawned in
	var/mob/living/carbon/human/H = mind.current
	if (istype(H))
		if (!H.languages.Find(H.default_language))
			H.languages.Insert(1, H.default_language)
		human_clients_mob_list |= H

	return TRUE

/mob/observer/ghost/verb/toggle_medHUD()
	set category = "Ghost"
	set name = "Toggle MedicHUD"
	set desc = "Toggles Medical HUD allowing you to see how everyone is doing"
	if(!client)
		return
	if(medHUD)
		medHUD = FALSE
		src << "<span class = 'notice'><b>Medical HUD Disabled</b></span>"
	else
		medHUD = TRUE
		src << "<span class = 'notice'><b>Medical HUD Enabled</b></span>"
/*
/mob/observer/ghost/verb/toggle_antagHUD()
	set category = "Ghost"
	set name = "Toggle AntagHUD"
	set desc = "Toggles AntagHUD allowing you to see who is the antagonist"

	if(!client)
		return
	var/mentor = is_mentor(usr.client)
	if(!config.antag_hud_allowed && (!client.holder || mentor))
		src << "\red Admins have disabled this for this round."
		return
	var/mob/observer/ghost/M = src
	if(jobban_isbanned(M, "AntagHUD"))
		src << "\red <b>You have been banned from using this feature</b>"
		return
	if(config.antag_hud_restricted && !M.has_enabled_antagHUD && (!client.holder || mentor))
		var/response = alert(src, "If you turn this on, you will not be able to take any part in the round.","Are you sure you want to turn this feature on?","Yes","No")
		if(response == "No") return
		M.can_reenter_corpse = FALSE
	if(!M.has_enabled_antagHUD && (!client.holder || mentor))
		M.has_enabled_antagHUD = TRUE
	if(M.antagHUD)
		M.antagHUD = FALSE
		src << "\blue <b>AntagHUD Disabled</b>"
	else
		M.antagHUD = TRUE
		src << "\blue <b>AntagHUD Enabled</b>"
*/
/mob/observer/ghost/proc/dead_tele(A in ghostteleportlocs - /area/prishtina/void/sky)
	set category = "Ghost"
	set name = "Teleport"
	set desc= "Teleport to a location"
	if(!isghost(usr))
		usr << "Not when you're not dead!"
		return

	/*	this is dumb - Kachnov
	usr.verbs -= /mob/observer/ghost/proc/dead_tele
	spawn(5)
		usr.verbs += /mob/observer/ghost/proc/dead_tele*/

	var/area/thearea = ghostteleportlocs[A]
	if(!thearea)	return

	var/list/L = list()

	if(usr.invisibility <= SEE_INVISIBLE_LIVING)
		for(var/turf/T in get_area_turfs(thearea.type))
			L += T
	else
		for(var/turf/T in get_area_turfs(thearea.type))
			L+=T

	if(!L || !L.len)
		usr << "No area available."

	stop_following()
	usr.forceMove(pick(L))

/mob/observer/ghost/verb/follow(input in getfitmobs()+"Cancel")
	set category = "Ghost"
	set name = "Follow" // "Haunt"
	set desc = "Follow and haunt a mob."

	if (input != "Cancel")
		var/list/mobs = getfitmobs()
		if (mobs[input])
			ManualFollow(mobs[input])

/mob/observer/ghost/verb/follow_soviet(input in getfitmobs(SOVIET)+"Cancel")
	set category = "Ghost"
	set name = "Follow a Soviet"
	set desc = "Follow and haunt a living Soviet."

	if (input != "Cancel")
		var/list/mobs = getfitmobs(SOVIET)
		if (mobs[input])
			ManualFollow(mobs[input])

/mob/observer/ghost/verb/follow_german(input in getfitmobs(GERMAN)+"Cancel")
	set category = "Ghost"
	set name = "Follow a German"
	set desc = "Follow and haunt a living German."

	if (input != "Cancel")
		var/list/mobs = getfitmobs(GERMAN)
		if (mobs[input])
			ManualFollow(mobs[input])

/mob/observer/ghost/verb/follow_paratroopers(input in getfitmobs("PARATROOPERS")+"Cancel")
	set category = "Ghost"
	set name = "Follow a Paratrooper"
	set desc = "Follow and haunt a living Paratrooper."

	if (input != "Cancel")
		var/list/mobs = getfitmobs("PARATROOPERS")
		if (mobs[input])
			ManualFollow(mobs[input])

/mob/observer/ghost/verb/follow_ss(input in getfitmobs("SS")+"Cancel")
	set category = "Ghost"
	set name = "Follow a SS soldier"
	set desc = "Follow and haunt a living SS soldier."

	if (input != "Cancel")
		var/list/mobs = getfitmobs("SS")
		if (mobs[input])
			ManualFollow(mobs[input])

/mob/observer/ghost/verb/follow_partisan(input in getfitmobs(PARTISAN)+"Cancel")
	set category = "Ghost"
	set name = "Follow a Partisan"
	set desc = "Follow and haunt a living Partisan."

	if (input != "Cancel")
		var/list/mobs = getfitmobs(PARTISAN)
		if (mobs[input])
			ManualFollow(mobs[input])

/mob/observer/ghost/verb/follow_civilian(input in getfitmobs(CIVILIAN)+"Cancel")
	set category = "Ghost"
	set name = "Follow a Civilian"
	set desc = "Follow and haunt a living Civilian."

	if (input != "Cancel")
		var/list/mobs = getfitmobs(CIVILIAN)
		if (mobs[input])
			ManualFollow(mobs[input])

/mob/observer/ghost/verb/follow_undead(input in getfitmobs(PILLARMEN)+"Cancel")
	set category = "Ghost"
	set name = "Follow an Undead"
	set desc = "Follow and haunt an Undead."

	if (input != "Cancel")
		var/list/mobs = getfitmobs(PILLARMEN)
		if (mobs[input])
			ManualFollow(mobs[input])

/proc/getdogs()
	var/list/dogs = list()
	for (var/mob/living/simple_animal/complex_animal/canine/dog/D in living_mob_list)
		var/name = D.name
		var/nameinc = TRUE
		var/oname = name
		while (dogs.Find(name))
			name = "[oname] ([++nameinc])"
		dogs[name] = D
	return dogs

/mob/observer/ghost/verb/follow_dog(input in getdogs()+"Cancel")
	set category = "Ghost"
	set name = "Follow a Dog"
	set desc = "Follow and haunt a living dog."

	if (input != "Cancel")
		ManualFollow(getdogs()[input])

/mob/observer/ghost/verb/follow_train()
	set category = "Ghost"
	set name = "Jump to the Main Train"

	var/oldloc = get_turf(src)

	var/datum/train_controller/german_train_controller/tc = german_train_master

	if (tc)
		for (var/obj/train_car_center/tcc in tc.reverse_train_car_centers)
			for (var/obj/train_pseudoturf/tpt in tcc.backwards_pseudoturfs) // start at the front
				ManualFollow(tpt)
				goto endloop // TRUE break statement is not enough

		endloop

		var/newloc = get_turf(src)

		if (oldloc == newloc) // we didn't move: train isn't here
			loc = locate(127, 454, TRUE) // take us to the train station

/mob/observer/ghost/verb/follow_supplytrain()
	set category = "Ghost"
	set name = "Jump to the Supply Train"
	follow_supplytrain_proc()

/mob/observer/ghost/proc/follow_supplytrain_proc()

	var/oldloc = get_turf(src)

	var/datum/train_controller/german_supplytrain_controller/tc = german_supplytrain_master

	if (tc)
		if (tc.here)
			for (var/obj/train_car_center/tcc in tc.reverse_train_car_centers)
				for (var/obj/train_pseudoturf/tpt in tcc.backwards_pseudoturfs) // start at the front
					ManualFollow(tpt)
					goto endloop // TRUE break statement is not enough

		endloop

		var/newloc = get_turf(src)

		if (oldloc == newloc) // we didn't move: train isn't here
			loc = locate(15, 526, TRUE) // take us to the train station

/mob/observer/ghost/verb/follow_supply_lift()
	set category = "Ghost"
	set name = "Jump to a Supply Lift"

	var/list/options = list()

	for (var/obj/lift_controller/lc in world)
		options += lc.jump_name

	options += "CANCEL"
	var/option = input("Which?") in options
	if (option != "CANCEL")
		for (var/obj/lift_controller/lc in world)
			if (lc.jump_name == option)
				ManualFollow(lc)
				break

/mob/observer/ghost/verb/see_battle_report()
	set category = "Ghost"
	set name = "See Battle Report"
	show_global_battle_report(src, TRUE)


// FOLLOWING TANKS

/proc/gettanks()
	var/list/tanks = list()
	for (var/obj/tank/tank in world)
		var/count = FALSE
		for (var/tank2 in tanks)
			var/obj/tank/other = tanks[tank2]
			if (other.name == tank.name)
				++count // tank, tank (1), tank (2), etc
		tanks["[tank.name][count ? "([count])" : ""]"] = tank
	return tanks

/mob/observer/ghost/verb/follow_tank(input in gettanks())
	set category = "Ghost"
	set name = "Follow a Tank"

	var/obj/tank/tank = gettanks()[input]
	if (!tank) return
	ManualFollow(tank)

// This is the ghost's follow verb with an argument
/mob/observer/ghost/proc/ManualFollow(var/atom/movable/target)
	if(!target || target == following || target == src)
		return

	stop_following()
	following = target
	moved_event.register(following, src, /atom/movable/proc/move_to_destination)
	dir_set_event.register(following, src, /atom/proc/recursive_dir_set)
	destroyed_event.register(following, src, /mob/observer/ghost/proc/stop_following)

	src << "<span class='notice'>Now following \the [following]</span>"

	var/mob/living/carbon/human/H = target
	if (istype(H) && H.real_name == "Supply Announcement System")
		follow_supplytrain_proc()
	else
		move_to_destination(following, following.loc, following.loc)

/mob/observer/ghost/proc/stop_following()
	if(following)
		src << "<span class='notice'>No longer following \the [following]</span>"
		moved_event.unregister(following, src)
		dir_set_event.unregister(following, src)
		destroyed_event.unregister(following, src)
		following = null

/mob/observer/ghost/move_to_destination(var/atom/movable/am, var/old_loc, var/new_loc)
	var/turf/T = get_turf(new_loc)
	if(check_holy(T))
		usr << "<span class='warning'>You cannot follow something standing on holy grounds!</span>"
		return
	..()

/mob/proc/check_holy(var/turf/T)
	return FALSE

/mob/observer/ghost/check_holy(var/turf/T)
	if(check_rights(R_ADMIN|R_FUN, FALSE, src))
		return FALSE
	return FALSE

/mob/observer/ghost/verb/jumptomob(target in getfitmobs() + "Cancel") //Moves the ghost instead of just changing the ghosts's eye -Nodrak
	set category = "Ghost"
	set name = "Jump to Mob"
	set desc = "Teleport to a mob"

	if (target == "Cancel") // also prevents sending the observer to nullspace when there are no mobs
		return

	if(isghost(usr)) //Make sure they're an observer!

		if (!target)//Make sure we actually have a target
			return
		else
			var/mob/M = getmobs()[target] //Destination mob
			var/turf/T = get_turf(M) //Turf of the destination mob

		//	if(T && isturf(T))	//Make sure the turf exists, then move the source to that destination.
			stop_following()
			forceMove(T)
		//	else
		//		src << "This mob is not located in the game world."
/*
/mob/observer/ghost/verb/boo()
	set category = "Ghost"
	set name = "Boo!"
	set desc= "Scare your crew members because of boredom!"

	if(bootime > world.time) return
	var/obj/machinery/light/L = locate(/obj/machinery/light) in view(1, src)
	if(L)
		L.flicker()
		bootime = world.time + 600
		return
	//Maybe in the future we can add more <i>spooky</i> code here!
	return
*/

/mob/observer/ghost/memory()
	set hidden = TRUE
	src << "<span class = 'red'>You are dead! You have no mind to store memory!</span>"

/mob/observer/ghost/add_memory()
	set hidden = TRUE
	src << "<span class = 'red'>You are dead! You have no mind to store memory!</span>"

/mob/observer/ghost/Post_Incorpmove()
	stop_following()
/*
/mob/observer/ghost/verb/analyze_air()
	set name = "Analyze Air"
	set category = "Ghost"

	if(!isghost(usr)) return

	// Shamelessly copied from the Gas Analyzers
	if (!( istype(usr.loc, /turf) ))
		return

	var/datum/gas_mixture/environment = usr.loc.return_air()

	var/pressure = environment.return_pressure()
	var/total_moles = environment.total_moles

	src << "\blue <b>Results:</b>"
	if(abs(pressure - ONE_ATMOSPHERE) < 10)
		src << "\blue Pressure: [round(pressure,0.1)] kPa"
	else
		src << "\red Pressure: [round(pressure,0.1)] kPa"
	if(total_moles)
		for(var/g in environment.gas)
			src << "\blue [gas_data.name[g]]: [round((environment.gas[g] / total_moles) * 100)]% ([round(environment.gas[g], 0.01)] moles)"
		src << "\blue Temperature: [round(environment.temperature-T0C,0.1)]&deg;C ([round(environment.temperature,0.1)]K)"
		src << "\blue Heat Capacity: [round(environment.heat_capacity(),0.1)]"
*/
/*
/mob/observer/ghost/verb/become_mouse()
	set name = "Become mouse"
	set category = "Ghost"
	return FALSE

	if(config.disable_player_mice)
		src << "<span class='warning'>Spawning as a mouse is currently disabled.</span>"
		return

	if(!MayRespawn(1, ANIMAL_SPAWN_DELAY))
		return

	var/turf/T = get_turf(src)
	if(!T || (T.z in config.admin_levels))
		src << "<span class='warning'>You may not spawn as a mouse on this Z-level.</span>"
		return

	var/response = alert(src, "Are you -sure- you want to become a mouse?","Are you sure you want to squeek?","Squeek!","Nope!")
	if(response != "Squeek!") return  //Hit the wrong key...again.


	//find a viable mouse candidate
	var/mob/living/simple_animal/mouse/host
	var/obj/machinery/atmospherics/unary/vent_pump/vent_found
	var/list/found_vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/v in machines)
		if(!v.welded && v.z == T.z)
			found_vents.Add(v)
	if(found_vents.len)
		vent_found = pick(found_vents)
		host = new /mob/living/simple_animal/mouse(vent_found.loc)
	else
		src << "<span class='warning'>Unable to find any unwelded vents to spawn mice at.</span>"

	if(host)
		if(config.uneducated_mice)
			host.universal_understand = FALSE
		announce_ghost_joinleave(src, FALSE, "They are now a mouse.")
		host.ckey = ckey
		host << "<span class='info'>You are now a mouse. Try to avoid interaction with players, and do not give hints away that you are more than a simple rodent.</span>"
*/
/*
/mob/observer/ghost/verb/view_manfiest()
	set name = "Show Crew Manifest"
	set category = "Ghost"

	var/dat
	dat += "<h4>Crew Manifest</h4>"
	dat += data_core.get_manifest()

	src << browse(dat, "window=manifest;size=370x420;can_close=1")

//This is called when a ghost is drag clicked to something.
/mob/observer/ghost/MouseDrop(atom/over)
	if(!usr || !over) return
	if(isghost(usr) && usr.client && isliving(over))
		var/mob/living/M = over
		// If they an admin, see if control can be resolved.
		if(usr.client.holder && usr.client.holder.cmd_ghost_drag(src,M))
			return
		// Otherwise, see if we can possess the target.
		if(usr == src && try_possession(M))
			return

	return ..()
*/
/mob/observer/ghost/proc/try_possession(var/mob/living/M)
	if(!config.ghosts_can_possess_animals)
		usr << "<span class='warning'>Ghosts are not permitted to possess animals.</span>"
		return FALSE
	if(!M.can_be_possessed_by(src))
		return FALSE
	return M.do_possession(src)
/*
//Used for drawing on walls with blood puddles as a spooky ghost.
/mob/observer/ghost/verb/bloody_doodle()

	set category = "Ghost"
	set name = "Write in blood"
	set desc = "If the round is sufficiently spooky, write a short message in blood on the floor or a wall. Remember, no IC in OOC or OOC in IC."

	if(!(config.cult_ghostwriter))
		src << "\red That verb is not currently permitted."
		return

	if (!stat)
		return

	if (usr != src)
		return FALSE //something is terribly wrong

	if(!round_is_spooky())
		src << "\red The veil is not thin enough for you to do that."
		return

	var/list/choices = list()
	for(var/obj/effect/decal/cleanable/blood/B in view(1,src))
		if(B.amount > FALSE)
			choices += B

	if(!choices.len)
		src << "<span class = 'warning'>There is no blood to use nearby.</span>"
		return

	var/obj/effect/decal/cleanable/blood/choice = input(src,"What blood would you like to use?") in null|choices

	var/direction = input(src,"Which way?","Tile selection") as anything in list("Here","North","South","East","West")
	var/turf/T = loc
	if (direction != "Here")
		T = get_step(T,text2dir(direction))

	if (!istype(T))
		src << "<span class='warning'>You cannot doodle there.</span>"
		return

	if(!choice || choice.amount == FALSE || !(Adjacent(choice)))
		return

	var/doodle_color = (choice.basecolor) ? choice.basecolor : "#A10808"

	var/num_doodles = FALSE
	for (var/obj/effect/decal/cleanable/blood/writing/W in T)
		num_doodles++
	if (num_doodles > 4)
		src << "<span class='warning'>There is no space to write on!</span>"
		return

	var/max_length = 50

	var/message = sanitize(input("Write a message. It cannot be longer than [max_length] characters.","Blood writing", ""))

	if (message)

		if (length(message) > max_length)
			message += "-"
			src << "<span class='warning'>You ran out of blood to write with!</span>"

		var/obj/effect/decal/cleanable/blood/writing/W = new(T)
		W.basecolor = doodle_color
		W.update_icon()
		W.message = message
		W.add_hiddenprint(src)
		W.visible_message("\red Invisible fingers crudely paint something in blood on [T]...")
*/

/mob/observer/ghost/verb/pointed(atom/A as mob|obj|turf in view())
	set category = "Ghost"
	set name = "Point To"
	usr.visible_message("<span class='deadsay'><b>[src]</b> points to [A]</span>")
	return TRUE

/mob/observer/ghost/proc/manifest(mob/user)
	var/is_manifest = FALSE
	if(!is_manifest)
		is_manifest = TRUE
		verbs += /mob/observer/ghost/proc/toggle_visibility

	if(invisibility != FALSE)
		user.visible_message( \
			"<span class='warning'>\The [user] drags ghost, [src], to our plane of reality!</span>", \
			"<span class='warning'>You drag [src] to our plane of reality!</span>" \
		)
		toggle_visibility(1)
	else
		user.visible_message ( \
			"<span class='warning'>\The [user] just tried to smash \his book into that ghost!  It's not very effective.</span>", \
			"<span class='warning'>You get the feeling that the ghost can't become any more visible.</span>" \
		)

/mob/observer/ghost/proc/toggle_icon(var/icon)
	if(!client)
		return

	var/iconRemoved = FALSE
	for(var/image/I in client.images)
		if(I.icon_state == icon)
			iconRemoved = TRUE
			qdel(I)

	if(!iconRemoved)
		var/image/J = image('icons/mob/mob.dmi', loc = src, icon_state = icon)
		client.images += J

/mob/observer/ghost/proc/toggle_visibility(var/forced = FALSE)
	set category = "Ghost"
	set name = "Toggle Visibility"
	set desc = "Allows you to turn (in)visible (almost) at will."

	var/toggled_invisible
	if(!forced && invisibility && world.time < toggled_invisible + 600)
		src << "You must gather strength before you can turn visible again..."
		return

	if(invisibility == FALSE)
		toggled_invisible = world.time
		visible_message("<span class='emote'>It fades from sight...</span>", "<span class='info'>You are now invisible.</span>")
	else
		src << "<span class='info'>You are now visible!</span>"

	invisibility = invisibility == INVISIBILITY_OBSERVER ? FALSE : INVISIBILITY_OBSERVER
	// Give the ghost a cult icon which should be visible only to itself
	toggle_icon("cult")

/mob/observer/ghost/verb/toggle_anonsay()
	set category = "Ghost"
	set name = "Toggle Anonymous Chat"
	set desc = "Toggles showing your key in dead chat."

	anonsay = !anonsay
	if(anonsay)
		src << "<span class='info'>Your key won't be shown when you speak in dead chat.</span>"
	else
		src << "<span class='info'>Your key will be publicly visible again.</span>"

/mob/observer/ghost/canface()
	return TRUE

/mob/proc/can_admin_interact()
    return FALSE

/mob/observer/ghost/can_admin_interact()
	return check_rights(R_ADMIN, FALSE, src)

/mob/observer/ghost/verb/toggle_ghostsee()
	set name = "Toggle Ghost Vision"
	set desc = "Toggles your ability to see things only ghosts can see, like other ghosts"
	set category = "Ghost"
	ghostvision = !(ghostvision)
	updateghostsight()
	usr << "You [(ghostvision?"now":"no longer")] have ghost vision."

/mob/observer/ghost/verb/toggle_darkness()
	set name = "Toggle Darkness"
	set category = "Ghost"
	seedarkness = !(seedarkness)
	updateghostsight()

/mob/observer/ghost/proc/updateghostsight()
	if (!seedarkness)
		see_invisible = SEE_INVISIBLE_OBSERVER_NOLIGHTING
	else
		see_invisible = ghostvision ? SEE_INVISIBLE_OBSERVER : SEE_INVISIBLE_LIVING

	updateghostimages()

/mob/observer/ghost/proc/updateghostimages()
	if (!client)
		return
	client.images -= ghost_sightless_images
	client.images -= ghost_darkness_images
	if(!seedarkness)
		client.images |= ghost_sightless_images
		if(ghostvision)
			client.images |= ghost_darkness_images
	else if(seedarkness && !ghostvision)
		client.images |= ghost_sightless_images
	client.images -= ghost_image //remove ourself

/mob/observer/ghost/MayRespawn(var/feedback = FALSE, var/respawn_time = FALSE)
	if(!client)
		return FALSE
	if(mind && mind.current && mind.current.stat != DEAD && can_reenter_corpse)
		if(feedback)
			src << "<span class='warning'>Your non-dead body prevent you from respawning.</span>"
		return FALSE
	if(config.antag_hud_restricted && has_enabled_antagHUD == TRUE)
		if(feedback)
			src << "<span class='warning'>antagHUD restrictions prevent you from respawning.</span>"
		return FALSE

	var/timedifference = world.time - timeofdeath
	if(respawn_time && timeofdeath && timedifference < respawn_time MINUTES)
		var/timedifference_text = time2text(respawn_time MINUTES - timedifference,"mm:ss")
		src << "<span class='warning'>You must have been dead for [respawn_time] minute\s to respawn. You have [timedifference_text] left.</span>"
		return FALSE

	return TRUE

/atom/proc/extra_ghost_link()
	return

/mob/extra_ghost_link(var/atom/ghost)
/*	if(client && eyeobj)
		return "|<a href='byond://?src=\ref[ghost];track=\ref[eyeobj]'>eye</a>"
*/
	return null
/mob/observer/ghost/extra_ghost_link(var/atom/ghost)
	if(mind && mind.current)
		return "|<a href='byond://?src=\ref[ghost];track=\ref[mind.current]'>body</a>"

/proc/ghost_follow_link(var/atom/target, var/atom/ghost)
	if((!target) || (!ghost)) return
	. = "<a href='byond://?src=\ref[ghost];track=\ref[target]'>follow</a>"
	. += target.extra_ghost_link(ghost)
