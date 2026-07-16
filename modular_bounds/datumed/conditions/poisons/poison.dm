/datum/medical_condition/toxin
	name = "Poisoning"
	desc = "A wound of some kind, but it doesn't seem to do anything."
	treatment_text = "Anti-poisoning medication, or time and rest."
	natural_cure_time = 15 MINUTES
	severity = 5
	health_offset = 0 // Toxin health offset is handled specially
	limb_independence = TRUE
	condition_icon = FA_ICON_SKULL
	severity_name_thresholds = list(
		"Minor" = 1,
		"Moderate" = 2.5,
		"Severe" = 5,
		"Critical" = 7.5,
		"Fatal" = INFINITY,
	)
	max_severity_fatal = TRUE
	death_message = "Your extreme blood poisoning finally gets the better of you."
	damage_type = TOX

/datum/medical_condition/toxin/on_application(mob/living/carbon/victim, obj/item/bodypart/target_bodypart)
	. = ..()
	maximum_health_offset = (victim.maxHealth * -2) - 20 // Enough to kill them + a bit of space for changing max health
	victim.treatable_conditions[CONDITION_POISONING] = src

/datum/medical_condition/toxin/on_removal()
	owner.treatable_conditions[CONDITION_POISONING] = null
	return ..()

/datum/medical_condition/toxin/owner_process(seconds_per_tick)
	. = ..()
	maximum_health_offset = (owner.maxHealth * -2) - 20
