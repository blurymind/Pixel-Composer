function DirectoryObject(name, path) constructor {
	self.name = name;
	self.path = path;
	
	subDir = ds_list_create();
	open = false;
	
	static destroy = function() {
		ds_list_destroy(subDir);
	}
	
	static getSub = function() {
		var _temp_name = ds_list_create();
		var folder = file_find_first(path + "/*", fa_directory);
		while(folder != "") {
			ds_list_add(_temp_name, folder);
			folder = file_find_next();
		}
		file_find_close();
		
		ds_list_clear(subDir);
		
		ds_list_sort(_temp_name, true);
		for( var i = 0; i < ds_list_size(_temp_name); i++ ) {
			var file = _temp_name[| i];
			
			if(directory_exists(path + "/" + file)) {
				var _fol_path = path + "/" + file;
				var fol = new DirectoryObject(file, _fol_path);
				ds_list_add(subDir, fol);
			}
		}
		
		ds_list_destroy(_temp_name);
	}
	getSub();
	
	static draw = function(_x, _y, _m, _w) {
		var hg = 28;
		var hh = 0;
		
		if(path == PANEL_COLLECTION.context.path)
			draw_sprite_stretched_ext(s_ui_panel_bg, 0, _x, _y, _w, hg, c_ui_blue_ltgrey, 1); 
		
		if(HOVER == PANEL_COLLECTION.panel && point_in_rectangle(_m[0], _m[1], 0, _y, _w, _y + hg - 1)) {
			draw_sprite_stretched_ext(s_ui_panel_bg, 0, _x, _y, _w, hg, c_ui_blue_white, 1);
			if(FOCUS == PANEL_COLLECTION.panel && mouse_check_button_pressed(mb_left)) {
				open = !open;
				
				if(PANEL_COLLECTION.context = self)
					PANEL_COLLECTION.setContext(COLLECTIONS);
				else
					PANEL_COLLECTION.setContext(self);
			}
		}
					
		draw_set_text(f_p0, fa_left, fa_center, c_white);
		if(ds_list_empty(subDir)) {
			draw_sprite_ext(s_folder_24, 0, _x + 16, _y + hg / 2 - 1, 1, 1, 0, c_ui_blue_dkgrey, 1);
		} else {
			draw_sprite_ext(s_folder_content_24, open, _x + 16, _y + hg / 2 - 1, 1, 1, 0, c_ui_blue_grey, 1);
		}
		draw_text(_x + 8 + 24, _y + hg / 2, name);
		hh += hg;
		_y += hg;
		
		if(open) {
			for(var i = 0; i < ds_list_size(subDir); i++) {
				var hg = subDir[| i].draw(_x + 16, _y, _m, _w - 16);
				hh += hg;
				_y += hg;
			}
		}
		
		return hh;
	}
}

function Panel_Collection(_panel) : PanelContent(_panel) constructor {
	group_w   = 180;
	content_w = w - 24 - group_w;
	content_h = h - 32 - 16;
	
	min_w = group_w + 40;
	min_h = 40; 
	
	context = COLLECTIONS;
	
	content_list = ds_list_create();
	
	file_dragging = noone;
	
	_menu_node = noone;
	contentPane = new scrollPane(content_w, content_h, function(_y, _m) {
		draw_clear_alpha(c_ui_blue_black, 0);
		if(content_list == -1) return 0;
		
		var grid_size  = 64;
		var grid_width = 80;
		var grid_space = 12;
		var nodes	   = content_list;
		var node_count = ds_list_size(nodes);
		var col        = max(1, floor(content_w / (grid_width + grid_space)));
		var row        = ceil(node_count / col);
		var hh         = grid_space;
		var yy         = _y + grid_space;
		var name_height = 0;
		
		for(var i = 0; i < row; i++) {
			name_height = 0;
			for(var j = 0; j < col; j++) {
				var index = i * col + j;
				if(index < node_count) {
					var _node = nodes[| index];
					var _nx   = grid_space + (grid_width + grid_space) * j;
					var _boxx = _nx + (grid_width - grid_size) / 2;
					
					draw_sprite_stretched(s_node_bg, 0, _boxx, yy, grid_size, grid_size);
					if(point_in_rectangle(_m[0], _m[1], _nx, yy, _nx + grid_width, yy + grid_size)) {
						draw_sprite_stretched(s_node_active, 0, _boxx, yy, grid_size, grid_size);	
						if(mouse_check_button_pressed(mb_left)) {
							file_dragging = _node;
						}
						
						if(mouse_check_button_pressed(mb_right)) {
							_menu_node = _node;
							var dia = dialogCall(o_dialog_menubox, mouse_mx + 8, mouse_my + 8);
							dia.setMenu([ 
								[ "Replace with selected", function() { 
									saveCollection(_menu_node.path, false);
								} ],
								[ "Delete", function() { 
									file_delete(_menu_node.path);
								} ],
							]);	
						}
					}
					
					if(_node.spr) {
						var ss = 32 / max(sprite_get_width(_node.spr), sprite_get_height(_node.spr));
						draw_sprite_ext(_node.spr, current_time / 60, _boxx + grid_size / 2, yy + grid_size / 2, ss, ss, 0, c_white, 1);
					} else {
						draw_sprite_ext(s_group_24, 0, _boxx + grid_size / 2, yy + grid_size / 2, 1, 1, 0, c_white, 1);
					}
					
					draw_set_text(f_p0, fa_center, fa_top, c_white);
					name_height = max(name_height, string_height_ext(_node.name, -1, grid_size) + 8);
					draw_text_ext(_boxx + grid_size / 2, yy + grid_size + 4, _node.name, -1, grid_width);
				}
			}
			var hght = grid_size + grid_space + name_height;
			hh += hght;
			yy += hght;
		}
		
		return hh;
	});
	
	folderPane = new scrollPane(group_w - 8, content_h, function(_y, _m) {
		draw_clear(c_ui_blue_black);
		var hh = 0;
		
		for(var i = 0; i < ds_list_size(COLLECTIONS.subDir); i++) {
			var hg = COLLECTIONS.subDir[| i].draw(8, _y, _m, folderPane.w - 16);
			hh += hg;
			_y += hg;
		}
		
		return hh;
	});
	
	function onResize() {
		content_w = w - 24 - group_w;
		content_h = h - 32 - 16;
		contentPane.resize(content_w, content_h);
		folderPane.resize(group_w - 8, content_h);
	}
	
	function buildNode(_node) {
		if(!_node) return noone;
		return _node.build(0, 0);
	}
	
	function setContext(cont) {
		context = cont;
		searchContent();
		contentPane.scroll_y_raw = 0;
		contentPane.scroll_y_to	 = 0;
	}
	
	function searchContent() {
		if(content_list != -1 && ds_exists(content_list, ds_type_list)) {
			for( var i = 0; i < ds_list_size(content_list); i++ ) {
				var _f = content_list[| i];
				if(_f.spr && sprite_exists(_f.spr)) 
					sprite_delete(_f.spr);
				delete _f;
			}
			ds_list_clear(content_list);
		} else
			content_list = ds_list_create();
		
		var _path = context.path;
		
		var _temp_name = ds_list_create();
		var folder = file_find_first(_path + "/*", fa_directory);
		while(folder != "") {
			ds_list_add(_temp_name, folder);
			folder = file_find_next();
		}
		file_find_close();
		
		ds_list_sort(_temp_name, true);
		for( var i = 0; i < ds_list_size(_temp_name); i++ ) {
			var file = _temp_name[| i];
			
			if(filename_ext(file) == ".json" || filename_ext(file) == ".pxcc") {
				var f = new FileContext(string_copy(file, 1, string_length(file) - 5), _path + "/" + file);
				ds_list_add(content_list, f);
				var icon_path = _path + "/" + string_copy(file, 1, string_length(file) - 5) + ".png";
				
				if(file_exists(icon_path)) {
					var _temp = sprite_add(icon_path, 0, false, false, 0, 0);
					var ww = sprite_get_width(_temp);
					var hh = sprite_get_height(_temp);
					var amo = ww % hh == 0? ww / hh : 1;
					sprite_delete(_temp);
					
					f.spr = sprite_add(icon_path, amo, false, false, 0, 0);
					sprite_set_offset(f.spr, sprite_get_width(f.spr) / 2, sprite_get_height(f.spr) / 2);
				}
			}
		}
		
		ds_list_destroy(_temp_name);
	}
	
	function saveCollection(_path, save_surface = true) {
		if(PANEL_INSPECTOR.inspecting == noone) return;
		
		if(ds_list_empty(PANEL_GRAPH.nodes_select_list)) {
			SAVE_COLLECTION(PANEL_INSPECTOR.inspecting, _path, save_surface);
		} else {
			SAVE_COLLECTIONS(PANEL_GRAPH.nodes_select_list, _path, save_surface);
		}
	}
	
	function drawContent() {
		draw_clear_alpha(c_ui_blue_black, 0);
		
		draw_sprite_stretched(s_ui_panel_bg, 1, group_w, 40, content_w + 16, content_h);
		contentPane.active = HOVER == panel;
		contentPane.draw(group_w + 8, 40, mx - group_w - 8, my - 40);
		
		folderPane.active = HOVER == panel;
		folderPane.draw(0, 40, mx, my - 40);
		
		draw_set_text(f_p0b, fa_left, fa_center, c_ui_blue_ltgrey);
		draw_text(24, 20, "Collections");
		
		var bx = w - 8 - 24;
		var by = 8;
		
		if(context != COLLECTIONS) {
			if(buttonInstant(s_button_hide, bx, by, 24, 24, [mx, my], FOCUS == panel, HOVER == panel, "Add selecting node as collection", s_add_24, 0, c_ui_lime) == 2) {
				if(PANEL_INSPECTOR.inspecting != noone) {
					var dia = dialogCall(o_dialog_file_name, mouse_mx + 8, mouse_my + 8);
					data_path = context.path;
					if(PANEL_INSPECTOR.inspecting)
						dia.tb_name._input_text = PANEL_INSPECTOR.inspecting.name;
					dia.onModify = function (txt) {
						var _pre_name = data_path + "/" + txt;
						var _name  = _pre_name + ".pxcc";
						var _i = 0;
						while(file_exists(_name)) {
							_name = _pre_name + string(_i) + ".pxcc";
							_i++;
						}
					
						saveCollection(_name);
					};
				}
			}
		} else {
			draw_sprite_ext(s_add_24, 0, bx + 12, by + 12, 1, 1, 0, c_ui_blue_dkgrey, 1);	
		}
		bx -= 32;
		
		if(buttonInstant(s_button_hide, bx, by, 24, 24, [mx, my], FOCUS == panel, HOVER == panel, "Add folder") == 2) {
			var dia = dialogCall(o_dialog_file_name, mouse_mx + 8, mouse_my + 8);
			dia.onModify = function (txt) {
				directory_create(txt);
			};
			dia.path = context.path + "/";
		}
		draw_sprite_ext(s_folder_add, 0, bx + 12, by + 12, 1, 1, 0, c_ui_blue_grey, 1);
		draw_sprite_ext(s_folder_add, 1, bx + 12, by + 12, 1, 1, 0, c_ui_lime, 1);
		bx -= 32;
		
		if(buttonInstant(s_button_hide, bx, by, 24, 24, [mx, my], FOCUS == panel, HOVER == panel, "Open in file explorer", s_folder_24) == 2) {
			var _realpath = context.path;
			var _windir   = environment_get_variable("WINDIR") + "\\explorer.exe";
			
			execute_shell(_windir, _realpath);
		}
		bx -= 32;
		
		if(buttonInstant(s_button_hide, bx, by, 24, 24, [mx, my], FOCUS == panel, HOVER == panel, "Refresh", s_refresh_16) == 2) {
			searchCollections();
			searchContent();
		}
		bx -= 32;
		
		if(file_dragging) {
			if(file_dragging.spr) {
				draw_sprite_ext(file_dragging.spr, 0, mx, my, 1, 1, 0, c_white, 0.5);
			}
			
			if(HOVER == PANEL_GRAPH.panel) {
				var app = noone;
				ds_list_clear(PANEL_GRAPH.nodes_select_list);
				
				if(instanceof(file_dragging) == "FileContext") {
					app = APPEND(file_dragging.path);
				} else 
					app = buildNode(file_dragging);
				file_dragging = false;
				
				if(!is_struct(app) && ds_exists(app, ds_type_list)) {
					PANEL_GRAPH.node_focus	      = noone;
					ds_list_copy(PANEL_GRAPH.nodes_select_list, app);
					
					if(!ds_list_empty(app)) {
						PANEL_GRAPH.node_dragging = app[| 0];
						PANEL_GRAPH.node_drag_sx  = app[| 0].x;
						PANEL_GRAPH.node_drag_sy  = app[| 0].y;
					}
					ds_list_destroy(app);
				} else {
					PANEL_GRAPH.node_focus	  = app;
					PANEL_GRAPH.node_dragging = app;
					PANEL_GRAPH.node_drag_sx  = app.x;
					PANEL_GRAPH.node_drag_sy  = app.y;
				}
				PANEL_GRAPH.node_drag_mx  = 0;
				PANEL_GRAPH.node_drag_my  = 0;
				
				PANEL_GRAPH.node_drag_ox  = 0;
				PANEL_GRAPH.node_drag_oy  = 0;
			}
			
			if(mouse_check_button_released(mb_left)) 
				file_dragging = noone;
		}
	}
}