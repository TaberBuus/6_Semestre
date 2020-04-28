#include <Servo.h>
Servo myservo;  // create servo object to control a servo

// initializing variables
int mode = -1; 
int sensorValue; 
String inString = "";    // string to hold input
int val;    // variable to read the value from the analog pin


// The setup routine runs once when you press reset:
void setup() {
  Serial.begin(9600); // Initialize serial communication at 9600 bits per second:
  myservo.attach(9);  // attaches the servo on pin 9 to the servo object
  // Check serial communication - acknowledgement routine 
  char a = 'b'; 
  Serial.print('a'); 
  while(a != 'a'){    // Wait for a specific charachter from the PC 
    a = Serial.read();   
  }
  //Serial.println("'/n Connected"); 
}


void loop() {
  while (Serial.available() > 0) {
    int inChar = Serial.read(); //
    if (isDigit(inChar)) {
      inString += (char)inChar;  // convert the incoming byte to a char and add it to the string:
    }
    if (inChar == '\n') {  // find line feed char 
      Serial.println(inString.toInt());
      myservo.write(map(inString.toInt(), 0, 100, 0, 180)); //Chance the third parameter if you chance the incomming value range match the 
      inString = "";  // clear the string for new input:
      
    }
  }   
}
