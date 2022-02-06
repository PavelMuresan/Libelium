#include <WaspSensorGas_Pro.h>
#include <WaspUtils.h>

/*
                    | A | B | C | D | E | F |
                    |-----------------------|
TeHuPr              |   |   |   |   | X |   |
O2                  |   | X |   |   |   |   |
Alarm               |   |   | X |   |   |   |
                    |-----------------------|
*/

#define RED_LED DIGITAL3
#define YELLOW_LED DIGITAL4

Gas O2(SOCKET_B);

bmeGasesSensor  bme;

float concentration;  // Stores the concentration level of O2 in ppm
float temperature;  // Stores the temperature in ºC
float humidity;   // Stores the realitve humidity in %RH
float pressure;   // Stores the pressure in Pa

int prag1 = 22.5; //First threshold for yellow alarm
int prag2 = 23.5; //Second threshold for red alarm
//int cycle_time = 120; // in seconds
unsigned long prev, b;
float O2Val;

// asta e folosita in void loop la inceput de tott
void Watchdog_setup_and_reset(int x, bool y = false) // x e timpul in secunde  iar y e enable
{
  int tt;

  if ( y)
  {
    tt = 3 * x % 60;
    if (tt > 59)  // 59 minutes max timer time
    {
      tt = 59;
    }
    if (tt < 1)
    {
      tt = 1;   // 1 minute is min timer time
    }
    RTC.setWatchdog(tt);
    USB.print(F("RTC timer reset succesful"));
    USB.print(F("next forced restart: "));
    USB.println(  RTC.getWatchdog()  );
  }

}

void alarm(int x){

  switch(x){
    case 0:
         // silence
     digitalWrite(RED_LED, LOW);
     digitalWrite(YELLOW_LED, LOW);  
     break;
    case 1:
         // buzz + yellow led
     digitalWrite(RED_LED, LOW);
     digitalWrite(YELLOW_LED, HIGH);
     break;
    case 2:
         // buzz +  red led
     digitalWrite(YELLOW_LED, LOW);
     digitalWrite(RED_LED, HIGH);
     break;
    default:
         // buzz + red led
     digitalWrite(YELLOW_LED, LOW);
     digitalWrite(RED_LED, HIGH);
     break;
    }
  
  }

void setup()
{
  // Open the USB connection
  USB.ON();
  RTC.ON();
  USB.println(F("USB port started..."));
  pinMode(RED_LED, OUTPUT);
  pinMode(YELLOW_LED, OUTPUT);
  alarm(0);

 int a = 2; // number of repetitions
 while(a){
  alarm(1);
  delay(1000);
  alarm(2);
  delay(1000);
  a = a-1;
  }

  alarm(0);

  ///////////////////////////////////////////
  // 1. Turn on the sensors
  ///////////////////////////////////////////

  // Power on the electrochemical sensor.
  // If the gases PRO board is off, turn it on automatically.
  USB.println(F("O2 sensor on..."));
  O2.ON();
  USB.println(F("Wait 3 min for warm up time..."));

  // First sleep time
  // After 2 minutes, Waspmote wakes up thanks to the RTC Alarm
 // PWR.deepSleep("00:00:02:30", RTC_OFFSET, RTC_ALM1_MODE1, ALL_ON);
  PWR.deepSleep("00:00:03:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_ON);
 // Watchdog_setup_and_reset( 4*60, true);
   USB.println(F("Wake up!"));
}

void loop()
{

  //prev = millis();
 // Watchdog_setup_and_reset( cycle_time2, true);
  ///////////////////////////////////////////
  // 2. Read sensors
  ///////////////////////////////////////////


  // Read the electrochemical sensor and compensate with the temperature internally
  concentration = O2.getConc();
  
  // Read enviromental variables
  temperature = O2.getTemp();
  humidity = O2.getHumidity();
  pressure = O2.getPressure();
  
  
  // And print the values via USB
  USB.println(F("***************************************"));
  USB.print(F("O2 concentration: "));
  USB.print(concentration);
  USB.println(F(" ppm"));


  O2Val = concentration / 10000;
  USB.print(F("O2 concentration: "));
  USB.print(O2Val);
  USB.println(F(" %"));
  USB.print(F("Temperature: "));
  USB.print(temperature);
  USB.println(F(" Celsius degrees"));
  USB.print(F("RH: "));
  USB.print(humidity);
  USB.println(F(" %"));
  USB.print(F("Pressure: "));
  USB.print(pressure);
  USB.println(F(" Pa"));

  // Show the remaining battery level
  USB.print(F("Battery Level: "));
  USB.print(PWR.getBatteryLevel(), DEC);
  USB.print(F(" %"));

  // Show the battery Volts
  USB.print(F(" | Battery (Volts): "));
  USB.print(PWR.getBatteryVolts());
  USB.println(F(" V"));


  if ( O2Val > prag1 )
  {
    if ( O2Val > prag2 )
    {
      alarm(2);
    }
    else
    {
      alarm(1);
    }
  }
  else
  { 
    alarm(0);
  }

   PWR.deepSleep("00:00:00:10", RTC_OFFSET, RTC_ALM1_MODE1, ALL_ON);
  ///////////////////////////////////////////
  // 5. Sleep
  ///////////////////////////////////////////

  // Go to deepsleep
  // After 2 minutes, Waspmote wakes up thanks to the RTC Alarm
  //  PWR.deepSleep("00:00:00:30", RTC_OFFSET, RTC_ALM1_MODE1, ALL_ON);






/*  b = cycle_time2 * 1000 - ( millis() - prev );
  if ( b < 1)
  {
    b = 0;
  }
  delay(b);*/
}

