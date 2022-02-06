

// define file name: MUST be 8.3 SHORT FILE NAME
char filename[] = "IOTDATA.TXT";

// array in order to read data
char output[101];

// define variable
uint8_t sd_answer;


void setup()
{
  // open USB port
  USB.ON();
  USB.println(F("SD card reader"));

  // Set SD ON
  SD.ON();
  SD.ls();

  USB.print(F("************************************************************************"));
  USB.print(F("************************************************************************"));

  USB.print(F("SHOWS  FILE CONTENTS"));
  SD.showFile(filename);

  delay(1000);
  USB.print(F("************************************************************************"));
  USB.print(F("************************************************************************"));
  USB.print(F("END"));
  SD.OFF();
}


void loop()
{
  delay(3000);

}


