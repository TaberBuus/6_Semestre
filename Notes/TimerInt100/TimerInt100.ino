/* READ ME
 * Timer Interrupt  
 * See website explanation:
 * https://www.instructables.com/id/Arduino-Timer-Interrupts/
 */

// ================================================================
// ===           Libraries and global variable                  ===
// ================================================================
boolean doFSRSample = false; 


// ================================================================
// ===                          Setup                           ===
// ================================================================
void setup() {
  Serial.begin(9600); 

  // TIMER 1 for interrupt frequency 100 Hz:
  cli();                // stop interrupts
  TCCR1A = 0;           // set entire TCCR1A register to 0
  TCCR1B = 0;           // same for TCCR1B
  TCNT1  = 0;           // initialize counter value to 0
  
  // set compare match register for 100 Hz increments
  OCR1A = 19999;        // = 16000000 / (8 * 100) - 1 (must be <65536)
  
  // turn on CTC mode
  TCCR1B |= (1 << WGM12);
  // Set CS12, CS11 and CS10 bits for 8 prescaler
  
  TCCR1B |= (0 << CS12) | (1 << CS11) | (0 << CS10);
  
  // enable timer compare interrupt
  TIMSK1 |= (1 << OCIE1A);
  sei();                // allow interrupts
}

// ================================================================
// ===                          Interrupt                       ===
// ================================================================
ISR(TIMER1_COMPA_vect){ //interrupt commands for TIMER 1 here
   doFSRSample = true; 
}

// ================================================================
// ===                          LOOP                            ===
// ================================================================
void loop() {
  if(doFSRSample){
    Serial.println(millis());
    doFSRSample = false; 
  }
}
