//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform float size;
uniform int border;
uniform int alpha;

#define TAU   6.28318

float bright(in vec4 col) {
	return dot(col.rgb, vec3(0.2126, 0.7152, 0.0722)) * col.a;
}

void main() {
	vec2 pixelPosition = v_vTexcoord * dimension;
	vec4 point = texture2D( gm_BaseTexture, v_vTexcoord );
	vec4 fill = vec4(0.);
	if(alpha == 0) 
		fill.a = 1.;
	float tau_div = TAU / 64.;
	gl_FragColor = point;
	
	if((alpha == 0 && length(point.rgb) > 0.) || (alpha == 1 && point.a > 0.)) {
		for(float i = 1.; i < size; i++) {
			for(float j = 0.; j < 64.; j++) {
				float ang = j * tau_div;
				vec2 pxs = (pixelPosition + vec2( cos(ang) * i,  sin(ang) * i)) / dimension;
				if(border == 1)
					pxs = clamp(pxs, vec2(0.), vec2(1.));
				
				vec4 sam = texture2D( gm_BaseTexture, pxs );
				if(pxs.x < 0. || pxs.x > 1. || pxs.y < 0. || pxs.y > 1.) {
					gl_FragColor = fill;
					break;
				}
				
				if((alpha == 0 && length(sam.rgb) == 0.) || (alpha == 1 && sam.a == 0.)) {
					gl_FragColor = fill;
					break;
				}
			}
		}
	}
}
