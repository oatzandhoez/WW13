/obj/item/device/assembly/timer
	name = "timer"
	desc = "Used to time things. Works well with contraptions which has to count down. Tick tock."
	icon_state = "timer"
//	origin_tech = list(TECH_MAGNET = TRUE)
	matter = list(DEFAULT_WALL_MATERIAL = 500, "glass" = 50, "waste" = 10)

	wires = WIRE_PULSE

	secured = FALSE

	var/timing = FALSE
	var/time = 10

	proc
		timer_end()


	activate()
		if(!..())	return FALSE//Cooldown check

		timing = !timing

		update_icon()
		return FALSE


	toggle_secure()
		secured = !secured
		if(secured)
			processing_objects.Add(src)
		else
			timing = FALSE
			processing_objects.Remove(src)
		update_icon()
		return secured


	timer_end()
		if(!secured)	return FALSE
		pulse(0)
		if(!holder)
			visible_message("\icon[src] *beep* *beep*", "*beep* *beep*")
		cooldown = 2
		spawn(10)
			process_cooldown()
		return


	process()
		if(timing && (time > FALSE))
			time--
		if(timing && time <= FALSE)
			timing = FALSE
			timer_end()
			time = 10
		return


	update_icon()
		overlays.Cut()
		attached_overlays = list()
		if(timing)
			overlays += "timer_timing"
			attached_overlays += "timer_timing"
		if(holder)
			holder.update_icon()
		return


	interact(mob/user as mob)//TODO: Have this use the wires
		if(!secured)
			user.show_message("<span class = 'red'>The [name] is unsecured!</span>")
			return FALSE
		var/second = time % 60
		var/minute = (time - second) / 60
		var/dat = text("<TT><b>Timing Unit</b>\n[] []:[]\n<A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A>\n</TT>", (timing ? text("<A href='?src=\ref[];time=0'>Timing</A>", src) : text("<A href='?src=\ref[];time=1'>Not Timing</A>", src)), minute, second, src, src, src, src)
		dat += "<BR><BR><A href='?src=\ref[src];refresh=1'>Refresh</A>"
		dat += "<BR><BR><A href='?src=\ref[src];close=1'>Close</A>"
		user << browse(dat, "window=timer")
		onclose(user, "timer")
		return


	Topic(href, href_list)
		if(..()) return TRUE
		if(!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
			usr << browse(null, "window=timer")
			onclose(usr, "timer")
			return

		if(href_list["time"])
			timing = text2num(href_list["time"])
			update_icon()

		if(href_list["tp"])
			var/tp = text2num(href_list["tp"])
			time += tp
			time = min(max(round(time), FALSE), 600)

		if(href_list["close"])
			usr << browse(null, "window=timer")
			return

		if(usr)
			attack_self(usr)

		return
