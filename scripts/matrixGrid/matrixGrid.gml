function matrixGrid(_type, _onModify, _unit = noone) constructor {
	size	 = 9;
	onModify = _onModify;
	unit	 = _unit;
	
	hover  = false;
	active = false;
	linked = false;
	b_link = button(function() { linked = !linked; });
	b_link.icon = THEME.value_link;
	
	onModifyIndex = function(index, val) { 
		if(linked) {
			for( var i = 0; i < size; i++ )
				onModify(i, toNumber(val)); 
			return;
		}
		
		onModify(index, toNumber(val)); 
	}
	
	onModifySingle[0] = function(val) { onModifyIndex(0, val); }
	onModifySingle[1] = function(val) { onModifyIndex(1, val); }
	onModifySingle[2] = function(val) { onModifyIndex(2, val); }
	
	onModifySingle[3] = function(val) { onModifyIndex(3, val); }
	onModifySingle[4] = function(val) { onModifyIndex(4, val); }
	onModifySingle[5] = function(val) { onModifyIndex(5, val); }
	
	onModifySingle[6] = function(val) { onModifyIndex(6, val); }
	onModifySingle[7] = function(val) { onModifyIndex(7, val); }
	onModifySingle[8] = function(val) { onModifyIndex(8, val); }
	
	extras = -1;
	
	for(var i = 0; i < size; i++) {
		tb[i] = new textBox(_type, onModifySingle[i]);
		tb[i].slidable = true;
	}
	
	static draw = function(_x, _y, _w, _h, _data, _m) {
		if(extras && instanceof(extras) == "buttonClass") {
			extras.hover  = hover;
			extras.active = active;
			
			extras.draw(_x + _w - ui(32), _y + _h / 2 - ui(32 / 2), ui(32), ui(32), _m, THEME.button_hide);
			_w -= ui(40);
		}
		
		if(unit != noone && unit.reference != noone) {
			_w += ui(4);
			
			unit.triggerButton.hover  = hover;
			unit.triggerButton.active = active;
			
			unit.draw(_x + _w - ui(32), _y + _h / 2 - ui(32 / 2), ui(32), ui(32), _m);
			_w -= ui(40);
		}
		
		b_link.hover = hover;
		b_link.active = active;
		b_link.icon_index = linked;
		b_link.icon_blend = linked? COLORS._main_accent : COLORS._main_icon;
		b_link.tooltip = linked? "Unlink values" : "Link values";
		
		var hh = TEXTBOX_HEIGHT + ui(8);
		var th = hh * 3 - ui(8);
		
		var bx = _x;
		var by = _y + th / 2 - ui(32 / 2);
		b_link.draw(bx + ui(4), by + ui(4), ui(24), ui(24), _m, THEME.button_hide);
		
		_x += ui(28);
		_w -= ui(28);
		
		var ww = _w / 3;
		
		for(var i = 0; i < 3; i++)
		for(var j = 0; j < 3; j++) {
			var ind = i * 3 + j;
			tb[ind].hover  = hover;
			tb[ind].active = active;
			
			var bx  = _x + ww * j;
			var by  = _y + hh * i;
			
			tb[ind].draw(bx + ui(8), by, ww - ui(8), TEXTBOX_HEIGHT, _data[ind], _m);
		}
		
		hover  = false;
		active = false;
		
		return th;
	}
}