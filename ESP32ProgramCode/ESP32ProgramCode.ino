// ================================================================
// ===           Libraries and global variable                  ===
// ================================================================
#include <ESP32_Servo.h>            // esp32 servo library
Servo servoObj;                     // create servo object to control a servo
hw_timer_t * timer = NULL;          // create timer data type

const uint8_t servoPin = 26;        // servo pin 
const uint8_t fsrSensorPin = 35;    // fsr sensor pin
const uint8_t arraySize = 100;      // number of values in integrel (this correspond to 0.5 sec) 

uint8_t  readingsIndexNum = 0;      // the index of the current reading
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
  timer = timerBegin(2, 80, true);               // timer 0, prescale = 80 (every count = 1 micro sec), true = count up
  timerAttachInterrupt(timer, &onTimer, true);   // set callback function, true = edge
  timerAlarmWrite(timer, 5000, true);            // set timer value to 3125 x 1 micro sec = 3.125 ms -> Fs = 320 Hz, true = reload
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
//float Poly45(float x, float y){  // calibrate FSR sensor
//  return p00 + p10*x + p01*y + p20*x*x + p11*x*y + p02*y*y + p30*x*x*x + p21*x*x*y 
//        + p12*x*y*y + p03*y*y*y + p40*x*x*x*x + p31*x*x*x*y + p22*x*x*y*y 
//        + p13*x*y*y*y + p04*y*y*y*y + p41*x*x*x*x*y + p32*x*x*x*y*y + p23*x*x*y*y*y 
//        + p14*x*y*y*y*y + p05*y*y*y*y*y; 
//}


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
                

// ans(x) = a*exp(b*x) + c*exp(d*x)
//      Coefficients (with 95% confidence bounds):
//        a =       5.346  (4.092, 6.6)
//        b =      0.4224  (0.3083, 0.5365)
//        c =    0.006816  (-0.0294, 0.04303)
//        d =       1.572  (0.6952, 2.449)


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
    readings[readingsIndexNum] = (float) analogRead(fsrSensorPin);   // read from the fsr sensor:
    integrel = 0;                                     // reset value
    scalesIndexNum = 0;                               // reset value
    for(int i = readingsIndexNum; scalesIndexNum < arraySize; i--){
      if(i < 0) i = arraySize-1;
      integrel += scale[scalesIndexNum]*readings[i];
      scalesIndexNum++; 
    }

   
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
