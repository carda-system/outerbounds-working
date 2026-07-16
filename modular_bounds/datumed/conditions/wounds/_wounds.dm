/datum/medical_condition/wound
	abstract_type = /datum/medical_condition/wound
	name = "Unknown Wound"
	desc = "A wound of some kind, but it doesn't seem to do anything."
	treatment_text = null
	natural_cure_time = null
	severity = null
	health_offset = 0
	limb_independence = FALSE
	/// Does this wound cause bleeding?
	var/causes_bleeding = FALSE
	/// Did we start with bleeding that has been healed?
	var/bleeding_healed = FALSE
	/// How much bleed per life tick does the wound cause maximum
	var/max_bleeding_amount = 0
	/// How much bleed per life tick does the wound actually cause, modified by severity
	var/actual_bleeding_amount = 0

/datum/medical_condition/wound/New(new_severity)
	. = ..()
	if(causes_bleeding)
		max_bleeding_amount *= SEVERITY_2_PERCENT(severity)

/datum/medical_condition/wound/on_application(mob/living/carbon/victim, obj/item/bodypart/target_bodypart)
	. = ..()
	actual_bleeding_amount = max_bleeding_amount
	if(causes_bleeding)
		victim.treatable_conditions[CONDITION_BANDAGABLE] |= src
		victim.treatable_conditions[CONDITION_BANDAGABLE][src] = target_bodypart.body_zone
		condition_alerts_list |= list(
			CONDITION_UI_BLEEDING = CONDITION_ALERT_NO_DATA
		)

/datum/medical_condition/wound/on_removal()
	var/list/treatable_conditions_list = owner?.treatable_conditions[CONDITION_BANDAGABLE]
	if(treatable_conditions_list.Find(src))
		owner.treatable_conditions[CONDITION_BANDAGABLE] -= src
	return ..()

/datum/medical_condition/wound/owner_process(seconds_per_tick)
	. = ..()
	if(!causes_bleeding && actual_bleeding_amount)
		actual_bleeding_amount = 0
		bleeding_healed = TRUE
		if(condition_alerts_list.Find(CONDITION_UI_BLEEDING))
			condition_alerts_list -= CONDITION_UI_BLEEDING
		var/list/treatable_conditions_list = owner.treatable_conditions[CONDITION_BANDAGABLE]
		if(treatable_conditions_list.Find(src))
			owner.treatable_conditions[CONDITION_BANDAGABLE] -= src

/datum/medical_condition/wound/natural_healing()
	. = ..()
	if(causes_bleeding) // Wounds will stop bleeding before they fully heal
		actual_bleeding_amount = round(treatment_heal_multiplier * max(actual_bleeding_amount - (max_bleeding_amount / 10), 0), DAMAGE_PRECISION)
		if(actual_bleeding_amount <= 0)
			causes_bleeding = FALSE
