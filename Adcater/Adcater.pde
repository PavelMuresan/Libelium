
/*
                    | A | B | C | D | E | F |
                    |-----------------------|
  BME280            |   |   |   |   | X |   |
  CO2               | X |   |   |   |   |   |
  NO2               |   | X |   |   |   |   |
  O3                |   |   | X |   |   |   |
  PM                |   |   |   | X |   |   |
  SO2               |   |   |   |   |   | X |
                    |-----------------------|
*/

#include <WaspXBee868LP.h>
#include <WaspFrame.h>
#include <WaspSensorGas_Pro.h>
#include <WaspPM.h>

// Destination MAC address
//////////////////////////////////////////
char RX_ADDRESS[] = "0013A20041C3ADE5";
//////////////////////////////////////////

// define variable
uint8_t error;

float concentration_SO2 = -10; // Stores the concentration level in 
float concentration_NO2 = -10; // Stores the concentration level in 
float concentration_O3 = -10; // Stores the concentration level in 
float concentration_CO2 = -10; // Stores the concentration level in ppm
float temperature = -10;      // Stores the temperature in ºC
float humidity = -10;         // Stores the realitve humidity in %RH
float pressure = -10;         // Stores the pressure in Pa
int status;

bmeGasesSensor bme;
Gas gas_CO2(SOCKET_A);
Gas gas_NO2(SOCKET_B);
Gas gas_O3 (SOCKET_C);
Gas gas_SO2(SOCKET_F);

void readSensors(){
  
  USB.println(F("MEASURING SENSORS"));
  delay(100);

  // Reading BME
  bme.ON();

  temperature = bme.getTemperature();
  humidity = bme.getHumidity();
  pressure = bme.getPressure();

  bme.OFF();
  USB.println(F("****************************************"));

  // Read sensors
  //*************************
  //Reading electrochemical sensors
  //gas_O3.ON();
  //gas_SO2.ON();
  //gas_CO2.ON();
  //gas_NO2.ON();

  //USB.println(F("... Enter deep sleep mode 3 minutes to warm up sensors"));
  //PWR.deepSleep("00:00:03:00", RTC_OFFSET, RTC_ALM1_MODE1, SENSOR_ON);
  
  //concentration_O3 = gas_O3.getConc(temperature);
  //concentration_SO2 = gas_SO2.getConc(temperature);
  //concentration_NO2 = gas_NO2.getConc(temperature);
  //concentration_CO2 = gas_CO2.getConc(temperature);

 // gas_O3.OFF();
 // gas_SO2.OFF();
 //gas_CO2.OFF();
 //gas_NO2.OFF();

//  PM.ON();
//    
//    //Reading Particle matter 
//  USB.print("...Reading PM sensor...");
//  status = PM.getPM(8000, 5000);
//  if (status == 1) 
//  {
//    USB.println(F(" OK"));
//  }
//  else
//  {
//    USB.println(F(" Error"));  
//  }  
//  //OFF PARTICLE SENSOR
//  PM.OFF();
    
  USB.println(F("****************************************"));


  ////////////////////////////
  //SHOWING RESULTS OF THE MEASURENMENTS
  ////////////////////////////
  //BME280 measure
  USB.println(F("... MEASUREMENT RESULTS..."));
  USB.println(F("... *************************************"));
  USB.print(F("... Ambient temperature --> "));
  USB.print(temperature);
  USB.println(F(" ºC"));
  USB.print(F("... Ambient Humidity --> "));
  USB.print(humidity);
  USB.println(F(" %"));
  USB.print(F("... Ambient pressure --> "));
  USB.print(pressure);
  USB.println(F(" Pa"));

  //Electrochemical sensor measure
  USB.print(F("... O3 concentration: "));
  USB.print(concentration_O3);
  USB.println(F(" ppm"));
  USB.print(F("... SO2 concentration: "));
  USB.print(concentration_SO2);
  USB.println(F(" ppm"));
  USB.print(F("... NO2 concentration: "));
  USB.print(concentration_NO2);
  USB.println(F(" ppm"));
  USB.print(F("... CO2 concentration: "));
  USB.print(concentration_CO2);
  USB.println(F(" ppm"));

  //Particle matter measure
//  USB.print(F("...PM 1: "));
//  USB.print(PM._PM1);
//  USB.println(F(" ug/m3"));
//  USB.print(F("...PM 2.5: "));
//  USB.print(PM._PM2_5);
//  USB.println(F(" ug/m3"));
//  USB.print(F("...PM 10: "));
//  USB.print(PM._PM10);
//  USB.println(F(" ug/m3"));
//  USB.println(F("... *************************************"));
}

//====================================================================
// Create a Data Frame Lorawan
//====================================================================
void makeFrame(uint8_t frame_type){

  // 1.1. create new frame
  USB.println(F("..CREATING FRAME PROCESS "));
  frame.createFrame(frame_type);  

  // 1.2. add frame fields
  frame.addSensor(SENSOR_STR, "Complete example message"); 
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel() ); 
  frame.addSensor(SENSOR_GASES_PRO_TC, temperature);
  frame.addSensor(SENSOR_GASES_PRO_HUM, humidity);
  frame.addSensor(SENSOR_GASES_PRO_PRES, pressure);
//  frame.addSensor(SENSOR_GASES_PRO_CO2, concentration_CO2);
//  frame.addSensor(SENSOR_GASES_PRO_O3, concentration_O3);
//  frame.addSensor(SENSOR_GASES_PRO_SO2, concentration_SO2);
//  frame.addSensor(SENSOR_GASES_PRO_NO2, concentration_NO2);
//  frame.addSensor(SENSOR_GASES_PRO_PM1, PM._PM1); 
//  frame.addSensor(SENSOR_GASES_PRO_PM2_5, PM._PM2_5); 
//  frame.addSensor(SENSOR_GASES_PRO_PM10, PM._PM10);
  
  USB.println(F("\n1. Created frame to be sent"));
  frame.showFrame();
  

  }

//====================================================================
// Send Data Frame
//====================================================================
void sendPacket(){
 
  // send XBee packet
  error = xbee868LP.send( RX_ADDRESS, frame.buffer, frame.length );   
  
  USB.println(F("\n2. Send a packet to the RX node: "));
  
  // check TX flag
  if( error == 0 )
  {
    USB.println(F("send ok"));
  }
  else 
  {
    USB.println(F("send error")); 
  }
 
  
  }

 void setRTCM(){
  error = xbee868LP.setRTCfromMeshlium(RX_ADDRESS);
      
  // check flag
  if( error == 0 )
  {
    USB.print(F("SET RTC ok. "));
  }
  else 
  {
    USB.print(F("SET RTC error. "));
  }  
  
  USB.print(F("RTC Time:"));
  USB.println(RTC.getTime());

  }

void setup()
{
  // init USB port
  USB.ON();
  USB.println(F("Complete example (TX node)"));

  // set Waspmote identifier
  frame.setID("node_TX");

  // init XBee
  xbee868LP.ON( SOCKET1 );  

}
  
void loop()
{ 
    // New iteration
  USB.ON();
  USB.println(F("\n*****************************************************"));
  USB.print(F("New iteration for BEIA "));
  USB.println(F("\n*****************************************************"));

  // Turn on RTC and get starting time
  RTC.ON();
  setRTCM();

  // Step 1: Read suitable sensors
  readSensors();

  // Step 2: Create data Frame
  USB.println("Create ASCII Frame");
  makeFrame(ASCII);

  // Step 3: Save on SD card
  //writeSD();

  // Step 4: Send data
  sendPacket(); 

  USB.println(F("---------------------------------"));
  USB.println(F("...Enter deep sleep mode 16 min"));
  PWR.deepSleep("00:00:16:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);
  USB.ON();
  USB.print(F("...wake up!! Date: "));
  USB.println(RTC.getTime());

  RTC.setWatchdog(720); // 12h in minutes
  USB.print(F("...Watchdog :"));
  USB.println(RTC.getWatchdog());
  USB.println(F("****************************************"));

}
