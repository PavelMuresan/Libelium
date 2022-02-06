
#include <WaspSensorGas_v30.h>
#include <WaspUtils.h>
#include <WaspSensorPrototyping_v20.h>

#define RED_LED DIGITAL8
#define YELLOW_LED DIGITAL7

void setup()
{
  // Open the USB connection
  USB.ON();
  RTC.ON();
  USB.println(F("USB port started..."));
  pinMode(RED_LED, OUTPUT);
  pinMode(YELLOW_LED, OUTPUT);
  PWR.setSensorPower(SENS_5V, SENS_ON);
}




void loop()
{
 digitalWrite(YELLOW_LED, LOW);
 digitalWrite(RED_LED, HIGH);
 delay(5000);
 digitalWrite(RED_LED, LOW);
 digitalWrite(YELLOW_LED, HIGH);
 delay(5000);

}


