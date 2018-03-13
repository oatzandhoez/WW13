/mob/living/carbon/human/var/last_scream = -1
/mob/living/carbon/human/var/last_surrender = -1
/mob/living/carbon/human/var/next_vocal_emote = -1

/mob/living/carbon/human/emote(var/act,var/m_type=1,var/message = null)

	if (world.time < next_vocal_emote)
		return

	// no more screaming when you shoot yourself
	var/do_after = 0
	if (act == "scream")
		do_after = 1

	spawn (do_after)
		if (act == "scream" && stat == UNCONSCIOUS || stat == DEAD)
			return

		var/param = null

		if (findtext(act, "-", TRUE, null))
			var/t1 = findtext(act, "-", TRUE, null)
			param = copytext(act, t1 + TRUE, length(act) + TRUE)
			act = copytext(act, TRUE, t1)

		if(findtext(act,"s",-1) && !findtext(act,"_",-2))//Removes ending s's unless they are prefixed with a '_'
			act = copytext(act,1,length(act))

		var/muzzled = istype(wear_mask, /obj/item/clothing/mask/muzzle) || istype(wear_mask, /obj/item/weapon/grenade)
		//var/m_type = 1

		for (var/obj/item/weapon/implant/I in src)
			if (I.implanted)
				I.trigger(act, src)

		if(stat == 2.0 && (act != "deathgasp"))
			return

		switch(act)
			if ("dance")
				if (!restrained())
					message = "dances."
					m_type = 1

					var/src_oloc = loc
					var/turns = 0
					spawn while (1)
						if (src_oloc != loc)
							break
						dir = pick(NORTH, EAST, SOUTH, WEST)
						++turns
						if (turns >= 10)
							break
						sleep(3)
			/*
			if ("airguitar")
				if (!restrained())
					message = "is strumming the air and headbanging like a safari chimp."
					m_type = 1
*/
			if ("blink")
				message = "blinks."
				m_type = 1

			if ("blink_r")
				message = "blinks rapidly."
				m_type = 1

			if ("bow")
				if (!buckled)
					var/M = null
					if (param)
						for (var/mob/A in view(null, null))
							if (param == A.name)
								M = A
								break
					if (!M)
						param = null

					if (param)
						message = "bows to [param]."
					else
						message = "bows."
				m_type = 1

			if ("custom")
				var/input = sanitize(input("Choose an emote to display.") as text|null)
				if (!input)
					return
				var/input2 = input("Is this a visible or hearable emote?") in list("Visible","Hearable")
				if (input2 == "Visible")
					m_type = 1
				else if (input2 == "Hearable")
					if (miming)
						return
					m_type = 2
				else
					alert("Unable to use this emote, must be either hearable or visible.")
					return
				return custom_emote(m_type, message)

			if ("me")

				//if(silent && silent > FALSE && findtext(message,"\"",1, null) > FALSE)
				//	return //This check does not work and I have no idea why, I'm leaving it in for reference.

				if (client)
					if (client.prefs.muted & MUTE_IC)
						src << "<span class = 'red'>You cannot send IC messages (muted).</span>"
						return
					if (client.handle_spam_prevention(message,MUTE_IC))
						return
				if (stat)
					return
				if(!(message))
					return
				return custom_emote(m_type, message)

			if ("salute")
				if (!buckled)
					var/M = null
					if (param)
						for (var/mob/A in view(null, null))
							if (param == A.name)
								M = A
								break
					if (!M)
						param = null

					if (param)
						message = "salutes to [param]."
					else
						message = "salutes."
				m_type = 1

			if ("choke")
				if(miming)
					message = "clutches [get_visible_gender() == MALE ? "his" : get_visible_gender() == FEMALE ? "her" : "their"] throat desperately!"
					m_type = 1
				else
					if (!muzzled)
						message = "chokes!"
						m_type = 2
					else
						message = "makes a strong noise."
						m_type = 2

			if ("clap")
				if (!restrained())
					message = "claps."
					m_type = 2
					if(miming)
						m_type = 1
			if ("flap")
				if (!restrained())
					message = "flaps [get_visible_gender() == MALE ? "his" : get_visible_gender() == FEMALE ? "her" : "their"] wings."
					m_type = 2
					if(miming)
						m_type = 1

			if ("aflap")
				if (!restrained())
					message = "flaps [get_visible_gender() == MALE ? "his" : get_visible_gender() == FEMALE ? "her" : "their"] wings ANGRILY!"
					m_type = 2
					if(miming)
						m_type = 1

			if ("drool")
				message = "drools."
				m_type = 1

			if ("eyebrow")
				message = "raises an eyebrow."
				m_type = 1

			if ("chuckle")
				if(miming)
					message = "appears to chuckle."
					m_type = 1
				else
					if (!muzzled)
						message = "chuckles."
						m_type = 2
					else
						message = "makes a noise."
						m_type = 2

			if ("twitch")
				message = "twitches violently."
				m_type = 1

			if ("twitch_s")
				message = "twitches."
				m_type = 1

			if ("faint")
				message = "faints."
				if(sleeping)
					return //Can't faint while asleep
				sleeping += 10 //Short-short nap
				m_type = 1

			if ("cough")
				if(miming)
					message = "appears to cough!"
					m_type = 1
				else
					if (!muzzled)
						message = "coughs!"
						m_type = 2
						playsound(get_turf(src), "cough_[gender]", 100)
					else
						message = "makes a strong noise."
						m_type = 2

			if ("frown")
				message = "frowns."
				m_type = 1

			if ("nod")
				message = "nods."
				m_type = 1

			if ("blush")
				message = "blushes."
				m_type = 1

			if ("wave")
				message = "waves."
				m_type = 1

			if ("gasp")
				if(miming)
					message = "appears to be gasping!"
					m_type = 1
				else
					if (!muzzled)
						message = "gasps!"
						m_type = 2
					else
						message = "makes a weak noise."
						m_type = 2

			if ("giggle")
				if(miming)
					message = "giggles silently!"
					m_type = 1
				else
					if (!muzzled)
						message = "giggles."
						m_type = 2
					else
						message = "makes a noise."
						m_type = 2

			if ("glare")
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (param == A.name)
							M = A
							break
				if (!M)
					param = null

				if (param)
					message = "glares at [param]."
				else
					message = "glares."

			if ("stare")
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (param == A.name)
							M = A
							break
				if (!M)
					param = null

				if (param)
					message = "stares at [param]."
				else
					message = "stares."

			if ("look")
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (param == A.name)
							M = A
							break

				if (!M)
					param = null

				if (param)
					message = "looks at [param]."
				else
					message = "looks."
				m_type = 1

			if ("grin")
				message = "grins."
				m_type = 1

			if ("cry")
				if(miming)
					message = "cries."
					m_type = 1
				else
					if (!muzzled)
						message = "cries."
						m_type = 2
						playsound(get_turf(src), "cry_[gender]", 100)
					else
						message = "makes a weak noise. [get_visible_gender() == MALE ? "He" : get_visible_gender() == FEMALE ? "She" : "They"] [get_visible_gender() == NEUTER ? "frown" : "frowns"]."
						m_type = 2

			if ("sigh")
				if(miming)
					message = "sighs."
					m_type = 1
				else
					if (!muzzled)
						message = "sighs."
						m_type = 2
						playsound(get_turf(src), "sigh_[gender]", 100)
					else
						message = "makes a weak noise."
						m_type = 2

			if ("laugh")
				if(miming)
					message = "acts out a laugh."
					m_type = 1
				else
					if (!muzzled)
						message = "laughs."
						m_type = 2
						playsound(get_turf(src), "laugh_[gender]", 100)
					else
						message = "makes a noise."
						m_type = 2

			if ("mumble")
				message = "mumbles!"
				m_type = 2
				if(miming)
					m_type = 1

			if ("grumble")
				if(miming)
					message = "grumbles!"
					m_type = 1
				if (!muzzled)
					message = "grumbles!"
					m_type = 2
				else
					message = "makes a noise."
					m_type = 2

			if ("groan")
				if(miming)
					message = "appears to groan!"
					m_type = 1
				else
					if (!muzzled)
						message = "groans!"
						m_type = 2
					else
						message = "makes a loud noise."
						m_type = 2

			if ("moan")
				if(miming)
					message = "appears to moan!"
					m_type = 1
				else
					message = "moans!"
					m_type = 2

			if ("johnny")
				var/M
				if (param)
					M = param
				if (!M)
					param = null
				else
					if(miming)
						message = "takes a drag from a cigarette and blows \"[M]\" out in smoke."
						m_type = 1
					else
						message = "says, \"[M], please. He had a family.\" [name] takes a drag from a cigarette and blows his name out in smoke."
						m_type = 2

			if ("point")
				if (!restrained())
					var/mob/M = null
					if (param)
						for (var/atom/A as mob|obj|turf|area in view(null, null))
							if (param == A.name)
								M = A
								break

					if (!M)
						message = "points."
					else
						pointed(M)

					if (M)
						message = "points to [M]."
					else
				m_type = 1

			if ("raise")
				if (!restrained())
					message = "raises a hand."
				m_type = 1

			if("shake")
				message = "shakes [get_visible_gender() == MALE ? "his" : get_visible_gender() == FEMALE ? "her" : "their"] head."
				m_type = 1

			if ("shrug")
				message = "shrugs."
				m_type = 1

			if ("signal")
				if (!restrained())
					var/t1 = round(text2num(param))
					if (isnum(t1))
						if (t1 <= 5 && (!r_hand || !l_hand))
							message = "raises [t1] finger\s."
						else if (t1 <= 10 && (!r_hand && !l_hand))
							message = "raises [t1] finger\s."
				m_type = 1

			if ("smile")
				message = "smiles."
				m_type = 1

			if ("shiver")
				message = "shivers."
				m_type = 2
				if(miming)
					m_type = 1

			if ("pale")
				message = "goes pale for a second."
				m_type = 1

			if ("tremble")
				message = "trembles in fear!"
				m_type = 1

			if ("sneeze")
				if (miming)
					message = "sneezes."
					m_type = 1
				else
					if (!muzzled)
						message = "sneezes."
						m_type = 2
						playsound(get_turf(src), "sneeze_[gender]", 100)
					else
						message = "makes a strange noise."
						m_type = 2

			if ("sniff")
				message = "sniffs."
				m_type = 2
				if(miming)
					m_type = 1

			if ("snore")
				if (miming)
					message = "sleeps soundly."
					m_type = 1
				else
					if (!muzzled)
						message = "snores."
						m_type = 2
					else
						message = "makes a noise."
						m_type = 2

			if ("whimper")
				if (miming)
					message = "appears hurt."
					m_type = 1
				else
					if (!muzzled)
						message = "whimpers."
						m_type = 2
					else
						message = "makes a weak noise."
						m_type = 2

			if ("wink")
				message = "winks."
				m_type = 1

			if ("yawn")
				if (!muzzled)
					message = "yawns."
					m_type = 2
					if(miming)
						m_type = 1
					else
						playsound(get_turf(src), "yawn_[gender]", 100)

			if ("collapse")
				Paralyse(2)
				message = "collapses!"
				m_type = 2
				if(miming)
					m_type = 1

			if("hug")
				m_type = 1
				if (!restrained())
					var/M = null
					if (param)
						for (var/mob/A in view(1, null))
							if (param == A.name)
								M = A
								break
					if (M == src)
						M = null

					if (M)
						message = "hugs [M]."
					else
						message = "hugs [get_visible_gender() == MALE ? "himself" : get_visible_gender() == FEMALE ? "herself" : "themselves"]."

			if ("handshake")
				m_type = 1
				if (!restrained() && !r_hand)
					var/mob/M = null
					if (param)
						for (var/mob/A in view(1, null))
							if (param == A.name)
								M = A
								break
					if (M == src)
						M = null

					if (M)
						if (M.canmove && !M.r_hand && !M.restrained())
							message = "shakes hands with [M]."
						else
							var/datum/gender/g = gender_datums[gender]
							message = "holds out [g.his] hand to [M]."

			if ("scream")
				if (last_scream != -1 && world.time - last_scream < 50)
					return
				last_scream = world.time
				if (miming)
					message = "acts out a scream!"
					m_type = 1
				else
					if (!muzzled)
						if (istype(src, /mob/living/carbon/human/vampire))
							message = "wryyys."
						else
							message = "screams!"
						m_type = 2
						scream_sound(src, FALSE)
					else
						message = "makes a very loud noise."
						m_type = 2

			if ("surrender")
				if (last_surrender != -1 && world.time - last_surrender < 1200)
					return
				last_surrender = world.time
				message = "surrenders!"
				Weaken(50)
				if(l_hand) unEquip(l_hand)
				if(r_hand) unEquip(r_hand)
			if ("dab")
				if (config.allow_dabbing)
					m_type = 1
					if (!restrained())
						message = "dabs."
						for (var/atom/movable/AM in get_step(src, dir))
							if (!AM.density)
								continue
							if (!ismob(AM))
								if (!istype(AM, /atom/movable/lighting_overlay) && !isitem(AM) && !istype(AM, /obj/effect))
									if (AM.name)
										message = "dabs on \the [AM]."
						for (var/atom/movable/AM in get_step(src, dir))
							if (!AM.density)
								continue
							if (istype(AM, /mob/observer))
								continue
							if (ismob(AM))
								message = "dabs on \the [AM]."

			if ("pose")
				if (istype(src, /mob/living/carbon/human/pillarman))
					var/mob/living/carbon/human/pillarman/P = src
					if (P.next_pose > world.time)
						P << "<span class = 'danger'>You can't pose again yet.</span>"
						return
					message = "poses [pick("fabulously", "spectacularly")]!"
					playsound(get_turf(P), 'sound/effects/awaken.ogg', 100)
					for (var/turf/T in getcircle(get_turf(P), 2))
						new/obj/effect/kana(T, P)
					for (var/mob/living/carbon/human/H in range(5, P))
						if (!H.takes_less_damage)
							H.SpinAnimation(7,1)
							H.Weaken(rand(2,3))
					P.next_pose = world.time + 600

			if ("help")
				src << {"blink, blink_r, blush, bow-(none)/mob, burp, choke, chuckle, clap, collapse, cough,
	cry, custom, dab, deathgasp, drool, eyebrow, frown, gasp, giggle, groan, grumble, handshake, hug-(none)/mob, glare-(none)/mob,
	grin, laugh, look-(none)/mob, moan, mumble, nod, pale, point-atom, raise, salute, shake, shiver, shrug,
	sigh, signal-#1-10, smile, sneeze, sniff, snore, stare-(none)/mob, scream, surrender, tremble, twitch, twitch_s, whimper,
	wink, yawn, swish, sway/wag, fastsway/qwag, stopsway/swag, dab"}

			else
				src << "<span class = 'notice'>Unusable emote '[act]'. Say *help for a list.</span>"





		if (message)
			log_emote("[name]/[key] : [message]")
			if (act == "surrender")
				custom_emote(m_type,message,"userdanger")
			else
				custom_emote(m_type,message)

		if (m_type == 2 && act != "scream")
			next_vocal_emote = world.time + 50