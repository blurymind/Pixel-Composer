function Node_VFX_Destroy(_x, _y, _group = -1) : Node_VFX_effector(_x, _y, _group) constructor {
	name = "Destroy";
	node_draw_icon = s_node_vfx_destroy;
	
	function onAffect(part, str) {
		var _sten = current_data[5];
		
		if(random(1) < str * _sten)
			part.kill();
	}
}