// ================================================================
// ===           Libraries and global variable                  ===
// ================================================================
#include <ESP32_Servo.h>            // esp32 servo library
Servo servoObj;                     // create servo object to control a servo
hw_timer_t * timer = NULL;          // create timer data type

const uint8_t servoPin = 26;        // servo pin 
const uint8_t fsrSensorPin = 35;    // fsr sensor pin
const uint8_t arraySize = 160;      // number of values in integrel (this correspond to 0.5 sec) 

uint8_t  readingsIndexNum = 0;      // the index of the current reading
uint8_t  scalesIndexNum = 0;        // the index of the current scalor value
float    readings[arraySize];       // the readings from the analog input
float    scale[arraySize];          // values to scale the integrel input
float    integrel = 0; 
boolean  doDataCollection = false;  // indicator to collect new analog reading 


float floatMap(float x, float in_min, float in_max, float out_min, float out_max) {
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

// ================================================================
// ===                          Setup                           ===
// ===============================================================
void setup() {
  Serial.begin(115200);             // initialize serial communication
  servoObj.attach(servoPin);        // attaches the servo on pin 26 to the servo object  
  dacWrite(25, 0);                  // mute speaker on M5stack
  analogSetCycles(255);             // set adc to max cycles used for charging the capacitor before performing ADC

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
  timer = timerBegin(0, 80, true);               // timer 0, prescale = 80 (every count = 1 micro sec), true = count up
  timerAttachInterrupt(timer, &onTimer, true);   // set callback function, true = edge
  timerAlarmWrite(timer, 3125, true);            // set timer value to 3125 x 1 micro sec = 3.125 ms -> Fs = 320 Hz, true = reload
  timerAlarmEnable(timer);                       // start timer
}

// ================================================================
// ===                          Functions                       ===
// ================================================================
 float p00 =       35.03  ;//(34.43, 35.63)
 float p10 =      0.2855  ;//(0.2717, 0.2994)
 float p01 =   4.064e-06  ;//(2.726e-06, 5.403e-06)
 float p20 =  -0.0002914  ;//(-0.0003159, -0.000267)
 float p11 =  -2.315e-08  ;//(-2.52e-08, -2.11e-08)
 float p02 =   -3.05e-13  ;//(-7.331e-13, 1.231e-13)
 float p30 =   1.125e-07  ;//(9.702e-08, 1.279e-07)
 float p21 =   3.188e-11  ;//(3.003e-11, 3.373e-11)
 float p12 =  -4.647e-16  ;//(-8.252e-16, -1.042e-16)
 float p03 =   3.789e-20  ;//(-1.483e-20, 9.061e-20)
 float p40 =  -1.007e-11  ;//(-1.363e-11, -6.513e-12)
 float p31 =  -1.366e-14  ;//(-1.449e-14, -1.283e-14)
 float p22 =  -2.208e-19  ;//(-3.983e-19, -4.323e-20)
 float p13 =   5.902e-23  ;//(2.633e-23, 9.17e-23)
 float p04 =  -2.857e-27  ;//(-5.936e-27, 2.219e-28)
 float p41 =   1.904e-18  ;//(1.682e-18, 2.127e-18)
 float p32 =   3.671e-23  ;//(-2.333e-23, 9.676e-23)
 float p23 =   1.902e-27  ;//(-8.288e-27, 1.209e-26)
 float p14 =  -1.669e-30  ;//(-2.852e-30, -4.864e-31)
 float p05 =   8.343e-35  ;//(1.076e-35, 1.561e-34)

float Poly45(float x, float y){  // calibrate FSR sensor
  return p00 + p10*x + p01*y + p20*x*x + p11*x*y + p02*y*y + p30*x*x*x + p21*x*x*y 
        + p12*x*y*y + p03*y*y*y + p40*x*x*x*x + p31*x*x*x*y + p22*x*x*y*y 
        + p13*x*y*y*y + p04*y*y*y*y + p41*x*x*x*x*y + p32*x*x*x*y*y + p23*x*x*y*y*y 
        + p14*x*y*y*y*y + p05*y*y*y*y*y; 
}

//uint16_t Poly3(float x){            // calibrate servo motor
//  return 0.2895*x*x*x + 0.4595*x*x + 0.2644*x + 79.01; 
//}

//    General model Exp2:
//    f(x) = a*exp(b*x) + c*exp(d*x)
//    Coefficients (with 95% confidence bounds):
//       a =        48.6  (45.51, 51.7)
//       b =     0.08924  (0.06766, 0.1108)
//       c =   8.437e-10  (-1.714e-09, 3.401e-09)
//       d =       5.284  (4.657, 5.911)
//    Goodness of fit:
//      SSE: 512.1
//      R-square: 0.9895
//      Adjusted R-square: 0.9886
//      RMSE: 3.825
uint16_t Exp2(float x){            // calibrate servo motor
  return (48.6)*exp(0.08924*x)+(8.437e-10)*exp(5.284*x); 
}



// ================================================================
// ===                          LOOP                            ===
// ================================================================
void loop() {
  if(!timer) {                                  // if timer is not running
    setup_timer();                              // start up timer
  }

  if(doDataCollection){
    readings[readingsIndexNum] = (float) analogRead(fsrSensorPin);   // read from the fsr sensor:
    integrel = 0;                                     // reset value
    scalesIndexNum = 0;                               // reset value
    for(int i = readingsIndexNum; scalesIndexNum < arraySize; i--){
      if(i < 0) i = arraySize-1;
      integrel += scale[scalesIndexNum]*readings[i];
      scalesIndexNum++; 
    }

    static float force = Poly45(readings[readingsIndexNum], integrel); 
    if( force >= 4.8351){
      servoObj.write(Exp2(force));
    }else {
      servoObj.write(180));
    }

    readingsIndexNum ++; 
    if (readingsIndexNum == arraySize) {                 // wrap around to the beginning:
      readingsIndexNum = 0;                            
    }    
    
    doDataCollection = false;
  }
}
