
// This example demonstrates Messenger's callback  & attach methods
// It outputs all the values of the default analog pins
// It sets the state (digitalWrite) of pins when receiving messages


#include <Messenger.h>
#include <MuxShield.h>

#define TOTAL_PORTS 8

int MARGIN = 3;

byte previousPinValue[54];  // PIN means PORT for input

int previousAnalogPinValue[16]; //
int previousMuxOnePinValue[16]; // first mux readings



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
   
   
    for (int k=17; k<54; k++) { // Read pins 17 to 53
        int portValue = digitalRead(k);
        if (previousPinValue[k] !=  portValue) { // only send the data when it changes, otherwise you get too many messages!
          Serial.print("d");      
          Serial.print(k, DEC);      
          Serial.print("v");
          Serial.print(portValue);
          Serial.print(' ');
          previousPinValue[k] =  portValue;
        }  
      }

      
        
     
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

    for (int j=0; j<16; j++) // FIRST MUX ROW
    {
      int value = muxShield.analogReadMS(1,j);
      if (previousMuxOnePinValue[j] !=  value && value > (previousMuxOnePinValue[j]+MARGIN) ||  value < (previousMuxOnePinValue[j]-MARGIN)) {
        Serial.print("a");      
        Serial.print((j + 100), DEC);      
        Serial.print("v");
        Serial.print(value);
        Serial.print(' ');
        previousMuxOnePinValue[j] =  value;
      }
    }


    
    
    
  }//ENDIF milliseconds

}

