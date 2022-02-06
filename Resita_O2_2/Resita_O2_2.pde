#include <WaspFrame.h>
#include <WaspSensorGas_Pro.h>

/*
                    | A | B | C | D | E | F |
                    |-----------------------|
  BME280            |   |   |   |   | X |   |
  O2                |   |   |   |   |   | X |
  Buzzer            |   |   | X |   |   |   |
                    |-----------------------|
*/



//====================================================================
// INSTANCE DEFINITION
//====================================================================
bmeGasesSensor bme;
Gas O2(SOCKET_F);


// Default device name
char *MOTE_ID = "H4";

//====================================================================
// PARAMETERS FOR SD CARD
//===================================================================
char SD_FILENAME[] = "IOTDATA.TXT";

// battery control variables
uint8_t battery;
// other variables
uint8_t error;
uint8_t error_flag;
int8_t cont;
uint8_t connection_status;

/////////////////////////////////////////////////
// Define measurement variables
////////////////////////////////////////////////

float temperature;      // Stores the temperature in ºC
float humidity;         // Stores the realitve humidity in %RH
float pressure;         // Stores the pressure in Pa
float concO2;


int status;




/*
 * Writes the frame to the SD card usind the following format:
 * When RTC is okay (set)
 * +\t<milis>\t<epoch_time>\t<frame>
 * When RTC is not set
 * -\t<milis>\t*\t<frame>
 * Uses NTP_IS_SYNC to see if the RTC is set.
 * Returns true if the write is succesful.
 */
bool writeSD(void) {
  bool ok = true;
  USB.println(F("--------------- Start of writeSD ------------------------"));
  uint8_t sd_status = 0;
  char epoch_time_str[16];
  char millis_str[16];

  // Start SD
  SD.ON();

  // Open file
  SdFile file;
  sd_status = SD.openFile(SD_FILENAME, &file, O_APPEND | O_CREAT | O_RDWR);
  if (sd_status == 1) {
    USB.println(F("Succesfully oppened file"));
  } else {
    USB.println(F("Failed to open file."));
    return false;
  }

  // Add newline
  ok &= file.write("\n") > 0;

//  if (NTP_IS_SYNC == true) {
//    USB.println(F("NTP is set - I will write the real time on the SD card."));
//    ok &= file.write("+\t") > 0;
//  } else {
//    USB.println(F("No NTP was synced. No time available :("));
//    ok &= file.write("-\t") > 0;
//  }

  ltoa(millis(), millis_str, 10);
  ok &= file.write(millis_str) > 0;
  ok &= file.write("\t") > 0;

  // Write epoch time (or *)
//  if (NTP_IS_SYNC) {
//    ltoa(RTC.getEpochTime(), epoch_time_str, 10);
//    ok &= file.write(epoch_time_str) > 0;
//  } else {
//    ok &= file.write("*") > 0;
//  }

  // Write \t before frame
  ok &= file.write("\t") > 0;

  ok &= file.write(frame.buffer, frame.length) > 0;

  if (ok) {
    USB.println(F("All write operation were succesful"));
  } else {
    USB.println(F("Some errors when writting."));
  }
  // Close the file
  SD.closeFile(&file);

  // Stop SD
  SD.OFF();
  USB.println(F("--------------- End of writeSD ------------------------"));
  return ok;
}

//====================================================================
// Measure the sensors
//====================================================================
void readSensors(int x) {
  delay(100);
  
  USB.println(F("****************************************"));
  USB.println(F("Powering on Oxygen sensor  to warm up"));

  O2.ON();

  if(x) 
  {USB.println(F("... Enter deep sleep mode 2min to warm up sensors"));
  PWR.deepSleep("00:00:02:00", RTC_OFFSET, RTC_ALM1_MODE1, SENSOR_ON);

  USB.println(F("Woke up from deep sleep. Reading BME first"));
  }
  
  USB.println(F("...BME ON"));
  bme.ON();

  USB.println(F("...reading temperature, humidity and presuure."));
  temperature = bme.getTemperature();
  humidity = bme.getHumidity();
  pressure = bme.getPressure();
  
  USB.println(F("...done reading... BME OFF."));
  bme.OFF();

  USB.println(F("Reading oxygen concentration..."));
  concO2 = O2.getConc(temperature);
    
  USB.println(F("... done reading... O2"));

  USB.print(F("... O2 concentration: "));
  USB.print(concO2);
  USB.println(F(" ppm"));
  
  USB.println(F("... *************************************"));
}

//====================================================================
// Create a Data Frame Lorawan
//====================================================================
void CreateDataFrame(uint8_t frame_type) {
  USB.println(F("..CREATING FRAME PROCESS "));

    frame.createFrame(ASCII);
    //Add BAT level
    frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());
    // Add temperature
    frame.addSensor(SENSOR_GASES_PRO_TC, temperature, 2);
    // Add humidity
    frame.addSensor(SENSOR_GASES_PRO_HUM, humidity, 2);
    // Add pressure value
    frame.addSensor(SENSOR_GASES_PRO_PRES, pressure, 2);
    // Add O2 value
    frame.addSensor(SENSOR_GASES_PRO_O2, concO2, 3);
    // Show the frame
    frame.showFrame();

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
   readSensors(1);
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

  // Step 1: Read suitable sensors
  readSensors(0);

  // Step 2: Create data Frame
  USB.println("Create ASCII Frame");
  CreateDataFrame(ASCII);

  // Step 3: Save on SD card
  writeSD();

  USB.println(F("---------------------------------"));
  USB.println(F("...Enter deep sleep mode 5 sec"));
  PWR.deepSleep("00:00:00:05", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);
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
