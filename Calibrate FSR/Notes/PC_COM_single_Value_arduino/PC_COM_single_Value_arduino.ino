#include <Servo.h>
Servo myservo;  // create servo object to control a servo

// initializing variables
int mode = -1; 
int sensorValue; 
String inString = "";    // string to hold input
int val;    // variable to read the value from the analog pin
uint8_t i = 0;
char a = 'b'; 

// The setup routine runs once when you press reset:
void setup() {
  // Initialize serial communication at 9600 bits per second:
  Serial.begin(9600);

  myservo.attach(9);  // attaches the servo on pin 9 to the servo object


   // Check serial communication - acknowledgement routine 
  Serial.print('a'); 

  while(a != 'a'){
    // Wait for a specific charachter from the PC 
    a = Serial.read();   
  }

  //Serial.println("'/n Connected"); 
}

// The loop routine runs over and over again forever:
void loop() {
  if(Serial.available() > 0){ // check if any data has been sent by the PC
    mode = Serial.read();  // Check if there is a request
    

    // Used to set different modes for various operations. 
    // F: read and send sensor value
    // M: send a sinus wave
    // S: receive servo motor command ( doesnt work )
    switch(mode){   
          
      case 'F': 
      Serial.print(analogRead(A0)); 
      Serial.write('a');
      break; 

      case 'M': 
      // Write the sinewave points, followed by the terminator "Carriage Return" and "Linefeed".
      while(a != 't'){
        Serial.print(sin(i*50.0/360.0));
        Serial.write(13); //Carriage Return (CR) - means move cursor to beginning
        Serial.write(10); //linefeed - means move line forward
        i++; 
      }
      break; 

  
      case 'S': // Doesnt work, the switch mode function apparrently clears the serial buffer...
        while (Serial.available() > 0) {
          int inChar = Serial.read();
          if (isDigit(inChar)) {
            // convert the incoming byte to a char and add it to the string:
            inString += (char)inChar;
          }
          if (inChar == '\n') {
            Serial.println(inString.toInt());
            //myservo.write(map(inString.toInt(), 0, 100, 0, 180));
            // clear the string for new input:
            inString = "";
          }
        }
      break; 
    }
  }
}
