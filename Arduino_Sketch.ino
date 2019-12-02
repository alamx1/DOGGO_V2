#include <Arduino.h>
#include <SPI.h>
#include "Adafruit_BLE.h"
#include "Adafruit_BluefruitLE_SPI.h"
#include "Adafruit_BluefruitLE_UART.h"
#include "Adafruit_BLEEddystone.h"
#include "Adafruit_BLEBattery.h"
//#include "BLEBeacon.h"

#include "BluefruitConfig.h"

#if SOFTWARE_SERIAL_AVAILABLE
  #include <SoftwareSerial.h>
#endif

/*=========================================================================
    APPLICATION SETTINGS

? ? FACTORYRESET_ENABLE? ?  Perform a factory reset when running this sketch
? ?
? ?                         Enabling this will put your Bluefruit LE module
                            in a 'known good' state and clear any config
                            data set in previous sketches or projects, so
? ?                         running this at least once is a good idea.
? ?
? ?                         When deploying your project, however, you will
                            want to disable factory reset by setting this
                            value to 0.? If you are making changes to your
? ?                         Bluefruit LE device via AT commands, and those
                            changes aren't persisting across resets, this
                            is the reason why.? Factory reset will erase
                            the non-volatile memory where config data is
                            stored, setting it back to factory default
                            values.
? ? ? ?
? ?                         Some sketches that require you to bond to a
                            central device (HID mouse, keyboard, etc.)
                            won't work at all with this feature enabled
                            since the factory reset will clear all of the
                            bonding data stored on the chip, meaning the
                            central device won't be able to reconnect.
    MINIMUM_FIRMWARE_VERSION  Minimum firmware version to have some new features
    
    MODE_LED_BEHAVIOUR        LED activity, valid options are
                              "DISABLE" or "MODE" or "BLEUART" or
                              "HWUART"  or "SPI"  or "MANUAL"   

    URL                       The URL that is advertised. It must not longer
                              than 17 bytes (excluding http:// and www.).
                              Note: ".com/" ".net/" count as 1                                                  
    -----------------------------------------------------------------------*/
    #define FACTORYRESET_ENABLE      1
    #define MINIMUM_FIRMWARE_VERSION    "0.7.0"
    #define MODE_LED_BEHAVIOUR          "MODE"
    #define URL                         "https://bit.ly/FindDoggo"
    #define MANUFACTURER_APPLE         "0x004C"

    #define BEACON_MANUFACTURER_ID      MANUFACTURER_APPLE
    #define DOGGO_BEACON_UUID           "DC-1D-DF-E3-58-01-4C-69-B5-87-8B-C3-88-32-64-25"
    #define BEACON_MAJOR                "0x0000"
    #define BEACON_MINOR                "0x0000"
    #define BEACON_RSSI_1M              "-54"
    
/*=========================================================================*/


// Create the bluefruit object, either software serial...uncomment these lines
/*
SoftwareSerial bluefruitSS = SoftwareSerial(BLUEFRUIT_SWUART_TXD_PIN, BLUEFRUIT_SWUART_RXD_PIN);

Adafruit_BluefruitLE_UART ble(bluefruitSS, BLUEFRUIT_UART_MODE_PIN,
                      BLUEFRUIT_UART_CTS_PIN, BLUEFRUIT_UART_RTS_PIN);
*/

/* ...or hardware serial, which does not need the RTS/CTS pins. Uncomment this line */
// Adafruit_BluefruitLE_UART ble(BLUEFRUIT_HWSERIAL_NAME, BLUEFRUIT_UART_MODE_PIN);

/* ...hardware SPI, using SCK/MOSI/MISO hardware SPI pins and then user selected CS/IRQ/RST */
Adafruit_BluefruitLE_SPI ble(BLUEFRUIT_SPI_CS, BLUEFRUIT_SPI_IRQ, BLUEFRUIT_SPI_RST);

/* ...software SPI, using SCK/MOSI/MISO user-defined SPI pins and then user selected CS/IRQ/RST */
//Adafruit_BluefruitLE_SPI ble(BLUEFRUIT_SPI_SCK, BLUEFRUIT_SPI_MISO,
//                             BLUEFRUIT_SPI_MOSI, BLUEFRUIT_SPI_CS,
//                             BLUEFRUIT_SPI_IRQ, BLUEFRUIT_SPI_RST);

Adafruit_BLEBattery battery(ble);
Adafruit_BLEEddystone eddyBeacon(ble);

// A small helper
void error(const __FlashStringHelper*err) {
  Serial.println(err);
  while (1);
}

/****  Sets up the HW an the BLE module (this function is called
            automatically on startup) ****/
/**************************************************************************/
void setup(void)
{
  while (!Serial);  // required for Flora & Micro
  delay(500);

  Serial.begin(115200);
  Serial.println(F("Adafruit Bluefruit AT Command Example"));
  Serial.println(F("-------------------------------------"));

  /* Initialise the module */
  Serial.print(F("Initialising the Bluefruit LE module: "));

  if ( !ble.begin(VERBOSE_MODE) )
  {
    error(F("Couldn't find Bluefruit, make sure it's in CoMmanD mode & check wiring?"));
  }
  Serial.println( F("OK!") );

  if ( FACTORYRESET_ENABLE )
  {
    /* Perform a factory reset to make sure everything is in a known state */
    Serial.println(F("Performing a factory reset: "));
    if ( ! ble.factoryReset() ){
      error(F("Couldn't factory reset"));
    }
  }

  /* Disable command echo from Bluefruit */
  ble.echo(false);

  Serial.println("Requesting Bluefruit info:");
  /* Print Bluefruit information */
  ble.info();

  /**** Eddystone ****/
  // EddyStone commands are added from firmware 0.6.6
  if ( !ble.isVersionAtLeast(MINIMUM_FIRMWARE_VERSION) )
  {
    error(F("EddyStone is only available from 0.6.6. Please perform firmware upgrade"));
  }

  // Enable Eddystone beacon service and reset Bluefruit if needed
  eddyBeacon.begin(true);

  /* Set EddyStone URL beacon data */
  Serial.println(F("Setting EddyStone-url to Adafruit website: "));

  if ( !eddyBeacon.setURL(URL) ) {
    error(F("Couldnt set, is URL too long !?"));
  }

  Serial.println(F("**************************************************"));
  Serial.println(F("Please use Google \"Physical Web\" application to test"));
  Serial.println(F("**************************************************"));

  /**** battery setup ****/
  // Enable Battery service and reset Bluefruit
  battery.begin(true);

  /** CMD MODE **/
  Serial.println(F("Please use Adafruit Bluefruit LE app to connect in UART mode"));
  Serial.println(F("Then Enter characters to send to Bluefruit"));
  Serial.println();

  /**** iBeacon ****/
  Serial.print(F("Setting up beacon"));
  adBeacon();

//  ble.verbose(false);  // debug info is a little annoying after this point!
//  /* Wait for connection */
//  while (! ble.isConnected()) {
//      delay(500);
//  }
//
//  // LED Activity command is only supported from 0.6.6
//  if ( ble.isVersionAtLeast(MINIMUM_FIRMWARE_VERSION) )
//  {
//    // Change Mode LED Activity
//    Serial.println(F("******************************"));
//    Serial.println(F("Change LED activity to " MODE_LED_BEHAVIOUR));
//    ble.sendCommandCheckOK("AT+HWModeLED=" MODE_LED_BEHAVIOUR);
//    Serial.println(F("******************************"));
//  }

  
}

int value = 0;

/****  Constantly poll for new command or response data ****/
/**************************************************************************/
void loop(void)
{
/****  Battery code: Constantly poll for new command or response data ****/
  // Should get Battery value from LIPO and update
//  battery.update(value);
//  Serial.print("Update battery level = ");
//  Serial.println(value);
//  delay(5000);

  if( !(ble.isConnected())){
    /**** EddyStone ****/
    Serial.println("Broadcasting now");
    eddyBeacon.startBroadcast();
  }

 /**** CMD Mode code: Constantly poll for new command or response data ****/
 // Check for user input
  char inputs[BUFSIZE+1];

  if ( getUserInput(inputs, BUFSIZE) )
  {
    // Send characters to Bluefruit
    Serial.print("[Send] ");
    Serial.println(inputs);

    ble.print("AT+BLEUARTTX=");
    ble.println(inputs);

    // check response stastus
    if (! ble.waitForOK() ) {
      Serial.println(F("Failed to send?"));
    }
  }

  // Check for incoming characters from Bluefruit
  ble.println("AT+BLEUARTRX");
  ble.readline();
  if (strcmp(ble.buffer, "OK") == 0) {
    // no data
    return;
  }
  // Some data was found, its in the buffer
  Serial.print(F("[Recv] ")); Serial.println(ble.buffer);
  
  if(strcmp(ble.buffer, "battery") == 0){
    battery.update(value);
    Serial.print("printing value");
    // Send characters to Bluefruit
    Serial.print("[Send] ");
    Serial.println(value);
    
    ble.print("AT+BLEUARTTX=");
    ble.println(value);

    // check response stastus
    if (! ble.waitForOK() ) {
      Serial.println(F("Failed to send?"));
    }    
  }
    
  //Serial.print(F("[Recv2] ")); Serial.println(ble.buffer);
  ble.waitForOK();

  /**** iBeacon ****/
  adBeacon();
}

/**************************************************************************/

/**** Advertise iBeacon ****/
void adBeacon(){
  Serial.println(F("Setting beacon configuration details for DOGGO: "));

  // AT+BLEBEACON=0x004C, DC-1D-DF-E3-58-01-4C-69-B5-87-8B-C3-88-32-64-25, 0x0000, 0x0000, -54
  ble.print("AT+BLEBEACON="        );
  ble.print(BEACON_MANUFACTURER_ID ); ble.print(',');
  ble.print(DOGGO_BEACON_UUID            ); ble.print(',');
  ble.print(BEACON_MAJOR           ); ble.print(',');
  ble.print(BEACON_MINOR           ); ble.print(',');
  ble.print(BEACON_RSSI_1M         );
  ble.println(); // print line causes the command to execute

  // check response status
  if (! ble.waitForOK() ) {
    error(F("Didn't get the OK"));
  }

  Serial.println();
  Serial.println(F("Open your beacon app to test"));  
}
/**** Checks for user input (via the Serial Monitor) ****/
bool getUserInput(char buffer[], uint8_t maxSize) {
  // timeout in 100 milliseconds
  TimeoutTimer timeout(100);

  memset(buffer, 0, maxSize);
  while( (!Serial.available()) && !timeout.expired() ) { delay(1); }

  if ( timeout.expired() ) return false;

  delay(2);
  uint8_t count=0;
  do
  {
    count += Serial.readBytes(buffer+count, maxSize);
    delay(2);
  } while( (count < maxSize) && (Serial.available()) );

  return true;
}

/**** Checks for user input (via the Serial Monitor) ****/
//void getUserInput(char buffer[], uint8_t maxSize)
//{
//  memset(buffer, 0, maxSize);
//  while( Serial.available() == 0 ) {
//    delay(1);
//  }
//
//  uint8_t count=0;
//
//  do
//  {
//    count += Serial.readBytes(buffer+count, maxSize);
//    delay(2);
//  } while( (count < maxSize) && !(Serial.available() == 0) );
//}
