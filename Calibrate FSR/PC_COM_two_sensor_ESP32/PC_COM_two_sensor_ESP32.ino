/*
 Write analog values to the serial port, followed by the Carriage Return and LineFeed terminator.
 Sampling at frequency of 320 Hz. 
 Connect M5stack at COM13. 
 */

boolean doDataCollection  = false;             // indicator to send new reading
const int strainSensorPin = 35;                // strain gauge sensor pin 
const int fsrSensorPin    = 2;                 // fsr sensor pin 
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
  
  analogReadResolution(12);             // sets the size (in bits) of the value returned by analogRead(), default is 12-bit (0 - 4095), range is 9 - 12 bits
  analogSetWidth(12);                   // set the sample bits and resolution. It can be a value between 9 (0 – 511) and 12 bits (0 – 4095). Default is 12-bit resolution.
  analogSetCycles(255);                 // set the number of cycles per sample. Default is 8. Range: 1 to 255.
  analogSetSamples(1);                  // set the number of samples in the range. Default is 1 sample. It has an effect of increasing sensitivity.
  analogSetAttenuation(ADC_11db);       // sets the input attenuation for ALL ADC inputs, default is ADC_11db, range is ADC_0db, ADC_2_5db, ADC_6db, ADC_11db
  dacWrite(25, 0);                      // mute speaker on M5stack
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
  timerAlarmWrite(timer, 5000, true);            // set timer value to 3125 x 1 micro sec = 3.125 ms -> Fs = 320 Hz), true = reload
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
    Serial.print(analogRead(fsrSensorPin));     // write fsr value to serial 
    Serial.write(13);                           // CR
    Serial.write(10);                           // LF
    Serial.print(analogRead(strainSensorPin));  // write strain value to serial
    Serial.write(13);                           // CR
    Serial.write(10);                           // LF
    Serial.flush();
    doDataCollection = false;                   // prevent reentry
  }
}
