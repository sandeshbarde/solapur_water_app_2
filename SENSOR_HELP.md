# 🚀 ZERO-CONFIG Sensor Integration (Skip IP Process)

To connect Wokwi to your App without worrying about IP addresses or Tunnels, we are now using **dweet.io** (a free public IoT bridge).

## 1. No Tunnel Needed
You do NOT need to run `ssh` or `localtunnel` anymore. Your PC doesn't even need to be on for Wokwi to talk to the App!

## 2. Update Wokwi
Copy and paste this code into your Wokwi **sketch.ino**. It sends data to the "solapur-water-app-ai-demo" cloud channel.

```cpp
#include <WiFi.h>
#include <HTTPClient.h>

const char* ssid = "Wokwi-GUEST";
const char* password = "";

// STABLE Cloud URL (http is more stable in Wokwi simulator)
const char* dweetUrl = "http://dweet.io/dweet/for/solapur-water-ai-v2-stable";

const int POT_PIN = 34;
const int TRIG_PIN = 5;
const int ECHO_PIN = 18;

void setup() {
  Serial.begin(115200);
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) { delay(500); Serial.print("."); }
  Serial.println(" Connected to Cloud!");
}

float getDistance() {
  digitalWrite(TRIG_PIN, LOW); delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH); delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
  long duration = pulseIn(ECHO_PIN, HIGH);
  float level = map(constrain(duration * 0.034 / 2, 2, 400), 400, 2, 0, 100);
  return level;
}

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    float pressure = (analogRead(POT_PIN) / 4095.0) * 100.0;
    float tank = getDistance();
    
    // Build Cloud Payload (Short keys to save memory: p=pressure, t=tank, f=flow)
    String query = "?p=" + String(pressure) + "&t=" + String(tank) + "&f=15.5";
    
    HTTPClient http;
    http.begin(String(dweetUrl) + query);
    int code = http.GET(); // Simple GET request
    if (code > 0) Serial.println("Cloud Updated: " + query);
    http.end();
  }
  delay(5000);
}
```

## 3. Verify in App
Just run your app: `flutter run -d MRO7GMEY4DX8YHNJ`
It will automatically connect to `dweet.io` and fetch the data. No settings required!
