#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup() {
	
	if (ofIsGLProgrammableRenderer()){
		shader.load("shadersGL3/shader");
	} else {
		shader.load("shadersGL2/shader");
	}

    img.load("bayer-raw.png");

	plane.set(img.getWidth(), img.getHeight());
    plane.mapTexCoords(0, 0, img.getWidth(), img.getHeight());
}


//--------------------------------------------------------------
void ofApp::update() {
}

//--------------------------------------------------------------
void ofApp::draw() {
	
    // bind our texture. in our shader this will now be tex0 by default
    // so we can just go ahead and access it there.
    img.getTexture().bind();
    shader.begin();
	
    ofPushMatrix();
	ofTranslate(img.getWidth()/2, img.getHeight()/2);
	ofScale(1,-1);
	plane.draw();
    ofPopMatrix();
	
    shader.end();
	img.getTexture().unbind();
}

//--------------------------------------------------------------
void ofApp::keyPressed(int key){
}

//--------------------------------------------------------------
void ofApp::keyReleased(int key){
}

//--------------------------------------------------------------
void ofApp::mouseMoved(int x, int y){
}

//--------------------------------------------------------------
void ofApp::mouseDragged(int x, int y, int button){
}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button){
}

//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button){
}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h){
}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg){
}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo){
}
