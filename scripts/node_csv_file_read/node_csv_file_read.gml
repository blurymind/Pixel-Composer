function Node_create_CSV_File_Read(_x, _y, _group = -1) {
	var path = "";
	if(!LOADING && !APPENDING) {
		path = get_open_filename(".csv", "");
		if(path == "") return noone;
	}
	
	var node = new Node_CSV_File_Read(_x, _y, _group);
	node.inputs[| 0].setValue(path);
	node.doUpdate();
	
	return node;
}

function Node_create_CSV_File_Read_path(_x, _y, path) {
	if(!file_exists(path)) return noone;
	
	var node = new Node_CSV_File_Read(_x, _y);
	node.inputs[| 0].setValue(path);
	node.doUpdate();
	
	return node;	
}

function Node_CSV_File_Read(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "CSV in";
	color = COLORS.node_blend_input;
	previewable = false;
	
	w = 128;
	min_h = 0;
	
	inputs[| 0]  = nodeValue(0, "Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")
		.setDisplay(VALUE_DISPLAY.path_load, ["*.csv", ""]);
		
	inputs[| 1]  = nodeValue(1, "Convert to number", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	outputs[| 0] = nodeValue(0, "Content", self, JUNCTION_CONNECT.output, VALUE_TYPE.text, "");
	
	outputs[| 1] = nodeValue(1, "Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.path, "")
		.setVisible(true, true);
	
	content = "";
	path_current = "";
	
	first_update = false;
	
	on_dragdrop_file = function(path) {
		if(updatePaths(path)) {
			doUpdate();
			return true;
		}
		
		return false;
	}
	
	function updatePaths(path) {
		if(path_current == path) return false;
		
		path = try_get_path(path);
		if(path == -1) return false;
		
		var ext = filename_ext(path);
		var _name = string_replace(filename_name(path), filename_ext(path), "");
		
		if(ext != ".csv") return false;
			
		outputs[| 1].setValue(path);
		
		var f = file_text_open_read(path);
		content = file_text_read_all_lines(f);
		file_text_close(f);
		
		var convert = inputs[| 1].getValue();
		if(convert) {
			for( var i = 0; i < array_length(content); i++ ) {
				var c = content[i];
				
				if(is_array(c)) {
					for( var j = 0; j < array_length(c); j++ )
						content[i][j] = toNumber(c[j]);
				} else 
					content[i] = toNumber(c);
			}
		}
		
		if(path_current == "") 
			first_update = true;
		path_current = path;
				
		return true;
	}
	
	static update = function() {
		var path = inputs[| 0].getValue();
		if(path == "") return;
		updatePaths(path);
		
		outputs[| 0].setValue(content);
	}
	
	function onDrawNode(xx, yy, _mx, _my, _s) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		var str = filename_name(path_current);
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}