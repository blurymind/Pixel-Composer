/*
function Node_Processor(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	array_process  = ARRAY_PROCESS.loop;
	process_amount = 0;
	inputs_data    = [];
	
	function process_data(_output, _data, _index) { return noone; }
	
	function preProcess(_outindex) {
		var _out = outputs[| _outindex].getValue();
		
		if(process_amount == 0) //render single data
			return process_data(_out, inputs_data, _outindex);
			
		if(!is_array(_out))
			_out = array_create(process_amount);
		else if(array_length(_out) != process_amount) 
			array_resize(_out, process_amount);
			
		var _data    = array_create(ds_list_size(inputs));
		for(var l = 0; l < process_amount; l++) {
			for(var i = 0; i < ds_list_size(inputs); i++) { //input prepare
				var _in = inputs_data[i];
				
				if(!inputs[| i].isArray(_in)) {
					_data[i] = inputs_data[i];	
					continue;
				}
				
				if(array_length(_in) == 0) {
					_data[i] = 0;
					continue;
				}
				var _index = 0;
				switch(array_process) {
					case ARRAY_PROCESS.loop : _index = safe_mod(l, array_length(_in)); break;
					case ARRAY_PROCESS.hold : _index = min(l, array_length(_in) - 1);  break;
				}
				_data[i] = _in[_index];
			}
				
			_out[l] = process_data(_out[l], _data, _outindex);
		}
		
		return _out;
	}
	
	static update = function() {
		process_amount = 0;
		inputs_data = array_create(ds_list_size(inputs));
		
		for(var i = 0; i < ds_list_size(inputs); i++) { //pre-collect current input data
			inputs_data[i] = inputs[| i].getValue();
			
			if(!is_array(inputs_data[i])) continue;
			if(array_length(inputs_data[i]) == 0) continue;
			if(!inputs[| i].isArray(inputs_data[i])) continue;
			
			if(typeArray(inputs[| i].display_type)) {
				process_amount = max(process_amount, array_length(inputs_data[i][0]));
			} else 
				process_amount = max(process_amount, array_length(inputs_data[i]));
		}
		
		for(var i = 0; i < ds_list_size(outputs); i++) {
			outputs[| i].setValue(preProcess(i));
		}
	}	
}