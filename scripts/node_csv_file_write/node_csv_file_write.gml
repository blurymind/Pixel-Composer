function Node_create_CSV_File_Write(_x, _y, _group = -1) {
	var path = "";
	
	var node = new Node_CSV_File_Write(_x, _y, _group);
	node.inputs[| 0].setValue(path);
	node.doUpdate();
	
	return node;
}

function Node_CSV_File_Write(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "CSV out";
	color = COLORS.node_blend_input;
	previewable = false;
	
	w = 128;
	min_h = 0;
	
	inputs[| 0]  = nodeValue(0, "Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")
		.setDisplay(VALUE_DISPLAY.path_save, ["*.csv", ""]);
	
	inputs[| 1]  = nodeValue(1, "Content", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, "")
		.setDisplay(true);
	
	static update = function() {
		var path = inputs[| 0].getValue();
		if(path == "") return;
		if(filename_ext(path) != ".csv")
			path += ".csv";
		
		var _val = inputs[| 1].getValue();
		var str = "";
		
		if(is_array(_val)) {
			for( var i = 0; i < array_length(_val); i++ ) {
				if(is_array(_val[i])) {
					for( var j = 0; j < array_length(_val[i]); j++ )
						str += (j? ", " : "") + string(_val[i][j])
					str += "\n";
				} else 
					str += (i? ", " : "") + string(_val[i])
			}
		} else 
			str = string(_val);
		
		var f = file_text_open_write(path);
		file_text_write_string(f, str);
		file_text_close(f);
	}
	
	function onDrawNode(xx, yy, _mx, _my, _s) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		var str = filename_name(inputs[| 0].getValue());
		if(filename_ext(str) != ".csv")
			str += ".csv";
			
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}