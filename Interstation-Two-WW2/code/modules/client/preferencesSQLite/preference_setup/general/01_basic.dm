/datum/preferences
	var/identifying_gender = MALE

/datum/category_item/player_setup_item/general/basic
	name = "Basic"
	sort_order = TRUE
	var/list/valid_player_genders = list(MALE, FEMALE)

datum/preferences/proc/set_biological_gender(var/set_gender)
	gender = set_gender
	identifying_gender = set_gender
/*
/datum/category_item/player_setup_item/general/basic/load_character()
	// real names
	S["real_name"]				>> pref.real_name
	S["name_is_always_random"]	>> pref.be_random_name

	// german names
	S["german_name"]				>> pref.german_name
	S["german_name_is_always_random"]	>> pref.be_random_name_german

	// russian names
	S["russian_name"]				>> pref.russian_name
	S["russian_name_is_always_random"]	>> pref.be_random_name_russian

	// ukrainian names
	S["ukrainian_name"]				>> pref.ukrainian_name
	S["ukrainian_name_is_always_random"]	>> pref.be_random_name_ukrainian


	S["gender"]					>> pref.gender

	S["be_spy"] >> pref.be_spy
	S["be_jew"] >> pref.be_jew

	// factional genders
	S["german_gender"] >> pref.german_gender
	S["russian_gender"] >> pref.russian_gender
	S["ukrainian_gender"] >> pref.ukrainian_gender

	// donor stuff
	S["role_preference_sov"] >> pref.client.role_preference_sov
	S["role_preference_ger"] >> pref.client.role_preference_ger

	S["body_build"]				>> pref.body_build
	S["age"]					>> pref.age
	S["spawnpoint"]				>> pref.spawnpoint
	S["OOC_Notes"]				>> pref.metadata

/datum/category_item/player_setup_item/general/basic/save_character()
	// real names
	S["real_name"]				<< pref.real_name
	S["name_is_always_random"]	<< pref.be_random_name

	// german names
	S["german_name"]				<< pref.german_name
	S["german_name_is_always_random"]	<< pref.be_random_name_german

	// russian names
	S["russian_name"]				<< pref.russian_name
	S["russian_name_is_always_random"]	<< pref.be_random_name_russian

	// ukrainian names
	S["ukrainian_name"]				<< pref.ukrainian_name
	S["ukrainian_name_is_always_random"]	<< pref.be_random_name_ukrainian

	S["gender"]					<< pref.gender

	S["be_spy"] << pref.be_spy
	S["be_jew"] << pref.be_jew

	// factional genders
	S["german_gender"] << pref.german_gender
	S["russian_gender"] << pref.russian_gender
	S["ukrainian_gender"] << pref.ukrainian_gender

	// donor stuff
	S["role_preference_sov"] << pref.client.role_preference_sov
	S["role_preference_ger"] << pref.client.role_preference_ger

	S["body_build"]				<< pref.body_build
	S["age"]					<< pref.age
	S["spawnpoint"]				<< pref.spawnpoint
	S["OOC_Notes"]				<< pref.metadata
*/
/datum/category_item/player_setup_item/general/basic/sanitize_character()

	var/datum/species/S = all_species[pref.species ? pref.species : "Human"]
	pref.age			= sanitize_integer(pref.age, S.min_age, S.max_age, initial(pref.age))
	pref.gender 		= sanitize_inlist(pref.gender, valid_player_genders, pick(valid_player_genders))
	pref.german_gender 		= sanitize_inlist(pref.german_gender, valid_player_genders, pick(valid_player_genders))
	pref.russian_gender 		= sanitize_inlist(pref.russian_gender, valid_player_genders, pick(valid_player_genders))
	pref.ukrainian_gender 		= sanitize_inlist(pref.ukrainian_gender, valid_player_genders, pick(valid_player_genders))
//	pref.be_jew 		= sanitize_inlist(pref.be_jew, list(0,1), pick(list(0,1)))
//	pref.be_spy 		= sanitize_inlist(pref.be_spy, list(0,1), pick(list(0,1)))
	pref.body_build 	= sanitize_inlist(pref.body_build, list("Slim", "Default", "Fat"), "Default")
	pref.identifying_gender = (pref.identifying_gender in all_genders_define_list) ? pref.identifying_gender : pref.gender
	pref.real_name		= sanitize_name(pref.real_name, pref.species)

	if(!pref.real_name)
		pref.real_name	= random_name(pref.gender, pref.species)

	/* start setting up german, russian names*/

	pref.german_name		= sanitize_name(pref.german_name, pref.species)

	if(!pref.german_name)
		pref.german_name	= random_german_name(pref.german_gender, pref.species)

	pref.russian_name		= sanitize_name(pref.russian_name, pref.species)
	if(!pref.russian_name)
		pref.russian_name	= random_russian_name(pref.russian_gender, pref.species)

	pref.ukrainian_name		= sanitize_name(pref.ukrainian_name, pref.species)
	if(!pref.ukrainian_name)
		pref.ukrainian_name	= random_ukrainian_name(pref.ukrainian_gender, pref.species)

	/*										*/

//	pref.spawnpoint		= sanitize_inlist(pref.spawnpoint, spawntypes, initial(pref.spawnpoint))
	pref.be_random_name	= sanitize_integer(pref.be_random_name, FALSE, TRUE, initial(pref.be_random_name))
	pref.be_random_name_german	= sanitize_integer(pref.be_random_name_german, FALSE, TRUE, initial(pref.be_random_name_german))
	pref.be_random_name_russian	= sanitize_integer(pref.be_random_name_russian, FALSE, TRUE, initial(pref.be_random_name_russian))
	pref.be_random_name_ukrainian	= sanitize_integer(pref.be_random_name_ukrainian, FALSE, TRUE, initial(pref.be_random_name_ukrainian))

/datum/category_item/player_setup_item/general/basic/content()
	//name
	. = "<b>Name:</b> "
	. += "<a href='?src=\ref[src];rename=1'><b>[pref.real_name]</b></a><br>"
	. += "(<a href='?src=\ref[src];random_name=1'>Random Name</A>) "
	. += "(<a href='?src=\ref[src];always_random_name=1'>Always Random Name: [pref.be_random_name ? "Yes" : "No"]</a>)"
	. += "<br><br>"
	//german name
	. += "<b>German Name:</b> "
	. += "<a href='?src=\ref[src];rename_german=1'><b>[pref.german_name]</b></a><br>"
	. += "(<a href='?src=\ref[src];random_name_german=1'>Random Name</A>) "
	. += "(<a href='?src=\ref[src];always_random_name_german=1'>Always Random Name: [pref.be_random_name_german ? "Yes" : "No"]</a>)"
	. += "<br><br>"
	//russian name
	. += "<b>Russian Name:</b> "
	. += "<a href='?src=\ref[src];rename_russian=1'><b>[pref.russian_name]</b></a><br>"
	. += "(<a href='?src=\ref[src];random_name_russian=1'>Random Name</A>) "
	. += "(<a href='?src=\ref[src];always_random_name_russian=1'>Always Random Name: [pref.be_random_name_russian ? "Yes" : "No"]</a>)"
	. += "<br><br>"
	//ukrainian name
	. += "<b>Ukrainian Name:</b> "
	. += "<a href='?src=\ref[src];rename_ukrainian=1'><b>[pref.ukrainian_name]</b></a><br>"
	. += "(<a href='?src=\ref[src];random_name_ukrainian=1'>Random Name</A>) "
	. += "(<a href='?src=\ref[src];always_random_name_ukrainian=1'>Always Random Name: [pref.be_random_name_ukrainian ? "Yes" : "No"]</a>)"
	. += "<br><br>"
	//gender
	. += "<b>Gender:</b> <a href='?src=\ref[src];gender=1'><b>[capitalize(lowertext(pref.gender))]</b></a><br>"
	. += "<br><br>"
	. += "<b>German Gender:</b> <a href='?src=\ref[src];gender_german=1'><b>[capitalize(lowertext(pref.german_gender))]</b></a><br>"
	. += "<br>"
	. += "<b>Russian Gender:</b> <a href='?src=\ref[src];gender_russian=1'><b>[capitalize(lowertext(pref.russian_gender))]</b></a><br>"
	. += "<br>"
	. += "<b>Ukrainian Gender:</b> <a href='?src=\ref[src];gender_ukrainian=1'><b>[capitalize(lowertext(pref.ukrainian_gender))]</b></a><br>"
	. += "<br><br>"

//	var/client/client = pref.client

	//. += "<b>Body Shape:</b> <a href='?src=\ref[src];body_build=1'><b>[pref.body_build]</b></a><br>" No. No no no no no no.
	. += "<b>Age:</b> <a href='?src=\ref[src];age=1'>[pref.age]</a><br>"

/datum/category_item/player_setup_item/general/basic/OnTopic(var/href,var/list/href_list, var/mob/user)

	//real names
	if(href_list["rename"])
		var/raw_name = input(user, "Choose your character's name:", "Character Name")  as text|null
		if (!isnull(raw_name) && CanUseTopic(user))
			var/new_name = sanitize_name(raw_name, pref.species)
			if(new_name)
				pref.real_name = new_name
				return TOPIC_REFRESH
			else
				user << "<span class='warning'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</span>"
				return TOPIC_NOACTION

	else if(href_list["random_name"])
		pref.real_name = random_name(pref.gender, pref.species)
		return TOPIC_REFRESH

	else if(href_list["always_random_name"])
		pref.be_random_name = !pref.be_random_name
		return TOPIC_REFRESH

	//german names
	if(href_list["rename_german"])
		var/raw_name = input(user, "Choose your character's German name:", "Character Name")  as text|null
		if (!isnull(raw_name) && CanUseTopic(user))
			var/new_name = sanitize_name(raw_name, pref.species)
			if(new_name)
				pref.german_name = new_name
				return TOPIC_REFRESH
			else
				user << "<span class='warning'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</span>"
				return TOPIC_NOACTION

	else if(href_list["random_name_german"])
		pref.german_name = random_german_name(pref.german_gender, pref.species)
		return TOPIC_REFRESH

	else if(href_list["always_random_name_german"])
		pref.be_random_name_german = !pref.be_random_name_german
		return TOPIC_REFRESH

	//russian names
	if(href_list["rename_russian"])
		var/raw_name = input(user, "Choose your character's Russian name:", "Character Name")  as text|null
		if (!isnull(raw_name) && CanUseTopic(user))
			var/new_name = sanitize_name(raw_name, pref.species)
			if(new_name)
				pref.russian_name = new_name
				return TOPIC_REFRESH
			else
				user << "<span class='warning'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</span>"
				return TOPIC_NOACTION

	else if(href_list["random_name_russian"])
		pref.russian_name = random_russian_name(pref.russian_gender, pref.species)
		return TOPIC_REFRESH

	else if(href_list["always_random_name_russian"])
		pref.be_random_name_russian = !pref.be_random_name_russian
		return TOPIC_REFRESH

	//ukrainian names
	if(href_list["rename_ukrainian"])
		var/raw_name = input(user, "Choose your character's UKRAINIAN/CIVILIAN name:", "Character Name")  as text|null
		if (!isnull(raw_name) && CanUseTopic(user))
			var/new_name = sanitize_name(raw_name, pref.species)
			if(new_name)
				pref.ukrainian_name = new_name
				return TOPIC_REFRESH
			else
				user << "<span class='warning'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</span>"
				return TOPIC_NOACTION

	else if(href_list["random_name_ukrainian"])
		pref.ukrainian_name = random_ukrainian_name(pref.ukrainian_gender, pref.species)
		return TOPIC_REFRESH

	else if(href_list["always_random_name_ukrainian"])
		pref.be_random_name_ukrainian = !pref.be_random_name_ukrainian
		return TOPIC_REFRESH

	else if(href_list["gender"])
		pref.gender = next_in_list(pref.gender, valid_player_genders)
		return TOPIC_REFRESH

	else if(href_list["gender_german"])
	//	var/next_gender = next_in_list(pref.german_gender, valid_player_genders)
/*		if (next_gender == FEMALE)
			user << "<span class = 'danger'>Germans can't be female.</span>"
			return*/
		pref.german_gender = next_in_list(pref.german_gender, valid_player_genders)
		return TOPIC_REFRESH

	else if(href_list["gender_russian"])
		pref.russian_gender = next_in_list(pref.russian_gender, valid_player_genders)
		return TOPIC_REFRESH

	else if(href_list["gender_ukrainian"])
		pref.ukrainian_gender = next_in_list(pref.ukrainian_gender, valid_player_genders)
		return TOPIC_REFRESH

	else if(href_list["body_build"])
		pref.body_build = input("Body Shape", "Body") in list("Default", "Slim", "Fat")
		return TOPIC_REFRESH

	else if(href_list["age"])
		var/datum/species/S = all_species[pref.species]
		var/new_age = input(user, "Choose your character's age:\n([S.min_age]-[S.max_age])", "Character Preference", pref.age) as num|null
		if(new_age && CanUseTopic(user))
			pref.age = max(min(round(text2num(new_age)), S.max_age), S.min_age)
			return TOPIC_REFRESH
/*
	else if(href_list["metadata"])
		var/new_metadata = sanitize(input(user, "Enter any information you'd like others to see, such as Roleplay-preferences:", "Game Preference" , pref.metadata)) as message|null
		if(new_metadata && CanUseTopic(user))
			pref.metadata = sanitize(new_metadata)
			return TOPIC_REFRESH*/

	return ..()
