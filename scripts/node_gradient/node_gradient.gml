function Node_Gradient(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Gradient";
	
	shader = sh_gradient;
	uniform_grad_blend	= shader_get_uniform(shader, "gradient_blend");
	uniform_grad		= shader_get_uniform(shader, "gradient_color");
	uniform_grad_time	= shader_get_uniform(shader, "gradient_time");
	uniform_grad_key	= shader_get_uniform(shader, "gradient_keys");
	uniform_grad_loop	= shader_get_uniform(shader, "gradient_loop");
	
	uniform_type		= shader_get_uniform(shader, "type");
	uniform_center		= shader_get_uniform(shader, "center");
	
	uniform_angle		= shader_get_uniform(shader, "angle");
	uniform_radius		= shader_get_uniform(shader, "radius");
	uniform_radius_shf	= shader_get_uniform(shader, "shift");
	
	inputs[| 0] = nodeValue(0, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2 )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue(1, "Gradient", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white)
		.setDisplay(VALUE_DISPLAY.gradient);
	
	inputs[| 2] = nodeValue(2, "Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Linear", "Circular", "Radial" ]);
	
	inputs[| 3] = nodeValue(3, "Angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.rotation);

	inputs[| 4] = nodeValue(4, "Radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, .5);
		
	inputs[| 5] = nodeValue(5, "Shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [-2, 2, 0.01]);
	
	inputs[| 6] = nodeValue(6, "Center", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [def_surf_size / 2, def_surf_size / 2])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 7] = nodeValue(7, "Loop", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 8] = nodeValue(8, "Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	input_display_list = [
		["Output",		true],	0, 8, 
		["Gradient",	false], 1, 5, 7,
		["Shape",		false], 2, 3, 4, 6
	];
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[| 6].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = _data[0];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
			
		var _gra = _data[1];
		var _gra_data = inputs[| 1].getExtraData();
		
		var _typ = _data[2];
		var _ang = _data[3];
		var _rad = _data[4];
		var _shf = _data[5];
		var _cnt = _data[6];
		var _lop = _data[7];
		var _msk = _data[8];
		var _grad_color = [];
		var _grad_time  = [];
		
		for(var i = 0; i < ds_list_size(_gra); i++) {
			_grad_color[i * 4 + 0] = color_get_red(_gra[| i].value) / 255;
			_grad_color[i * 4 + 1] = color_get_green(_gra[| i].value) / 255;
			_grad_color[i * 4 + 2] = color_get_blue(_gra[| i].value) / 255;
			_grad_color[i * 4 + 3] = 1;
			_grad_time[i]  = _gra[| i].time;
		}
		
		if(_typ == 0 || _typ == 2) {
			inputs[| 3].setVisible(true);
			inputs[| 4].setVisible(false);
		} else if(_typ == 1) {
			inputs[| 3].setVisible(false);
			inputs[| 4].setVisible(true);
		}
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		shader_set(shader);
			shader_set_uniform_i(uniform_grad_blend, ds_list_get(_gra_data, 0));
			shader_set_uniform_f_array(uniform_grad, _grad_color);
			shader_set_uniform_f_array(uniform_grad_time, _grad_time);
			shader_set_uniform_i(uniform_grad_key, ds_list_size(_gra));
			shader_set_uniform_i(uniform_grad_loop, _lop);
			
			shader_set_uniform_f_array(uniform_center, [_cnt[0] / _dim[0], _cnt[1] / _dim[1]]);
			shader_set_uniform_i(uniform_type, _typ);
			
			shader_set_uniform_f(uniform_angle, degtorad(_ang));
			shader_set_uniform_f(uniform_radius, _rad * sqrt(2));
			shader_set_uniform_f(uniform_radius_shf, _shf);
			
			BLEND_OVER
			if(is_surface(_msk))
				draw_surface_stretched_ext(_msk, 0, 0, _dim[0], _dim[1], c_white, 1);
			else
				draw_sprite_stretched_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], c_white, 1);
			BLEND_NORMAL
		shader_reset();
		surface_reset_target();
		
		return _outSurf;
	}
}