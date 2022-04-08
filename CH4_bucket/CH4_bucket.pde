/*
                    | A | B | C | D | E | F |
                    |-----------------------|
  CH4               |   |   |   | X |   |   |
                    |-----------------------|
*/
#include <WaspFrame.h>
#include <WaspSensorGas_Pro.h>
#include "INIRCH4.h"


INIRCH4 CH4 = INIRCH4();

char SD_FILENAME[] = "IOTDATA.TXT";

CH4Reading ch4_values;

int status;

bool NTP_IS_SYNC = false;
bool LW_IS_SET = false;

char *MOTE_ID = "DELTA X";

uint8_t battery;

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
    //USB.println(F("Succesfully oppened file"));
  } else {
    USB.println(F("Failed to open file."));
    return false;
  }

  // Add newline
  ok &= file.write("\n") > 0;

  if (NTP_IS_SYNC == true) {
    USB.println(F("NTP is set - I will write the real time on the SD card."));
    ok &= file.write("+\t") > 0;
  } else {
    //USB.println(F("No NTP was synced. No time available :("));
    ok &= file.write("-\t") > 0;
  }

  ltoa(millis(), millis_str, 10);
  ok &= file.write(millis_str) > 0;
  ok &= file.write("\t") > 0;

  // Write epoch time (or *)
  if (NTP_IS_SYNC) {
    ltoa(RTC.getEpochTime(), epoch_time_str, 10);
    ok &= file.write(epoch_time_str) > 0;
  } else {
    ok &= file.write("*") > 0;
  }

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
  //USB.println(F("--------------- End of writeSD ------------------------"));
  return ok;
}

void readSensors() {
  delay(100);
      USB.println(F("...powering on CH4 sensor"));
  CH4.ON();

  USB.println(F("... Enter deep sleep mode 3 minutes to warm up sensors"));
  PWR.deepSleep("00:00:03:00", RTC_OFFSET, RTC_ALM1_MODE1, SENSOR_ON);
    USB.println(F("Woke up from deep sleep"));
  ch4_values = CH4.read_sensor();
  USB.print(ch4_values.conc);
  USB.println(F(" ppm"));
  CH4.OFF();
}


void CreateDataFrame(uint8_t frame_type) {

  frame.createFrame(frame_type, MOTE_ID);
  // CH4
  if(ch4_values.succes) {
    frame.addSensor(SENSOR_GASES_CH4, ch4_values.conc);
    frame.addSensor(SENSOR_CH4_M, ch4_values.faults);
    frame.addSensor(SENSOR_CH4_TS, ch4_values.sensor_temp);
  } else {
     frame.addSensor(SENSOR_GASES_CH4, -1);
  }

  //frame.showFrame();
}

void setup() {
  uint8_t error;

  // Turn ON the USB and print a start message
  USB.ON();
  delay(100);
  USB.println(MOTE_ID);

  // Init RTC
  RTC.ON();

  // Getting time
  USB.print(F("Time [Day of week, YY/MM/DD, hh:mm:ss]: "));
  USB.println(RTC.getTime());


}

void loop() {
  // New iteration
  USB.ON();

  // Turn on RTC and get starting time
  RTC.ON();

  // Check battery level
  battery = PWR.getBatteryLevel();
  USB.print(F("Battery level: "));
  USB.println(battery, DEC);

  // Step 1: Read suitable sensors
  readSensors();

  // Step 2: Create data Frame
  CreateDataFrame(ASCII);

  // Step 3: Save on SD card
  writeSD();
   PWR.deepSleep("00:00:16:00", RTC_OFFSET, RTC_ALM1_MODE1, SENSOR_ON);

//  USB.println(F("---------------------------------"));
//  USB.println(F("...Enter deep sleep mode 19 min"));
//  PWR.deepSleep("00:00:19:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);
//  USB.ON();
//  USB.print(F("...wake up!! Date: "));
//  USB.println(RTC.getTime());
//
//  RTC.setWatchdog(720); // 12h in minutes
//  USB.print(F("...Watchdog :"));
//  USB.println(RTC.getWatchdog());
//  USB.println(F("****************************************"));
}

//***********************************************************************************************
// END OF THE SKETCH
//***********************************************************************************************
