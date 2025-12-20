/area/event
	area_light_color = COLOR_LIGHTING_DEFAULT_DARK
	ambience = list()
	dynamic_lighting = FALSE
	flags = null
	ship_area = FALSE
	prevent_ship_area = TRUE

/area/event/outside //not full bright
	ambience = list('sound/ambience/windamb1.ogg','sound/ambience/windamb2.ogg',) //for the snowyness
	dynamic_lighting = TRUE
	flags = null
	ship_area = TRUE
	prevent_ship_area = FALSE
