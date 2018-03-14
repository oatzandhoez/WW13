/datum/job/soviet
	faction = "Station"

/datum/job/soviet/give_random_name(var/mob/living/carbon/human/H)
	H.name = H.species.get_random_russian_name(H.gender)
	H.real_name = H.name

/datum/job/soviet/commander
	title = "Kapitan"
	en_meaning = "Company Commander"
	rank_abbreviation = "Kpt"
	head_position = TRUE
	selection_color = "#530909"
	spawn_location = "JoinLateRACO"
	additional_languages = list( "German" = 100, "Ukrainian" = 50 )
	is_officer = TRUE
	is_commander = TRUE
	whitelisted = TRUE

	// AUTOBALANCE
	min_positions = 1
	max_positions = 1

/datum/job/soviet/commander/equip(var/mob/living/carbon/human/H)
	if(!H)	return FALSE

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/swat/wrappedboots(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/sovuni/officer(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/caphat/sovofficercap(H), slot_head)
	if (istype(H, /mob/living/carbon/human/megastalin))
		H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/revolver/nagant_revolver/gibber(H), slot_belt)
	else
		H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/revolver/nagant_revolver(H), slot_belt)
	H.equip_to_slot_or_del(new /obj/item/weapon/attachment/scope/adjustable/binoculars(H), slot_l_hand)
	spawn (5) // after we have our name
		if (!istype(H, /mob/living/carbon/human/megastalin))
			if (!istype(get_area(H), /area/prishtina/admin))
				world << "<b><big>[H.real_name] is the [title] of the Soviet forces!</big></b>"
	H << "<span class = 'notice'>You are the <b>[title]</b>, the highest ranking officer present. Your job is the organize the Russian forces and lead them to victory. You take orders from the <b>Soviet High Command</b>.</span>"
	H.give_radio()
	H.setStat("strength", STAT_MEDIUM_LOW)
	H.setStat("engineering", STAT_VERY_LOW)
	H.setStat("rifle", STAT_LOW)
	H.setStat("mg", STAT_MEDIUM_LOW)
	H.setStat("pistol", STAT_NORMAL)
	H.setStat("heavyweapon", STAT_NORMAL)
	H.setStat("medical", STAT_VERY_LOW)
	return TRUE

/datum/job/soviet/commander/get_keys()
	return list(new/obj/item/weapon/key/soviet, new/obj/item/weapon/key/soviet/soldat, new/obj/item/weapon/key/soviet/medic, new/obj/item/weapon/key/soviet/engineer,
		new/obj/item/weapon/key/soviet/QM, new/obj/item/weapon/key/soviet/command_intermediate, new/obj/item/weapon/key/soviet/command_high, new/obj/item/weapon/key/soviet/bunker_doors)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
/datum/job/soviet/XO
	title = "Starshiy Leytenant"
	en_meaning = "Company Executive Officer"
	rank_abbreviation = "STLy"
	head_position = FALSE
	selection_color = "#530909"
	spawn_location = "JoinLateRAXO"
	additional_languages = list( "German" = 100, "Ukrainian" = 50 )
	is_officer = TRUE

	// AUTOBALANCE
	min_positions = 1
	max_positions = 1
	player_threshold = PLAYER_THRESHOLD_MEDIUM

/datum/job/soviet/XO/equip(var/mob/living/carbon/human/H)
	if(!H)	return FALSE

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/swat/wrappedboots(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/sovuni/officer(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/caphat/sovofficercap(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/revolver/nagant_revolver(H), slot_belt)
	H.equip_to_slot_or_del(new /obj/item/weapon/attachment/scope/adjustable/binoculars(H), slot_l_hand)
	H << "<span class = 'notice'>You are the <b>[title]</b>, the second-in-command of the Russian forces. Your job is to take orders from the <b>Commandir</b> and coordinate with squad leaders.</span>"
	H.give_radio()
	H.setStat("strength", STAT_MEDIUM_LOW)
	H.setStat("engineering", STAT_VERY_LOW)
	H.setStat("rifle", STAT_LOW)
	H.setStat("mg", STAT_MEDIUM_LOW)
	H.setStat("pistol", STAT_NORMAL)
	H.setStat("heavyweapon", STAT_NORMAL)
	H.setStat("medical", STAT_VERY_LOW)
	return TRUE

/datum/job/soviet/XO/get_keys()
	return list(new/obj/item/weapon/key/soviet, new/obj/item/weapon/key/soviet/soldat, new/obj/item/weapon/key/soviet/medic, new/obj/item/weapon/key/soviet/engineer,
		new/obj/item/weapon/key/soviet/QM, new/obj/item/weapon/key/soviet/command_intermediate, new/obj/item/weapon/key/soviet/command_high, new/obj/item/weapon/key/soviet/bunker_doors)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/datum/job/soviet/staff_officer
	title = "Leytenant"
	en_meaning = "Platoon Officer"
	rank_abbreviation = "Lyt"
	head_position = FALSE
	selection_color = "#530909"
	spawn_location = "JoinLateRASO"
	additional_languages = list( "German" = 100, "Ukrainian" = 50 )
	is_officer = TRUE

	// AUTOBALANCE
	min_positions = 1
	max_positions = 2
	player_threshold = PLAYER_THRESHOLD_HIGH
	scale_to_players = PLAYER_THRESHOLD_HIGHEST

/datum/job/soviet/staff_officer/equip(var/mob/living/carbon/human/H)
	if(!H)	return FALSE

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/swat/wrappedboots(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/sovuni/officer(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/caphat/sovofficercap(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/revolver/nagant_revolver(H), slot_belt)
	H.equip_to_slot_or_del(new /obj/item/weapon/attachment/scope/adjustable/binoculars(H), slot_l_hand)
	H << "<span class = 'notice'>You are the <b>[title]</b>, one of the vice-commanders of the Russian forces. Your job is to take orders from the <b>Commandir</b> and coordinate with squad leaders.</span>"
	H.give_radio()
	H.setStat("strength", STAT_MEDIUM_LOW)
	H.setStat("engineering", STAT_VERY_LOW)
	H.setStat("rifle", STAT_LOW)
	H.setStat("mg", STAT_MEDIUM_LOW)
	H.setStat("pistol", STAT_NORMAL)
	H.setStat("heavyweapon", STAT_NORMAL)
	H.setStat("medical", STAT_VERY_LOW)
	return TRUE

/datum/job/soviet/staff_officer/get_keys()
	return list(new/obj/item/weapon/key/soviet, new/obj/item/weapon/key/soviet/soldat, new/obj/item/weapon/key/soviet/medic, new/obj/item/weapon/key/soviet/engineer,
		new/obj/item/weapon/key/soviet/QM, new/obj/item/weapon/key/soviet/command_intermediate, new/obj/item/weapon/key/soviet/command_high, new/obj/item/weapon/key/soviet/bunker_doors)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
/datum/job/soviet/MP
	title = "Voyennaya Politsiya"
	en_meaning = "MPO"
	rank_abbreviation = "Srg"
	selection_color = "#2d2d63"
	spawn_location = "JoinLateRAMP"
	additional_languages = list( "German" = 100, "Ukrainian" = 33 )
	is_officer = TRUE

	// AUTOBALANCE
	min_positions = 1
	max_positions = 3
	player_threshold = PLAYER_THRESHOLD_LOW
	scale_to_players = PLAYER_THRESHOLD_HIGHEST

/datum/job/soviet/MP/equip(var/mob/living/carbon/human/H)
	if(!H)	return FALSE
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/swat/wrappedboots(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/sovuni/MP(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/tactical/sovhelm/MP(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/soviet/MP(H), slot_belt)
	H << "<span class = 'notice'>You are the <b>[title]</b>, a military police officer. Keep the <b>Soldat</b>en in line.</span>"
	H.give_radio()
	H.setStat("strength", STAT_VERY_HIGH)
	H.setStat("engineering", STAT_VERY_LOW)
	H.setStat("rifle", STAT_LOW)
	H.setStat("mg", STAT_LOW)
	H.setStat("pistol", STAT_NORMAL)
	H.setStat("heavyweapon", STAT_NORMAL)
	H.setStat("medical", STAT_VERY_LOW)
	return TRUE

/datum/job/soviet/MP/get_keys()
	return list(new/obj/item/weapon/key/soviet, new/obj/item/weapon/key/soviet/soldat, new/obj/item/weapon/key/soviet/medic, new/obj/item/weapon/key/soviet/engineer,
		new/obj/item/weapon/key/soviet/QM, new/obj/item/weapon/key/soviet/command_intermediate)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/job/soviet/squad_leader
	title = "Starshiy Serzhant"
	en_meaning = "Platoon 2IC"
	rank_abbreviation = "StSr"
	head_position = FALSE
	selection_color = "#770e0e"
	spawn_location = "JoinLateRASL"
	additional_languages = list( "German" = 33 )
	is_officer = TRUE
	is_squad_leader = TRUE
	SL_check_independent = TRUE

	// AUTOBALANCE
	min_positions = 4
	max_positions = 4

/datum/job/soviet/squad_leader/equip(var/mob/living/carbon/human/H)
	if(!H)	return FALSE

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/swat/wrappedboots(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/caphat/sovofficercap(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/sovuni/officer(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/automatic/ppsh(H), slot_belt)
	H.equip_to_slot_or_del(new /obj/item/weapon/attachment/scope/adjustable/binoculars(H), slot_l_hand)
	H.visible_message("<span class = 'notice'>You are the <b>[title]</b>. Your job is to lead offensive units of the Russian force according to the <b>Commandir</b>'s and the <b>Ofitser</b>'s orders.</span>")
	H.give_radio()
	H.setStat("strength", STAT_NORMAL)
	H.setStat("engineering", STAT_LOW)
	H.setStat("rifle", STAT_MEDIUM_LOW)
	H.setStat("mg", STAT_MEDIUM_HIGH)
	H.setStat("pistol", STAT_MEDIUM_LOW)
	H.setStat("heavyweapon", STAT_NORMAL)
	H.setStat("medical", STAT_LOW)
	return TRUE

/datum/job/soviet/squad_leader/get_keys()
	return list(new/obj/item/weapon/key/soviet, new/obj/item/weapon/key/soviet/soldat,
		new/obj/item/weapon/key/soviet/command_intermediate, new/obj/item/weapon/key/soviet/bunker_doors)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/datum/job/soviet/medic
	title = "Sanitar"
	en_meaning = "Medic"
	rank_abbreviation = "Efr"
	selection_color = "#770e0e"
	spawn_location = "JoinLateRA"

	// AUTOBALANCE
	min_positions = 1
	max_positions = 5
	player_threshold = PLAYER_THRESHOLD_LOW
	scale_to_players = PLAYER_THRESHOLD_HIGHEST

/datum/job/soviet/medic/equip(var/mob/living/carbon/human/H)
	if(!H)	return FALSE

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/swat/wrappedboots(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/tactical/sovhelm/medic(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/sovuni(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/boltaction/mosin(H), slot_back)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/soviet(H), slot_l_hand)
	H.equip_to_slot_or_del(new /obj/item/weapon/doctor_handbook(H), slot_l_store)
	H << "<span class = 'notice'>You are the <b>[title]</b>, a medic. Your job is to keep the army healthy and in good condition.</span>"
	H.give_radio()
	H.setStat("strength", STAT_MEDIUM_LOW)
	H.setStat("engineering", STAT_LOW)
	H.setStat("rifle", STAT_MEDIUM_LOW)
	H.setStat("mg", STAT_NORMAL)
	H.setStat("pistol", STAT_NORMAL)
	H.setStat("heavyweapon", STAT_MEDIUM_LOW)
	H.setStat("medical", STAT_MEDIUM_HIGH)
	return TRUE

/datum/job/soviet/medic/get_keys()
	return list(new/obj/item/weapon/key/soviet, new/obj/item/weapon/key/soviet/soldat,
		new/obj/item/weapon/key/soviet/medic)

/datum/job/soviet/doctor
	title = "Doktor"
	en_meaning = "Dr"
	rank_abbreviation = "2lt"
	selection_color = "#770e0e"
	spawn_location = "JoinLateRADr"
	is_nonmilitary = TRUE
	additional_languages = list( "German" = 100, "Ukrainian" = 50 )
	SL_check_independent = TRUE

	// AUTOBALANCE
	min_positions = 1
	max_positions = 3
	scale_to_players = PLAYER_THRESHOLD_HIGHEST

/datum/job/soviet/doctor/equip(var/mob/living/carbon/human/H)
	if(!H)	return FALSE

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/color/white(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/doctor(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_med(H), slot_back)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/latex(H), slot_gloves)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/medical(H), slot_belt)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/toggle/labcoat(H), slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/adv(H), slot_l_hand)
	H.equip_to_slot_or_del(new /obj/item/weapon/doctor_handbook(H), slot_l_store)
	H << "<span class = 'notice'>You are the <b>[title]</b>, a doctor. Your job is to stay back at base and treat wounded that come in from the front, as well as treat prisoners and base personnel.</span>"
	H.give_radio()
	H.setStat("strength", STAT_LOW)
	H.setStat("engineering", STAT_VERY_LOW)
	H.setStat("rifle", STAT_LOW)
	H.setStat("mg", STAT_VERY_LOW)
	H.setStat("pistol", STAT_MEDIUM_LOW)
	H.setStat("heavyweapon", STAT_VERY_LOW)
	H.setStat("medical", STAT_VERY_HIGH)
	return TRUE

/datum/job/soviet/doctor/get_keys()
	return list(new/obj/item/weapon/key/soviet, new/obj/item/weapon/key/soviet/medic)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/datum/job/soviet/sniper
	title = "Snaiper"
	en_meaning = "Sniper"
	rank_abbreviation = "Kras"
	selection_color = "#770e0e"
	spawn_location = "JoinLateRA"

	// AUTOBALANCE
	min_positions = 1
	max_positions = 4
	player_threshold = PLAYER_THRESHOLD_MEDIUM
	scale_to_players = PLAYER_THRESHOLD_HIGHEST

/datum/job/soviet/sniper/equip(var/mob/living/carbon/human/H)
	if(!H)	return FALSE

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/swat/wrappedboots(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/tactical/sovhelm(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/sovuni(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/boltaction/mosin(H), slot_back)
	H.equip_to_slot_or_del(new /obj/item/weapon/attachment/scope/adjustable/sniper_scope(H), slot_r_store)
	H << "<span class = 'notice'>You are the <b>[title]</b>, a sniper. Your job is to assist normal <b>Soldat</b> from behind defenses.</span>"
	H.give_radio()
	H.setStat("strength", STAT_NORMAL)
	H.setStat("engineering", STAT_NORMAL)
	H.setStat("rifle", STAT_VERY_HIGH)
	H.setStat("mg", STAT_NORMAL)
	H.setStat("pistol", STAT_NORMAL)
	H.setStat("heavyweapon", STAT_MEDIUM_LOW)
	H.setStat("medical", STAT_VERY_LOW)
	return TRUE

/datum/job/soviet/sniper/get_keys()
	return list(new/obj/item/weapon/key/soviet, new/obj/item/weapon/key/soviet/soldat)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/datum/job/soviet/engineer
	title = "Boyevoy Saper"
	en_meaning = "Engineer"
	rank_abbreviation = "Efr"
	selection_color = "#770e0e"
	spawn_location = "JoinLateRA"

	// AUTOBALANCE
	min_positions = 1
	max_positions = 4
	player_threshold = PLAYER_THRESHOLD_LOW
	scale_to_players = PLAYER_THRESHOLD_HIGHEST

/datum/job/soviet/engineer/equip(var/mob/living/carbon/human/H)
	if(!H)	return FALSE

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/swat/wrappedboots(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/tactical/sovhelm(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/sovuni(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/boltaction/mosin(H), slot_back)
	H.equip_to_slot_or_del(new /obj/item/weapon/material/knife/combat(H), slot_l_hand)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/industrial(H), slot_r_hand)
	H.equip_to_slot_or_del(new /obj/item/weapon/shovel/spade/russia(H), slot_belt)
	H << "<span class = 'notice'>You are the <b>[title]</b>, an engineer. Your job is to build forward defenses.</span>"
	H.give_radio()
	H.setStat("strength", STAT_MEDIUM_HIGH)
	H.setStat("engineering", STAT_VERY_HIGH)
	H.setStat("rifle", STAT_MEDIUM_LOW)
	H.setStat("mg", STAT_MEDIUM_HIGH)
	H.setStat("pistol", STAT_NORMAL)
	H.setStat("heavyweapon", STAT_MEDIUM_LOW)
	H.setStat("medical", STAT_VERY_LOW)
	return TRUE

/datum/job/soviet/engineer/get_keys()
	return list(new/obj/item/weapon/key/soviet, new/obj/item/weapon/key/soviet/soldat, new/obj/item/weapon/key/soviet/engineer)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/datum/job/soviet/heavy_weapon
	title = "Pulemetchik"
	en_meaning = "Heavy Weapons Operator"
	rank_abbreviation = "Efr"
	selection_color = "#770e0e"
	spawn_location = "JoinLateRA"

	// AUTOBALANCE
	min_positions = 1
	max_positions = 3
	player_threshold = PLAYER_THRESHOLD_LOW
	scale_to_players = PLAYER_THRESHOLD_HIGHEST

/datum/job/soviet/heavy_weapon/equip(var/mob/living/carbon/human/H)
	if(!H)	return FALSE

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/swat/wrappedboots(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/tactical/sovhelm(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/sovuni(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/automatic/dp(H), slot_r_hand)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/soviet(H), slot_back)
	H << "<span class = 'notice'>You are the <b>[title]</b>, a heavy weapons unit. Your job is to assist normal <b>Soldat</b>i in front line combat.</span>"
	H.give_radio()
	H.setStat("strength", STAT_VERY_HIGH)
	H.setStat("engineering", STAT_NORMAL)
	H.setStat("rifle", STAT_MEDIUM_LOW)
	H.setStat("mg", STAT_VERY_HIGH)
	H.setStat("pistol", STAT_NORMAL)
	H.setStat("heavyweapon", STAT_NORMAL) // misleading statname, heavyweapons soldiers are best with MGs
	H.setStat("medical", STAT_LOW)
	return TRUE

/datum/job/soviet/heavy_weapon/get_keys()
	return list(new/obj/item/weapon/key/soviet, new/obj/item/weapon/key/soviet/soldat)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/datum/job/soviet/soldier
	title = "Sovietsky Soldat"
	en_meaning = "Infantry Soldier"
	rank_abbreviation = "Kras"
	selection_color = "#770e0e"
	spawn_location = "JoinLateRA"
	allow_spies = TRUE

	// AUTOBALANCE
	min_positions = 5
	max_positions = 12
	scale_to_players = PLAYER_THRESHOLD_HIGHEST

/datum/job/soviet/soldier/equip(var/mob/living/carbon/human/H)
	if(!H)	return FALSE

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/swat/wrappedboots(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/tactical/sovhelm(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/sovuni(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/soviet_basic/soldier(H), slot_belt)
	H << "<span class = 'notice'>You are the <b>[title]</b>, a normal infantry unit. Your job is to participate in front line combat.</span>"
	H.give_radio()
	H.setStat("strength", STAT_NORMAL)
	H.setStat("engineering", STAT_NORMAL)
	H.setStat("rifle", STAT_NORMAL)
	H.setStat("mg", STAT_NORMAL)
	H.setStat("pistol", STAT_NORMAL)
	H.setStat("heavyweapon", STAT_NORMAL)
	H.setStat("medical", STAT_NORMAL)

	if (prob(8))
		H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/svt(H), slot_back)
	else
		H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/boltaction/mosin(H), slot_back)

	return TRUE

/datum/job/soviet/soldier/get_keys()
	return list(new/obj/item/weapon/key/soviet, new/obj/item/weapon/key/soviet/soldat)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
/datum/job/soviet/dogmaster
	title = "Dressirovshchik"
	en_meaning = "Dog Trainer"
	rank_abbreviation = "MlSr"
	selection_color = "#770e0e"
	spawn_location = "JoinLateRA"
	allow_spies = TRUE

/datum/job/soviet/dogmaster/equip(var/mob/living/carbon/human/H)
	if(!H)	return FALSE

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/swat/wrappedboots(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/tactical/sovhelm(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/sovuni(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/boltaction/mosin(H), slot_back)
	H << "<span class = 'notice'>You are the <b>[title]</b>, the master of the dogs.</span>"
	H << "<span class = 'warning'>See your notes for dog commands.</span>"

	H.add_memory("As a Dressirovshchik, you have access to a number of dog commands. To use them, simply shout! them near a dog which belongs to your faction. These are listed below:")
	H.add_memory("")
	H.add_memory("attack! - attack armed enemies.")
	H.add_memory("kill! - kill armed or unarmed enemies.")
	H.add_memory("guard! - attack enemies who come near us.")
	H.add_memory("patrol! - start patrolling.")
	H.add_memory("stop patrolling! - stop patrolling.")
	H.add_memory("be passive! - only attack in self defense.")
	H.add_memory("stop everything! - stop patrolling and be passive.")
	H.add_memory("follow! - follow me.")
	H.add_memory("stop following! - stop following whoever you're following.")
	H.add_memory("prioritize {following/attacking}! - tells the dog if it should stop following you when it finds a target to attack.")
	H.add_memory("")
	H.add_memory("Some commands overlap. There are three categories of commands: attack modes, patrol modes, and follow modes. Each type of command can be used in tandem with commands of the other types.")
	H.add_memory("")
	H.memory()

	H.give_radio()
	H.setStat("strength", STAT_MEDIUM_LOW)
	H.setStat("engineering", STAT_MEDIUM_LOW)
	H.setStat("rifle", STAT_MEDIUM_LOW)
	H.setStat("mg", STAT_MEDIUM_LOW)
	H.setStat("pistol", STAT_NORMAL)
	H.setStat("heavyweapon", STAT_MEDIUM_LOW)
	H.setStat("medical", STAT_MEDIUM_LOW)
	return TRUE

/datum/job/soviet/dogmaster/get_keys()
	return list(new/obj/item/weapon/key/soviet, new/obj/item/weapon/key/soviet/soldat)
*/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/datum/job/soviet/tankcrew
	title = "Tank-ekipazh"
	en_meaning = "Tank Crewman"
	rank_abbreviation = "Efr"
	selection_color = "#770e0e"
	spawn_location = "JoinLateRA"
	is_tankuser = TRUE

	// AUTOBALANCE
	min_positions = 2
	max_positions = 2
	player_threshold = PLAYER_THRESHOLD_MEDIUM

/datum/job/soviet/tankcrew/equip(var/mob/living/carbon/human/H)
	if(!H)	return FALSE

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/swat/wrappedboots(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/caphat/sovtankerhat(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/sovuni/sovtankeruni(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/automatic/ppsh(H), slot_back)
	H << "<span class = 'notice'>You are the <b>[title]</b>, a tank crewman. Your job is to work with another crewman to operate a tank.</span>"
	H.give_radio()
	H.setStat("strength", STAT_VERY_HIGH)
	H.setStat("engineering", STAT_MEDIUM_HIGH)
	H.setStat("rifle", STAT_MEDIUM_LOW)
	H.setStat("mg", STAT_MEDIUM_HIGH)
	H.setStat("pistol", STAT_NORMAL)
	H.setStat("heavyweapon", STAT_MEDIUM_LOW)
	H.setStat("medical", STAT_MEDIUM_LOW)
	return TRUE

/datum/job/soviet/tankcrew/get_keys()
	return list(new/obj/item/weapon/key/soviet, new/obj/item/weapon/key/soviet/soldat, new/obj/item/weapon/key/soviet/command_intermediate)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/datum/job/soviet/anti_tank_crew
	title = "Protivotankovyy Soldat"
	en_meaning = "Anti-Tank Trooper"
	rank_abbreviation = "Kras"
	selection_color = "#770e0e"
	spawn_location = "JoinLateRA"

	// AUTOBALANCE
	min_positions = 2
	max_positions = 2
	player_threshold = PLAYER_THRESHOLD_MEDIUM

/datum/job/soviet/anti_tank_crew/equip(var/mob/living/carbon/human/H)
	if(!H)	return FALSE

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/swat/wrappedboots(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/sovuni(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/tactical/sovhelm(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/heavysniper/ptrd(H), slot_back)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/soviet/anti_tank_crew(H), slot_belt)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/pistol/tokarev(H), slot_r_store)
	H << "<span class = 'notice'>You are the <b>[title]</b>, an anti-tank infantry unit. Your job is to destroy enemy tanks.</span>"
	H.give_radio()
	H.setStat("strength", STAT_NORMAL)
	H.setStat("engineering", STAT_NORMAL)
	H.setStat("rifle", STAT_NORMAL)
	H.setStat("mg", STAT_NORMAL)
	H.setStat("pistol", STAT_NORMAL)
	H.setStat("heavyweapon", STAT_VERY_HIGH)
	H.setStat("medical", STAT_NORMAL)
	return TRUE

/datum/job/soviet/anti_tank_crew/get_keys()
	return list(new/obj/item/weapon/key/soviet, new/obj/item/weapon/key/soviet/soldat)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/datum/job/soviet/guard
	title = "Gvardeyec"
	en_meaning = "Guard"
	rank_abbreviation = "Kras"
	selection_color = "#a8b800"
	spawn_location = "JoinLateRA"
	additional_languages = list( "German" = 100 )
	is_guard = TRUE

	// AUTOBALANCE
	min_positions = 1
	max_positions = 3
	player_threshold = PLAYER_THRESHOLD_LOW
	scale_to_players = PLAYER_THRESHOLD_HIGHEST

var/first_guard = FALSE
/datum/job/soviet/guard/equip(var/mob/living/carbon/human/H)
	if(!H)	return FALSE

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/swat/wrappedboots(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/ushanka(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/sovuni(H), slot_w_uniform)
	if(first_guard)
		H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/heavysniper/ptrd(H), slot_back)
		var/obj/item/weapon/storage/belt/security/tactical/belt = new(H)
		new /obj/item/ammo_casing/a145(belt)
		new /obj/item/ammo_casing/a145(belt)
		new /obj/item/ammo_casing/a145(belt)
		new /obj/item/ammo_casing/a145(belt)
		new /obj/item/ammo_casing/a145(belt)
		new /obj/item/ammo_casing/a145(belt)
		H.equip_to_slot_or_del(belt, slot_belt)
	else
		H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/svt(H), slot_back)
		var/obj/item/weapon/storage/belt/security/tactical/belt = new(H)
		new /obj/item/ammo_magazine/mosin(belt)
		new /obj/item/ammo_magazine/mosin(belt)
		new /obj/item/ammo_magazine/mosin(belt)
		new /obj/item/ammo_magazine/mosin(belt)
		new /obj/item/ammo_magazine/mosin(belt)
		new /obj/item/ammo_magazine/mosin(belt)
		H.equip_to_slot_or_del(belt, slot_belt)
	H << "<span class = 'notice'>You are the <b>[title]</b>, a guard. Your job is to operate the minigun.</span>"
	H.give_radio()
	H.setStat("strength", STAT_VERY_HIGH)
	H.setStat("engineering", STAT_NORMAL)
	H.setStat("rifle", STAT_VERY_HIGH)
	H.setStat("mg", STAT_NORMAL)
	H.setStat("pistol", STAT_NORMAL)
	H.setStat("heavyweapon", STAT_NORMAL)
	H.setStat("medical", STAT_NORMAL)
	return TRUE

/datum/job/soviet/guard/get_keys()
	return list(new/obj/item/weapon/key/soviet, new/obj/item/weapon/key/soviet/soldat, new/obj/item/weapon/key/soviet/bunker_doors)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/datum/job/soviet/QM
	title = "Zavhoz"
	en_meaning = "Quartermaster"
	rank_abbreviation = "Srg"
	selection_color = "#a8b800"
	spawn_location = "JoinLateRAQM"
	additional_languages = list( "German" = 100 )
	is_officer = TRUE
	SL_check_independent = TRUE

	// AUTOBALANCE
	min_positions = 1
	max_positions = 1
	player_threshold = PLAYER_THRESHOLD_LOW

/datum/job/soviet/QM/equip(var/mob/living/carbon/human/H)
	if(!H)	return FALSE

	H.equip_to_slot_or_del(new /obj/item/clothing/under/sovuni/officer(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/swat/wrappedboots(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/boltaction/mosin(H), slot_back)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/caphat/sovcap/fieldcap(H), slot_head)
	H << "<span class = 'notice'>You are the <b>[title]</b>, a Quartermaster. Your job is to keep the army well armed and supplied.</span>"
	H.give_radio()
	H.setStat("strength", STAT_MEDIUM_HIGH)
	H.setStat("engineering", STAT_LOW)
	H.setStat("rifle", STAT_MEDIUM_LOW)
	H.setStat("mg", STAT_NORMAL)
	H.setStat("pistol", STAT_NORMAL)
	H.setStat("heavyweapon", STAT_VERY_LOW)
	H.setStat("medical", STAT_VERY_LOW)
	return TRUE

/datum/job/soviet/QM/get_keys()
	return list(new/obj/item/weapon/key/soviet, new/obj/item/weapon/key/soviet/soldat,  new/obj/item/weapon/key/soviet/QM, new/obj/item/weapon/key/soviet/bunker_doors, new/obj/item/weapon/key/soviet/command_intermediate, new/obj/item/weapon/key/soviet/engineer)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/datum/job/soviet/sturmovik
	title = "Sturmovik"
	en_meaning = "Shock Trooper"
	rank_abbreviation = "Kras"
	selection_color = "#770e0e"
	spawn_location = "JoinLateRA"
	is_sturmovik = TRUE

	// AUTOBALANCE
	min_positions = 1
	max_positions = 5
	player_threshold = PLAYER_THRESHOLD_LOW
	scale_to_players = PLAYER_THRESHOLD_HIGHEST

/datum/job/soviet/sturmovik/equip(var/mob/living/carbon/human/H)
	if(!H)	return FALSE

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/swat/wrappedboots(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/tactical/sovhelm(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/sovuni(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/automatic/ppsh(H), slot_back)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/bulletproof/cn42(H), slot_wear_suit)
	H << "<span class = 'notice'>You are the <b>[title]</b>, an elite infantry soldier. Your job is assist normal <b>Soldat</b>i in front line combat.</span>"
	H.give_radio()

	H.stamina *= 1.5
	H.max_stamina *= 1.5

	// glorious sturmovik stats
	H.setStat("strength", STAT_VERY_HIGH)
	H.setStat("engineering", STAT_MEDIUM_HIGH)
	H.setStat("rifle", STAT_VERY_HIGH)
	H.setStat("mg", STAT_MEDIUM_HIGH)
	H.setStat("pistol", STAT_VERY_HIGH)
	H.setStat("heavyweapon", STAT_MEDIUM_HIGH)
	H.setStat("medical", STAT_LOW)
	return TRUE

/datum/job/soviet/sturmovik/get_keys()
	return list(new/obj/item/weapon/key/soviet, new/obj/item/weapon/key/soviet/soldat)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/datum/job/soviet/chef
	title = "Povar"
	en_meaning = "Chef"
	rank_abbreviation = "Pov"
	selection_color = "#770e0e"
	spawn_location = "JoinLateRAChef"
	allow_spies = TRUE
	is_nonmilitary = TRUE
	SL_check_independent = TRUE

	// AUTOBALANCE
	min_positions = 1
	max_positions = 1

/datum/job/soviet/chef/equip(var/mob/living/carbon/human/H)
	if(!H)	return FALSE

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/swat/wrappedboots(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/tactical/sovhelm(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/sovuni(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/chef/classic(H), slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/boltaction/mosin(H), slot_back)
	H << "<span class = 'notice'>You are the <b>[title]</b>, a front chef. Your job is to keep the Red Army well fed.</span>"
	H.give_radio()
	H.setStat("strength", STAT_MEDIUM_LOW)
	H.setStat("engineering", STAT_MEDIUM_LOW)
	H.setStat("rifle", STAT_MEDIUM_LOW)
	H.setStat("mg", STAT_MEDIUM_LOW)
	H.setStat("pistol", STAT_NORMAL)
	H.setStat("heavyweapon", STAT_VERY_LOW)
	H.setStat("medical", STAT_MEDIUM_LOW)
	return TRUE

/datum/job/soviet/chef/get_keys()
	return list(new/obj/item/weapon/key/soviet, new/obj/item/weapon/key/soviet/soldat)
