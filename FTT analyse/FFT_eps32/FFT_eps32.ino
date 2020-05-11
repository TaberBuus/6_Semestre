/*
 FFT analyze 
 
 Write analog read values to the serial port, followed by the Carriage Return and LineFeed terminator.

 Sampling frequence 320.

 board: m5stack
 port: COM13
 */

const int strainSensor = 2;                    // strain gauge pin 
boolean doDataCollection = false;               // indicator to send new reading
hw_timer_t * timer = NULL;                      // create timer data type

// ================================================================
// ===                          Setup                           ===
// ================================================================
void setup() {
  Serial.begin(115200);                         // initialize serial communication at 9600 bits per second:
  if (timer) {                                  // if timer is running
    timerEnd(timer);                            // stopping timer
    timer = NULL;                               // delete timer
  }
  analogSetCycles(255);                         // set adc to max cycles used for charging the capacitor before performing ADC
  dacWrite(25, 0);                              // mute speaker on M5stack

}

// ================================================================
// ===                          Interrupt                       ===
// ================================================================
void IRAM_ATTR onTimer() {
  doDataCollection = true;                      // indicate to send new analog read value  
}

void setup_timer() {
  timer = timerBegin(0, 80, true);              // timer 0, prescale = 80 (every count = 1 micro sec), true = count up
  timerAttachInterrupt(timer, &onTimer, true);  // set callback function, true = edge
  timerAlarmWrite(timer, 3125, true);           // set timer value to 3125 x 1 micro sec = 3.125 ms -> Fs = 320 Hz), true = reload
  timerAlarmEnable(timer);                      // start timer
}


// ================================================================
// ===                          Loop                            ===
// ================================================================
void loop() {
  if (!timer) {                                 // if timer is not running
    setup_timer();                              // start up timer
  }
  if(doDataCollection){                         // send new data
    // Write the analog data, followed by the terminator "Carriage Return" and "Linefeed".
    Serial.print(analogRead(strainSensor));
    Serial.write(13);                           // carriage Return 
    Serial.write(10);                           // linefeed 
    Serial.flush();                             // flush serial buffer
    doDataCollection = false;                   // prevent reentry 
  }
}
