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

  cli();//stop interrupts 
  
  //set timer0 interrupt at 2kHz
  TCCR0A = 0;// set entire TCCR0A register to 0
  TCCR0B = 0;// same for TCCR0B
  TCNT0  = 0;//initialize counter value to 0
  // set compare match register for 2khz increments
  OCR0A = 194;// = (16*10^6) / (2000*64) - 1 (must be <256)
  // turn on CTC mode
  TCCR0A |= (1 << WGM01);
  // Set CS02, CS01 and CS00 bits for 256 prescaler
  TCCR0B |= (1 << CS02) | (0 << CS01) | (0 << CS00);
  // enable timer compare interrupt
  TIMSK0 |= (1 << OCIE0A);

  sei();//allow interrupts

  Serial.println("Setup complete");
}

// ================================================================
// ===                          Interrupt                       ===
// ================================================================
ISR(TIMER0_COMPA_vect){//timer0 interrupt 2kHz toggles pin 8
//generates pulse wave of frequency 2kHz/2 = 1kHz (takes two cycles for full wave- toggle high then toggle low)
    Serial.println("virker"); 
 
}
// ================================================================
// ===                          LOOP                            ===
// ================================================================
void loop() {
  
}
