function Node_Convolution(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Convolution";
	
	shader = sh_convolution;
	uniform_dim = shader_get_uniform(shader, "dimension");
	uniform_ker = shader_get_uniform(shader, "kernel");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Kernel", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, array_create(9))
		.setDisplay(VALUE_DISPLAY.kernel);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _ker = _data[1];
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		BLEND_OVER
		
		shader_set(shader);
			shader_set_uniform_f(uniform_dim, surface_get_width(_outSurf), surface_get_height(_outSurf));
			shader_set_uniform_f_array(uniform_ker, _ker);
			draw_surface_safe(_data[0], 0, 0);
		shader_reset();
		
		BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}