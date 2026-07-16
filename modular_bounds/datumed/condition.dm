/datum/medical_condition
	abstract_type = /datum/medical_condition
	/// The name of the condition as it appears to players
	var/name = "Unknown Condition"
	/// The base name to reference when updating the name with severity, do not manually set
	var/base_name = null
	/// A brief description of the condition, do not put treatment text in this
	var/desc = "A medical condition of some kind, but it doesn't seem to do anything."
	/// How to treat the condition, if at all
	var/treatment_text = null
	/// What color is this condition in the tgui menu
	var/menu_color = "#FFF"
	/// The fontawesome icon this will have in the conditions menu
	var/condition_icon = FA_ICON_INFO_CIRCLE
	/// List of alerts for the tgui conditions menu
	var/list/condition_alerts_list = list()
	/// How much of a treatment healing multiplier do we apply to the condition? >1 means faster healing
	var/treatment_heal_multiplier = 1
	/// If the condition should only last a certain amount of time, how long? In SECONDS
	var/natural_cure_time = null
	/// Cooldown between times the severity should drop on this wound
	COOLDOWN_DECLARE(natural_healing_delay)
	/// This condition's damage type, used for calculating limb health
	var/damage_type = BRUTE
	/// Generic "severity" tracker, for use by subtypes for whatever they wish
	var/severity = 0
	/// The severity we started with, used for natural healing, don't set directly
	var/starting_severity = 0
	/// Does the name of this datum change based on severity?
	var/severity_changes_name = TRUE
	/// What we call different severity levels, needs to be in proper order like shown here
	var/list/severity_name_thresholds = list(
		"Negligible" = 1,
		"Minor" = 3,
		"Moderate" = 6,
		"Severe" = INFINITY,
	)
	/// The owner of this condition
	var/mob/living/carbon/owner = null
	/// The specific limb of the owner we are applied to, always null for whole body conditions
	var/obj/item/bodypart/owner_bodypart = null
	/// The maximum health offset this wound can have, modified by severity, negative lowers health
	var/maximum_health_offset = 0
	/// The actual health offset modified by severity, do not set directly
	var/health_offset = 0
	/// If this can be applied to a limb independent of if that limb is actually there or not, for delimbing wounds
	var/limb_independence = FALSE
	/// If this condition can kill you at 10 severity
	var/max_severity_fatal = FALSE
	/// The message given if this condiiton kills you because of max severity
	var/death_message = null
	/// The source of this condition, for removing specific conditions from a mob
	var/source = CONDITION_SOURCE_NORMAL

/datum/medical_condition/New(new_severity)
	severity = min(CONDITION_SEVERITY_MAX, new_severity)
	starting_severity = severity
	base_name = name
	treatment_text = "Treatment: [treatment_text]"

/datum/medical_condition/Destroy(force)
	owner = null
	owner_bodypart = null
	on_removal(TRUE)
	return ..()

/// What to do to the mob and or the limb on application
/datum/medical_condition/proc/on_application(mob/living/carbon/victim, obj/item/bodypart/target_bodypart, condition_source)
	SHOULD_CALL_PARENT(TRUE)
	if(!victim || (!limb_independence && !target_bodypart))
		message_admins("Condition \"[src.name]\" has no target, or needs a target bodypart and didn't get one!")
		qdel(src) // ?? How did you do that
		return
	owner = victim
	if(target_bodypart)
		owner_bodypart = target_bodypart
	if(natural_cure_time)
		COOLDOWN_START(src, natural_healing_delay, natural_cure_time / 20)
	update_condition_name()
	health_offset = maximum_health_offset * SEVERITY_2_PERCENT(severity)
	if(treatment_text)
		condition_alerts_list |= list(
			CONDITION_UI_TREATMENT = treatment_text
		)
	if(max_severity_fatal)
		condition_alerts_list |= list(
			CONDITION_UI_MAX_SEVERITY_FATAL = CONDITION_ALERT_NO_DATA
		)
	if(!isnull(condition_source))
		source = condition_source

/// What to do to the mob and or the limb on removal
/datum/medical_condition/proc/on_removal(already_deleting = FALSE)
	SHOULD_CALL_PARENT(TRUE)
	if(!owner)
		return
	owner.medical_conditions -= src
	if(!already_deleting)
		qdel(src)

/// Connected to life processing to the owner mob, for condition progression, or constant effects
/datum/medical_condition/proc/owner_process(seconds_per_tick, mob/living/carbon/current_owner)
	SHOULD_CALL_PARENT(TRUE)
	if(owner != current_owner)
		owner = current_owner
	var/obj/item/bodypart/owner_limb = owner.get_bodypart(owner.medical_conditions[src])
	if((!istype(owner_limb) || !owner_limb) && !limb_independence)
		on_removal()
		return
	if(severity <= 0)
		on_removal()
		return
	update_condition_name()
	if(natural_cure_time)
		if(COOLDOWN_FINISHED(src, natural_healing_delay))
			natural_healing()
			COOLDOWN_START(src, natural_healing_delay, natural_cure_time / 20)
	health_offset = maximum_health_offset * SEVERITY_2_PERCENT(severity)
	if(treatment_heal_multiplier > 1)
		condition_alerts_list |= list(
			CONDITION_UI_TREATMENT_QUALITY = "This condition has been treated to a quality of [treatment_heal_multiplier * 100], changing the rate it heals at."
		)
	if(istype(owner_limb)) // This feels like it may be expensive to run? Look at doing it a better way later
		owner_limb.update_limb_health_values_for_conditions()
	if(max_severity_fatal && (severity == CONDITION_SEVERITY_MAX) && (owner.stat != DEAD))
		achieve_death()

/// Called when the natural healing cooldown has finished
/datum/medical_condition/proc/natural_healing()
	severity = round(treatment_heal_multiplier * max(severity - (starting_severity / 20),  0), DAMAGE_PRECISION)

/// Handles killing the owner if a condition manages to directly kill them
/datum/medical_condition/proc/achieve_death()
	if(death_message)
		to_chat(owner, span_userdanger(death_message))
	owner.investigate_log("has been killed by condition [src.name] that reached maximum severity.", INVESTIGATE_DEATHS)
	owner.death()
	severity -= severity / 5 // A little bit of reprieve for revival

/// Updates the name of the datum depending on severity level
/datum/medical_condition/proc/update_condition_name()
	if(!severity_changes_name)
		return
	var/severity_append = null
	for(var/threshold as anything in severity_name_thresholds)
		var/threshold_number = severity_name_thresholds[threshold]
		if(severity <= threshold_number)
			severity_append = threshold
			break
	name = "[base_name] ([severity_append])"
