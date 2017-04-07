#pragma once

#include "ofMain.h"
#include "ofxOsc.h"
#include "ofxOpenCv.h"
#include "StateMachine.hpp"
#include "ofxGui.h"

class ofApp : public ofBaseApp{

	public:
		void setup();
		void update();
		void draw();

		void keyPressed(int key);

    ofVideoGrabber webcam;
    ofxCvGrayscaleImage frame;
    
    ofxCvGrayscaleImage flux;
    
    ofxCvColorImage frameColor;
    ofxCvGrayscaleImage prevFrame;
    
    int getAverage(ofxCvGrayscaleImage image);
    ofxCvGrayscaleImage convertToBinary(ofxCvGrayscaleImage image, int threshold=100);
    
    float average;
    
    ofxOscSender sender;
    ofxOscMessage message;
    

    
    StateMachine sm;
    
    ofxPanel gui;
    ofxIntSlider brightnessThreshold;
    ofxIntSlider fluxThreshold;
    ofxFloatSlider maxAmp;
    
    int fluxInt;
    int brightnessInt;
};
