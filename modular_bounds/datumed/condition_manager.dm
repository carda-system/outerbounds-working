/mob/living/carbon
	/// Reference to the tgui panel that lets you view medical conditions
	var/datum/conditions_panel/conditions_panel
	/// List of all active conditions as well as what body zone they are tied to
	var/list/medical_conditions = list()
	/// List of conditions that can be treated and by what
	var/list/treatable_conditions = list(
		CONDITION_BANDAGABLE = list(),
		CONDITION_POISONING = null,
	)

/// Runs through all of the conditions on a mob and updates them
/mob/living/carbon/proc/update_medical_conditions(seconds_per_tick)
	for(var/datum/medical_condition/condition as anything in medical_conditions)
		if(!istype(condition))
			medical_conditions -= condition
			QDEL_NULL(condition)
			continue
		condition.owner_process(seconds_per_tick, src)
	for(var/obj/item/bodypart/part as anything in bodyparts)
		part.refresh_bleed_rate()
	updatehealth()

/// Adds a medical condition to the target body zone, or the whole body if none provided and one not needed by the datum
/mob/living/carbon/proc/add_medical_condition(datum/medical_condition/condition, target_body_zone, condition_source)
	if(!target_body_zone && !condition.limb_independence)
		message_admins("[src] tried to add a condition that requires a specific bodypart defined with no bodypart defined!")
		return
	if(!get_bodypart(target_body_zone) && target_body_zone)
		return // Much more likely to happen, but still wrong
	medical_conditions += condition
	condition.on_application(src, target_body_zone ? get_bodypart(target_body_zone) : null, condition_source)
	medical_conditions[condition] = target_body_zone ? target_body_zone : CONDITION_FULL_BODY
	return condition

/// Removes a medical condition on the target body zone (or whole body) that matches the path given
/mob/living/carbon/proc/remove_medical_condition(datum/medical_condition/condition, target_body_zone, condition_source)
	if(isnull(condition))
		return
	if(!target_body_zone)
		target_body_zone = CONDITION_FULL_BODY
	for(var/datum/medical_condition/mob_condition in medical_conditions)
		if(istype(mob_condition, condition))
			if(medical_conditions[mob_condition] == target_body_zone)
				if(condition_source && (mob_condition.source != condition_source))
					continue
				mob_condition.on_removal()
				return

/// Checks if a condition with a type already exists, if so then changes severity of the condition, if not then adds a new one with that severity
/mob/living/carbon/proc/add_or_change_medical_condition(datum/medical_condition/condition, target_body_zone, condition_source, severity)
	if(isnull(condition))
		return
	var/checked_body_zone = target_body_zone ? target_body_zone : CONDITION_FULL_BODY
	var/should_add_condition = TRUE
	var/datum/medical_condition/current_condition
	for(var/datum/medical_condition/mob_condition in medical_conditions)
		if(istype(mob_condition, condition))
			if(medical_conditions[mob_condition] == checked_body_zone)
				if(condition_source && (mob_condition.source != condition_source))
					continue
				current_condition = mob_condition
				should_add_condition = FALSE
				break
	if(should_add_condition)
		var/datum/medical_condition/new_condition = new condition(severity)
		add_medical_condition(new_condition, target_body_zone, condition_source)
	else
		current_condition.severity = severity

/// Takes a damage amount and wounding type and converts them into medical conditions, hacky fix for tg combat stuff
/obj/item/bodypart/proc/damage_to_conditions(damage_amount, wounding_type)
	if(!wounding_type)
		message_admins("[src] tried to get a medical condition from damage without a wounding type!")
		return // Nuh uh?
	var/datum/medical_condition/condition_to_add
	switch(wounding_type)
		if(WOUND_BLUNT)
			if(damage_amount < 13)
				condition_to_add = /datum/medical_condition/wound/bruise
			else
				condition_to_add = pick_weight(list(
					/datum/medical_condition/wound/crack = 1,
					/datum/medical_condition/wound/crushing = 3,
				))
		if(WOUND_SLASH)
			if(damage_amount < 13)
				condition_to_add = pick_weight(list(
					/datum/medical_condition/wound/scratch = 3,
					/datum/medical_condition/wound/cut = 2,
				))
			else
				condition_to_add = pick_weight(list(
					/datum/medical_condition/wound/scratch = 2,
					/datum/medical_condition/wound/cut = 5,
					/datum/medical_condition/wound/shred = 1,
				))
		if(WOUND_PIERCE)
			if(damage_amount < 13)
				condition_to_add = pick_weight(list(
					/datum/medical_condition/wound/scratch = 3,
					/datum/medical_condition/wound/cut = 2,
				))
			else
				condition_to_add = pick_weight(list(
					/datum/medical_condition/wound/scratch = 2,
					/datum/medical_condition/wound/cut = 3,
					/datum/medical_condition/wound/stab = 2,
				))
		if(WOUND_BURN)
			condition_to_add = /datum/medical_condition/wound/burn
	if(!condition_to_add)
		message_admins("[src] tried to get a medical condition from damage but didn't get one from logic!")
		return // What?
	var/condition_max = condition_to_add::maximum_health_offset
	var/new_condition_severity = min(10, abs(round((damage_amount * 10) / condition_max, DAMAGE_PRECISION)))
	condition_to_add = new condition_to_add(new_condition_severity)
	owner.add_medical_condition(condition_to_add, body_zone)
