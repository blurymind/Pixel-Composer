function buttonGradient(_onApply) {
	return new buttonGradientClass(_onApply);
}

function buttonGradientClass(_onApply) constructor {
	active = false;
	hover  = false;
	
	onApply = _onApply;
	
	static draw = function(_x, _y, _w, _h, _gradient, _data, _m) {
		var click = false;
		if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h)) {
			draw_sprite_stretched(THEME.button, 1, _x, _y, _w, _h);	
			if(mouse_press(mb_left, active)) {
				var dialog = dialogCall(o_dialog_gradient, WIN_W / 2, WIN_H / 2);
				dialog.setGradient(_gradient, _data);
				dialog.onApply = onApply;
				click = true;
			}
			if(mouse_click(mb_left, active))
				draw_sprite_stretched(THEME.button, 2, _x, _y, _w, _h);	
		} else {
			draw_sprite_stretched(THEME.button, 0, _x, _y, _w, _h);		
		}
		
		draw_gradient(_x + ui(6), _y + ui(6), _w - ui(12), _h - ui(12), _gradient, _data[| 0]);
		
		hover  = false;
		active = false;
		
		return click;
	}
}