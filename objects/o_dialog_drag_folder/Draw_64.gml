/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(THEME.dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched_ext(THEME.dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h, COLORS._main_accent, 1);
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text_title);
	draw_text(dialog_x + ui(24), dialog_y + ui(16), "Import directory");
#endregion

#region directory option
	var dir_y = dialog_y + ui(44);
	
	cb_recursive.active = sFOCUS;
	cb_recursive.hover  = sHOVER;
	cb_recursive.draw(dialog_x + dialog_w - ui(48), dir_y, dir_recursive, mouse_ui);
		
	draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
	draw_text(dialog_x + ui(20), dir_y + ui(14), "Recursive");
	
	dir_y += ui(40);
	tb_filter.active = sFOCUS;
	tb_filter.hover  = sHOVER;
	tb_filter.draw(dialog_x + ui(100), dir_y, dialog_w - ui(120), ui(36), dir_filter, mouse_ui);
		
	draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
	draw_text(dialog_x + ui(20), dir_y + ui(18), "Filter");
	
	var bx = dialog_x + dialog_w - ui(120);
	dir_y += ui(48);
	
	if(buttonInstant(THEME.button, bx, dir_y, ui(100), ui(40), mouse_ui, sFOCUS, sHOVER) == 2) {
		if(target) {
			var paths = paths_to_array(dir_paths, dir_recursive, dir_filter);
			target.updatePaths(paths);
			target.doUpdate();
		}
		instance_destroy();
	}
	
	draw_set_text(f_p0b, fa_center, fa_center, COLORS._main_text_accent);
	draw_text(bx + ui(50), dir_y + ui(20), "Import");
#endregion