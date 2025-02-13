function array_create_from_list(list) {
	var arr = array_create(ds_list_size(list));
	for( var i = 0; i < ds_list_size(list); i++ )
		arr[i] = list[| i];
	return arr;
}

function array_safe_set(arr, index, value) {
	if(index < 0) return;
	if(index >= array_length(arr)) return;
	
	array_set(arr, index, value);
}

function array_safe_get(arr, index, def = 0) {
	if(index >= array_length(arr)) return def;
	return arr[index];
}

function array_exists(arr, val) {
	for( var i = 0; i < array_length(arr); i++ ) {
		if(arr[i] == val) return true;
	}
	return false;
}

function array_find(arr, val) {
	for( var i = 0; i < array_length(arr); i++ ) {
		if(arr[i] == val) return i;
	}
	return -1;
}

function array_remove(arr, val) {
	if(!array_exists(arr, val)) return;
	var ind = array_find(arr, val);
	array_delete(arr, ind, 1);
}

function array_push_unique(arr, val) {
	if(array_exists(arr, val)) return;
	array_push(arr, val);
}

function array_append(arr, arr0) {
	for( var i = 0; i < array_length(arr0); i++ )
		array_push(arr, arr0[i]);
}

function array_merge() {
	var arr = [];
	for( var i = 0; i < argument_count; i++ ) {
		array_append(arr, argument[i]);
	}
	
	return arr;
}

function array_clone(arr) {
	var _res = array_create(array_length(arr));
	 for( var i = 0; i < array_length(arr); i++ ) {
		 _res[i] = arr[i];
	 }
	 return _res;
}

function array_min(arr) {
	if(array_length(arr) == 0) return 0;
	
	var mn = arr[0];
	 for( var i = 0; i < array_length(arr); i++ )
		 mn = min(mn, arr[i]);
	 return mn;
}

function array_max(arr) {
	if(array_length(arr) == 0) return 0;
	
	var mx = arr[0];
	 for( var i = 0; i < array_length(arr); i++ )
		 mx = max(mx, arr[i]);
	 return mx;
}