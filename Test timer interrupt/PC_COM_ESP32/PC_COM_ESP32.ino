/*
 Sampling at frequency of 320 Hz. 
 Connect M5stack at COM13. 
 */

boolean doDataCollection  = false;             // indicator to send new reading
const int strainSensorPin = 2;                // strain gauge sensor pin 
hw_timer_t * timer = NULL;                     // create timer data type

// ================================================================
// ===                          Setup                           ===
// ================================================================
void setup() {
  Serial.begin(115200);                        // initialize serial communication at 115200 bits per second
  if (timer) {                                 // if timer is running
    timerEnd(timer);                           // stopping timer
    timer = NULL;                              // delete timer
  }
  analogSetCycles(255);                        // set adc to max cycles used for charging the capacitor before performing ADC
  dacWrite(25, 0);                             // mute speaker on M5stack
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
  timerAlarmWrite(timer, 3125, true);          // set timer value to 500000 x 1 micro sec = 0.5 sec -> Fs = 2 Hz), true = reload
  timerAlarmEnable(timer);                       // start timer
}


// ================================================================
// ===                          Loop                            ===
// ================================================================
void loop() {
  if(!timer) {                                  // if timer is not running
    setup_timer();                              // start up timer
  }
  if(doDataCollection){
    // Write the analog data, followed by the terminator "Carriage Return" and "Linefeed".
    Serial.print(10);         // write fsr value to serial 
    Serial.write(13);                           // CR
    Serial.write(10);                           // LF
    Serial.flush();
    doDataCollection = false;                   // prevent reentry
  }
}
