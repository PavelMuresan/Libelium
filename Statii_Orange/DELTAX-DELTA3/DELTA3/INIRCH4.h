#define DEBUG_INIRCH4 2
#define DEBUG_UART 1
#define PRINT_INIRCH4(str)    USB.print(F("[INIRCH4] ")); USB.print(str);
#define PRINTLN_INIRCH4(str)    USB.print(F("[INIRCH4] ")); USB.println(str);

#define ERROR_TIMEOUT 1
#define ERROR_CHECKSUM 2
#define ERROR_FAULTS 3
#define ERROR_UNKNOWN 4
#define ERROR_FORMAT 5

#include <WaspUART.h>
#define NORMAL_MESSAGE_SIZE 70
#define WORD_SIZE 10

struct __attribute__((packed)) inir_frame {
  char start_char[10];
  char conc[10];
  char faults[10];
  char temp[10];
  char crc[10];
  char crc_complement[10];
  char end_char[10];
};

typedef struct CH4Reading {
  bool succes;
  uint8_t error;
  uint32_t conc;
  uint32_t sensor_temp;
  uint32_t faults;
} CH4Reading;

class INIRCH4 {
  public:

    INIRCH4() {
      uart = WaspUART();
    }

    bool ON() {
#if DEBUG_INIRCH4 > 0
      PRINTLN_INIRCH4(F("Starting DUST_SENSOR_POWER"));
#endif
      pinMode(DUST_SENSOR_POWER, OUTPUT);
      digitalWrite(DUST_SENSOR_POWER, HIGH);
#if DEBUG_INIRCH4 > 0
      PRINTLN_INIRCH4(F("Wait 5 secs for power to start"));
#endif
      delay(5000);

      uart.setBaudrate(38400);
      uart._buffer = read_buffer;
      uart._bufferSize = sizeof(read_buffer);

      uart.setTimeout(10);
      return true;
    }

    void wait_to_warm() {
      delay(30 * 1000);
      delay(30 * 1000);
    }

    CH4Reading read_sensor(const uint8_t max_read_tries = 5) {

      serialFlush(SOCKET1);
      uint8_t r;
      for (int i = 0; i < max_read_tries; i++) {
        r = read_frame();
        if (r == 0)
          break;
      }

      CH4Reading result;
      result.error = r;
      result.succes = r == 0;
      result.conc = word_to_dec(frame_buffer.conc);
      result.sensor_temp = word_to_dec(frame_buffer.temp);
      result.faults = word_to_dec(frame_buffer.faults);

      return result;
    }

    /*
       Reads a sensor frame into frame_buffer
       Returns 0 if succeded / error code if error.
    */
    uint8_t read_frame() {
  #if DEBUG_INIRCH4 > 0
      PRINTLN_INIRCH4(F("Waspmote Starting UART..."));
#endif
      uart.setUART(SOCKET1);
      sbi(UCSR1C, USBS1); // two stop bytes


      // Set Aux 2 (1||2)
      Utils.setMuxAux2();

      uart.beginUART();
      delay(500);

      // Asteptam cuvantul (4 bytes in hex) de inceput cadru timp de 5 secunde
      if (uart.waitFor("0000005b", 5000) == 0) {
        // Daca nu apare, eroare (bufferul e suficient - un mesaj intreg)
        return ERROR_TIMEOUT;
      } else {
        // Daca an gasit, copiem in frame
        memcpy(&frame_buffer, "0000005b\r\n", 10);
      }

      // 5 secunde incercam sa citim restul din cadru (6 * 8 = 48 de octeti)
      uint8_t bytes_remaining = NORMAL_MESSAGE_SIZE - WORD_SIZE;
      bool first_read = true;
      // Pentru simplitate, doar prima data golim bufferul, pentru ca la final (hopefully), sa avem 24 de octeti
      unsigned long previous = millis();
      while (((millis() - previous) < 5000) && bytes_remaining > 0) {
        uint16_t nbytes = uart.readBuffer(bytes_remaining, first_read);
        first_read = false;
        bytes_remaining -= nbytes;
      }

      // If failed to read in 5 sec, return ERROR_TIMEOUT
      if (bytes_remaining) {
        return ERROR_TIMEOUT;
      }

      if (uart._length != (NORMAL_MESSAGE_SIZE - WORD_SIZE)) {
        // Should not happen
        return ERROR_UNKNOWN;
      }

      // Copy bytes into frame
      memcpy((char *)&frame_buffer + 8, uart._buffer, sizeof(frame_buffer) - WORD_SIZE);

#if DEBUG_INIRCH4 > 0
      PRINTLN_INIRCH4(F("INIRCH4 FRAME..."));
      print_buf((char *)&frame_buffer, sizeof(frame_buffer));
#endif
      // The frame should end with 0000005d
      if (strncmp(frame_buffer.end_char, "0000005d", 8)) {
        return ERROR_FORMAT;
      }

      // Return success
      return 0;
    }

    bool OFF() {
      closeSerial(1);

#if DEBUG_INIRCH4 > 0
      PRINTLN_INIRCH4(F("Close UART."));
      PRINTLN_INIRCH4(F("Wait 5 sec for power to go down."));
#endif

      digitalWrite(DUST_SENSOR_POWER, LOW);

      delay(5000);
      return true;
    }
  private:
    uint32_t word_to_dec(char *s) {
      // TODO: prevent error on wrongly formated strings
      char buf[9];
      memcpy(buf, s, 8);
      buf[8] = '\0';
      return strtoul(buf, NULL, 16);
    }

    void print_buf(char *p, size_t len) {
      PRINTLN_INIRCH4(F("------------------------"));
      PRINTLN_INIRCH4(len);
      for (size_t i = 0; i < len; i++) {
        //USB.printf("%d p[%d] == %2hhx\n", i / 10, i % 10, p[i]);
        USB.print(p[i]);
      }
      USB.println(F(""));
      PRINTLN_INIRCH4(F("\n------------------------"));
    }

  protected:
    WaspUART uart;
    uint8_t read_buffer[NORMAL_MESSAGE_SIZE];

    struct inir_frame frame_buffer;

};
