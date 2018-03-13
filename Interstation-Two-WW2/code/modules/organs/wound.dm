
// 2017-07-08: 	Modified infection check proc to add a boolean proc to check if
//							wound can be infected -- Irra

/****************************************************
					WOUNDS
****************************************************/
/datum/wound
	// number representing the current stage
	var/current_stage = FALSE

	// description of the wound
	var/desc = "wound" //default in case something borks

	// amount of damage this wound causes
	var/damage = FALSE
	// ticks of bleeding left.
	var/bleed_timer = FALSE
	// amount of damage the current wound type requires(less means we need to apply the next healing stage)
	var/min_damage = FALSE

	// is the wound bandaged?
	var/bandaged = FALSE
	// Similar to bandaged, but works differently
	var/clamped = FALSE
	// is the wound salved?
	var/salved = FALSE
	// is the wound disinfected?
	var/disinfected = FALSE
	var/created = FALSE
	// number of wounds of this type
	var/amount = TRUE
	// amount of germs in the wound
	var/germ_level = FALSE

	/*  These are defined by the wound type and should not be changed */

	// stages such as "cut", "deep cut", etc.
	var/list/stages
	// internal wounds can only be fixed through surgery
	var/internal = FALSE
	// maximum stage at which bleeding should still happen. Beyond this stage bleeding is prevented.
	var/max_bleeding_stage = FALSE
	// one of CUT, PIERCE, BRUISE, BURN
	var/damage_type = CUT
	// whether this wound needs a bandage/salve to heal at all
	// the maximum amount of damage that this wound can have and still autoheal
	var/autoheal_cutoff = 15




	// helper lists
	var/tmp/list/desc_list = list()
	var/tmp/list/damage_list = list()

	New(var/_damage)

		created = world.time

		// reading from a list("stage" = damage) is pretty difficult, so build two separate
		// lists from them instead
		for(var/V in stages)
			desc_list += V
			damage_list += stages[V]

		damage = _damage

		// initialize with the appropriate stage
		init_stage(_damage)

		bleed_timer += _damage

	// returns TRUE if there's a next stage, FALSE otherwise
	proc/init_stage(var/initial_damage)
		current_stage = stages.len

		while(current_stage > 1 && damage_list[current_stage-1] <= initial_damage / amount)
			current_stage--

		min_damage = damage_list[current_stage]
		desc = desc_list[current_stage]

	// the amount of damage per wound
	proc/wound_damage()
		return damage / amount

	proc/can_autoheal()
		if(wound_damage() <= autoheal_cutoff)
			return TRUE

		return is_treated()

	// checks whether the wound has been appropriately treated
	proc/is_treated()
		if(damage_type == BRUISE || damage_type == CUT)
			return bandaged
		else if(damage_type == BURN)
			return salved

	// Checks whether other other can be merged into
	proc/can_merge(var/datum/wound/other)
		if (other.type != type) return FALSE
		if (other.current_stage != current_stage) return FALSE
		if (other.damage_type != damage_type) return FALSE
		if (!(other.can_autoheal()) != !(can_autoheal())) return FALSE
		if (!(other.bandaged) != !(bandaged)) return FALSE
		if (!(other.clamped) != !(clamped)) return FALSE
		if (!(other.salved) != !(salved)) return FALSE
		if (!(other.disinfected) != !(disinfected)) return FALSE
		//if (other.germ_level != germ_level) return FALSE
		return TRUE

	proc/merge_wound(var/datum/wound/other)
		damage += other.damage
		amount += other.amount
		bleed_timer += other.bleed_timer
		germ_level = max(germ_level, other.germ_level)
		created = max(created, other.created)	//take the newer created time

	// proc for checking whether the wound is considered open enough for infections
	// this is not the proc that instantizes an infection in a wound - use infection_check() instead!
	proc/can_be_infected()
		if (damage < 10)	//small cuts, tiny bruises, and moderate burns shouldn't be infectable.
			return FALSE
		if (is_treated() && damage < 25)	//anything less than a flesh wound (or equivalent) isn't infectable if treated properly
			return FALSE
		if (disinfected)
			germ_level = FALSE	//reset this, just in case
			return FALSE

		if (damage_type == BRUISE && !bleeding()) //bruises only infectable if bleeding
			return FALSE

		return TRUE

	// checks if wound is considered open for external infections
	// untreated cuts (and bleeding bruises) and burns are possibly infectable, chance higher if wound is bigger
	proc/infection_check()
		if (can_be_infected())
			var/dam_coef = round(damage/10)
			switch (damage_type)
				if (BRUISE)
					return prob(dam_coef*5)
				if (BURN)
					return prob(dam_coef*10)
				if (CUT)
					return prob(dam_coef*20)

		return FALSE

	proc/bandage()
		bandaged = TRUE

	proc/salve()
		salved = TRUE

	proc/disinfect()
		disinfected = TRUE

	// heal the given amount of damage, and if the given amount of damage was more
	// than what needed to be healed, return how much heal was left
	// set @heals_internal to also heal internal organ damage
	proc/heal_damage(amount, heals_internal = FALSE)
		if(internal && !heals_internal)
			// heal nothing
			return amount

		var/healed_damage = min(damage, amount)
		amount -= healed_damage
		damage -= healed_damage

		while(wound_damage() < damage_list[current_stage] && current_stage < desc_list.len)
			current_stage++
		desc = desc_list[current_stage]
		min_damage = damage_list[current_stage]

		// return amount of healing still leftover, can be used for other wounds
		return amount

	// opens the wound again
	proc/open_wound(_damage)
		damage += _damage
		bleed_timer += _damage

		while(current_stage > 1 && damage_list[current_stage-1] <= damage / amount)
			current_stage--

		desc = desc_list[current_stage]
		min_damage = damage_list[current_stage]

	// returns whether this wound can absorb the given amount of damage.
	// this will prevent large amounts of damage being trapped in less severe wound types
	proc/can_worsen(_damage_type, _damage)
		if (damage_type != _damage_type)
			return FALSE	//incompatible damage types

		if (amount > 1)
			return FALSE

		//with 1.5*, a shallow cut will be able to carry at most 30 damage,
		//37.5 for a deep cut
		//52.5 for a flesh wound, etc.
		var/max_wound_damage = 1.5*damage_list[1]
		if (damage + _damage > max_wound_damage)
			return FALSE

		return TRUE

	proc/bleeding()
		if (internal)
			return FALSE	// internal wounds don't bleed in the sense of this function

		if (current_stage > max_bleeding_stage)
			return FALSE

		if (bandaged||clamped)
			return FALSE

		if (wound_damage() <= 30 && bleed_timer <= FALSE)
			return FALSE	//Bleed timer has run out. Wounds with more than 30 damage don't stop bleeding on their own.

		return TRUE

/** WOUND DEFINITIONS **/

//Note that the MINIMUM damage before a wound can be applied should correspond to
//the damage amount for the stage with the same name as the wound.
//e.g. /datum/wound/cut/deep should only be applied for 15 damage and up,
//because in it's stages list, "deep cut" = 15.
/proc/get_wound_type(var/type = CUT, var/damage)
	switch(type)
		if(CUT)
			switch(damage)
				if(70 to INFINITY)
					return /datum/wound/cut/massive
				if(60 to 70)
					return /datum/wound/cut/gaping_big
				if(50 to 60)
					return /datum/wound/cut/gaping
				if(25 to 50)
					return /datum/wound/cut/flesh
				if(15 to 25)
					return /datum/wound/cut/deep
				if(0 to 15)
					return /datum/wound/cut/small
		if(PIERCE)
			switch(damage)
				if(60 to INFINITY)
					return /datum/wound/puncture/massive
				if(50 to 60)
					return /datum/wound/puncture/gaping_big
				if(30 to 50)
					return /datum/wound/puncture/gaping
				if(15 to 30)
					return /datum/wound/puncture/flesh
				if(0 to 15)
					return /datum/wound/puncture/small
		if(BRUISE)
			return /datum/wound/bruise
		if(BURN)
			switch(damage)
				if(50 to INFINITY)
					return /datum/wound/burn/carbonised
				if(40 to 50)
					return /datum/wound/burn/deep
				if(30 to 40)
					return /datum/wound/burn/severe
				if(15 to 30)
					return /datum/wound/burn/large
				if(0 to 15)
					return /datum/wound/burn/moderate
	return null //no wound

/** CUTS **/
/datum/wound/cut/bleeding()
	return ..() && wound_damage() >= 5

/datum/wound/cut/small
	// link wound descriptions to amounts of damage
	// Minor cuts have max_bleeding_stage set to the stage that bears the wound type's name.
	// The major cut types have the max_bleeding_stage set to the clot stage (which is accordingly given the "blood soaked" descriptor).
	max_bleeding_stage = 3
	stages = list("ugly ripped cut" = 20, "ripped cut" = 10, "cut" = 5, "healing cut" = 2, "small scab" = FALSE)
	damage_type = CUT

/datum/wound/cut/deep
	max_bleeding_stage = 3
	stages = list("ugly deep ripped cut" = 25, "deep ripped cut" = 20, "deep cut" = 15, "clotted cut" = 8, "scab" = 2, "fresh skin" = FALSE)
	damage_type = CUT

/datum/wound/cut/flesh
	max_bleeding_stage = 4
	stages = list("ugly ripped flesh wound" = 35, "ugly flesh wound" = 30, "flesh wound" = 25, "blood soaked clot" = 15, "large scab" = 5, "fresh skin" = FALSE)
	damage_type = CUT

/datum/wound/cut/gaping
	max_bleeding_stage = 3
	stages = list("gaping wound" = 50, "large blood soaked clot" = 25, "blood soaked clot" = 15, "small angry scar" = 5, "small straight scar" = FALSE)
	damage_type = CUT

/datum/wound/cut/gaping_big
	max_bleeding_stage = 3
	stages = list("big gaping wound" = 60, "healing gaping wound" = 40, "large blood soaked clot" = 25, "large angry scar" = 10, "large straight scar" = FALSE)
	damage_type = CUT

datum/wound/cut/massive
	max_bleeding_stage = 3
	stages = list("massive wound" = 70, "massive healing wound" = 50, "massive blood soaked clot" = 25, "massive angry scar" = 10,  "massive jagged scar" = FALSE)
	damage_type = CUT

/** PUNCTURES **/
/datum/wound/puncture/can_worsen(damage_type, damage)
	return FALSE
/datum/wound/puncture/can_merge(var/datum/wound/other)
	return FALSE
/datum/wound/puncture/bleeding()
	return ..() && wound_damage() >= 5

/datum/wound/puncture/small
	max_bleeding_stage = 2
	stages = list("puncture" = 5, "healing puncture" = 2, "small scab" = FALSE)
	damage_type = PIERCE

/datum/wound/puncture/flesh
	max_bleeding_stage = 2
	stages = list("puncture wound" = 15, "blood soaked clot" = 5, "large scab" = 2, "small round scar" = FALSE)
	damage_type = PIERCE

/datum/wound/puncture/gaping
	max_bleeding_stage = 3
	stages = list("gaping hole" = 30, "large blood soaked clot" = 15, "blood soaked clot" = 10, "small angry scar" = 5, "small round scar" = FALSE)
	damage_type = PIERCE

/datum/wound/puncture/gaping_big
	max_bleeding_stage = 3
	stages = list("big gaping hole" = 50, "healing gaping hole" = 20, "large blood soaked clot" = 15, "large angry scar" = 10, "large round scar" = FALSE)
	damage_type = PIERCE

datum/wound/puncture/massive
	max_bleeding_stage = 3
	stages = list("massive wound" = 60, "massive healing wound" = 30, "massive blood soaked clot" = 25, "massive angry scar" = 10,  "massive jagged scar" = FALSE)
	damage_type = PIERCE

/** BRUISES **/
/datum/wound/bruise/bleeding()
	return ..() && wound_damage() >= 20

/datum/wound/bruise
	stages = list("monumental bruise" = 80, "huge bruise" = 50, "large bruise" = 30,
				  "moderate bruise" = 20, "small bruise" = 10, "tiny bruise" = 5)
	max_bleeding_stage = 3 //only large bruise and above can bleed.
	autoheal_cutoff = 30
	damage_type = BRUISE

/** BURNS **/
/datum/wound/burn
	max_bleeding_stage = FALSE
/datum/wound/burn/bleeding()
	return FALSE

/datum/wound/burn/moderate
	stages = list("ripped burn" = 10, "moderate burn" = 5, "healing moderate burn" = 2, "fresh skin" = FALSE)
	damage_type = BURN

/datum/wound/burn/large
	stages = list("ripped large burn" = 20, "large burn" = 15, "healing large burn" = 5, "fresh skin" = FALSE)
	damage_type = BURN

/datum/wound/burn/severe
	stages = list("ripped severe burn" = 35, "severe burn" = 30, "healing severe burn" = 10, "burn scar" = FALSE)
	damage_type = BURN

/datum/wound/burn/deep
	stages = list("ripped deep burn" = 45, "deep burn" = 40, "healing deep burn" = 15,  "large burn scar" = FALSE)
	damage_type = BURN

/datum/wound/burn/carbonised
	stages = list("carbonised area" = 50, "healing carbonised area" = 20, "massive burn scar" = FALSE)
	damage_type = BURN

/** INTERNAL BLEEDING **/
/datum/wound/internal_bleeding
	internal = TRUE
	stages = list("severed artery" = 30, "cut artery" = 20, "damaged artery" = 10, "bruised artery" = 5)
	autoheal_cutoff = 5
	max_bleeding_stage = 4	//all stages bleed. It's called internal bleeding after all.

/** EXTERNAL ORGAN LOSS **/
/datum/wound/lost_limb

/datum/wound/lost_limb/New(var/obj/item/organ/external/lost_limb, var/losstype, var/clean)
	var/damage_amt = lost_limb.max_damage
	if(clean) damage_amt /= 2

	switch(losstype)
		if(DROPLIMB_EDGE, DROPLIMB_BLUNT)
			damage_type = CUT
			max_bleeding_stage = 3 //clotted stump and above can bleed.
			stages = list(
				"ripped stump" = damage_amt*1.3,
				"bloody stump" = damage_amt,
				"clotted stump" = damage_amt*0.5,
				"scarred stump" = FALSE
				)
		if(DROPLIMB_BURN)
			damage_type = BURN
			stages = list(
				"ripped charred stump" = damage_amt*1.3,
				"charred stump" = damage_amt,
				"scarred stump" = damage_amt*0.5,
				"scarred stump" = FALSE
				)

	..(damage_amt)

/datum/wound/lost_limb/can_merge(var/datum/wound/other)
	return FALSE //cannot be merged
