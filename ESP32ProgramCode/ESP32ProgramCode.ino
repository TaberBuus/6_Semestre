// ================================================================
// ===           Libraries and global variable                  ===
// ================================================================
#include <ESP32_Servo.h>            // esp32 servo library
Servo servoObj;                     // create servo object to control a servo
hw_timer_t * timer = NULL;          // create timer data type

const uint8_t servoPin = 26;        // servo pin 
const uint8_t fsrSensorPin = 35;    // fsr sensor pin
const uint8_t arraySize = 100;      // number of values in integrel (this correspond to 0.5 sec) 

uint8_t  currentIndexNumber = 0;    // the index of the current reading
uint8_t  scalesIndexNum = 0;        // the index of the current scalor value
float    readings[arraySize];       // the readings from the analog input
float    scale[arraySize];          // values to scale the integrel input
float    integrel = 0; 
boolean  doDataCollection = false;  // indicator to collect new analog reading 
float    force = 0; 


float floatMap(float x, float in_min, float in_max, float out_min, float out_max) {
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

// ================================================================
// ===                          Setup                           ===
// ===============================================================
void setup() {
  Serial.begin(115200);             // initialize serial communication
  servoObj.attach(servoPin);        // attaches the servo on pin 26 to the servo object  
  
  analogReadResolution(12);             // sets the size (in bits) of the value returned by analogRead(), default is 12-bit (0 - 4095), range is 9 - 12 bits
  analogSetWidth(12);                   // set the sample bits and resolution. It can be a value between 9 (0 – 511) and 12 bits (0 – 4095). Default is 12-bit resolution.
  analogSetCycles(255);                 // set the number of cycles per sample. Default is 8. Range: 1 to 255.
  analogSetSamples(1);                  // set the number of samples in the range. Default is 1 sample. It has an effect of increasing sensitivity.
  analogSetAttenuation(ADC_11db);       // sets the input attenuation for ALL ADC inputs, default is ADC_11db, range is ADC_0db, ADC_2_5db, ADC_6db, ADC_11db
  dacWrite(25, 0);                      // mute speaker on M5stack
  
  if (timer) {                      // if timer is running
    timerEnd(timer);                // stopping timer
    timer = NULL;                   // delete timer
  }

  for (int i = 0; i < arraySize; i++) {
    readings[i] = 0;                              // initialize all the readings to 0
    scale[i] =  floatMap(i, 0, (arraySize), 100, 0);   // find all scale factors
  } 
}

// ================================================================
// ===                          Interrupt                       ===
// ================================================================
void IRAM_ATTR onTimer() {
  doDataCollection = true;                       // indicate to send new analog read value  
}

void setup_timer() {
  timer = timerBegin(2, 80, true);               // timer 0, prescale = 80 (every count = 1 micro sec), true = count up
  timerAttachInterrupt(timer, &onTimer, true);   // set callback function, true = edge
  timerAlarmWrite(timer, 5000, true);            // set timer value to 3125 x 1 micro sec = 3.125 ms -> Fs = 320 Hz, true = reload
  timerAlarmEnable(timer);                       // start timer
}

// ================================================================
// ===                          Functions                       ===
// ================================================================
float p00 =     0.01933  ;//(-0.02756, 0.06623)
float p10 =  -0.0002077  ;//(-0.000524, 0.0001085)
float p01 =   2.318e-08  ;//(2.121e-09, 4.424e-08)
float p20 =   2.753e-06  ;//(2.294e-06, 3.211e-06)
float p11 =  -1.438e-10  ;//(-2.126e-10, -7.499e-11)
float p30 =   -2.08e-09  ;//(-2.357e-09, -1.803e-09)
float p21 =   1.355e-13  ;//(8.466e-14, 1.864e-13)
float p40 =   4.861e-13  ;//(4.348e-13, 5.374e-13)
float p31 =  -3.788e-17  ;//(-4.777e-17, -2.8e-17)

float Poly41(float x, float y){
  return p00 + p10*x + p01*y + p20*x*x + p11*x*y + p30*x*x*x + p21*x*x*y 
         + p40*x*x*x*x + p31*x*x*x*y; 
}

int Exp2(float x){            // calibrate servo motor
  return 5.346*exp(0.4224*x) + 0.006816*exp(1.572*x);
}

// ================================================================
// ===                          LOOP                            ===
// ================================================================
void loop() {
  if(!timer) {                                  // if timer is not running
    setup_timer();                              // start up timer
  }

  if(doDataCollection){
    Serial.println(micros()); 
    readings[currentIndexNumber] = (float) analogRead(fsrSensorPin);   
    integrel = 0;                                                    
    int i = 0;

    for(int index = currentIndexNumber; i < arraySize; index--){
      if(index < 0) index = arraySize-1;
      integrel += readings[index] * scale[i];
      i++;
    }
  
//    integrel = 0;                                     // reset value
//    scalesIndexNum = 0;                               // reset value
//    for(int i = readingsIndexNum; scalesIndexNum < arraySize; i--){
//      if(i < 0) i = arraySize-1;
//      integrel += scale[scalesIndexNum]*readings[i];
//      scalesIndexNum++; 
//    }

   
    float force = Poly41(readings[readingsIndexNum], integrel); 
    if( force < 5.6){
      servoObj.write(Exp2(force));
    }else {
      servoObj.write(100);
    }

    readingsIndexNum ++; 
    if (readingsIndexNum == arraySize) {                 // wrap around to the beginning:
      readingsIndexNum = 0;                            
    }    
    doDataCollection = false;
  }
}
