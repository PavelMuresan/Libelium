#include <WaspUtils.h>
#include <WaspSensorPrototyping_v20.h>




void setup()
{
/*pinMode(DIGITAL1, OUTPUT);

pinMode(DIGITAL2, OUTPUT);

pinMode(DIGITAL3, OUTPUT);

pinMode(DIGITAL3, OUTPUT);

pinMode(DIGITAL4, OUTPUT);

pinMode(DIGITAL5, OUTPUT);

pinMode(DIGITAL6, OUTPUT);

pinMode(DIGITAL7, OUTPUT);

pinMode(DIGITAL8, OUTPUT);

digitalWrite(DIGITAL1, LOW);
digitalWrite(DIGITAL2, LOW);
digitalWrite(DIGITAL3, LOW);
digitalWrite(DIGITAL3, LOW);
digitalWrite(DIGITAL4, LOW);
digitalWrite(DIGITAL5, LOW);
digitalWrite(DIGITAL6, LOW);
digitalWrite(DIGITAL7, LOW);
digitalWrite(DIGITAL8, LOW);

USB.ON();*/
USB.println("5V is on");
PWR.setSensorPower(SENS_3V3, SENS_ON);

}

void loop()
{
/*
digitalWrite(DIGITAL1, HIGH);
USB.println("1 is on");
delay(5000);
digitalWrite(DIGITAL1, LOW);

digitalWrite(DIGITAL2, HIGH);
USB.println("2 is on");
delay(5000);
digitalWrite(DIGITAL2, LOW);

digitalWrite(DIGITAL3, HIGH);
USB.println("3 is on");
delay(5000);
digitalWrite(DIGITAL3, LOW);

digitalWrite(DIGITAL4, HIGH);
USB.println("4 is on");
delay(5000);
digitalWrite(DIGITAL4, LOW);

digitalWrite(DIGITAL5, HIGH);
USB.println("5 is on");
delay(5000);
digitalWrite(DIGITAL5, LOW);

digitalWrite(DIGITAL6, HIGH);
USB.println("6 is on");
delay(5000);
digitalWrite(DIGITAL6, LOW);

digitalWrite(DIGITAL7, HIGH);
USB.println("7 is on");
delay(5000);
digitalWrite(DIGITAL7, LOW);

digitalWrite(DIGITAL8, HIGH);
USB.println("8 is on");
delay(5000);
digitalWrite(DIGITAL8, LOW);

USB.println("------------------------------");
delay(2000);
USB.println("3V3 is on");
PWR.setSensorPower(SENS_3V3, SENS_ON);
delay(2000);
USB.println("------------------------------");

digitalWrite(DIGITAL1, LOW);
USB.println("1 is off");
delay(5000);
digitalWrite(DIGITAL2, LOW);
USB.println("2 is off");
delay(5000);
digitalWrite(DIGITAL3, LOW);
USB.println("3 is off");
delay(5000);
digitalWrite(DIGITAL4, LOW);
USB.println("4 is off");
delay(5000);
digitalWrite(DIGITAL5, LOW);
USB.println("5 is off");
delay(5000);
digitalWrite(DIGITAL6, LOW);
USB.println("6 is off");
delay(5000);
digitalWrite(DIGITAL7, LOW);
USB.println("7 is off");
delay(5000);
digitalWrite(DIGITAL8, LOW);
USB.println("8 is off");
delay(5000);

      // pinMode(DUST_SENSOR_POWER, OUTPUT);
     // digitalWrite(DUST_SENSOR_POWER, HIGH);
/*delay(1000);
  PWR.setSensorPower(SENS_3V3, SENS_OFF);
  //digitalWrite(DUST_SENSOR_POWER, LOW);

digitalWrite(DIGITAL1, LOW);
digitalWrite(DIGITAL2, LOW);
digitalWrite(DIGITAL3, LOW);
digitalWrite(DIGITAL3, LOW);
digitalWrite(DIGITAL4, LOW);
digitalWrite(DIGITAL5, LOW);
digitalWrite(DIGITAL6, LOW);
digitalWrite(DIGITAL7, LOW);
digitalWrite(DIGITAL8, LOW);

delay(1000);*/
}
