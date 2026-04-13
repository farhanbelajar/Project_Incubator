import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_database/firebase_database.dart';

class DataSensor extends StatefulWidget {
  const DataSensor({super.key});

  @override
  State<DataSensor> createState() => _DataSensorState();
}

class _DataSensorState extends State<DataSensor> {

  double ecg = 0, raw = 0, bpm = 0;
  double tempDht = 0, humidity = 0, tempDs = 0;
  double lat = 0, lng = 0;

  List<FlSpot> ecgData = [];
  double time = 0;

  final ref = FirebaseDatabase.instance.ref("monitoring");
  final controlRef = FirebaseDatabase.instance.ref("control");

  bool modeManual = false;
  bool kipas1 = false;
  bool lampu1 = false;

  @override
  void initState() {
    super.initState();

    ref.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {

          ecg = (data["ecg"] ?? 0).toDouble();
          raw = (data["raw"] ?? 0).toDouble();
          bpm = (data["bpm"] ?? 0).toDouble();

          tempDht = (data["temp_dht"] ?? 0).toDouble();
          humidity = (data["humidity"] ?? 0).toDouble();
          tempDs = (data["temp_ds"] ?? 0).toDouble();

          lat = (data["lat"] ?? 0).toDouble();
          lng = (data["lng"] ?? 0).toDouble();

          time += 1;
          ecgData.add(FlSpot(time, ecg));
          if (ecgData.length > 50) ecgData.removeAt(0);
        });
      }
    });

    controlRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          modeManual = data["mode"] ?? false;
          kipas1 = data["kipas1"] == 1;
          lampu1 = data["lampu1"] == 1;
        });
      }
    });
  }

  void sendControl() {
    controlRef.set({
      "mode": modeManual,
      "kipas1": kipas1 ? 1 : 0,
      "lampu1": lampu1 ? 1 : 0,
    });
  }

  // ================= STATUS LOGIC =================
  Map<String, String> getStatus(String type, double value) {

    switch (type) {

      case "BPM":
        if (value < 60) return {"status": "Rendah", "desc": "Detak jantung lambat"};
        if (value <= 100) return {"status": "Normal", "desc": "Detak normal"};
        return {"status": "Tinggi", "desc": "Detak cepat"};

      case "ECG":
        if (value < 1000) return {"status": "Lemah", "desc": "Sinyal lemah"};
        if (value < 3000) return {"status": "Normal", "desc": "Sinyal stabil"};
        return {"status": "Noise", "desc": "Gangguan tinggi"};

      case "Temp":
        if (value < 20) return {"status": "Dingin", "desc": "Suhu rendah"};
        if (value <= 30) return {"status": "Normal", "desc": "Suhu normal"};
        return {"status": "Panas", "desc": "Suhu tinggi"};

      case "Humidity":
        if (value < 30) return {"status": "Kering", "desc": "Udara kering"};
        if (value <= 70) return {"status": "Normal", "desc": "Kelembaban normal"};
        return {"status": "Lembab", "desc": "Kelembaban tinggi"};

      default:
        return {"status": "-", "desc": ""};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0B1E3A),
      appBar: AppBar(
        title: const Text("Smart Monitoring",
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff0B1E3A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            _card("ECG", ecg, Icons.monitor_heart, "ECG"),
            _card("BPM", bpm, Icons.favorite, "BPM"),
            _card("Temp DHT", tempDht, Icons.thermostat, "Temp"),
            _card("Humidity", humidity, Icons.water_drop, "Humidity"),
            _card("Temp DS", tempDs, Icons.device_thermostat, "Temp"),

            _card("Latitude", lat, Icons.location_on, ""),
            _card("Longitude", lng, Icons.map, ""),

            const SizedBox(height: 20),

            _chart(),

            const SizedBox(height: 20),

            _controlPanel(),
          ],
        ),
      ),
    );
  }

  // ================= CARD =================
  Widget _card(String title, double value, IconData icon, String type) {

    final statusData = getStatus(type, value);

    return GestureDetector(
      onTap: () => _showDetail(title, value, statusData),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff1E3C72), Color(0xff2A5298)],
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(color: Colors.white70)),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value.toStringAsFixed(1),
                    style: const TextStyle(color: Colors.white, fontSize: 18)),
                Text(statusData["status"]!,
                    style: const TextStyle(color: Colors.orange, fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }

  // ================= POPUP =================
  void _showDetail(String title, double value, Map statusData) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xff132A4A),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Nilai: ${value.toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 10),
            Text(statusData["status"],
                style: const TextStyle(color: Colors.orange)),
            Text(statusData["desc"],
                style: const TextStyle(color: Colors.white70)),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  // ================= CONTROL =================
  Widget _controlPanel() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xff132A4A),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [

          const Text("CONTROL", style: TextStyle(color: Colors.white)),

          SwitchListTile(
            title: const Text("Manual Mode",
                style: TextStyle(color: Colors.white)),
            value: modeManual,
            onChanged: (v) {
              setState(() => modeManual = v);
              sendControl();
            },
          ),

          if (modeManual) ...[
            SwitchListTile(
              title: const Text("Kipas 1",
                  style: TextStyle(color: Colors.white)),
              value: kipas1,
              onChanged: (v) {
                setState(() => kipas1 = v);
                sendControl();
              },
            ),
            SwitchListTile(
              title: const Text("Lampu 1",
                  style: TextStyle(color: Colors.white)),
              value: lampu1,
              onChanged: (v) {
                setState(() => lampu1 = v);
                sendControl();
              },
            ),
          ]
        ],
      ),
    );
  }

  // ================= CHART =================
  Widget _chart() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xff132A4A),
        borderRadius: BorderRadius.circular(15),
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 4095,
          titlesData: FlTitlesData(show: false),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: ecgData,
              isCurved: true,
              color: Colors.green,
              barWidth: 2,
              dotData: FlDotData(show: false),
            )
          ],
        ),
      ),
    );
  }
}