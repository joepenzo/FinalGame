
// This example demonstrates Messenger's callback  & attach methods
// It outputs all the values of the default analog pins
// It sets the state (digitalWrite) of pins when receiving messages


#include <Messenger.h>
#include <MuxShield.h>

#define TOTAL_PORTS 8

#define MARGIN 6

byte previousPinValue[54];  // PIN means PORT for input
int previousAnalogPinValue[13]; //
int previousMuxOnePinValue[16]; // first mux readings
int previousMuxSecondPinValue[16]; // second mux readings



//Initialize the Mux Shield
MuxShield muxShield;

// Define a metronome
unsigned long previousMillis = 0;
//Set the default interval to every 20 milliseconds
unsigned long interval = 20;

// Instantiate Messenger object with the message function and the default separator (the space character)
Messenger message = Messenger(); 



// Define messenger function
void messageCompleted() {
  int pin = 0;
  // Loop through all the available elements of the message
  while ( message.available() ) {
    int pin = message.readInt();
    int state = message.readInt();
    // Set the pin as determined by the message
    digitalWrite( pin, state);
  }
}

void setup() {
  muxShield.setMode(1,ANALOG_IN);
  muxShield.setMode(2,ANALOG_IN);
 // muxShield.setMode(3,ANALOG_IN);
  
  // Initiate Serial Communication
  Serial.begin(57600); 
  message.attach(messageCompleted);
}

void loop() {
  // The following line is the most effective way of 
  // feeding the serial data to Messenger
  while ( Serial.available() ) message.process(Serial.read());
  
  if ( millis() - previousMillis > interval ) {
    previousMillis = millis();
   
        
     
    // normal analog pins 
    for (int i=10; i< 16; i++) // skip the first pins,
    {
        if (previousAnalogPinValue[i] != analogRead(i) && analogRead(i) > (previousAnalogPinValue[i]+MARGIN) ||  analogRead(i) < (previousAnalogPinValue[i]-MARGIN)) { // only send the data when it changes, otherwise you get too many messages!
        //if (previousAnalogPinValue[i] !=  analogRead(i)) { // only send the data when it changes, otherwise you get too many messages!
          Serial.print("a");      
          Serial.print(i, DEC);      
          Serial.print("v");
          Serial.print(analogRead(i));
          Serial.print(' ');
          previousAnalogPinValue[i] = analogRead(i);
        }
    }

    for (int i=0; i<16; i++) // FIRST MUX ROW
    {
      int value = muxShield.analogReadMS(1,i);
      if (previousMuxOnePinValue[i] !=  value && value > (previousMuxOnePinValue[i]+MARGIN) ||  value < (previousMuxOnePinValue[i]-MARGIN)) {
        Serial.print("a");      
        Serial.print((i + 100), DEC);      
        Serial.print("v");
        Serial.print(value);
        Serial.print(' ');
        previousMuxOnePinValue[i] =  value;
      }
    }

//    
//     for (char i=22; i<54; i++) { // Read pins 22 to 53
//        int portValue = digitalRead(i);
//        if (previousPinValue[i] !=  portValue) { // only send the data when it changes, otherwise you get too many messages!
//          Serial.print("d");      
//          Serial.print(i, DEC);      
//          Serial.print("v");
//          Serial.print(portValue);
//          Serial.print(' ');
//          previousPinValue[i] =  portValue;
//        }  
//      }

      
    
    
  }//ENDIF milliseconds

}

