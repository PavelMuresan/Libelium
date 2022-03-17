#include <WaspFrame.h>
#include <WaspSensorGas_Pro.h>

/*
                    | A | B | C | D | E | F |
                    |-----------------------|
  O2                |   |   |   |   |   | X |
                    |-----------------------|
*/

//====================================================================
// INSTANCE DEFINITION
//====================================================================

//bmeGasesSensor bme;
Gas O2(SOCKET_F);

// Default device name
char *MOTE_ID = "H10";

// battery control variables
uint8_t battery;

// Define measurement variables
float concO2;
int status;

//====================================================================
// Measure the sensors
//====================================================================
void readSensors(bool wait_for_sensor_warmup=true) {
  delay(100);

  USB.println(F("****************************************"));
  USB.println(F("Powering on Oxygen sensor  to warm up"));

  O2.ON();
  
  if(wait_for_sensor_warmup) {
    USB.println(F("... Enter deep sleep mode 45 minutes to warm up sensors"));
    PWR.deepSleep("00:00:00:45", RTC_OFFSET, RTC_ALM1_MODE1, SENSOR_ON);
  }

  USB.println(F("Reading oxygen concentration..."));
  concO2 = O2.getConc((float)-1000.0);


  USB.println(F("... done reading... O2"));

  USB.print(F("... O2 concentration: "));
  USB.print(concO2);
  USB.println(F(" ppm"));

  USB.println(F("... *************************************"));
}

void setup() {
  uint8_t error;

  // Turn ON the USB and print a start message
  USB.ON();
  delay(100);
  USB.println(F("\n*****************************************************"));
  USB.print(F("BEIA "));
  USB.println(MOTE_ID);
  USB.println(F("*****************************************************"));

  // Init RTC
  RTC.ON();

  // Getting time
  USB.print(F("Time [Day of week, YY/MM/DD, hh:mm:ss]: "));
  USB.println(RTC.getTime());
    
}

void loop() {
  // New iteration
  USB.ON();
  USB.println(F("\n*****************************************************"));
  USB.print(F("New iteration for BEIA "));
  USB.println(MOTE_ID);
  USB.println(F("*****************************************************"));

  // Turn on RTC and get starting time
  RTC.ON();

  // Check battery level
  battery = PWR.getBatteryLevel();
  USB.print(F("Battery level: "));
  USB.println(battery, DEC);

  // Read suitable sensors
  readSensors();

  USB.println(F("---------------------------------"));
  USB.println(F("...Enter deep sleep mode 5 sec"));
  PWR.deepSleep("00:00:00:05", RTC_OFFSET, RTC_ALM1_MODE1, SENSOR_ON);

  USB.ON();
  USB.print(F("...wake up!! Date: "));
  USB.println(RTC.getTime());

  RTC.setWatchdog(720); // 12h in minutes
  USB.print(F("...Watchdog :"));
  USB.println(RTC.getWatchdog());
  USB.println(F("****************************************"));
}

//***********************************************************************************************
// END OF THE SKETCH
//***********************************************************************************************
