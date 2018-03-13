#define PLAYER_THRESHOLD_LOW 10
#define PLAYER_THRESHOLD_MEDIUM 20
#define PLAYER_THRESHOLD_HIGH 30
#define PLAYER_THRESHOLD_HIGHEST 50

/proc/check_for_german_train_conductors()
	if (!game_started)
		return TRUE // if we haven't started the game yet
	if (initial(grace_period) == grace_period)
		return TRUE // if we started with a grace period and we're still in that
	for (var/mob/living/carbon/human/H in world)
		var/cont = FALSE
		if (locate(/obj/item/weapon/key/german/train) in H)
			cont = TRUE
		for (var/obj/item/clothing/clothing in H)
			if (locate(/obj/item/weapon/key/german/train) in clothing)
				cont = TRUE
				break
		if (cont)
			if (H.stat == CONSCIOUS && H.mind.assigned_job.base_type_flag() == GERMAN)
				return TRUE // found a conscious german dude with the key
	return FALSE

/datum/job/var/allow_spies = FALSE
/datum/job/var/is_officer = FALSE
/datum/job/var/is_squad_leader = FALSE
/datum/job/var/is_commander = FALSE
/datum/job/var/is_petty_commander = FALSE
/datum/job/var/is_nonmilitary = FALSE
/datum/job/var/spawn_delay = FALSE
/datum/job/var/delayed_spawn_message = ""
/datum/job/var/is_SS = FALSE
/datum/job/var/is_primary = TRUE
/datum/job/var/is_secondary = FALSE
/datum/job/var/is_paratrooper = FALSE
/datum/job/var/is_sturmovik = FALSE
/datum/job/var/is_guard = FALSE
/datum/job/var/is_tankuser = FALSE
/datum/job/var/rank_abbreviation = null

// new autobalance stuff - Kachnov
/datum/job/var/min_positions = 1 // absolute minimum positions if we reach player threshold
/datum/job/var/max_positions = 1 // absolute maximum positions if we reach player threshold
/datum/job/var/player_threshold = 0 // number of players who have to be on for this job to be open
/datum/job/var/scale_to_players = 50 // as we approach this, our open positions approach max_positions. Does nothing if min_positions == max_positions, so just don't touch it

/* type_flag() replaces flag, and base_type_flag() replaces department_flag
 * this is a better solution than bit constants, in my opinion */

/datum/job
	var/_base_type_flag = -1

/datum/job/proc/specialcheck()
	return TRUE

/datum/job/proc/type_flag()
	return "[type]"

/datum/job/proc/base_type_flag(var/most_specific = FALSE)

	if (_base_type_flag != -1)
		return _base_type_flag

	if (istype(src, /datum/job/soviet))
		. = SOVIET
	else if (istype(src, /datum/job/partisan))
		if (istype(src, /datum/job/partisan/civilian))
			. = CIVILIAN
		else
			. = PARTISAN
	else if (istype(src, /datum/job/german))
		if (!most_specific)
			. = GERMAN
		else
			if (!is_SS)
				. = GERMAN
			else
				. = SCHUTZSTAFFEL
	else if (istype(src, /datum/job/ukrainian))
		. = UKRAINIAN
	else if (istype(src, /datum/job/italian))
		. = ITALIAN
	else if (istype(src, /datum/job/pillarman))
		. = PILLARMEN

	_base_type_flag = .
	return _base_type_flag

/datum/job/proc/get_side_name()
	return capitalize(lowertext(base_type_flag()))

/datum/job/proc/assign_faction(var/mob/living/carbon/human/user)

	if (!spies[GERMAN])
		spies[GERMAN] = FALSE
	if (!spies[SOVIET])
		spies[SOVIET] = FALSE
	if (!spies[PARTISAN])
		spies[PARTISAN] = FALSE

	if (!squad_leaders[GERMAN])
		squad_leaders[GERMAN] = FALSE
	if (!squad_leaders[SOVIET])
		squad_leaders[SOVIET] = FALSE
	if (!squad_leaders[PARTISAN])
		squad_leaders[PARTISAN] = FALSE

	if (!officers[GERMAN])
		officers[GERMAN] = FALSE
	if (!officers[SOVIET])
		officers[SOVIET] = FALSE
	if (!officers[PARTISAN])
		officers[PARTISAN] = FALSE

	if (!commanders[GERMAN])
		commanders[GERMAN] = FALSE
	if (!commanders[SOVIET])
		commanders[SOVIET] = FALSE
	if (!commanders[PARTISAN])
		commanders[PARTISAN] = FALSE

	if (!soldiers[GERMAN])
		soldiers[GERMAN] = FALSE
	if (!soldiers[SOVIET])
		soldiers[SOVIET] = FALSE
	if (!soldiers[PARTISAN])
		soldiers[PARTISAN] = FALSE


	if (!squad_members[GERMAN])
		squad_members[GERMAN] = FALSE
	if (!squad_members[SOVIET])
		squad_members[SOVIET] = FALSE
	if (!squad_members[PARTISAN])
		squad_members[PARTISAN] = FALSE

	if (!istype(user))
		return

	if (istype(src, /datum/job/german))

		if (istype(src, /datum/job/german/soldier_ss))
			user.base_faction = new/datum/faction/german/SS(user, src)
		else
			user.base_faction = new/datum/faction/german(user, src)

		if (is_officer && !is_commander)
			user.officer_faction = new/datum/faction/german/officer(user, src)

		else if (is_commander)
			if (istype(src, /datum/job/german/squad_leader_ss))
				user.officer_faction = new/datum/faction/german/commander/SS(user, src)
			else
				user.officer_faction = new/datum/faction/german/commander(user, src)

		if (is_squad_leader)
			switch (squad_leaders[GERMAN])
				if (0)
					user.squad_faction = new/datum/faction/squad/one/leader(user, src)
				if (1)
					user.squad_faction = new/datum/faction/squad/two/leader(user, src)
				if (2)
					user.squad_faction = new/datum/faction/squad/three/leader(user, src)
				if (3)
					user.squad_faction = new/datum/faction/squad/four/leader(user, src)
		else if (!is_officer && !is_commander && !is_nonmilitary && !is_SS && !is_paratrooper && !is_guard && !is_tankuser)
			switch (squad_members[GERMAN]) // non officers
				if (0 to MEMBERS_PER_SQUAD-1)
					user.squad_faction = new/datum/faction/squad/one(user, src)
				if ((MEMBERS_PER_SQUAD) to (MEMBERS_PER_SQUAD*2)-1)
					user.squad_faction = new/datum/faction/squad/two(user, src)
				if ((MEMBERS_PER_SQUAD*2) to (MEMBERS_PER_SQUAD*3)-1)
					user.squad_faction = new/datum/faction/squad/three(user, src)
				if ((MEMBERS_PER_SQUAD*3) to (MEMBERS_PER_SQUAD*4)-1)
					user.squad_faction = new/datum/faction/squad/four(user, src)
				if ((MEMBERS_PER_SQUAD*4) to INFINITY) // latejoiners
					if (prob(50))
						if (prob(50))
							user.squad_faction = new/datum/faction/squad/one(user, src)
						else
							user.squad_faction = new/datum/faction/squad/two(user, src)
					else
						if (prob(50))
							user.squad_faction = new/datum/faction/squad/three(user, src)
						else
							user.squad_faction = new/datum/faction/squad/four(user, src)

	else if (istype(src, /datum/job/soviet))
		user.base_faction = new/datum/faction/soviet(user, src)

		if (is_officer && !is_commander)
			user.officer_faction = new/datum/faction/soviet/officer(user, src)

		else if (is_commander)
			user.officer_faction = new/datum/faction/soviet/commander(user, src)

		if (is_squad_leader)
			switch (squad_leaders[SOVIET])
				if (0)
					user.squad_faction = new/datum/faction/squad/one/leader(user, src)
				if (1)
					user.squad_faction = new/datum/faction/squad/two/leader(user, src)
				if (2)
					user.squad_faction = new/datum/faction/squad/three/leader(user, src)
				if (3)
					user.squad_faction = new/datum/faction/squad/four/leader(user, src)
		else if (!is_officer && !is_commander && !is_nonmilitary && !is_guard && !is_tankuser)
			switch (squad_members[SOVIET]) // non officers
				if (0 to 7-1)
					user.squad_faction = new/datum/faction/squad/one(user, src)
				if (8-1 to 14-1)
					user.squad_faction = new/datum/faction/squad/two(user, src)
				if (15-1 to 21-1)
					user.squad_faction = new/datum/faction/squad/three(user, src)
				if (22-1 to 28-1)
					user.squad_faction = new/datum/faction/squad/four(user, src)

	else if (istype(src, /datum/job/partisan))
		user.base_faction = new/datum/faction/partisan(user, src)
		if (is_officer && !is_commander)
			user.officer_faction = new/datum/faction/partisan/officer(user, src)
		else if (is_commander)
			user.officer_faction = new/datum/faction/partisan/commander(user, src)


/datum/job/proc/try_make_jew(var/mob/living/carbon/human/user)
	return // disabled

/datum/job/proc/try_make_initial_spy(var/mob/living/carbon/human/user)
	return // disabled

/datum/job/proc/try_make_latejoin_spy(var/mob/user)
	return //disabled

/datum/job/proc/opposite_faction_name()
	if (istype(src, /datum/job/german))
		return "Soviet"
	else
		return GERMAN
// make someone a spy regardless, allowing them to swap uniforms
/datum/job/proc/make_spy(var/mob/living/carbon/human/user)

	user << "<span class = 'danger'>You are the spy.</span><br>"
	user << "<span class = 'warning'>Sabotage your own team wherever possible. To change your uniform and radio to the [opposite_faction_name()] one, right click your uniform and use 'Swap'. You know both Russian and German; to change your language, use the IC tab.</span>"

	user.add_memory("Spy Objectives")
	user.add_memory("")
	user.add_memory("")
	user.add_memory("Sabotage your own team wherever possible. To change your uniform and radio to the [opposite_faction_name()] one, right click your uniform and use 'Swap'. You know both Russian and German; to change your language, use the IC tab.")

	user.is_spy = TRUE // lets admins see who's a spy

	var/mob/living/carbon/human/H = user

	if (istype(H))
		var/obj/item/clothing/under/under = H.w_uniform
		if (under && istype(under))
			under.add_alternative_setting()

	if (istype(src, /datum/job/german))
		if (!H.languages.Find(RUSSIAN))
			H.add_language(RUSSIAN, TRUE)
		H.spy_faction = new/datum/faction/soviet()
	else
		if (!H.languages.Find(GERMAN))
			H.add_language(GERMAN, TRUE)
		H.spy_faction = new/datum/faction/german()


/proc/get_side_name(var/side, var/datum/job/j)
	if (j && (istype(j, /datum/job/german/squad_leader_ss) || istype(j, /datum/job/german/soldier_ss)))
		return "Waffen-S.S."
	if(side == PARTISAN)
		return CIVILIAN
	if(side == SOVIET)
		return "Red Army"
	if(side == GERMAN)
		return "German Wehrmacht"
	if (side == PILLARMEN)
		return "PILLARMEN"
	return null

// here's a story
// the lines to give people radios and harnesses are really long and go off screen like this one
// and I got tired of constantly having to readd radios because merge conflicts
// so now there's this magical function that equips a human with a radio and harness
//	- Kachnov

/mob/living/carbon/human/var/gave_radio = FALSE

/mob/living/carbon/human/proc/give_radio()

	if (gave_radio)
		return


	gave_radio = TRUE

	spawn (1)

		// we already have something that holds radios
		if (!original_job.is_paratrooper && !original_job.is_sturmovik && !(original_job.is_SS && !original_job.is_commander))
			equip_to_slot_or_del(new /obj/item/clothing/suit/radio_harness(src), slot_wear_suit)

		spawn (0)
			if (istype(original_job, /datum/job/soviet))
				if (original_job.is_officer)
					equip_to_slot_or_del(new /obj/item/device/radio/rbs/command(src), slot_s_store)
				else
					equip_to_slot_or_del(new /obj/item/device/radio/rbs(src), slot_s_store)
			else if (istype(original_job, /datum/job/german))
				if (original_job.is_SS)
					if (original_job.is_officer)
						equip_to_slot_or_del(new /obj/item/device/radio/feldfu/SS/command(src), slot_s_store)
					else
						equip_to_slot_or_del(new /obj/item/device/radio/feldfu/SS(src), slot_s_store)
				else
					if (original_job.is_officer)
						equip_to_slot_or_del(new /obj/item/device/radio/feldfu/command(src), slot_s_store)
					else
						equip_to_slot_or_del(new /obj/item/device/radio/feldfu(src), slot_s_store)
			else if (istype(original_job, /datum/job/partisan))
				equip_to_slot_or_del(new /obj/item/device/radio/partisan(src), slot_s_store)

	src << "<span class = 'notice'><b>You have a radio in your suit storage. To use it while its on your back, prefix your message with ':b'.</b></span>"

/datum/job/update_character(var/mob/living/carbon/human/H)
	..()
	if (is_officer)
		H.make_artillery_officer()
		H.verbs += /mob/living/carbon/human/proc/Execute
		H << "<span class = 'info'>As an officer, you can check coordinates and execute your subordinates.</span>"

	// hack to make scope icons immediately appear - Kachnov
	spawn (20)
		for (var/obj/item/weapon/gun/G in H.contents)
			for (var/obj/item/weapon/attachment/scope/S in G.contents)
				if (S.azoom)
					S.azoom.Grant(H)

		for (var/obj/item/weapon/attachment/scope/S in H.contents)
			if (S.azoom)
				S.azoom.Grant(H)
