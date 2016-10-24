//CM prison_rescue GAME MODE

/datum/game_mode/ice_colony
	name = "Ice Colony"
	config_tag = "Ice Colony"
	required_players = 1 //Need at least one player, but really we need 2.
	xeno_required_num = 1 //Need at least one xeno.
	flags_round_type = MODE_INFESTATION

/* Pre-pre-startup */
//We have to be really careful that we don't pick() from null lists.
//So use list.len as much as possible before a pick() for logic checks.
/datum/game_mode/ice_colony/can_start()
	initialize_special_clamps()
	initialize_starting_predator_list()
	if(!initialize_starting_xenomorph_list())
		return
	initialize_starting_survivor_list()
	return 1

/datum/game_mode/ice_colony/announce()
	world << "<span class='round_header'>The current game map is - Ice colony!</span>"

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/* Pre-setup */
//We can ignore this for now, we don't want to do anything before characters are set up.
/datum/game_mode/ice_colony/pre_setup()
	return 1

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/* Post-setup */
//This happens after create_character, so our mob SHOULD be valid and built by now, but without job data.
//We move it later with transform_survivor but they might flicker at any start_loc spawn landmark effects then disappear.
//Xenos and survivors should not spawn anywhere until we transform them.
/datum/game_mode/ice_colony/post_setup()
	initialize_post_predator_list()
	initialize_post_xenomorph_list()
	initialize_post_survivor_list()

	defer_powernet_rebuild = 2 //Build powernets a little bit later, it lags pretty hard.

	spawn (50)
		command_announcement.Announce("An automated distress signal has been received from archaeology site \"Shiva's Snowball\", on border ice world \"Ifrit\". A response team from the USS Sulaco will be dispatched shortly to investigate.", "USS Sulaco")


/datum/game_mode/ice_colony/transform_xeno(var/datum/mind/ghost)

	var/mob/living/carbon/Xenomorph/Larva/new_xeno = new(pick(xeno_spawn_ice_colony))
	new_xeno.amount_grown = 200
	var/mob/original = ghost.current

	ghost.transfer_to(new_xeno)

	new_xeno << "<B>You are now an alien!</B>"
	new_xeno << "<B>Your job is to spread the hive and protect the Queen. You can become the Queen yourself by evolving into a drone.</B>"
	new_xeno << "Use say :a to talk to the hive."

	new_xeno.update_icons()

	if(original) //Just to be sure.
		del(original)

//Start the Survivor players. This must go post-setup so we already have a body.
/datum/game_mode/ice_colony/transform_survivor(var/datum/mind/ghost)

	var/mob/living/carbon/human/H = ghost.current

	H.loc = pick(surv_spawn_ice_colony)

	//Damage them for realism purposes
	H.take_organ_damage(rand(0,15), rand(0,15))

//Give them proper jobs and stuff here later
	var/randjob = rand(0,3)
	switch(randjob)
/*		if(0) //assistant
			H.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(H), slot_w_uniform)
		if(1) //civilian in pajamas
			H.equip_to_slot_or_del(new /obj/item/clothing/under/pj/red(H), slot_w_uniform)*/
		if(0) //Scientist
			H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/scientist(H), slot_w_uniform)
		if(1) //Doctor
			H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/medical(H), slot_w_uniform)
	/*	if(4) //Chef!
			H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chef(H), slot_w_uniform)
		if(5) //Botanist
			H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/hydroponics(H), slot_w_uniform)
		if(6)//Atmos
			H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/atmospheric_technician(H), slot_w_uniform)
		if(7) //Chaplain
			H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chaplain(H), slot_w_uniform)
		if(8) //Miner
			H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/miner(H), slot_w_uniform)*/
		if(2) //Corporate guy
			H.equip_to_slot_or_del(new /obj/item/clothing/under/liaison_suit(H), slot_w_uniform)
		/*if(3) //Prisoner
			H.equip_to_slot_or_del(new /obj/item/clothing/under/color/orange(H), slot_w_uniform)*/
		if(3) //Security
			H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC(H), slot_w_uniform)

	H.equip_to_slot_or_del(new /obj/item/clothing/head/ushanka(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/snow_suit(H), slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather(H), slot_wear_mask)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/snow(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(H), slot_gloves)
	H.equip_to_slot_or_del(new /obj/item/device/flashlight(H), slot_r_store)
	H.equip_to_slot_or_del(new /obj/item/weapon/crowbar(H), slot_l_store)

	H.update_icons()

	//Give them some information
	spawn(4)
		H << "<h2>You are a survivor!</h2>"
		H << "\blue You are a survivor of the attack on the ice habitat. You worked or lived on the colony, and managed to avoid the alien attacks.. until now."
		H << "\blue You are fully aware of the xenomorph threat and are able to use this knowledge as you see fit."
		H << "\blue You are NOT aware of the marines or their intentions, and lingering around arrival zones will get you survivor-banned."
	return 1

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

//This is processed each tick, but check_win is only checked 5 ticks, so we don't go crazy with scanning for mobs.
/datum/game_mode/ice_colony/process()
	process_infestation()

///////////////////////////
//Checks to see who won///
//////////////////////////
/datum/game_mode/ice_colony/check_win()
	check_win_infestation()

///////////////////////////////
//Checks if the round is over//
///////////////////////////////
/datum/game_mode/ice_colony/check_finished()
	if(round_finished) return 1

//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relevant information stated//
//////////////////////////////////////////////////////////////////////
/datum/game_mode/ice_colony/declare_completion()
	. = declare_completion_infestation()