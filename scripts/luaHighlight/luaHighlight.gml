global.lua_reserved = ds_map_create();
var reserved = ["and", "break", "do", "else", "elseif", "end", "false", 
				"for", "function", "if", "in", "local", "nil", "not", 
				"or", "repeat", "return", "then", "true", "until", "while"];
					   
for( var i = 0; i < array_length(reserved); i++ )
	global.lua_reserved[? reserved[i]] = 1;

function token_splice(str) {
	var st = [];
	var ss = str;
	var sp;
	var cc;
	var tk = [" ", "(", ")", "[", "]", "{", "}", ",", ";", "+", "-", "*", "/", "="];
	
	do {
		sp = 999999;
		for( var i = 0; i < array_length(tk); i++ ) {
			var _pos = string_pos(tk[i], ss);
			if(_pos != 0) sp = min(sp, _pos);
		}
		
		if(sp == 999999) { //no delim left
			array_push(st, ss);
			break;
		}
		
		var _ss = string_copy(ss, 1, sp - 1);
		array_push(st, _ss);
		
		cc = string_char_at(ss, sp);
		array_push(st, cc);
		
		ss = string_copy(ss, sp + 1, string_length(ss) - sp);
	} until(sp == 0);
	
	return st;
}

function draw_code(_x, _y, str) {
	var tx = _x
	var ty = _y;
	
	var isStr = true;
	var stringSplice = string_splice(str, "\"");
	var amo = array_length(stringSplice);
	var word;
	
	for( var i = 0; i < amo; i++ ) {
		var _w = stringSplice[i];
		_w = string_trim_end(_w);
		
		isStr = !isStr;
		
		if(isStr) {
			word = "\"" + _w;
			if(i < amo - 1) word += "\"";
			
			draw_set_color(isStr? COLORS.lua_highlight_string : COLORS._main_text);
			draw_text(tx, ty, word);
			tx += string_width(word);
			continue;
		}
		
		var words = token_splice(_w);
			
		for( var j = 0; j < array_length(words); j++ ) {
			word = words[j];
			var wordNoS = string_replace_all(word, " ", "");
			
			draw_set_color(COLORS._main_text);
			if(word == "(" || word == ")" || word == "[" || word == "]" || word == "{" || word == "}")
				draw_set_color(COLORS.lua_highlight_bracklet);
			else if(ds_map_exists(global.lua_reserved, word))
				draw_set_color(COLORS.lua_highlight_keyword);
			else if(wordNoS == string_decimal(wordNoS))
				draw_set_color(COLORS.lua_highlight_number);
			else if(j < array_length(words) - 1) {
				if(words[j + 1] == "(")
					draw_set_color(COLORS.lua_highlight_function);
			}
			
			draw_text(tx, ty, word);
			tx += string_width(word);
		}
	}
}