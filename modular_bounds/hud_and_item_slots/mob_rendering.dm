/// Updates the socks slot overlay
/mob/proc/update_worn_socks()

/mob/living/carbon/human/update_worn_socks()
	remove_overlay(SOCKS_LAYER)
	hud_used?.update_inventory_slot(ITEM_SLOT_SOCKS)
	if(num_legs < 2)
		return
	if(wear_socks)
		var/obj/item/worn_item = wear_socks
		if(HAS_TRAIT(worn_item, TRAIT_NO_WORN_ICON) || (obscured_slots & HIDEBELT))
			return
		var/icon_file = 'icons/mob/clothing/belt.dmi'
		var/mutable_appearance/clothing_overlay = worn_item.build_worn_icon(default_layer = SOCKS_LAYER, default_icon_file = icon_file, bodyshape = bodyshape)
		apply_height(clothing_overlay, ENTIRE_BODY)
		overlays_standing[SOCKS_LAYER] = clothing_overlay
	apply_overlay(SOCKS_LAYER)

/// Updates the specstorage slot overlay
/mob/proc/update_worn_specstorage()

/mob/living/carbon/human/update_worn_specstorage()
	remove_overlay(SPECSTORAGE_LAYER)
	hud_used?.update_inventory_slot(ITEM_SLOT_SPECSTORAGE)
	if(wear_specstorage)
		var/obj/item/worn_item = wear_specstorage
		if(HAS_TRAIT(worn_item, TRAIT_NO_WORN_ICON))
			return
		var/icon_file = 'icons/mob/clothing/belt.dmi'
		var/mutable_appearance/clothing_overlay = worn_item.build_worn_icon(default_layer = SPECSTORAGE_LAYER, default_icon_file = icon_file, bodyshape = bodyshape)
		apply_height(clothing_overlay, ENTIRE_BODY)
		var/obj/item/bodypart/chest/my_chest = get_bodypart(BODY_ZONE_CHEST)
		my_chest?.worn_back_offset?.apply_offset(clothing_overlay)
		overlays_standing[SPECSTORAGE_LAYER] = clothing_overlay
	apply_overlay(SPECSTORAGE_LAYER)

/// Updates the armor slot overlay
/mob/proc/update_worn_armor()

/mob/living/carbon/human/update_worn_armor()
	remove_overlay(ARMOR_LAYER)
	hud_used?.update_inventory_slot(ITEM_SLOT_ARMOR)
	if(wear_armor)
		var/obj/item/worn_item = wear_armor
		if(HAS_TRAIT(worn_item, TRAIT_NO_WORN_ICON))
			return
		var/icon_file = 'icons/mob/clothing/belt.dmi'
		var/mutable_appearance/clothing_overlay = worn_item.build_worn_icon(default_layer = ARMOR_LAYER, default_icon_file = icon_file, bodyshape = bodyshape)
		apply_height(clothing_overlay, ENTIRE_BODY)
		var/obj/item/bodypart/chest/my_chest = get_bodypart(BODY_ZONE_CHEST)
		my_chest?.worn_suit_offset?.apply_offset(clothing_overlay)
		overlays_standing[ARMOR_LAYER] = clothing_overlay
	apply_overlay(ARMOR_LAYER)

/// Updates the underwear bottom slot overlay
/mob/proc/update_worn_underbottom()

/mob/living/carbon/human/update_worn_underbottom()
	remove_overlay(UNDERWEAR_BOTTOM_LAYER)
	hud_used?.update_inventory_slot(ITEM_SLOT_UNDERBOTTOM)
	if(wear_underbottom)
		var/obj/item/worn_item = wear_underbottom
		if(HAS_TRAIT(worn_item, TRAIT_NO_WORN_ICON) || (obscured_slots & HIDEUNDERBOTTOMS))
			return
		var/icon_file = 'icons/mob/clothing/belt.dmi'
		var/mutable_appearance/clothing_overlay = worn_item.build_worn_icon(default_layer = UNDERWEAR_BOTTOM_LAYER, default_icon_file = icon_file, bodyshape = bodyshape)
		apply_height(clothing_overlay, ENTIRE_BODY)
		var/obj/item/bodypart/chest/my_chest = get_bodypart(BODY_ZONE_CHEST)
		my_chest?.worn_uniform_offset?.apply_offset(clothing_overlay)
		overlays_standing[UNDERWEAR_BOTTOM_LAYER] = clothing_overlay
	apply_overlay(UNDERWEAR_BOTTOM_LAYER)

/// Updates the underwear top slot overlay
/mob/proc/update_worn_undertop()

/mob/living/carbon/human/update_worn_undertop()
	remove_overlay(UNDERWEAR_TOP_LAYER)
	hud_used?.update_inventory_slot(ITEM_SLOT_UNDERTOP)
	if(wear_undertop)
		var/obj/item/worn_item = wear_undertop
		if(HAS_TRAIT(worn_item, TRAIT_NO_WORN_ICON) || (obscured_slots & HIDEUNDERTOPS))
			return
		var/icon_file = 'icons/mob/clothing/belt.dmi'
		var/mutable_appearance/clothing_overlay = worn_item.build_worn_icon(default_layer = UNDERWEAR_TOP_LAYER, default_icon_file = icon_file, bodyshape = bodyshape)
		apply_height(clothing_overlay, ENTIRE_BODY)
		var/obj/item/bodypart/chest/my_chest = get_bodypart(BODY_ZONE_CHEST)
		my_chest?.worn_uniform_offset?.apply_offset(clothing_overlay)
		overlays_standing[UNDERWEAR_TOP_LAYER] = clothing_overlay
	apply_overlay(UNDERWEAR_TOP_LAYER)
