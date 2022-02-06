/*  
 *  ------ [RTC_1] Setting and reading time example -------- 
 *  
 *  Explanation: This example shows how to set and read the Time using
 *  the Waspmote RTC
 *  
 *  Copyright (C) 2016 Libelium Comunicaciones Distribuidas S.L. 
 *  http://www.libelium.com 
 *  
 *  This program is free software: you can redistribute it and/or modify 
 *  it under the terms of the GNU General Public License as published by 
 *  the Free Software Foundation, either version 3 of the License, or 
 *  (at your option) any later version. 
 *  
 *  This program is distributed in the hope that it will be useful, 
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of 
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
 *  GNU General Public License for more details. 
 *  
 *  You should have received a copy of the GNU General Public License 
 *  along with this program.  If not, see . 
 *  
 *  Version:           3.0
 *  Design:            David Gascón 
 *  Implementation:    Marcos Yarza
 */

void setup()
{
  // Open the USB connection
  USB.ON();
  USB.println(F("RTC_1 example"));

  // Powers RTC up, init I2C bus and read initial values
  USB.println(F("Init RTC"));
  RTC.ON();
  
  // Setting time [yy:mm:dd:dow:hh:mm:ss]
  RTC.setTime("22:01:25:03:09:37:00");
  USB.print(F("Setting time: "));
  //USB.println(F("21:12:17:06:13:13:00"));
}

void loop()
{
  // Reading time
  USB.print(F("Time [Day of week, YY/MM/DD, hh:mm:ss]: "));
  USB.println(RTC.getTime());
  
  delay(1000); 
}
