// Processing program to correctly display Bayer8 images 
// (i.e, de-bayering, de-mosaicing), using a bi-linear GLSL shader.
// Written for Processing v.3.3.7, Golan Levin, July 2018
// Assumes Bayer images with GRBG pattern.
// 
//
// Helpful resources: 
// The Book of Shaders, by Patricio Gonzalez Vivo and Jen Lowe
//    https://thebookofshaders.com/
// Shaders (Processing Shader Tutorial), by Andres Colubri
//    https://processing.org/tutorials/pshader/
// Related links: 
//    https://github.com/jdthomas/bayer2rgb (lots of algos!)
//    https://github.com/rasmus25/debayer-rpi/blob/master/demosaic.frg
//    http://casual-effects.com/research/McGuire2009Bayer/index.html
//    https://forum.openframeworks.cc/t/solved-ofvideograbber-with-bayer8-pixelformat/15822
//    https://hal.archives-ouvertes.fr/hal-00683233/document


PShader texShader;
PImage bayerRawImage;
PShape texturedRect;

void setup() {
  size(1280, 720, P3D);
  noStroke();

  bayerRawImage = loadImage("bayer-raw.png"); 
  texShader = loadShader("shaderEdgeAware.frag"); //or shaderBilinear.frag
  texturedRect = createTexturedRect(bayerRawImage);
}

//=================================================
void draw() {
  background(128);
  shader(texShader);
  shape(texturedRect);
}

//=================================================
PShape createTexturedRect (PImage texImage) {

  textureMode(NORMAL);
  PShape sh = createShape();
  sh.beginShape(QUAD_STRIP);
  sh.noStroke();
  sh.texture(texImage);

  float x0 = 0.0; 
  float y0 = 0.0; 
  float x1 = (float)texImage.width; 
  float y1 = (float)texImage.height;
  float z = 0;

  sh.normal(0.0, 0.0, z);
  sh.vertex(x0, y0, z, 0.0, 0.0); 
  sh.vertex(x0, y1, z, 0.0, 1.0);
  sh.normal(1.0, 0.0, z);
  sh.vertex(x1, y0, z, 1.0, 0.0);
  sh.vertex(x1, y1, z, 1.0, 1.0);
  sh.endShape();
  return sh;
}

//=================================================
void keyPressed() {
  if (key == ' ') {
    // saveFrame("output.png");
  }
}
