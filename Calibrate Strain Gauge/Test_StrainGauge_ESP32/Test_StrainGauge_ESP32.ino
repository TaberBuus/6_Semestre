boolean doLoadCellSample = false; 

const int numReadings = 300;     // points in the running filter
int readings[numReadings];      // the readings from the analog input
int readIndex = 0;              // the index of the current reading
int total = 0;                  // the running total
int initialReading = 0;         // Zero the sensor value; 


int inputPin = 35;               // input pin; 
float dataValue;         
// float a = 1373.364;           // slope found though callibration
float a = 0.913;                 // bit level to kilogram
float b = 856.831;               // Zero output offset

void setup() {
  Serial.begin(115200);
  analogReadResolution(12);             // Sets the size (in bits) of the value returned by analogRead(), default is 12-bit (0 - 4095), range is 9 - 12 bits
  analogSetWidth(12);                   // Set the sample bits and resolution. It can be a value between 9 (0 – 511) and 12 bits (0 – 4095). Default is 12-bit resolution.
  analogSetCycles(8);                   // Set the number of cycles per sample. Default is 8. Range: 1 to 255.
  analogSetSamples(1);                  // Set the number of samples in the range. Default is 1 sample. It has an effect of increasing sensitivity.
  analogSetAttenuation(ADC_11db);       // Sets the input attenuation for ALL ADC inputs, default is ADC_11db, range is ADC_0db, ADC_2_5db, ADC_6db, ADC_11db
  dacWrite(25, 0);                      // mute speaker on M5stack


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
  dataValue = (float) (total / numReadings); 
  //dataValue = (float) (total / numReadings) - initialReading;

 
  dataValue =  (1.095*dataValue -937.1-14);
  
  Serial.println(dataValue); 
  delay(10); 
}
