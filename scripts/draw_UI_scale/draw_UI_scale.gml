function line_height(font = noone, offset = 0) {
	var ff = draw_get_font();
	
	if(font != noone)
		draw_set_font(font);
	var hh = string_height("l") + offset * UI_SCALE;
	
	draw_set_font(ff);
	return hh;
}

#macro TEXTBOX_HEIGHT line_height(f_p0, 12)

gml_pragma("forceinline");
function ui(val) { return val * UI_SCALE; }