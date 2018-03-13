/datum/antagonist/proc/print_player_summary()

	if(!current_antagonists.len)
		return FALSE

	var/text = "<br><br><font size = 2><b>The [current_antagonists.len == TRUE ? "[role_text] was" : "[role_text_plural] were"]:</b></font>"
	for(var/datum/mind/P in current_antagonists)
		text += print_player_full(P)
		text += get_special_objective_text(P)
		if(!global_objectives.len && P.objectives && P.objectives.len)
			var/failed
			var/num = TRUE
			for(var/datum/objective/O in P.objectives)
				text += print_objective(O, num)
				if(O.check_completion())
					text += "<font color='green'><b>Success!</b></font>"

				else
					text += "<font color='red'>Fail.</font>"

					failed = TRUE
				num++
				if(failed)
					text += "<br><font color='red'><b>The [role_text] has failed.</b></font>"
				else
					text += "<br><font color='green'><b>The [role_text] was successful!</b></font>"

	if(global_objectives && global_objectives.len)
		text += "<BR><FONT size = 2>Their objectives were:</FONT>"
		var/num = TRUE
		for(var/datum/objective/O in global_objectives)
			text += print_objective(O, num, TRUE)
			num++

	// Display the results.
	world << text

/datum/antagonist/proc/print_objective(var/datum/objective/O, var/num, var/append_success)
	var/text = "<br><b>Objective [num]:</b> [O.explanation_text] "
	if(append_success)
		if(O.check_completion())
			text += "<font color='green'><b>Success!</b></font>"
		else
			text += "<font color='red'>Fail.</font>"
	return text

/datum/antagonist/proc/print_player_lite(var/datum/mind/ply)
	var/role = ply.assigned_role ? "\improper[ply.assigned_role]" : "\improper[ply.special_role]"
	var/text = "<br><b>[ply.name]</b> (<b>[ply.key]</b>) as \a <b>[role]</b> ("
	if(ply.current)
		if(ply.current.stat == DEAD)
			text += "died"
		else if(isNotStationLevel(ply.current.z))
			text += "fled the station"
		else
			text += "survived"
		if(ply.current.real_name != ply.name)
			text += " as <b>[ply.current.real_name]</b>"
	else
		text += "body destroyed"
	text += ")"

	return text

/datum/antagonist/proc/print_player_full(var/datum/mind/ply)
	var/text = print_player_lite(ply)

	var/TC_uses = FALSE
	var/uplink_true = FALSE
	var/purchases = ""
	if(uplink_true)
		text += " (used [TC_uses] TC)"
		if(purchases)
			text += "<br>[purchases]"

	return text

/proc/print_ownerless_uplinks()
	return FALSE

/proc/get_uplink_purchases(var/obj/item/device/uplink/H)
	return list()
