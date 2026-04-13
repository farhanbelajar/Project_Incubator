#include <Wire.h>
#include <WiFi.h>
#include "DHT.h"
#include <LiquidCrystal_I2C.h>
#include <Firebase_ESP_Client.h>

#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

// =====================================================
// WIFI CONFIG
// =====================================================

#define WIFI_SSID "LYMBADS"
#define WIFI_PASSWORD "123456789"

// =====================================================
// FIREBASE CONFIG
// =====================================================

#define API_KEY "-"
#define DATABASE_URL "-"
#define USER_EMAIL "farhan1@gmail.com"
#define USER_PASSWORD "123456"

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;


// =====================================================
// SENSOR CONFIG
// =====================================================

// DHT11
#define DHT_PIN 2
#define DHT_TYPE DHT11
DHT dht(DHT_PIN, DHT_TYPE);

// PIR Motion
#define PIR_PIN 14

// Sound Sensor
#define SOUND_PIN 34
int soundValue = 0;
int soundThreshold = 100;

// Buzzer
#define BUZZER_PIN 12

// =====================================================
// RELAY CONFIG
// =====================================================

#define RELAY1_PIN 5   // IN1 = KIPAS
#define RELAY2_PIN 4   // IN2 = LAMPU

int relay1State = 0;
int relay2State = 0;

String modeControl = "auto";


// =====================================================
// LCD CONFIG
// =====================================================

LiquidCrystal_I2C lcd(0x27, 20, 4);

// =====================================================
// GLOBAL VARIABLES
// =====================================================

float temperature = 0;
float humidity = 0;
int motionStatus = 0;

unsigned long lastDHTRead = 0;
const int DHT_INTERVAL = 2000;


// =====================================================
// TIMER SYSTEM (NON BLOCKING)
// =====================================================

unsigned long lastSensorRead = 0;
unsigned long lastFirebaseSend = 0;
unsigned long lastLCDUpdate = 0;
unsigned long lastControlRead = 0;

const int SENSOR_INTERVAL = 1000;
const int FIREBASE_INTERVAL = 3000;
const int LCD_INTERVAL = 1000;
const int CONTROL_INTERVAL = 1500;


// =====================================================
// SETUP
// =====================================================

void setup()
{
  Serial.begin(115200);

  pinMode(PIR_PIN, INPUT);
  pinMode(BUZZER_PIN, OUTPUT);

  pinMode(RELAY1_PIN, OUTPUT);
  pinMode(RELAY2_PIN, OUTPUT);

  digitalWrite(RELAY1_PIN, LOW);
  digitalWrite(RELAY2_PIN, LOW);

  dht.begin();

  setupLCD();
  connectWiFi();
  connectFirebase();

  Serial.println("System Ready");
}


// =====================================================
// LOOP RESPONSIVE
// =====================================================

void loop()
{
  unsigned long now = millis();

  if (now - lastSensorRead > SENSOR_INTERVAL)
  {
    lastSensorRead = now;
    readSensors();
    controlBuzzer();
  }

  if (now - lastControlRead > CONTROL_INTERVAL)
  {
    lastControlRead = now;
    readControlFirebase();
    controlRelay();
  }

  if (now - lastLCDUpdate > LCD_INTERVAL)
  {
    lastLCDUpdate = now;
    updateLCD();
  }

  if (now - lastFirebaseSend > FIREBASE_INTERVAL)
  {
    lastFirebaseSend = now;
    sendToFirebase();
    printSerial();
  }
}


// =====================================================
// LCD SETUP
// =====================================================

void setupLCD()
{
  Wire.begin(21, 22);

  lcd.begin(20, 4);
  lcd.backlight();

  lcd.setCursor(0, 0);
  lcd.print("IoT Monitoring");

  lcd.setCursor(0, 1);
  lcd.print("Starting...");
}


// =====================================================
// WIFI CONNECT
// =====================================================

void connectWiFi()
{
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  Serial.print("Connecting WiFi");

  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print(".");
    delay(500);
  }

  Serial.println();
  Serial.println("WiFi Connected");
  Serial.println(WiFi.localIP());
}


// =====================================================
// FIREBASE CONNECT
// =====================================================

void connectFirebase()
{
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;

  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  Serial.println("Firebase Ready");
}


// =====================================================
// READ ALL SENSORS
// =====================================================

void readSensors()
{
  readPIR();
  readSound();
  readDHT();
}


// =====================================================
// PIR SENSOR
// =====================================================

void readPIR()
{
  motionStatus = digitalRead(PIR_PIN);
}


// =====================================================
// SOUND SENSOR
// =====================================================

void readSound()
{
  soundValue = analogRead(SOUND_PIN);
}


// =====================================================
// DHT SENSOR
// =====================================================

void readDHT()
{
  if (millis() - lastDHTRead > DHT_INTERVAL)
  {
    float h = dht.readHumidity();
    float t = dht.readTemperature();

    if (isnan(h) || isnan(t))
    {
      Serial.println("DHT11 ERROR");
      return;
    }

    humidity = h;
    temperature = t;

    lastDHTRead = millis();
  }
}


// =====================================================
// FIREBASE CONTROL READ
// =====================================================

void readControlFirebase()
{
  if (!Firebase.ready()) return;

  if (Firebase.RTDB.getString(&fbdo, "/control/mode"))
  {
    modeControl = fbdo.stringData();
  }

  if (modeControl == "manual")
  {
    if (Firebase.RTDB.getInt(&fbdo, "/control/relay1"))
      relay1State = fbdo.intData();

    if (Firebase.RTDB.getInt(&fbdo, "/control/relay2"))
      relay2State = fbdo.intData();
  }
}


// =====================================================
// RELAY CONTROL (AUTO BERDASARKAN SUHU)
// =====================================================

void controlRelay()
{

  if (modeControl == "auto")
  {

    if (temperature < 27)
    {
      relay2State = 1; // Lampu ON
      relay1State = 0; // Kipas OFF
    }

    else if (temperature >= 27 && temperature <= 30)
    {
      relay2State = 0; // Lampu OFF
      relay1State = 0; // Kipas OFF
    }

    else if (temperature > 30)
    {
      relay2State = 0; // Lampu OFF
      relay1State = 1; // Kipas ON
    }
  }

  digitalWrite(RELAY1_PIN, relay1State);
  digitalWrite(RELAY2_PIN, relay2State);
}


// =====================================================
// LCD UPDATE
// =====================================================

void updateLCD()
{
  lcd.setCursor(0, 0);
  lcd.print("Temp:");
  lcd.print(temperature);
  lcd.print("C ");

  lcd.setCursor(10, 0);
  lcd.print("Hum:");
  lcd.print(humidity);
  lcd.print(" ");

  lcd.setCursor(0, 1);
  lcd.print("Motion:");
  lcd.print(motionStatus ? "YES" : "NO ");

  lcd.setCursor(0, 2);
  lcd.print("Fan:");
  lcd.print(relay1State);

  lcd.setCursor(10, 2);
  lcd.print("Lamp:");
  lcd.print(relay2State);

  lcd.setCursor(0, 3);
  lcd.print("Mode:");
  lcd.print(modeControl);
}


// =====================================================
// SEND DATA TO FIREBASE
// =====================================================

void sendToFirebase()
{
  if (!Firebase.ready()) return;

  Firebase.RTDB.setFloat(&fbdo, "/sensor/temperature", temperature);
  Firebase.RTDB.setFloat(&fbdo, "/sensor/humidity", humidity);
  Firebase.RTDB.setInt(&fbdo, "/sensor/motion", motionStatus);
  Firebase.RTDB.setInt(&fbdo, "/sensor/sound", soundValue);

  Firebase.RTDB.setInt(&fbdo, "/sensor/relay1", relay1State);
  Firebase.RTDB.setInt(&fbdo, "/sensor/relay2", relay2State);
  Firebase.RTDB.setString(&fbdo, "/sensor/mode", modeControl);
}


// =====================================================
// BUZZER CONTROL
// =====================================================

void controlBuzzer()
{
  if (soundValue > soundThreshold)
    digitalWrite(BUZZER_PIN, HIGH);
  else
    digitalWrite(BUZZER_PIN, LOW);
}


// =====================================================
// SERIAL MONITOR
// =====================================================

void printSerial()
{
  Serial.println("===== SENSOR DATA =====");

  Serial.print("Temperature : ");
  Serial.println(temperature);

  Serial.print("Humidity    : ");
  Serial.println(humidity);

  Serial.print("Motion      : ");
  Serial.println(motionStatus);

  Serial.print("Sound       : ");
  Serial.println(soundValue);

  Serial.print("Fan         : ");
  Serial.println(relay1State);

  Serial.print("Lamp        : ");
  Serial.println(relay2State);

  Serial.print("Mode        : ");
  Serial.println(modeControl);

  Serial.println("=======================");
}