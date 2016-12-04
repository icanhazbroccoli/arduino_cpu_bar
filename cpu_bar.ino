int pins[17]= {-1, 5, 4, 3, 2, 14, 15, 16, 17, 13, 12, 11, 10, 9, 8, 7, 6};
int cols[8] = {pins[13], pins[3], pins[4], pins[10], pins[06], pins[11], pins[15], pins[16]};
int rows[8] = {pins[9], pins[14], pins[8], pins[12], pins[1], pins[7], pins[2], pins[5]};

void setup() {
  for (int i= 1; i <= 16; i++) {
    pinMode(pins[i], OUTPUT);
  }
  clearScr();
  Serial.begin(9600);
}

void clearScr() {
  for (int i= 1; i <= 8; i++) {
    digitalWrite(cols[i - 1], LOW);
  }
  for (int i= 1; i <= 8; i++) {
    digitalWrite(rows[i - 1], LOW);
  }
}

void drawBar(int val) { // 0..100
  int percent= 8 * val / 100;
  for (int i = 0; i < 8; i++) {
    digitalWrite(rows[7 - i], (i+1 <= percent) ? HIGH : LOW);
  }
}

int inputVal= 0;
void loop() {
  if (Serial.available() > 0) {
    inputVal= Serial.parseInt();
    if (inputVal < 0) inputVal = 0;
    if (inputVal > 100) inputVal = 100;
    Serial.print(inputVal);
    Serial.print('\n');
    clearScr();
    drawBar(inputVal);
  }
}
