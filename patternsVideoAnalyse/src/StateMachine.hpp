//
//  StateMachine.hpp
//  patternsVideoAnalyse
//
//  Created by Jildert Viet on 13-12-16.
//
//

#ifndef StateMachine_hpp
#define StateMachine_hpp

#include <stdio.h>
#include "ofMain.h"

class StateMachine{
public:
    StateMachine(){
        
    }
    
    ofVec2f fluxRange = ofVec2f(0,0);
    int fluxThreshold = 100;
    int brightnessThreshold = 100;
    ofVec2f brightnessRange = ofVec2f(0,0);
    
    float amplitude=0.5;
    float ampStepSize = 0.05;
    
    bool bHasPattern = false;
    int state = 0; // 0 = silent, 1 = pattern, 2 = noise
    
    bool update(int flux, int brightness){
        if(flux > fluxRange.y){
            fluxRange.x = flux;
//            fluxThreshold = getThreshold(fluxRange, 0.5); // Find good ratio
        }
        if(brightness > brightnessRange.y){
            brightnessRange.x = brightness;
//            brightnessThreshold = getThreshold(brightnessRange, 0.3); // Find good ratio
        }
        
        
        if(flux > fluxThreshold && brightness > brightnessThreshold){ // RUIS
            // Decrease amplitude
            if(bHasPattern)
                cout << "Pattern to noise" << endl;
            updateAmplitude(amplitude-ampStepSize);
            bHasPattern = false;
            state = 2;
        }
        if(flux < fluxThreshold && brightness > brightnessThreshold){ // PATTERN
            if(!bHasPattern)
                cout << "Pattern detected!" << endl;
            bHasPattern = true;
            state = 1;
            // Do nothing
        }
        if(flux < fluxThreshold && brightness < brightnessThreshold){ // NOTHING
            if(bHasPattern)
                cout << "Pattern to silence" << endl;
            // Increase amplitude
            updateAmplitude(amplitude+ampStepSize);
            bHasPattern = false;
            state = 0;
        }
    }

    
    int getThreshold(ofVec2f range, float ratio){
        int threshold = (range.y - range.x)*ratio;
        return threshold;
    }
    
    void updateAmplitude(float amp){
        if(amp < 1){
            amplitude = amp;
        }
        if(amp < 0){
            amplitude = 0;
        }
    }
};
#endif /* StateMachine_hpp */
