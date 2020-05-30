
#include <SPI.h>
#include <WiFiNINA.h>
#include <Arduino_LSM6DS3.h>
#include <WiFiUdp.h>
#include <OSCMessage.h>

IPAddress ip(192, 168, 0, 3);
IPAddress subnet(255, 255, 255, 0);
IPAddress dns(8, 8, 8, 8);
IPAddress gateway(192, 168, 0, 1);

#include "arduino_secrets.h"
WiFiUDP UDP;

const IPAddress outIP (192, 168, 0, 255);
const unsigned int outPort = 10000;
const unsigned int localPort = 9999;

char ssid[] = SECRET_SSID;
char pass[] = SECRET_PASS;
int status = WL_IDLE_STATUS;

void setup() {
  Serial.begin(9600);
  if (!IMU.begin()) {
    Serial.println("Failed to initialize IMU!");
    while (1);
  }
  Serial.print("Accelerometer sample rate = ");
  Serial.print(IMU.accelerationSampleRate());
  Serial.println(" Hz");
  Serial.println();
  Serial.println("Acceleration in G's");
  Serial.println("X\tY\tZ");
  if (WiFi.status() == WL_NO_MODULE) {
    Serial.println("Communication with WiFi module failed!");
    while (true);
  }
  String fv = WiFi.firmwareVersion();
  if (fv < "1.0.0") {
    Serial.println("Please upgrade the firmware");
  }
  while (status != WL_CONNECTED) {
    Serial.print("Attempting to connect to WPA SSID: ");
    Serial.println(ssid);
    WiFi.config(ip, dns, gateway, subnet);
    status = WiFi.begin(ssid, pass);
    delay(10000);
  }
  Serial.print("You're connected to the network");
  printCurrentNet();
  printWifiData();
  UDP.begin(localPort);
}

void loop() {
  float x, y, z;
  if (IMU.accelerationAvailable()) {
    IMU.readAcceleration(x, y, z);
    OSCMessage msgx("/nano/x");
    msgx.add(x);
    Serial.print(x);
    Serial.print('\t');
    OSCMessage msgy("/nano/y");
    msgy.add(y);
    Serial.print(y);
    Serial.print('\t');
    OSCMessage msgz("/nano/z");
    msgz.add(z);
    Serial.println(z);
    UDP.beginPacket(outIP, outPort);
    msgx.send(UDP);
    UDP.endPacket();
    UDP.beginPacket(outIP, outPort);
    msgy.send(UDP);
    UDP.endPacket();
    UDP.beginPacket(outIP, outPort);
    msgz.send(UDP);
    UDP.endPacket();
    msgx.empty();
    msgy.empty();
    msgz.empty();
  }
  delay(50);
}

void printWifiData() {
  IPAddress ip = WiFi.localIP();
  Serial.print("IP Address: ");
  Serial.println(ip);
  Serial.println(ip);

  byte mac[6];
  WiFi.macAddress(mac);
  Serial.print("MAC address: ");
  printMacAddress(mac);
}

void printCurrentNet() {
  Serial.print("SSID: ");
  Serial.println(WiFi.SSID());

  byte bssid[6];
  WiFi.BSSID(bssid);
  Serial.print("BSSID: ");
  printMacAddress(bssid);

  long rssi = WiFi.RSSI();
  Serial.print("signal strength (RSSI):");
  Serial.println(rssi);

  byte encryption = WiFi.encryptionType();
  Serial.print("Encryption Type:");
  Serial.println(encryption, HEX);
  Serial.println();
}

void printMacAddress(byte mac[]) {
  for (int i = 5; i >= 0; i--) {
    if (mac[i] < 16) {
      Serial.print("0");
    }
    Serial.print(mac[i], HEX);
    if (i > 0) {
      Serial.print(":");
    }
  }
  Serial.println();
}
