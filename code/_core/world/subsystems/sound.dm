var/global/list/active_sounds = list()

/subsystem/sound/
	name = "Sound Subsystem"
	tick_rate = DECISECONDS_TO_TICKS(1)
	priority = SS_ORDER_PRELOAD

/subsystem/sound/on_life()
	for(var/F in active_sounds)
		var/sound/S = F
		if(active_sounds[S] != -1)
			active_sounds[S] -= 1
			if(active_sounds[S] <= 0)
				S.status = SOUND_MUTE | SOUND_UPDATE
				for(var/mob/M in all_mobs_with_clients)
					M << S
				active_sounds -= S
				qdel(S)
				continue

	return TRUE

/proc/stop_sound(var/sound_path,var/list/atom/hearers)
	for(var/F in active_sounds)
		var/sound/S = F
		if(S.file == sound_path)
			S.status = SOUND_MUTE
			for(var/atom/H in hearers)
				H << S

proc/stop_ambient_sounds(var/atom/hearer)
	var/sound/created_sound = sound()
	created_sound.priority = 100
	created_sound.status = SOUND_MUTE
	//hearer << created_sound

proc/stop_music_track(var/client/hearer)
	var/sound/created_sound = sound()
	created_sound.priority = 100
	created_sound.status = SOUND_MUTE
	//hearer << created_sound

proc/play_ambient_sound(var/sound_path,var/atom/hearer,var/volume=1,var/pitch=1,var/loop=0,var/pan=0,var/echo=0,var/environment=ENVIRONMENT_GENERIC)

	var/sound/created_sound = sound(sound_path)
	created_sound.frequency = pitch
	created_sound.repeat = loop
	created_sound.pan = pan
	created_sound.channel = SOUND_CHANNEL_AMBIENT
	created_sound.priority = 0
	created_sound.echo = echo
	created_sound.environment = environment
	created_sound.status = 0
	created_sound.volume = volume

	hearer << created_sound

proc/play_music_track(var/music_track_id,var/client/hearer,var/volume=25)

	stop_music_track(hearer)

	var/track/T = all_tracks[music_track_id]
	if(!T)
		return FALSE

	var/sound/created_sound = sound(T.path)
	created_sound.channel = SOUND_CHANNEL_MUSIC
	created_sound.priority = 0
	created_sound.environment = ENVIRONMENT_GENERIC
	created_sound.status = 0
	created_sound.volume = volume

	hearer.mob << created_sound
	hearer.current_music_track = music_track_id
	hearer.next_music_track = curtime + T.length

	return created_sound

/proc/play_sound(var/sound_path, var/list/atom/hearers = list(), var/list/pos = list(0,0,0), var/volume=75, var/pitch=1, var/loop=0, var/duration=0, var/pan=0, var/channel=SOUND_CHANNEL_FX, var/priority=0, var/echo = 0, var/environment = ENVIRONMENT_GENERIC, var/invisibility_check = 0)
	var/sound/created_sound = sound(sound_path)

	created_sound.frequency = pitch
	created_sound.repeat = loop
	created_sound.pan = pan
	created_sound.priority = priority
	created_sound.echo = echo
	created_sound.environment = environment
	created_sound.status = 0
	created_sound.channel = channel

	if(loop)
		active_sounds[created_sound] = -1
	else if(duration)
		active_sounds[created_sound] = duration

	for(var/mob/M in hearers)
		if(!M.client || !M.client.settings)
			continue

		if(invisibility_check && M.see_invisible < invisibility_check)
			continue

		volume *= M.client.settings.loaded_data["volume_master"] / 100

		switch(channel)
			if(SOUND_CHANNEL_MUSIC)
				volume *= M.client.settings.loaded_data["volume_music"] / 100
			if(SOUND_CHANNEL_AMBIENT)
				volume *= M.client.settings.loaded_data["volume_ambient"] / 100
			if(SOUND_CHANNEL_FOOTSTEPS)
				volume *= M.client.settings.loaded_data["volume_footsteps"] / 100
			if(SOUND_CHANNEL_UI)
				volume *= M.client.settings.loaded_data["volume_ui"] / 100
			if(SOUND_CHANNEL_FX)
				volume *= M.client.settings.loaded_data["volume_fx"] / 100

		var/local_volume = volume

		if(created_sound.z >= 0)
			var/turf/mob_turf = get_turf(M)
			created_sound.x = pos[1] - mob_turf.x
			created_sound.y = pos[2] - mob_turf.y
			created_sound.z = pos[3] - mob_turf.z

			if(channel != SOUND_CHANNEL_MUSIC)
				var/distance = max(0,sqrt(created_sound.x**2 + created_sound.y**2)-(VIEW_RANGE*0.5))
				local_volume = (local_volume - distance*0.25)*max(0,SOUND_RANGE - distance)/SOUND_RANGE

		if(local_volume <= 0)
			continue

		created_sound.volume = local_volume

		M << created_sound

	return created_sound