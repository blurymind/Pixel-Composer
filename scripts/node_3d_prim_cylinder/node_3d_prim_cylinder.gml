function Node_3D_Cylinder(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "3D Cylinder";
	dimension_index = 2;
	
	inputs[| 0] = nodeValue(0, "Sides", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 16);
	
	inputs[| 1] = nodeValue(1, "Thickness", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2);
		
	inputs[| 2] = nodeValue(2, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue(3, "Render position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ def_surf_size / 2, def_surf_size / 2 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 4] = nodeValue(4, "Render rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 5] = nodeValue(5, "Render scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 6] = nodeValue(6, "Textures top",	self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 7] = nodeValue(7, "Textures bottom", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 8] = nodeValue(8, "Textures side",	self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 9] = nodeValue(9, "Object scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 10] = nodeValue(10, "Light direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
		
	inputs[| 11] = nodeValue(11, "Light height", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, [-1, 1, 0.01]);
		
	inputs[| 12] = nodeValue(12, "Light intensity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 13] = nodeValue(13, "Light color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	inputs[| 14] = nodeValue(14, "Ambient color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_grey);
	
	inputs[| 15] = nodeValue(15, "Object rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 16] = nodeValue(16, "Object position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 17] = nodeValue(17, "Projection", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Orthographic", "Perspective" ]);
		
	inputs[| 18] = nodeValue(18, "Field of view", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 60)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 90, 1 ]);
		
	inputs[| 19] = nodeValue(19, "Taper", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01 ]);
	
	input_display_list = [2, 
		["Geometry",			false], 0, 1, 19,
		["Object transform",	false], 16, 15, 9,
		["Camera",				false], 17, 18, 3, 5, 
		["Texture",				 true], 6, 7, 8,
		["Light",				false], 10, 11, 12, 13, 14,
	];
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	outputs[| 1] = nodeValue(1, "3D object", self, JUNCTION_CONNECT.output, VALUE_TYPE.d3object, function() { return submit_vertex(); });
	
	outputs[| 2] = nodeValue(2, "Normal pass", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	output_display_list = [
		0, 2, 1
	]
	
	_3d_node_init(2, /*Transform*/ 3, 15, 5);
	
	sides = 16;
	taper = 1;
	thick =  0.5;
	VB_top = vertex_create_buffer();
	VB_sid = vertex_create_buffer();
	
	static generate_vb = function() {
		var _ox, _oy, _nx, _ny, _ou, _nu;
		
		vertex_begin(VB_top, FORMAT_PNT);
		for(var i = 0; i <= sides; i++)  {
			_nx = lengthdir_x(0.5, i * 360 / sides);
			_ny = lengthdir_y(0.5, i * 360 / sides);
			
			if(i) {
				vertex_add_pnt(VB_top, [  0, thick / 2,   0], [0, 1, 0], [  0 + 0.5,   0 + 0.5]);
				vertex_add_pnt(VB_top, [_ox, thick / 2, _oy], [0, 1, 0], [_ox + 0.5, _oy + 0.5]);
				vertex_add_pnt(VB_top, [_nx, thick / 2, _ny], [0, 1, 0], [_nx + 0.5, _ny + 0.5]);
			}
			
			_ox = _nx;
			_oy = _ny;
		}
		
		vertex_end(VB_top);
		
		vertex_begin(VB_sid, FORMAT_PNT);
		for(var i = 0; i <= sides; i++)  {
			_nx = lengthdir_x(0.5, i * 360 / sides);
			_ny = lengthdir_y(0.5, i * 360 / sides);
			_nu = i / sides;
			
			var nrm_y = 1 - taper;
			
			if(i) {
				vertex_add_pnt(VB_sid, [_ox * taper, -thick / 2, _oy * taper], [_nx, nrm_y, _ny], [_ou, 0]);
				vertex_add_pnt(VB_sid, [_ox,          thick / 2, _oy        ], [_nx, nrm_y, _ny], [_ou, 1]);
				vertex_add_pnt(VB_sid, [_nx,          thick / 2, _ny        ], [_nx, nrm_y, _ny], [_nu, 1]);
																	        
				vertex_add_pnt(VB_sid, [_nx,          thick / 2, _ny        ], [_nx, nrm_y, _ny], [_nu, 1]);
				vertex_add_pnt(VB_sid, [_nx * taper, -thick / 2, _ny * taper], [_nx, nrm_y, _ny], [_nu, 0]);
				vertex_add_pnt(VB_sid, [_ox * taper, -thick / 2, _oy * taper], [_nx, nrm_y, _ny], [_ou, 0]);
			}
			
			_ox = _nx;
			_oy = _ny;
			_ou = _nu;
		}
		vertex_end(VB_sid);
	}
	generate_vb();
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		_3d_gizmo(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static submit_vertex = function(index = 0) {
		var _lpos = getSingleValue(16, index);
		var _lrot = getSingleValue(15, index);
		var _lsca = getSingleValue( 9, index);
		
		var face_top	= getSingleValue(6, index);
		var face_bot	= getSingleValue(7, index);
		var face_sid	= getSingleValue(8, index);
		
		_3d_local_transform(_lpos, _lrot, _lsca);
		
		matrix_set(matrix_world, matrix_stack_top());
		vertex_submit(VB_top, pr_trianglelist, surface_get_texture(face_top));
				
		matrix_stack_push(matrix_build(0, -thick, 0, 0, 0, 0, taper, 1, taper));
		matrix_set(matrix_world, matrix_stack_top());
		vertex_submit(VB_top, pr_trianglelist, surface_get_texture(face_bot));
		matrix_stack_pop();
				
		matrix_set(matrix_world, matrix_stack_top());
		vertex_submit(VB_sid, pr_trianglelist, surface_get_texture(face_sid));
		
		_3d_clear_local_transform();
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _sides = _data[0];
		var _thick = _data[1];
		var _taper = _data[19];
		
		if(_sides != sides || _thick != thick || _taper != taper) {
			sides = _sides;
			thick = _thick;
			taper = _taper;
			generate_vb();	
		}
		
		var _dim		= _data[2];
		var _pos		= _data[3];
		//var _rot		= _data[4];
		var _sca		= _data[5];
		var face_top	= _data[6];
		var face_bot	= _data[7];
		var face_sid	= _data[8];
		
		var _lpos = _data[16];
		var _lrot = _data[15];
		var _lsca = _data[ 9];
		
		var _ldir = _data[10];
		var _lhgt = _data[11];
		var _lint = _data[12];
		var _lclr = _data[13];
		var _aclr = _data[14];
		
		var _proj = _data[17];
		var _fov  = _data[18];
		
		inputs[| 18].setVisible(_proj);
		
		var pass = "diff";
		switch(_output_index) {
			case 0 : pass = "diff" break;
			case 2 : pass = "norm" break;
		}
		
		_3d_pre_setup(_outSurf, _dim, _pos, _sca, _ldir, _lhgt, _lint, _lclr, _aclr, _lpos, _lrot, _lsca, _proj, _fov, pass);
		
		matrix_set(matrix_world, matrix_stack_top());
		vertex_submit(VB_top, pr_trianglelist, surface_get_texture(face_top));
				
		matrix_stack_push(matrix_build(0, -thick, 0, 0, 0, 0, taper, 1, taper));
		matrix_set(matrix_world, matrix_stack_top());
		vertex_submit(VB_top, pr_trianglelist, surface_get_texture(face_bot));
		matrix_stack_pop();
				
		matrix_set(matrix_world, matrix_stack_top());
		vertex_submit(VB_sid, pr_trianglelist, surface_get_texture(face_sid));
		
		_3d_post_setup();
		
		return _outSurf;
	}
}