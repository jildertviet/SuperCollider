#include "ofApp.h"

#define WIDTH   320
#define HEIGHT  240
//--------------------------------------------------------------
void ofApp::setup(){
    
    
    ofSetFrameRate(30);
    
    sender.setup("localhost", 6060);
    
    
    gui.setup();
    gui.add(brightnessThreshold.setup("brightnessThreshold", 100, 0, 255));
    gui.add(fluxThreshold.setup("fluxThreshold", 10, 0, 255));
    gui.add(maxAmp.setup("maxAmp", 0.8, 0, 1));
    
    
    
    
    
    
    
    
    
    
    
    ofSetLogLevel(OF_LOG_VERBOSE);
    ofSetLogLevel("ofThread", OF_LOG_ERROR);
    ofSetVerticalSync(false);
    ofEnableAlphaBlending();
    
    omxCameraSettings.width = 1280;
    omxCameraSettings.height = 720;
    omxCameraSettings.framerate = 30;
    omxCameraSettings.isUsingTexture = true;
    
    videoGrabber.setup(omxCameraSettings);
    
    fbo.allocate(omxCameraSettings.width, omxCameraSettings.height);
    fbo.begin();
    ofClear(0, 0, 0, 0);
    fbo.end();
}

//--------------------------------------------------------------
void ofApp::update(){
    ofBackground(100, 100, 100);
        
    
    if(videoGrabber.isFrameNew()){
        frameColor.setFromPixels(videoGrabber.getPixels());
        frame.setFromColorImage(frameColor);
        
        // Flux

        flux.absDiff(frame, prevFrame);
        flux = convertToBinary(flux, fluxThreshold);
        
        fluxInt = getAverage(flux);
        brightnessInt = getAverage(convertToBinary(frame, brightnessThreshold));
        
        cout << fluxInt << "\t " << "\t ";
        cout << brightnessInt << endl;
        
        // Feed statemachine
        sm.update(fluxInt, brightnessInt);
        
        // Send OSC
        message.clear();
        message.setAddress("/fromOF"); // [Flux, Brightness, Amplitude, HasPattern]
        message.addInt32Arg(fluxInt);
        message.addInt32Arg(brightnessInt);
        message.addFloatArg(sm.amplitude);
        message.addInt32Arg(sm.state);
        sender.sendMessage(message);
        
        // Save image
        prevFrame = frame;
    }
}

//--------------------------------------------------------------
void ofApp::draw(){
//    frame.draw(0,0);
//    flux.draw(0,240);
//    convertToBinary(frame,100).draw(0,240*2);
    gui.draw();
    
    string f = ofToString(fluxInt);
    string b = ofToString(brightnessInt);
    
    ofDrawBitmapString(f+"\t"+b, 300, 10);
}

//--------------------------------------------------------------
void ofApp::keyPressed(int key){

}

//--------------------------------------------------------------
int ofApp::getAverage(ofxCvGrayscaleImage image){
    average = 0;
    for(int w=0; w<image.getWidth(); w++){
        for(int h=0; h<image.getHeight(); h++){
            int val = (image.getPixels().getColor(w, h)).getBrightness();
//            cout << val << endl;
            average += val; // Grayscale value?
        }
    }
    average = average/(image.getWidth()*image.getHeight());
    return average;
}
//--------------------------------------------------------------
ofxCvGrayscaleImage ofApp::convertToBinary(ofxCvGrayscaleImage image, int threshold){
    ofPixels pixels = image.getPixels();
    for(int w=0; w<image.getWidth(); w++){
        for(int h=0; h<image.getHeight(); h++){
//            int val = (image.getPixels().getColor(w, h)).getBrightness();
            int color;
            if(pixels.getColor(w, h).getBrightness()>threshold){
                color = 255;
            } else{
                color = 0;
            }
            pixels.setColor(w, h, ofColor(color));
//            average += val; // Grayscale value?
        }
    }
    image.setFromPixels(pixels);
    return image;
}






