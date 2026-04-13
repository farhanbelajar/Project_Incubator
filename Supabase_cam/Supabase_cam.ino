#include <WiFi.h>
#include "esp_camera.h"
#include <HTTPClient.h>
#include <WiFiClientSecure.h>
#include "soc/soc.h"
#include "soc/rtc_cntl_reg.h"

// ================= WIFI =================
const char* ssid = "//";
const char* password = "//";

// ================= SUPABASE =================
String supabase_url = "//";
String anon_key = "//";
String bucket = "//";

// ================= CAMERA PIN =================
#define PWDN_GPIO_NUM     32
#define RESET_GPIO_NUM    -1
#define XCLK_GPIO_NUM      0
#define SIOD_GPIO_NUM     26
#define SIOC_GPIO_NUM     27
#define Y9_GPIO_NUM       35
#define Y8_GPIO_NUM       34
#define Y7_GPIO_NUM       39
#define Y6_GPIO_NUM       36
#define Y5_GPIO_NUM       21
#define Y4_GPIO_NUM       19
#define Y3_GPIO_NUM       18
#define Y2_GPIO_NUM        5
#define VSYNC_GPIO_NUM    25
#define HREF_GPIO_NUM     23
#define PCLK_GPIO_NUM     22
#define FLASH_GPIO_NUM     4

// ================= INTERVAL =================
unsigned long lastTime = 0;
const int interval = 10000;

// ================= CAMERA =================
void setupCamera() {
  camera_config_t config;
  config.ledc_channel = LEDC_CHANNEL_0;
  config.ledc_timer = LEDC_TIMER_0;

  config.pin_d0 = Y2_GPIO_NUM;
  config.pin_d1 = Y3_GPIO_NUM;
  config.pin_d2 = Y4_GPIO_NUM;
  config.pin_d3 = Y5_GPIO_NUM;
  config.pin_d4 = Y6_GPIO_NUM;
  config.pin_d5 = Y7_GPIO_NUM;
  config.pin_d6 = Y8_GPIO_NUM;
  config.pin_d7 = Y9_GPIO_NUM;

  config.pin_xclk = XCLK_GPIO_NUM;
  config.pin_pclk = PCLK_GPIO_NUM;
  config.pin_vsync = VSYNC_GPIO_NUM;
  config.pin_href = HREF_GPIO_NUM;

  config.pin_sscb_sda = SIOD_GPIO_NUM;
  config.pin_sscb_scl = SIOC_GPIO_NUM;

  config.pin_pwdn = PWDN_GPIO_NUM;
  config.pin_reset = RESET_GPIO_NUM;

  config.xclk_freq_hz = 20000000;
  config.pixel_format = PIXFORMAT_JPEG;

  // 🔥 OPTIMASI (BIAR GA CEPAT ERROR)
  config.frame_size = FRAMESIZE_QVGA;
  config.jpeg_quality = 15;
  config.fb_count = 1;

  if (esp_camera_init(&config) != ESP_OK) {
    Serial.println("Camera Init Failed!");
    ESP.restart();
  }
}

// ================= UPLOAD =================
bool uploadImage(camera_fb_t *fb) {
  if (!fb) return false;

  WiFiClientSecure client;
  client.setInsecure(); // 🔥 WAJIB untuk HTTPS

  HTTPClient https;

  String fileName = "esp32_" + String(millis()) + ".jpg";
  String url = supabase_url + "/storage/v1/object/" + bucket + "/" + fileName;

  Serial.println("Upload ke:");
  Serial.println(url);

  if (!https.begin(client, url)) {
    Serial.println("HTTPS Begin Failed");
    return false;
  }

  https.addHeader("Content-Type", "image/jpeg");
  https.addHeader("Authorization", "Bearer " + anon_key);
  https.addHeader("apikey", anon_key);

  int httpCode = https.POST(fb->buf, fb->len);

  Serial.print("HTTP Code: ");
  Serial.println(httpCode);

  https.end();

  return (httpCode == 200 || httpCode == 201);
}

// ================= SETUP =================
void setup() {
  WRITE_PERI_REG(RTC_CNTL_BROWN_OUT_REG, 0);

  Serial.begin(115200);

  pinMode(FLASH_GPIO_NUM, OUTPUT);
  digitalWrite(FLASH_GPIO_NUM, LOW);

  WiFi.begin(ssid, password);
  Serial.print("Connecting WiFi");

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("\nWiFi Connected");
  Serial.println(WiFi.localIP());

  setupCamera();
}

// ================= LOOP =================
void loop() {
  if (millis() - lastTime > interval) {
    Serial.println("Capture & Upload");

    // 🔥 Flash ON
    digitalWrite(FLASH_GPIO_NUM, HIGH);
    delay(100);

    // 📸 Capture
    camera_fb_t *fb = esp_camera_fb_get();

    // 🔥 Flash OFF
    digitalWrite(FLASH_GPIO_NUM, LOW);

    if (!fb) {
      Serial.println("Capture Failed");
      return;
    }

    // 🚀 Upload ke Supabase
    if (uploadImage(fb)) {
      Serial.println("UPLOAD SUCCESS (KE SUPABASE)");
    } else {
      Serial.println("UPLOAD FAILED");
    }

    esp_camera_fb_return(fb);
    fb = NULL;

    lastTime = millis();
  }
}