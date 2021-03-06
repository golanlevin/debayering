#version 120

// Fragment shader to correctly display GRBG Bayer8 images.
// For 0F 0.10, shadersGL2
// Golan Levin, July 2018

uniform sampler2DRect tex0;
varying vec2 texCoordVarying;

void main() {
	
	// Fetch the normalized (0..1) coordinates of 3x3 neighborhood texels
	vec2 texCoord0 = texCoordVarying + vec2(-1.0, -1.0);
	vec2 texCoord1 = texCoordVarying + vec2( 0.0, -1.0);
	vec2 texCoord2 = texCoordVarying + vec2(+1.0, -1.0);
	vec2 texCoord3 = texCoordVarying + vec2(-1.0,  0.0);
	vec2 texCoord4 = texCoordVarying + vec2( 0.0,  0.0);
	vec2 texCoord5 = texCoordVarying + vec2(+1.0,  0.0);
	vec2 texCoord6 = texCoordVarying + vec2(-1.0, +1.0);
	vec2 texCoord7 = texCoordVarying + vec2( 0.0, +1.0);
	vec2 texCoord8 = texCoordVarying + vec2(+1.0, +1.0);
	
	// Fetch the (source) colors at those neighboring texels
	vec4 src0 = texture2DRect(tex0, texCoord0);
	vec4 src1 = texture2DRect(tex0, texCoord1);
	vec4 src2 = texture2DRect(tex0, texCoord2);
	vec4 src3 = texture2DRect(tex0, texCoord3);
	vec4 src4 = texture2DRect(tex0, texCoord4);
	vec4 src5 = texture2DRect(tex0, texCoord5);
	vec4 src6 = texture2DRect(tex0, texCoord6);
	vec4 src7 = texture2DRect(tex0, texCoord7);
	vec4 src8 = texture2DRect(tex0, texCoord8);
	
	// Use modulo voodoo to determine which Bayer pixel this is.
	// Note that we depend on the input and output sizes being the same.
	float xMod2 = floor(mod(texCoordVarying.x, 2));
	float yMod2 = floor(mod(texCoordVarying.y, 2));
	
	// Compute the destination color, using bilinear interpolation.
	vec4 dst = vec4(0.0,0.0,0.0,1.0);
	if (yMod2 < 1.0) {
		if (xMod2 < 1.0) {
			// GREEN (upper left)
			dst.r = (src3.g + src5.g)/2.0; // sideAvg;
			dst.g = (src4.b);
			dst.b = (src1.g + src7.g)/2.0; // vertAvg;
		} else {
			// RED (upper right)
			dst.r = (src4.g);
			dst.g = (src1.r + src3.b + src5.b + src7.r)/4.0; // cardAvg;
			dst.b = (src0.g + src2.g + src6.g + src8.g)/4.0; // diagAvg;
		}
	} else {
		if (xMod2 < 1.0) {
			// BLUE (bottom left)
			dst.r = (src0.g + src2.g + src6.g + src8.g)/4.0; // diagAvg;
			dst.g = (src1.b + src3.r + src5.r + src7.b)/4.0; // cardAvg;
			dst.b = (src4.g);
		} else {
			// GREEN (bottom right)
			dst.r = (src1.g + src7.g)/2.0; // vertAvg;
			dst.g = (src4.r);
			dst.b = (src3.g + src5.g)/2.0; // sideAvg;
		}
	}
	
	// Set the output texel accordingly.
	gl_FragColor = dst;
}
