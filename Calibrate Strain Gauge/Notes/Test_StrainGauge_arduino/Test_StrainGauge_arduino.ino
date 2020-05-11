
boolean doFsrSample = false; 

const int numReadings = 5;      // points in the running filter
int readings[numReadings];      // the readings from the analog input
int readIndex = 0;              // the index of the current reading
int total = 0;                  // the running total
int initialReading = 0;         // Zero the sensor value; 

int inputPin = A1;              // input pin; 

float data;         
float a = 1373.364; 

void setup() {
  Serial.begin(19200); 

  for (int i = 0; i < numReadings; i++){
    initialReading += analogRead(A1); 
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
  data = (float) (total / numReadings) - initialReading;
  Serial.println((data/1023)*5)*a; 

  delay(100); 
}
