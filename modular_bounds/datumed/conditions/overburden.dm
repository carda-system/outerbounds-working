/datum/medical_condition/overburden
	name = "Overburdening"
	desc = "Carrying more weight than the body can comfortably handle, resulting in slower movement."
	treatment_text = "Reduce weight of carried items or become stronger."
	natural_cure_time = null
	severity = 5
	health_offset = 0
	limb_independence = TRUE
	condition_icon = FA_ICON_BOXES_STACKED
	severity_name_thresholds = list(
		"Little" = 4,
		"Noticeable" = 6,
		"Heavy" = 8,
		"Extreme" = INFINITY,
	)
	max_severity_fatal = FALSE
	/// The last agility modifier we applied to a mob
	var/last_agility_offset = 0

/datum/medical_condition/overburden/on_application(mob/living/carbon/victim, obj/item/bodypart/target_bodypart)
	. = ..()
	decide_reflex_offset()

/datum/medical_condition/overburden/on_removal()
	owner?.adjust_attribute_modifier(ATTRIBUTE_REFLEX, -last_agility_offset)
	return ..()

/datum/medical_condition/overburden/owner_process(seconds_per_tick)
	. = ..()
	decide_reflex_offset()

/// Figures out what we should do to the owner's reflex offset based on severity
/datum/medical_condition/overburden/proc/decide_reflex_offset()
	switch(severity)
		if(0 to 4)
			change_reflex_offset(last_agility_offset, -1)
		if(4 to 6)
			change_reflex_offset(last_agility_offset, -2)
		if(6 to 8)
			change_reflex_offset(last_agility_offset, -3)
		if(8 to INFINITY)
			change_reflex_offset(last_agility_offset, -4)

/// Changes the owner's reflex offset
/datum/medical_condition/overburden/proc/change_reflex_offset(old_offset, new_offset)
	owner.adjust_attribute_modifier(ATTRIBUTE_REFLEX, -old_offset)
	owner.adjust_attribute_modifier(ATTRIBUTE_REFLEX, new_offset)
	last_agility_offset = new_offset
