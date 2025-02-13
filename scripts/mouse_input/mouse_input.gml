function mouse_click(mouse, focus = true) {
	return focus && mouse_check_button(mouse);
}

function mouse_press(mouse, focus = true) {
	return focus && mouse_check_button_pressed(mouse);
}

function mouse_release(mouse, focus = true) {
	return focus && mouse_check_button_released(mouse);
}

#region mouse global
	globalvar MOUSE_WRAP, MOUSE_WRAPPING;
	MOUSE_WRAP = false;
	MOUSE_WRAPPING = false;
	
	function setMouseWrap() {
		MOUSE_WRAP = true;
	}
#endregion