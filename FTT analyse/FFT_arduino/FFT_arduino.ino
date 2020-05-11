/*
 FFT analyze 
 
 Write analog read values to the serial port, followed by the Carriage Return and LineFeed terminator.

 Sampling frequence 320.

 Use analog pin A1
 */

boolean doFsrSample = false; 

// The setup routine runs once when you press reset:
void setup() {
  // Initialize serial communication at 9600 bits per second:
  Serial.begin(19200);

  cli();              // stop interrupts 
  // TIMER 0 for interrupt frequency 320.5128205128205 Hz:
  TCCR0A = 0;         // set entire TCCR0A register to 0
  TCCR0B = 0;         // same for TCCR0B
  TCNT0  = 0;         // initialize counter value to 0
  
  // set compare match register for 2khz increments
  OCR0A = 194;        // = (16*10^6) / (2000*64) - 1 (must be <256)
  // turn on CTC mode
  TCCR0A |= (1 << WGM01);
  // Set CS02, CS01 and CS00 bits for 256 prescaler
  TCCR0B |= (1 << CS02) | (0 << CS01) | (0 << CS00);
  // enable timer compare interrupt
  TIMSK0 |= (1 << OCIE0A);
  sei();              // allow interrupts
}


ISR(TIMER0_COMPA_vect){   //interrupt commands for TIMER 0 here
  doFsrSample = true;
}


// The loop routine runs over and over again forever:
void loop() {
  if(doFsrSample){
    // Write the analog data, followed by the terminator "Carriage Return" and "Linefeed".
    Serial.print(analogRead(A1));
    Serial.write(13);
    Serial.write(10);
    doFsrSample = false; 
  }
}
