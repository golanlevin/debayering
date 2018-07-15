// Fragment shader to correctly display GRBG Bayer8 images.
// See https://processing.org/tutorials/pshader/
// Written for Processing v.3.3.7
// Golan Levin, July 2018

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

// Some of these are inherited from Processing's "default shader"
uniform sampler2D texture;
uniform vec2 texOffset;
varying vec4 vertTexCoord;


void main() {

	// Fetch the normalized (0..1) coordinates of 3x3 neighborhood texels
	vec2 texCoord0 = vertTexCoord.st + vec2(-texOffset.s, -texOffset.t);
	vec2 texCoord1 = vertTexCoord.st + vec2(         0.0, -texOffset.t);
	vec2 texCoord2 = vertTexCoord.st + vec2(+texOffset.s, -texOffset.t);
	vec2 texCoord3 = vertTexCoord.st + vec2(-texOffset.s,          0.0);
	vec2 texCoord4 = vertTexCoord.st + vec2(         0.0,          0.0);
	vec2 texCoord5 = vertTexCoord.st + vec2(+texOffset.s,          0.0);
	vec2 texCoord6 = vertTexCoord.st + vec2(-texOffset.s, +texOffset.t);
	vec2 texCoord7 = vertTexCoord.st + vec2(         0.0, +texOffset.t);
	vec2 texCoord8 = vertTexCoord.st + vec2(+texOffset.s, +texOffset.t);

	// Fetch the (source) colors at those neighboring texels
	vec4 src0 = texture2D(texture, texCoord0);
	vec4 src1 = texture2D(texture, texCoord1);
	vec4 src2 = texture2D(texture, texCoord2);
	vec4 src3 = texture2D(texture, texCoord3);
	vec4 src4 = texture2D(texture, texCoord4);
	vec4 src5 = texture2D(texture, texCoord5);
	vec4 src6 = texture2D(texture, texCoord6);
	vec4 src7 = texture2D(texture, texCoord7);
	vec4 src8 = texture2D(texture, texCoord8);

	// Use modulo voodoo to determine which Bayer pixel this is. 
	// Note that we depend on the input and output sizes being the same.
	float xMod2 = floor(mod(gl_FragCoord.x, 2));
	float yMod2 = floor(mod(gl_FragCoord.y, 2)); 

	// Compute the destination color, using bilinear interpolation.
	vec4 dst = vec4(0.0,0.0,0.0,1.0); 
    if (yMod2 > 0.0) {
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



