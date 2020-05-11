boolean doLoadCellSample = false; 

const int numReadings = 10;     // points in the running filter
int readings[numReadings];      // the readings from the analog input
int readIndex = 0;              // the index of the current reading
int total = 0;                  // the running total
int initialReading = 0;         // Zero the sensor value; 


int inputPin = 2;               // input pin; 
float dataValue;         
float a = 1373.364;             // slope found though callibration

void setup() {
  Serial.begin(115200); 
  dacWrite(25, 0);              // mute speaker on M5stack
  analogSetCycles(255);         // set adc to max cycles used for charging the capacitor before performing ADC
  delay(100); 

  // Zero the sensor to start weight.
  for (int i = 0; i < numReadings; i++){
    initialReading += analogRead(inputPin); 
  }
  initialReading = initialReading / numReadings; 

  // initialize all the readings to 0:
  for (int thisReading = 0; thisReading < numReadings; thisReading++) {
    readings[thisReading] = 0;
  }
}

void loop() {
  // subtract the last reading:
  total = total - readings[readIndex];
  
  // read from the sensor:
  readings[readIndex] = analogRead(inputPin);
  
  // add the reading to the total:
  total = total + readings[readIndex];
  
  // advance to the next position in the array:
  readIndex = readIndex + 1;

  // if we're at the end of the array...
  if (readIndex >= numReadings) {
    // ...wrap around to the beginning:
    readIndex = 0;
  }

  // calculate the average and subtract initialReading:
  dataValue = (float) (total / numReadings) - initialReading;
  dataValue = a*(dataValue/4095)*3.3; 
  Serial.println(dataValue); 
  delay(100); 
}
