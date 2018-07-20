#version 150

// Fragment shader to correctly display GRBG Bayer8 images.
// For 0F 0.10, shadersGL3
// Golan Levin, July 2018

uniform sampler2DRect tex0;
in vec2 texCoordVarying;
out vec4 outputColor;


void main() {
	
	// Fetch the coordinates of 3x3 neighborhood texels
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
	vec4 src0 = texture(tex0, texCoord0);
	vec4 src1 = texture(tex0, texCoord1);
	vec4 src2 = texture(tex0, texCoord2);
	vec4 src3 = texture(tex0, texCoord3);
	vec4 src4 = texture(tex0, texCoord4);
	vec4 src5 = texture(tex0, texCoord5);
	vec4 src6 = texture(tex0, texCoord6);
	vec4 src7 = texture(tex0, texCoord7);
	vec4 src8 = texture(tex0, texCoord8);
	
	// Use modulo voodoo to determine which Bayer pixel this is.
	// Note that we depend on the input and output sizes being the same.
	float xMod2 = floor(mod(texCoordVarying.x, 2));
	float yMod2 = floor(mod(texCoordVarying.y, 2));
	
	// Compute the interpolated destination color.
	vec4 dst  = vec4(0.0,0.0,0.0,1.0);
	vec4 difA = vec4(0.0,0.0,0.0,1.0);
	vec4 difB = vec4(0.0,0.0,0.0,1.0);

	if (yMod2 < 1.0) {
		if (xMod2 < 1.0) {
			// GREEN (upper left)
			dst.r = (src3.g + src5.g)/2.0; // sideAvg;
			dst.g = (src4.b);
			dst.b = (src1.g + src7.g)/2.0; // vertAvg;
			
		} else {
			
			// RED (upper right)
			dst.r = (src4.g);
			
			difA.g = abs(src3.b - src5.b);
			difB.g = abs(src1.r - src7.r);
			if (difA.g < difB.g) {
				dst.g = (src3.b + src5.b)/2.0;
			} else if (difB.g < difA.g) {
				dst.g = (src1.r + src7.r)/2.0;
			} else {
				dst.g = (src1.r + src3.b + src5.b + src7.r)/4.0; // cardAvg;
			}
			
			difA.b = abs(src0.g - src8.g);
			difB.b = abs(src2.g - src6.g);
			if (difA.b < difB.b) {
				dst.b = (src0.g + src8.g)/2.0;
			} else if (difB.b < difA.b) {
				dst.b = (src2.g + src6.g)/2.0;
			} else {
				dst.b = (src0.g + src2.g + src6.g + src8.g)/4.0; // diagAvg;
			}
		}
	} else {
		if (xMod2 < 1.0) {
			// BLUE (bottom left)
			
			difA.r = abs(src0.g - src8.g);
			difB.r = abs(src2.g - src6.g);
			if (difA.r < difB.r) {
				dst.r = (src0.g + src8.g)/2.0;
			} else if (difB.r < difA.r) {
				dst.r = (src2.g + src6.g)/2.0;
			} else {
				dst.r = (src0.g + src2.g + src6.g + src8.g)/4.0; // diagAvg;
			}
			
			difA.g = abs(src3.r - src5.r);
			difB.g = abs(src1.b - src7.b);
			if (difA.g < difB.g) {
				dst.g = (src3.r + src5.r)/2.0;
			} else if (difB.g < difA.g) {
				dst.g = (src1.b + src7.b)/2.0;
			} else {
				dst.g = (src1.b + src3.r + src5.r + src7.b)/4.0; // cardAvg;
			}
			
			dst.b = (src4.g);

		} else {
			// GREEN (bottom right)
			dst.r = (src1.g + src7.g)/2.0; // vertAvg;
			dst.g = (src4.r);
			dst.b = (src3.g + src5.g)/2.0; // sideAvg;
		}
	}
	
	// Set the output texel accordingly.
	outputColor = dst;
}
 

