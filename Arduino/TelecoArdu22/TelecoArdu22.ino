#include <WiFiNINA.h>
#include <WiFiUdp.h>
#include <OSCMessage.h>
#include <OSCBundle.h>
#include <OSCData.h>
#include "arduino_secrets.h"

WiFiUDP UDP;
const unsigned int localPort = 10000;
char ssid[] = SECRET_SSID;
char pass[] = SECRET_PASS;
int status = WL_IDLE_STATUS;
OSCErrorCode error;
float red,green,blue;
void setup() {
  pinMode(9, OUTPUT);
  pinMode(10, OUTPUT);
  pinMode(11, OUTPUT);
  Serial.begin(115200);

  Serial.println();
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.begin(ssid, pass);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
  Serial.println("Starting UDP");
  UDP.begin(localPort);
}


void ledr(OSCMessage &msg) {
  red = msg.getFloat(0);
}

void ledg(OSCMessage &msg) {
  green = msg.getFloat(0);
}

void ledb(OSCMessage &msg) {
  blue = msg.getFloat(0);
}

void loop() {
  analogWrite(9, abs(red)*255);
  analogWrite(10, abs(green)*255);
  analogWrite(11, abs(blue)*255);
  OSCMessage msg;
  int size = UDP.parsePacket();
  if (size > 0) {
    while (size--) {
      msg.fill(UDP.read());
    }
    if (!msg.hasError()) {
      msg.dispatch("/nano/x", ledr);
      msg.dispatch("/nano/y", ledg);
      msg.dispatch("/nano/z", ledb);
    } else {
      error = msg.getError();
      Serial.print("error: ");
      Serial.println(error);
    }
  }
}
