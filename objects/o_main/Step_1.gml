/// @description init
#region window
	//if(keyboard_check_pressed(vk_f12)) DEBUG = !DEBUG;
	
	if(_cursor != CURSOR) {
		window_set_cursor(CURSOR);
		_cursor = CURSOR;
	}
	CURSOR = cr_default;
	
	if((win_wp != WIN_W || win_hp != WIN_H) && (WIN_W > 1 && WIN_H > 1)) {
		display_refresh();
		Render();
	}
#endregion

#region focus
	HOVER = noone;
	
	if(PANEL_MAIN != 0)
		PANEL_MAIN.stepBegin();
	DIALOG_DEPTH_HOVER = 0;
	
	with(_p_dialog) {
		checkFocus();	
	}
#endregion

#region nodes
	var _k = ds_map_find_first(NODE_MAP);
	var _a = ds_map_size(NODE_MAP);
	repeat(_a) {
		NODE_MAP[? _k].stepBegin();
		_k = ds_map_find_next(NODE_MAP, _k);
	}
	
	if(UPDATE & RENDER_TYPE.full || ANIMATOR.rendering)
		Render();
	if(UPDATE & RENDER_TYPE.partial)
		Render(true);
	UPDATE = RENDER_TYPE.none;
#endregion

#region clicks
	DOUBLE_CLICK = false;
	if(mouse_press(mb_left)) {
		if(dc_check > 0) {
			DOUBLE_CLICK = true;
			dc_check = 0;
		} else
			dc_check = PREF_MAP[? "double_click_delay"];
	}
	
	dc_check -= DELTA_TIME;
#endregion

#region step
	if(array_length(action_last_frame) > 0) {
		ds_stack_push(UNDO_STACK, action_last_frame);
		ds_stack_clear(REDO_STACK);
	}
	action_last_frame = [];
#endregion

#region dialog
	if(!ds_list_empty(DIALOGS))
		DIALOGS[| ds_list_size(DIALOGS) - 1].checkMouse();
	
	if(mouse_release(mb_left))
		DIALOG_CLICK = true;
#endregion

#region modifiers
	if(CTRL == KEYBOARD_STATUS.down)
		CTRL  = KEYBOARD_STATUS.pressing;
	if(SHIFT == KEYBOARD_STATUS.down)
		SHIFT  = KEYBOARD_STATUS.pressing;
	if(ALT == KEYBOARD_STATUS.down)
		ALT  = KEYBOARD_STATUS.pressing;
		
	if(CTRL == KEYBOARD_STATUS.up)
		CTRL  = KEYBOARD_STATUS.idle;
	if(SHIFT == KEYBOARD_STATUS.up)
		SHIFT  = KEYBOARD_STATUS.idle;
	if(ALT == KEYBOARD_STATUS.up)
		ALT  = KEYBOARD_STATUS.idle;

	if(keyboard_check_pressed(vk_control))
		CTRL  = KEYBOARD_STATUS.down;
	if(keyboard_check_pressed(vk_shift))
		SHIFT = KEYBOARD_STATUS.down;
	if(keyboard_check_pressed(vk_alt))
		ALT  = KEYBOARD_STATUS.down;
	
	if(keyboard_check_released(vk_control))
		CTRL  = KEYBOARD_STATUS.up;
	if(keyboard_check_released(vk_shift))
		SHIFT = KEYBOARD_STATUS.up;
	if(keyboard_check_released(vk_alt))
		ALT  = KEYBOARD_STATUS.up;	
#endregion

#region mouse wrap
	MOUSE_WRAPPING = max(0, MOUSE_WRAPPING - 1);
	
	if(MOUSE_WRAP) {
		var _pad = 2;
		
		if(mouse_x < _pad) {
			window_mouse_set(window_get_width() - _pad, mouse_y);
			MOUSE_WRAPPING = 2;
		} else if(mouse_x > window_get_width() - _pad) {
			window_mouse_set(_pad, mouse_y);
			MOUSE_WRAPPING = 2;
		}
			
		if(mouse_y < _pad) {
			window_mouse_set(mouse_x, window_get_height() - _pad);
			MOUSE_WRAPPING = 2;
		} else if(mouse_y > window_get_height() - _pad) {
			window_mouse_set(mouse_x, _pad);
			MOUSE_WRAPPING = 2;
		}
	}
	MOUSE_WRAP = false;
#endregion

//if(KEYBOARD_PRESSED) print(string(KEYBOARD_PRESSED) + " | " + string(irandom_range(10000, 99999)))