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
float force = 0; 


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
// float p00 =       35.03  ;//(34.43, 35.63)
// float p10 =      0.2855  ;//(0.2717, 0.2994)
// float p01 =   4.064e-06  ;//(2.726e-06, 5.403e-06)
// float p20 =  -0.0002914  ;//(-0.0003159, -0.000267)
// float p11 =  -2.315e-08  ;//(-2.52e-08, -2.11e-08)
// float p02 =   -3.05e-13  ;//(-7.331e-13, 1.231e-13)
// float p30 =   1.125e-07  ;//(9.702e-08, 1.279e-07)
// float p21 =   3.188e-11  ;//(3.003e-11, 3.373e-11)
// float p12 =  -4.647e-16  ;//(-8.252e-16, -1.042e-16)
// float p03 =   3.789e-20  ;//(-1.483e-20, 9.061e-20)
// float p40 =  -1.007e-11  ;//(-1.363e-11, -6.513e-12)
// float p31 =  -1.366e-14  ;//(-1.449e-14, -1.283e-14)
// float p22 =  -2.208e-19  ;//(-3.983e-19, -4.323e-20)
// float p13 =   5.902e-23  ;//(2.633e-23, 9.17e-23)
// float p04 =  -2.857e-27  ;//(-5.936e-27, 2.219e-28)
// float p41 =   1.904e-18  ;//(1.682e-18, 2.127e-18)
// float p32 =   3.671e-23  ;//(-2.333e-23, 9.676e-23)
// float p23 =   1.902e-27  ;//(-8.288e-27, 1.209e-26)
// float p14 =  -1.669e-30  ;//(-2.852e-30, -4.864e-31)
// float p05 =   8.343e-35  ;//(1.076e-35, 1.561e-34)


   float p00 =       0.344  ;//(0.3381, 0.3499)
   float p10 =    0.002804  ;//(0.002668, 0.00294)
   float p01 =   3.991e-08  ;//(2.677e-08, 5.305e-08)
   float p20 =  -2.862e-06  ;//(-3.102e-06, -2.621e-06)
   float p11 =  -2.273e-10  ;//(-2.475e-10, -2.072e-10)
   float p02 =  -2.995e-15  ;//(-7.199e-15, 1.209e-15)
   float p30 =   1.104e-09  ;//(9.527e-10, 1.256e-09)
   float p21 =   3.131e-13  ;//(2.949e-13, 3.312e-13)
   float p12 =  -4.563e-18  ;//(-8.104e-18, -1.023e-18)
   float p03 =   3.721e-22  ;//(-1.456e-22, 8.898e-22)
   float p40 =  -9.892e-14  ;//(-1.339e-13, -6.396e-14)
   float p31 =  -1.341e-16  ;//(-1.423e-16, -1.26e-16)
   float p22 =  -2.168e-21  ;//(-3.911e-21, -4.245e-22)
   float p13 =   5.796e-25  ;//(2.586e-25, 9.005e-25)
   float p04 =  -2.806e-29  ;//(-5.829e-29, 2.179e-30)
   float p41 =    1.87e-20  ;//(1.651e-20, 2.089e-20)
   float p32 =   3.605e-25  ;//(-2.291e-25, 9.501e-25)
   float p23 =   1.867e-29  ;//(-8.139e-29, 1.187e-28)
   float p14 =  -1.639e-32  ;//(-2.8e-32, -4.776e-33)
   float p05 =   8.193e-37  ;//(1.057e-37, 1.533e-36)

float Poly45(float x, float y){  // calibrate FSR sensor
  return p00 + p10*x + p01*y + p20*x*x + p11*x*y + p02*y*y + p30*x*x*x + p21*x*x*y 
        + p12*x*y*y + p03*y*y*y + p40*x*x*x*x + p31*x*x*x*y + p22*x*x*y*y 
        + p13*x*y*y*y + p04*y*y*y*y + p41*x*x*x*x*y + p32*x*x*x*y*y + p23*x*x*y*y*y 
        + p14*x*y*y*y*y + p05*y*y*y*y*y; 
}

//uint16_t Poly3(float x){            // calibrate servo motor
//  return 0.2895*x*x*x + 0.4595*x*x + 0.2644*x + 79.01; 
//}

//General model Exp2:
//     f(x) = a*exp(b*x) + c*exp(d*x)
//Coefficients (with 95% confidence bounds):
//       a =   2.669e-08  (-6.227e-07, 6.761e-07)
//       b =       3.389  (-0.5694, 7.348)
//       c =       4.461  (2.401, 6.522)
//       d =      0.4105  (0.2973, 0.5237)
//Goodness of fit:
//  SSE: 258.9
//  R-square: 0.9796
//  Adjusted R-square: 0.9762
//  RMSE: 3.792

int Exp2(float x){            // calibrate servo motor
  return (2.017)*exp(0.8094*x);
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

    
    float force = Poly45(readings[readingsIndexNum], integrel); 
    Serial.println((force/9.82)*1000);
    if( force < 5.54){
      //Serial.println(Exp2(force)); 
      servoObj.write(Exp2(force));
    }else {
      servoObj.write(180);
    }

    readingsIndexNum ++; 
    if (readingsIndexNum == arraySize) {                 // wrap around to the beginning:
      readingsIndexNum = 0;                            
    }    
    
    doDataCollection = false;
  }
}
