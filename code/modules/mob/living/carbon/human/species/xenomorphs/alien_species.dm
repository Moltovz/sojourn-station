//Stand-in until this is made more lore-friendly.
/datum/species/xenos
	name = "Xenomorph"
	name_plural = "Xenomorphs"

	default_language = LANGUAGE_XENOMORPH
	language = LANGUAGE_HIVEMIND
	unarmed_types = list(/datum/unarmed_attack/claws/strong, /datum/unarmed_attack/bite/strong)
	hud_type = /datum/hud_data/alien
	rarity_value = 3

	has_fine_manipulation = 0
	siemens_coefficient = 0
	gluttonous = GLUT_ANYTHING

	brute_mod = 0.25 // Hardened carapace.
	burn_mod = 1.1    // Weak to fire.

	warning_low_pressure = 50
	hazard_low_pressure = -1

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	flags =  NO_BREATHE | NO_SCAN | NO_PAIN | NO_SLIP | NO_POISON | NO_MINOR_CUT
	spawn_flags = IS_RESTRICTED

	reagent_tag = IS_XENOS

	speech_sounds = list('sound/voice/hiss1.ogg','sound/voice/hiss2.ogg','sound/voice/hiss3.ogg','sound/voice/hiss4.ogg')
	speech_chance = 100

	breath_type = null
	poison_type = null

	vision_flags = SEE_SELF|SEE_MOBS

	has_organ = list(
		BP_HEART =  /obj/item/organ/internal/vital/heart,
		BP_BRAIN =  /obj/item/organ/internal/vital/brain/xeno,
		BP_PLASMA = /obj/item/organ/internal/xenos/plasmavessel,
		BP_HIVE =   /obj/item/organ/internal/xenos/hivenode,
	)

	bump_flag = ALIEN
	swap_flags = ~HEAVY
	push_flags = (~HEAVY) ^ ROBOT

	var/alien_number = 0
	var/caste_name = "creature" // Used to update alien name.
	var/weeds_heal_rate = 1     // Health regen on weeds.
	var/weeds_plasma_rate = 5   // Plasma regen on weeds.

/datum/species/xenos/get_bodytype()
	return "Xenomorph"

/datum/species/xenos/get_random_name()
	return "alien [caste_name] ([alien_number])"

/datum/species/xenos/can_understand(var/mob/other)
	return istype(other,/mob/living/carbon/alien/larva)

/datum/species/xenos/hug(var/mob/living/carbon/human/H,var/mob/living/target)
	H.visible_message(
		SPAN_NOTICE("[H] caresses [target] with its scythe-like arm."),
		SPAN_NOTICE("You caress [target] with your scythe-like arm.")
	)

/datum/species/xenos/handle_post_spawn(var/mob/living/carbon/human/H)

	if(H.mind)
		H.mind.assigned_role = "Alien"

	alien_number++ //Keep track of how many aliens we've had so far.
	H.real_name = "alien [caste_name] ([alien_number])"
	H.name = H.real_name

	..()

/datum/species/xenos/handle_environment_special(var/mob/living/carbon/human/H)

	var/turf/T = H.loc
	if(!T) return
	var/datum/gas_mixture/environment = T.return_air()
	if(!environment) return

	var/obj/effect/plant/plant = locate() in T
	if((environment.gas["plasma"] > 0 || (plant && plant.seed && plant.seed.name == "xenomorph")) && !regenerate(H))
		var/obj/item/organ/internal/xenos/plasmavessel/P = H.internal_organs_by_name[BP_PLASMA]
		P.stored_plasma += weeds_plasma_rate
		P.stored_plasma = min(max(P.stored_plasma,0),P.max_plasma)
	..()

/datum/species/xenos/proc/regenerate(var/mob/living/carbon/human/H)
	var/heal_rate = weeds_heal_rate
	var/mend_prob = 10
	if (!H.resting)
		heal_rate = weeds_heal_rate / 3
		mend_prob = 1

	//first heal damages
	if (H.getBruteLoss() || H.getFireLoss() || H.getOxyLoss() || H.getToxLoss())
		H.adjustBruteLoss(-heal_rate)
		H.adjustFireLoss(-heal_rate)
		H.adjustOxyLoss(-heal_rate)
		if (prob(5))
			to_chat(H, "<span class='alium'>You feel a soothing sensation come over you...</span>")
		return 1

	//next internal organs
	for(var/obj/item/organ/I in H.internal_organs)
		if(I.damage > 0)
			I.damage = max(I.damage - heal_rate, 0)
			if (prob(5))
				to_chat(H, "<span class='alium'>You feel a soothing sensation within your [I.parent_organ]...</span>")
			return 1

	//next mend broken bones, approx 10 ticks each
	for(var/obj/item/organ/external/E in H.bad_external_organs)
		if (E.status & ORGAN_BROKEN)
			if (prob(mend_prob))
				if (E.mend_fracture())
					to_chat(H, "<span class='alium'>You feel something mend itself inside your [E.name].</span>")
			return 1

	return 0

/datum/species/xenos/drone
	name = "Xenomorph Drone"
	caste_name = "drone"
	weeds_plasma_rate = 15
	slowdown = 1
	rarity_value = 5

	default_form = /datum/species_form/alien/drone

	has_organ = list(
		BP_HEART =  /obj/item/organ/internal/vital/heart,
		BP_BRAIN =  /obj/item/organ/internal/vital/brain/xeno,
		BP_PLASMA = /obj/item/organ/internal/xenos/plasmavessel/drone,
		O_ACID =   /obj/item/organ/internal/xenos/acidgland/drone,
		BP_HIVE =   /obj/item/organ/internal/xenos/hivenode,
		O_RESIN =  /obj/item/organ/internal/xenos/resinspinner,
	)

	inherent_verbs = list(
		/mob/living/proc/ventcrawl
	)

/datum/species/xenos/drone/handle_post_spawn(var/mob/living/carbon/human/H)

	var/mob/living/carbon/human/A = H
	if(!istype(A))
		return ..()
	..()

/datum/species/xenos/hunter

	name = "Xenomorph Hunter"
	weeds_plasma_rate = 5
	caste_name = "hunter"
	slowdown = -2
	total_health = 150

	default_form = /datum/species_form/alien/hunter

	has_organ = list(
		BP_HEART =  /obj/item/organ/internal/vital/heart,
		BP_BRAIN =  /obj/item/organ/internal/vital/brain/xeno,
		BP_PLASMA = /obj/item/organ/internal/xenos/plasmavessel/hunter,
		BP_HIVE =   /obj/item/organ/internal/xenos/hivenode,
	)

	inherent_verbs = list(
		/mob/living/proc/ventcrawl,
		/mob/living/carbon/human/proc/tackle,
		/mob/living/carbon/human/proc/gut,
		/mob/living/carbon/human/proc/leap,
		/mob/living/carbon/human/proc/psychic_whisper
	)

/datum/species/xenos/sentinel
	name = "Xenomorph Sentinel"
	weeds_plasma_rate = 10
	caste_name = "sentinel"
	slowdown = 0
	total_health = 125

	default_form = /datum/species_form/alien/sentinel

	has_organ = list(
		BP_HEART =  /obj/item/organ/internal/vital/heart,
		BP_BRAIN =  /obj/item/organ/internal/vital/brain/xeno,
		BP_PLASMA = /obj/item/organ/internal/xenos/plasmavessel/sentinel,
		O_ACID =   /obj/item/organ/internal/xenos/acidgland,
		BP_HIVE =   /obj/item/organ/internal/xenos/hivenode,
	)

	inherent_verbs = list(
		/mob/living/proc/ventcrawl,
		/mob/living/carbon/human/proc/tackle
	)

/datum/species/xenos/queen

	name = "Xenomorph Queen"
	total_health = 250
	weeds_heal_rate = 5
	weeds_plasma_rate = 20
	caste_name = "queen"
	slowdown = 4
	rarity_value = 10

	default_form = /datum/species_form/alien/queen

	has_organ = list(
		BP_HEART =  /obj/item/organ/internal/vital/heart,
		BP_BRAIN =  /obj/item/organ/internal/vital/brain/xeno,
		O_EGG =    /obj/item/organ/internal/xenos/eggsac,
		BP_PLASMA = /obj/item/organ/internal/xenos/plasmavessel/queen,
		O_ACID =   /obj/item/organ/internal/xenos/acidgland,
		BP_HIVE =   /obj/item/organ/internal/xenos/hivenode,
		O_RESIN =  /obj/item/organ/internal/xenos/resinspinner,
	)

	inherent_verbs = list(
		/mob/living/proc/ventcrawl,
		/mob/living/carbon/human/proc/psychic_whisper
	)

/datum/species/xenos/queen/handle_login_special(var/mob/living/carbon/human/H)
	..()
	// Make sure only one official queen exists at any point.
	if(!alien_queen_exists(1,H))
		H.real_name = "alien queen ([alien_number])"
		H.name = H.real_name
	else
		H.real_name = "alien princess ([alien_number])"
		H.name = H.real_name

/datum/hud_data/alien

	icon = 'icons/mob/screen1_alien.dmi'
/*	has_a_intent =  1
	has_m_intent =  1
	has_warnings =  1
	has_hands =     1
	has_drop =      1
	has_throw =     1
	has_resist =    1
	has_pressure =  0
	has_nutrition = 0
	has_bodytemp =  0*/
	has_internals = 0

	gear = list(
	"belt" =         slot_belt,
	"l_hand" =       slot_l_hand,
	"r_hand" =       slot_r_hand,
	"mask" =         slot_wear_mask,
	"head" =         slot_head,
	"storage1" =     slot_l_store,
	"storage2" =     slot_r_store
	)