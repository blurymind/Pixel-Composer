function Node_Noise_Hex(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Hexagonal noise";
	
	shader = sh_noise_grid_hex;
	uniform_dim = shader_get_uniform(shader, "dimension");
	uniform_sed = shader_get_uniform(shader, "seed");
	uniform_pos = shader_get_uniform(shader, "position");
	uniform_sca = shader_get_uniform(shader, "scale");
	uniform_ang = shader_get_uniform(shader, "angle");
	
	uniform_sam = shader_get_uniform(shader, "useSampler");
	
	inputs[| 0] = nodeValue(0, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2 )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue(1, "Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, irandom(99999));
	
	inputs[| 2] = nodeValue(2, "Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue(3, "Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 8, 8 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 4] = nodeValue(4, "Texture sample", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
		
	input_display_list = [
		["Output",	false], 0, 
		["Noise",	false], 1, 2, 3,
		["Texture",	false], 4,
	];
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[| 2].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = _data[0];
		var _sed = _data[1];
		var _pos = _data[2];
		var _sca = _data[3];
		var _sam = _data[4];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		surface_set_target(_outSurf);
		shader_set(shader);
			shader_set_uniform_f_array(uniform_dim, [_dim[0], _dim[1]]);
			shader_set_uniform_f(uniform_sed, _sed);
			shader_set_uniform_f_array(uniform_pos, _pos);
			shader_set_uniform_f_array(uniform_sca, _sca);
			shader_set_uniform_i(uniform_sam, is_surface(_sam));
			
			if(is_surface(_sam))
				draw_surface_stretched(_sam, 0, 0, _dim[0], _dim[1]);
			else
				draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		shader_reset();
		surface_reset_target();
		
		return _outSurf;
	}
}