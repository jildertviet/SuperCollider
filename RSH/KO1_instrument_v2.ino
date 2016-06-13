#include <Messenger.h>

#define  kNumSensors  2
#define  kMaxHeight  100

int trigPins[] = {5,2};
int echoPins[] = {4,3};
int cms[] = {0,0};
int absCms[] = {0,0};
int maxHeights[] = {40, 20};
int values[kNumSensors];


int buttonPins[] = {9}; 
int buttonStates[] = {0};
int prevButtonStates[] = {0};

//-------------------------------SETUP-----------------------------------

void setup() 
{
  Serial.begin(9600);
  for(int i=0; i<kNumSensors; i++){
    values[i] = 0;
    pinMode(trigPins[i], OUTPUT);
    pinMode(echoPins[i], INPUT);
  }  
  pinMode(buttonPins[0], INPUT);
  
}

//------------------------------LOOP-------------------------------------

void loop(){
  // SENSORS
  
  for(int i=0; i<kNumSensors; i++){
    long duration = sendOutPulse(trigPins[i], echoPins[i]);
    absCms[i] = microsecondsToCentimeters(duration);
    cms[i] = constrain(microsecondsToCentimeters(duration), 0, maxHeights[i]);
    // Serial out
    if(abs(values[i] - cms[i]) < 10)
      values[i] = cms[i];
  }
  // Send Data (sensors)
  for(int i=0; i<kNumSensors; i++){
    sendValue(i);
    sendValue(values[i]); 
  }
  
  // BUTTONS
  for(int i=0; i<1; i++){
    prevButtonStates[i] = buttonStates[i];
    buttonStates[i] = digitalRead(buttonPins[i]);
    // Send Data (buttons)
    if(prevButtonStates[i]!=buttonStates[i] && buttonStates[i]==1){
      sendValue(1);
      for(int j=0; j<kNumSensors; j++){
        if(absCms[j]<80)
          values[j] = cms[j];
      }
    } else{
      sendValue(0);
    }
  }
  
  Serial.println(); // Kan dit weg?
  
  delay(80);
} 

long sendOutPulse(int trigPin, int echoPin){
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  return pulseIn(echoPin, HIGH);
}

long microsecondsToCentimeters(long microseconds){
  return microseconds / 29 / 2; 
}

void sendValue (int x){              // function to send the pin value followed by a "space". 
 Serial.print(x);
 Serial.write(32);
}


 
