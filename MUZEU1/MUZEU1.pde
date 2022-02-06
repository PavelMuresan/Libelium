#include <WaspSensorGas_Pro.h>
#include <WaspPM.h>
#include <WaspXBee868LP.h>
#include <Wasp485.h>
#include <WaspFrame.h> 
#include <TSL2561.h>

/*
                    | A | B | C | D | E | F |
                    |-----------------------|
TeHuPr              | X |   |   |   |   |   |
CO2                 |   | X |   |   |   |   |
SO2                 |   |   | X |   |   |   |
NO2                 |   |   |   |   |   | X |
PM-X                |   |   |   | X |   |   |
Lum                 |   |   |   |   | X |   |
                    |-----------------------|
*/

// Destination MAC address
char RX_ADDRESS[] =  "0013A20041C3B269"; 


// define variable
uint8_t error;
uint8_t error2;
uint8_t answer = -1;
uint8_t retries = 0;

Gas CO2(SOCKET_B);
Gas SO2(SOCKET_C);
Gas NO2(SOCKET_F);

bmeGasesSensor  bme;

float temperature;
float humidity;
float pressure;

float concCO2;
float concNO2;
float concSO2;
float light;

int OPC_status;
int OPC_measure;

char node_ID[] = "MUZEU1";

void read_light()
{
// Power on the 3v3.
      PWR.setSensorPower(SENS_3V3, SENS_ON);
// Enable the communication with the board
      digitalWrite(GP_I2C_MAIN_EN, HIGH);  
// Power on the sensor.
      TSL.ON();    
// Read the luminosity sensor
      TSL.getLuminosity();
      light = TSL.lux;
// Disable the communication with the board
      digitalWrite(GP_I2C_MAIN_EN, LOW);
// Power off the sensor.
      PWR.setSensorPower(SENS_3V3, SENS_OFF);
}

void read_sensors()
{
// Read enviromental variables
    read_light();
    bme.ON();
    temperature = bme.getTemperature();
    humidity = bme.getHumidity();
    pressure = bme.getPressure();
    bme.OFF();

//Power on gas sensors and wait for them to warm up. (2 minutes0
    CO2.ON();
    NO2.ON();
    SO2.ON();

    USB.println(RTC.getTime());
    USB.println(F("Enter deep sleep mode to wait for sensors heating time (2 min.)..."));
    PWR.deepSleep("00:00:02:00", RTC_OFFSET, RTC_ALM1_MODE1, SENSOR_ON);
    USB.println(RTC.getTime());
    USB.println(F("wake up!!\r\n"));

// Read the sensors and compensate with the temperature internally
    concCO2 = CO2.getConc(temperature);
    concNO2 = NO2.getConc(temperature);
    concSO2 = SO2.getConc(temperature);
    
//Power off sensors
    CO2.OFF();
    NO2.OFF();
    SO2.OFF();

//Turn on the particle matter sensor
    OPC_status = PM.ON();
    if (OPC_status == 1)
    {
        USB.println(F("Particle sensor started"));
    }
    else
    {
        USB.println(F("Error starting the particle sensor"));
    }

// Get measurement from the particle matter sensor
    if (OPC_status == 1)
    {
        // Power the fan and the laser and perform a measure of 5 seconds
        OPC_measure = PM.getPM(5000, 5000);
    }

    PM.OFF();
}

void send_frame()
{
// Create new frame (ASCII)
    frame.createFrame(ASCII);
    // Add PM1
    frame.addSensor(SENSOR_GASES_PRO_PM1, PM._PM1, 2);
    // Add PM2.5
    frame.addSensor(SENSOR_GASES_PRO_PM2_5, PM._PM2_5, 2);
    // Add PM10
    frame.addSensor(SENSOR_GASES_PRO_PM10, PM._PM10, 2);
    //Add BAT level
    frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());
    // Add temperature
    frame.addSensor(SENSOR_GASES_PRO_TC, temperature, 2);
    // Add humidity
    frame.addSensor(SENSOR_GASES_PRO_HUM, humidity, 2);
    // Add pressure value
    frame.addSensor(SENSOR_GASES_PRO_PRES, pressure, 2);
    // Add CO2 value
    frame.addSensor(SENSOR_GASES_PRO_CO2, concCO2, 2);
    // Add NO2 value
    frame.addSensor(SENSOR_GASES_PRO_NO2, concNO2, 2);
    // Add SO2 value
    frame.addSensor(SENSOR_GASES_PRO_SO2, concSO2, 2);
    //Add light
    frame.addSensor(SENSOR_GASES_PRO_LUXES, light, 2);
    // Show the frame
    frame.showFrame();
    

// send XBee packet
  xbee868LP.ON( SOCKET1 );  

  error = xbee868LP.send( RX_ADDRESS, frame.buffer, frame.length );   
  
  if( error == 0 )
  {
    USB.println(F("send ok"));
    
    Utils.blinkGreenLED();
    
  }
  else 
  {
    USB.println(F("send error"));
    
    // blink red LED
    Utils.blinkRedLED();
  }

  delay(5000);
  xbee868LP.OFF();  
}


void setup()
{
  USB.ON();
  //error2 = RTC.setTime("21:11:19:06:18:16:00");
  USB.println(error2);

 
  USB.println(F("-------------------------------"));
  USB.println(F("START SETUP"));
  USB.println(F("-------------------------------"));

  // store Waspmote identifier in EEPROM memory
  frame.setID( node_ID );

  // assigns the SPI
  while ((answer != 0) & (retries < 3))
  {
    retries ++;
    answer = W485.ON();
    delay(1000);
  }
  if ( answer == 0) {
    USB.println(F("RS485 in socket 0"));
  }
  delay(100);
  W485.OFF();

  // Configures the I2C isolator
  pinMode(GP_I2C_MAIN_EN, OUTPUT);
}

void loop()
{
    USB.println(F("-------------------------------"));
    USB.println(F("START LOOP"));
    USB.println(F("-------------------------------"));

    RTC.ON();
    RTC.getTime();

    read_sensors();
    send_frame();

// 5. Sleep for 10 minutes
  USB.println(F("5. Enter deep sleep 12 min..."));
  PWR.deepSleep("00:00:12:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);
  USB.println(F("6. Wake up!!\n\n"));
}
