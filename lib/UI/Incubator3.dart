import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class Incubator3 extends StatefulWidget {
  const Incubator3({super.key});

  @override
  State<Incubator3> createState() => _Incubator3State();
}

class _Incubator3State extends State<Incubator3> {

  final DatabaseReference sensorRef =
  FirebaseDatabase.instance.ref("sensor");

  final DatabaseReference controlRef =
  FirebaseDatabase.instance.ref("control");

  double temperature = 0;
  double humidity = 0;
  int motion = 0;
  int sound = 0;

  bool fan1 = false;
  bool fan2 = false;

  String mode = "auto";

  @override
  void initState() {
    super.initState();
    readSensor();
    readControl();
  }

  // ================= READ SENSOR =================
  void readSensor() {
    sensorRef.onValue.listen((event) {
      final data = event.snapshot.value;

      if (data != null) {
        Map map = data as Map;

        setState(() {
          temperature = double.tryParse(map["temperature"].toString()) ?? 0;
          humidity = double.tryParse(map["humidity"].toString()) ?? 0;
          motion = int.tryParse(map["motion"].toString()) ?? 0;
          sound = int.tryParse(map["sound"].toString()) ?? 0;
        });
      }
    });
  }

  // ================= READ CONTROL =================
  void readControl(){
    controlRef.onValue.listen((event){
      final data = event.snapshot.value;

      if(data != null){
        Map map = data as Map;

        setState(() {
          // 🔥 FIX: relay aktif LOW (0 = ON)
          fan1 = (map["relay1"] ?? 1) == 0;
          fan2 = (map["relay2"] ?? 1) == 0;
          mode = map["mode"].toString();
        });
      }
    });
  }

  // ================= CONTROL =================
  void setMode(String newMode){
    controlRef.child("mode").set(newMode);
  }

  // 🔥 FIX: dibalik
  void setFan1(bool value){
    controlRef.child("relay1").set(value ? 0 : 1);
  }

  void setFan2(bool value){
    controlRef.child("relay2").set(value ? 0 : 1);
  }

  // ================= SENSOR CARD =================
  Widget sensorCard(String title, String value, bool isOn) {

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff1E3C72), Color(0xff2A5298)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 8,
            offset: Offset(2,4),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Icon(
            isOn ? Icons.filter_b_and_w : Icons.mode_fan_off,
            size: 35,
            color: Colors.white,
          ),

          const SizedBox(height: 10),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold
            ),
          ),

        ],
      ),
    );
  }

  // ================= MODE BADGE =================
  Widget modeBadge(){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: mode == "auto" ? Colors.green : Colors.orange,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "Mode : $mode",
        style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  // ================= MANUAL CONTROL =================
  Widget manualControl(){
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xff132A4A),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        children: [

          const Text(
            "Manual Control",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white
            ),
          ),

          const SizedBox(height: 10),

          SwitchListTile(
            activeColor: Colors.green,
            title: const Text("Fan 1", style: TextStyle(color: Colors.white)),
            value: fan1,
            onChanged: (v){
              setFan1(v);
            },
          ),

          SwitchListTile(
            activeColor: Colors.blue,
            title: const Text("Fan 2", style: TextStyle(color: Colors.white)),
            value: fan2,
            onChanged: (v){
              setFan2(v);
            },
          ),

        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xff0B1E3A),

      appBar: AppBar(
        backgroundColor: const Color(0xff0B1E3A),
        title: const Text("Incubator 3",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),

      body: SafeArea(

        child: LayoutBuilder(
          builder: (context, constraints) {

            int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

            return SingleChildScrollView(

              child: Column(

                children: [

                  const SizedBox(height: 15),

                  modeBadge(),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: (){
                          setMode("auto");
                        },
                        child: const Text("AUTO"),
                      ),

                      const SizedBox(width: 10),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        onPressed: (){
                          setMode("manual");
                        },
                        child: const Text("MANUAL"),
                      ),

                    ],
                  ),

                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),

                    child: GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),

                      children: [

                        sensorCard("Temperature", "$temperature °C", true),
                        sensorCard("Humidity", "$humidity %", true),
                        sensorCard("Motion", motion == 1 ? "Detected" : "No Motion", motion == 1),
                        sensorCard("Sound", "$sound", true),
                        sensorCard("Fan 1", fan1 ? "ON" : "OFF", fan1),
                        sensorCard("Fan 2", fan2 ? "ON" : "OFF", fan2),

                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  if(mode == "manual")
                    manualControl(),

                  const SizedBox(height: 20)

                ],
              ),
            );
          },
        ),
      ),
    );
  }
}