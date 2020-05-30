#include <ArduinoBLE.h>
#include <Servo.h>
#include <Adafruit_Sensor.h>
#include <DHT.h>
#include <DHT_U.h>

#define DHTPIN    5     
#define DHTTYPE   DHT11     
#define RED       9
#define GREEN     10
#define BLUE      11

Servo srv;
long delayMS;

BLEService BService("DB69FECC-945E-4269-800C-AAB2A8BD356B"); // BLE LED Service
BLECharacteristic  writeChars("3B0B89F6-8329-4DD1-86C4-43E9499D0595", BLEWrite | BLERead | BLENotify, 64);
BLECharacteristic readChars("0FF80DFD-8536-4E36-B3C8-D88466E184E0", BLERead | BLENotify, 64);


DHT_Unified dht(DHTPIN, DHTTYPE);

long timed = millis();
int p[11];
int srvPos = 10;
int sign = 1;
float temperature = 0, humidity = 0;
char charVal[64];

void setup() {
  pinMode(RED, OUTPUT);
  pinMode(GREEN, OUTPUT);
  pinMode(BLUE, OUTPUT);
  Serial.begin(9600);
  srv.attach(3);
  dht.begin();
  sensor_t sensor;
  dht.temperature().getSensor(&sensor);
  dht.humidity().getSensor(&sensor);
  delayMS = sensor.min_delay / 1000;
  
  if (!BLE.begin()) {
    Serial.println("starting BLE failed!");
    while (1);
  }

  // set advertised local name and service UUID:
  BLE.setLocalName("Bluetooth Shit");
  BLE.setAdvertisedService(BService);

  BService.addCharacteristic(writeChars);
  BService.addCharacteristic(readChars);

  BLE.addService(BService);
  readChars.setValue(0);
  writeChars.setValue(0);
  BLE.advertise();

  Serial.println("BLE Shit Peripheral");
}

void loop() {
  BLEDevice central = BLE.central();
  int l = 0;
  int k = 100;
  if (central) {
    Serial.print("Connected to central: ");
    Serial.println(central.address());
    while (central.connected()) {
      sensors_event_t event;
      srv.write(srvPos);
      if (millis() - timed >= delayMS) {
        dht.temperature().getEvent(&event);
        temperature = event.temperature;
        dht.humidity().getEvent(&event);
        humidity = event.relative_humidity;
        timed = millis();
      }
      String temp = String(temperature) + " °C," + String(humidity) + "%";
      readChars.writeValue(temp.c_str(), temp.length());

      if (writeChars.written()) {
        sprintf(charVal, "%64c", NULL);
        strncpy(charVal, (char*)writeChars.value(), writeChars.valueLength());
        String received(charVal);
        received.trim();
        Serial.println(received);
        p[0] = 0;
        for (int i = 1; i < 11; i++){
          p[i] = received.indexOf(',', p[i-1]+1);
        }
        float ax = received.substring(p[0],p[1]).toFloat();
        float ay = received.substring(p[1]+1,p[2]).toFloat();
        float az = received.substring(p[2]+1,p[3]).toFloat();
        float gx = received.substring(p[3]+1,p[4]).toFloat();
        float gy = received.substring(p[4]+1,p[5]).toFloat();
        float gz = received.substring(p[5]+1,p[6]).toFloat();
        float red = received.substring(p[6]+1,p[7]).toFloat();
        float green = received.substring(p[7]+1,p[8]).toFloat();
        float blue = received.substring(p[8]+1,p[9]).toFloat();
        float alpha = received.substring(p[9]+1,p[10]).toFloat();
        float tempsrv = received.substring(p[10]+1).toFloat();
        srvPos = int(tempsrv);
        analogWrite(9, int(red*alpha/255));
        analogWrite(10, int(blue*alpha/255));
        analogWrite(11, int(green*alpha/255));
        /*
        Serial.print("Accel: ");
        Serial.print(ax);
        Serial.print(", ");
        Serial.print(ay);
        Serial.print(", ");
        Serial.print(az);
        Serial.println();
        Serial.print("Gyro: ");
        Serial.print(gx);
        Serial.print(", ");
        Serial.print(gy);
        Serial.print(", ");
        Serial.print(gz);
        Serial.println();
        Serial.print("Colors: ");
        Serial.print(red);
        Serial.print(", ");
        Serial.print(green);
        Serial.print(", ");
        Serial.print(blue);
        Serial.print(", ");
        Serial.print(alpha);
        Serial.println();
        Serial.print("Servo: ");
        Serial.print(srvPos);
        Serial.println();
        */
      }
    }
    Serial.print(F("Disconnected from central: "));
    Serial.println(central.address());
  }
}
