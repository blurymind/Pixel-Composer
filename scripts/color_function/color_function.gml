function colorFromRGBArray(arr) {
	var r = round(real(arr[0]) * 255);
	var g = round(real(arr[1]) * 255);
	var b = round(real(arr[2]) * 255);
	return make_color_rgb(r, g, b);
}

function colorArrayFromReal(clr) {
	return [color_get_red(clr) / 255, color_get_green(clr) / 255, color_get_blue(clr) / 255 ];	
}

function colorBrightness(clr) {
	var r2 = color_get_red(clr) / 255;
	var g2 = color_get_green(clr) / 255;
	var b2 = color_get_blue(clr) / 255;
	return 0.299 * r2 + 0.587 * g2 + 0.224 * b2;
}