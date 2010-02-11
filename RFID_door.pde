/* 
Modified by Denhart
This code is based on the sample from arduino.cc, created by djmatic...
So what's the difference? This code contains a list of allowed rfid tags,
which then is compared with the data from a rfid tag(s). So with a simple if/else
loop you're able to control what happens when an allowd id is read, this
could be a relay, LED, etc.
Hardware connections:
RFID reader GND to arduino GND
RFID reader VCC pin connected to arduino 5v
RFID reader /Enable pin connected to arduino digital pin 2
RFID reader SOUT pin connected to Serial RX pin at  arduino digital pin 8
*/

#include <SoftwareSerial.h>
#define RXPIN 7 //This defines the RxPin 
#define TXPIN 8 // This defines the TxPin
#define NO_OF_TAGS 2 //This defines the number of tags used in "tags" variable
#define ENABLE_PIN 18 //This defines the RFID /ENABLE pin
#define BAUD_RATE 9600 //This defines the baudrate for serial monitor 
#define RFID_BAUD 2400 //This defines the baudrate for the rfid SOUT
#define RELAY_PIN 1 // Defines the relay pin
#define PIEZO_PIN 4 //Defines the piezo_pin , must be PWM 
int found;
int tagno;
int allowed;
int  val = 0;
char code[10];
int bytesread = 0;
//Array of allowed tags
char tags[NO_OF_TAGS][11] =
{
  "220079BCC6",
  "22007B1AA5"
};


void setup()
{
  Serial.begin(BAUD_RATE); //Set hardware serial for monitor to 9600bps
  // Set digital pin as OUTPUT for the RFID /ENABLE pin and activate the RFID reader
  pinMode(ENABLE_PIN,OUTPUT);
  pinMode(RELAY_PIN, OUTPUT); 
  pinMode(PIEZO_PIN, OUTPUT); 
  digitalWrite(ENABLE_PIN, LOW);
}


void loop()
{
  int i;
  SoftwareSerial RFID = SoftwareSerial(RXPIN,TXPIN);
  RFID.begin(RFID_BAUD);

  if((val = RFID.read()) == 10) // check for header
    {
      bytesread = 0;
      while(bytesread<10)
        {
          val = RFID.read(); // read 10 digit code

          if((val == 10)||(val == 13)) // if header or stop bytes before the 10 digit reading stop reading!
            {
              break;
            }
          code[bytesread] = val; // add the digit
          bytesread++; // ready to read next digit
        }
    }
   if(bytesread == 10) // if 10 digit read is complete
    {
      allowed = 0;
      for(tagno=0;tagno<NO_OF_TAGS;tagno++) //Loops through all our allowed tags
        {
           found = 1;
           for(i=0;i<10;i++)
             {
               if (code[i]!=tags[tagno][i]) found = 0; //If it doesn't match set false
             }
           if(found) //If found is >0 set allowed = 1 and stop
             {
               allowed = 1;
               break;
             }

        }
      if(allowed) //So if allowed is >0 your in :P
        {
          Serial.print("Welcome\n\n"); //Do what ever you want in here.
          digitalWrite(RELAY_PIN, HIGH);   // set the LED on
          delay(10000);                  // wait for x second(s)
          digitalWrite(RELAY_PIN, LOW);    // set the LED off
        }
      else
        {
           Serial.print("Go away\n"); //Yet again you can do what ever you want.
          analogWrite(PIEZO_PIN, 105); 
          delay(1000); 
          digitalWrite(PIEZO_PIN, LOW);
      }
      bytesread = 0;
      delay(500);
    }
}
