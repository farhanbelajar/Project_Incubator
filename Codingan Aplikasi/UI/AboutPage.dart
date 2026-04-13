import 'package:flutter/material.dart';

class Aboutpage extends StatefulWidget {
  const Aboutpage({super.key});

  @override
  State<Aboutpage> createState() => _AboutpageState();
}

class _AboutpageState extends State<Aboutpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0B1E3A),

      appBar: AppBar(
        title: const Text(
          "About Application",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff0B1E3A),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ===== TITLE =====
            const Text(
              "IoT Monitoring Incubator System",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Aplikasi ini digunakan untuk memonitor 3 sistem incubator dalam satu platform berbasis Internet of Things (IoT). Sistem ini mampu menampilkan data sensor secara real-time seperti suhu, kelembaban, detak jantung (ECG), dan lokasi GPS.",
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 25),

            // ===== INCUBATOR =====
            _sectionTitle("🔬 Sistem Incubator"),

            _card("Incubator 1",
                "Monitoring suhu, kelembaban, dan kondisi lingkungan secara real-time."),
            _card("Incubator 2",
                "Dilengkapi dengan sensor tambahan untuk monitoring lebih detail."),
            _card("Incubator 3",
                "Integrasi ECG (detak jantung) dan GPS untuk monitoring lanjutan."),

            const SizedBox(height: 25),

            // ===== SENSOR =====
            _sectionTitle("📡 Sensor yang Digunakan"),

            _card("DHT Sensor",
                "Digunakan untuk mengukur suhu dan kelembaban udara."),
            _card("DS18B20",
                "Sensor suhu dengan akurasi tinggi, cocok untuk monitoring objek."),
            _card("ECG Sensor",
                "Digunakan untuk membaca sinyal jantung dan menghitung BPM."),
            _card("GPS Module",
                "Digunakan untuk mendapatkan lokasi (latitude & longitude)."),

            const SizedBox(height: 25),

            // ===== MICROCONTROLLER =====
            _sectionTitle("🧠 Mikrokontroler"),

            _card("ESP32",
                "Digunakan sebagai pengirim data utama ke Firebase melalui WiFi."),
            _card("Arduino Mega",
                "Digunakan untuk membaca beberapa sensor dan mengirim data ke ESP32."),
            _card("ESP32 (38 Pin)",
                "Digunakan untuk menangani sensor tambahan seperti ECG dan komunikasi data."),

            const SizedBox(height: 25),

            // ===== SYSTEM =====
            _sectionTitle("🌐 Sistem IoT"),

            _card("Firebase Realtime Database",
                "Digunakan sebagai server untuk menyimpan dan sinkronisasi data secara real-time."),
            _card("Flutter Application",
                "Digunakan sebagai interface monitoring yang menampilkan data secara visual dan interaktif."),

            const SizedBox(height: 30),

            // ===== FOOTER =====
            const Center(
              child: Text(
                "© 2026 IoT Monitoring System",
                style: TextStyle(color: Colors.white54),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ===== SECTION TITLE =====
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.orange,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ===== CARD =====
  Widget _card(String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xff132A4A),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            desc,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}