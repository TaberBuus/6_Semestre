/*
  Calibrate FSR sensor.
  
  Latest edit: 
  23.04 (Buus) - Created
  
  Reads an analog input on pin 0, prints the result to the Serial Monitor.
  Graphical representation is available using Serial Plotter (Tools > Serial Plotter menu).
  Attach the setup as this: 
  +5V - FSR - (A0 pin) - Resistor (preferabel 3K ohm) - GND 

  +5V - push button - D1 pin 

  Calibration instruction: 
  1.  Press button, Led blink 1 times
  2.  Place 5g   on sensor, press button and led blink 2 times
  3.  Place 10g  on sensor, press button and led blink 2 times
  4.  Place 25g  on sensor, press button and led blink 2 times
  5.  Place 50g  on sensor, press button and led blink 2 times
  5.  Place 100g on sensor, press button and led blink 2 times
  6.  Place 250g on sensor, press button and led blink 2 times
  7.  Place 500g on sensor, press button and led blink 2 times
  8.  Place 1000g on sensor, press button and led blink 2 times
  9.  Place 1500g on sensor, press button and led blink 2 times
  10. Place 2000g on sensor, press button and led blink 2 times
  
  Detailed description of calbration algorithm
  http://mathforum.org/library/drmath/view/72047.html
*/

const int8_t buttonPin = 1;

void setup() {
  Serial.begin(9600);   // initialize serial communication at 9600 bits per second. 
  pinMode(LED_BUILTIN, OUTPUT);  // initialize digital pin LED_BUILTIN as an output.
  pinMode(1, INPUT_PULLUP); 
}

void loop() {
  int sensorValue = analogRead(A0);   // read the input on analog pin 0:
  Serial.println(sensorValue);        // print out the value you read:
}

double fit_G( int N_points, double px[], double py[] ) {
  int i;
  double S00, S10, S20, S30, S40, S01, S11, S21;
  double denom, x, y, a, b, c;
  S00=S10=S20=S30=S40=S01=S11=S21=0;
 
  for (i=0; i<N_points; i++) { 
    x = px[i];
    y = py[i];
    //S00 += 1; // x^0+y^0
    S10 += x;
    S20 += x * x;
    S30 += x * x * x;
    S40 += x * x * x * x;
    S01 += y;
    S11 += x * y;
    S21 += x * x * y;
  }
  S00 = N_points;
 
  denom =   S00*(S20*S40 - S30*S30) - S10*(S10*S40 - S20*S30) + S20*(S10*S30 - S20*S20);

   c = (S01*(S20*S40-S30*S30)-S11*(S10*S40-S20*S30)+S21*(S10*S30-S20*S20))/denom;
   b = (S00*(S11*S40-S30*S21)-S10*(S01*S40-S21*S20)+S20*(S01*S30-S11*S20))/denom;*/
   a = (  S00*(S20*S21 - S11*S30) - S10*(S10*S21 - S01*S30) + S20*(S10*S11 - S01*S20) )/denom;
           
  double g = a*2;
  return g;
}
