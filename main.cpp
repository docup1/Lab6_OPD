#include <Arduino.h>

bool flag = false;
uint32_t btnTimer = 0;
int iterator = 0;
bool reles[4] = {0, 0, 0, 0};
bool btnState;

void setup() {
  // put your setup code here, to run once:
  pinMode(12, OUTPUT);
  pinMode(11, OUTPUT);
  pinMode(10, OUTPUT);
  pinMode(9, OUTPUT);
  pinMode(3, INPUT_PULLUP);
}

void loop() {
  btnState = !digitalRead(3);
  if (btnState && millis() - btnTimer > 500) {
    reles[iterator] = !reles[iterator];
    iterator++;
    if(iterator >= 5) {
      iterator = 0;
      reles[0] = 0;
      reles[1] = 0;
      reles[2] = 0;
      reles[3] = 0;
    }
    btnTimer = millis();
  }
  digitalWrite(12, !reles[3]);
  digitalWrite(11, !reles[2]);
  digitalWrite(10, !reles[1]);
  digitalWrite(9, !reles[0]);
}
