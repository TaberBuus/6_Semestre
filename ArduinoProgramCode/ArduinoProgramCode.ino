/* READ ME
 * Timer Interrupt  
 * See website explanation:
 * https://www.instructables.com/id/Arduino-Timer-Interrupts/
 */

// ================================================================
// ===           Libraries and global variable                  ===
// ================================================================
#include <Servo.h>      // arduino uses timer 1 for PWM interface
Servo myservo;          // create servo object to control a servo
#define FILTERSIZE 5

uint16_t data[FILTERSIZE];
boolean doFsrSample = false;    // activated by timer interrupt
boolean sendServoCmd = false; 
uint16_t val = 5; 


// ================================================================
// ===                          Setup                           ===
// ===============================================================
void setup() {
  Serial.begin(9600); 
  myservo.attach(9);  // attaches the servo on pin 9 to the servo object  
  
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

// ================================================================
// ===                          Interrupt                       ===
// ================================================================

ISR(TIMER0_COMPA_vect){   //interrupt commands for TIMER 0 here
  doFsrSample = true;
}


// ================================================================
// ===                          Functions                       ===
// ================================================================

uint16_t voltageToMass(uint16_t value){
  float valueTemp = (float) value; 
  valueTemp = (valueTemp/1023)*5; 
  valueTemp = (6.652e-13)*exp(valueTemp * 7.029) + 20.56*exp(valueTemp*0.4484);
  return (uint16_t) valueTemp; 
}

// ================================================================
// ===                          LOOP                            ===
// ================================================================

void loop() {
  if(doFsrSample){
    data[1] = voltageToMass( analogRead(A0) ); 
    sendServoCmd = true; 
    doFsrSample = false; 
  }

  if(sendServoCmd){
    // sets the servo position according to the scaled value;
    // scale it to use it with the servo (value between 0 and 180) 
    myservo.write( map(data[1], 0, 1413, 80, 180)  );    
    sendServoCmd = false;  
  }
}
