import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';

class Incubator2 extends StatefulWidget {
  const Incubator2({super.key});

  @override
  State<Incubator2> createState() => _Incubator2State();
}

class _Incubator2State extends State<Incubator2> {

  final DatabaseReference sensorRef =
  FirebaseDatabase.instance.ref("inkubator/data");

  final DatabaseReference modeRef =
  FirebaseDatabase.instance.ref("inkubator/mode");

  final DatabaseReference controlRef =
  FirebaseDatabase.instance.ref("inkubator/control");

  double temperatureDS = 0;
  double temperatureDHT = 0;
  double humidity = 0;

  double lat = 0;
  double lon = 0;
  double speed = 0;
  int sat = 0;

  String mode = "auto";

  List<bool> fan = [false,false,false,false,false,false];
  List<bool> lamp = [false,false];

  List<FlSpot> bodyTempChart = [];
  List<FlSpot> roomTempChart = [];
  List<FlSpot> humidityChart = [];

  double x = 0;

  @override
  void initState() {
    super.initState();
    listenSensor();
    listenMode();
  }

  // ================= SENSOR =================
  void listenSensor() {
    sensorRef.onValue.listen((event) {

      final data = event.snapshot.value;

      if (data != null) {

        Map map = data as Map;

        setState(() {

          temperatureDS =
              double.tryParse(map["temperature_ds"].toString()) ?? 0;

          temperatureDHT =
              double.tryParse(map["temperature_dht"].toString()) ?? 0;

          humidity =
              double.tryParse(map["humidity"].toString()) ?? 0;

          lat =
              double.tryParse(map["gps"]["lat"].toString()) ?? 0;

          lon =
              double.tryParse(map["gps"]["lon"].toString()) ?? 0;

          speed =
              double.tryParse(map["gps"]["speed"].toString()) ?? 0;

          sat =
              int.tryParse(map["gps"]["sat"].toString()) ?? 0;

          x++;

          bodyTempChart.add(FlSpot(x, temperatureDS));
          roomTempChart.add(FlSpot(x, temperatureDHT));
          humidityChart.add(FlSpot(x, humidity));

          if(bodyTempChart.length > 20){
            bodyTempChart.removeAt(0);
            roomTempChart.removeAt(0);
            humidityChart.removeAt(0);
          }
        });
      }
    });
  }

  // ================= MODE =================
  void listenMode(){
    modeRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if(data != null){
        setState(() {
          mode = data.toString();
        });
      }
    });
  }

  void setMode(String newMode){
    modeRef.set(newMode);
  }

  // ================= CONTROL =================
  void setFan(int index,bool value){
    controlRef.child("fan${index+1}").set(value ? 0 : 1);
    setState(() => fan[index] = value);
  }

  void setLamp(int index,bool value){
    controlRef.child("lamp${index+1}").set(value ? 0 : 1);
    setState(() => lamp[index] = value);
  }

  // ================= SENSOR CARD =================
  Widget sensorCard(String title, String value, IconData icon) {

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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(icon, size: 38, color: Colors.white),

            const SizedBox(height: 10),

            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 5),

            Text(
              value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold
              ),
            )

          ],
        ),
      ),
    );
  }

  // ================= CHART =================
  Widget chartCard(String title,List<FlSpot> data){

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xff132A4A),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (value){
                    return const FlLine(
                      color: Colors.white10,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: data,
                    isCurved: true,
                    color: Colors.cyanAccent,
                    dotData: FlDotData(show: false),
                    barWidth: 3,
                  )
                ],
              ),
            ),
          )
        ],
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

          for(int i=0;i<6;i++)
            SwitchListTile(
              activeColor: Colors.green,
              title: Text("Fan ${i+1}",
                  style: const TextStyle(color: Colors.white)),
              value: fan[i],
              onChanged: (v){
                setFan(i,v);
              },
            ),

          const Divider(color: Colors.white24),

          for(int i=0;i<2;i++)
            SwitchListTile(
              activeColor: Colors.orange,
              title: Text("Lamp ${i+1}",
                  style: const TextStyle(color: Colors.white)),
              value: lamp[i],
              onChanged: (v){
                setLamp(i,v);
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
        title: const Text("👶 Smart Baby Incubator",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),

      body: SingleChildScrollView(

        child: Column(

          children: [

            const SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
            ),

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

            const SizedBox(height: 10),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,

              children: [

                sensorCard("Body Temp", "$temperatureDS °C", Icons.thermostat),
                sensorCard("Room Temp", "$temperatureDHT °C", Icons.device_thermostat),
                sensorCard("Humidity", "$humidity %", Icons.water_drop),
                sensorCard("GPS Sat", "$sat", Icons.gps_fixed),
                sensorCard("Latitude", lat.toStringAsFixed(5), Icons.location_on),
                sensorCard("Longitude", lon.toStringAsFixed(5), Icons.map),
                sensorCard("Speed", "$speed km/h", Icons.speed),

              ],
            ),

            chartCard("Body Temperature", bodyTempChart),
            chartCard("Room Temperature", roomTempChart),
            chartCard("Humidity", humidityChart),

            if(mode == "manual")
              manualControl(),

            const SizedBox(height: 20)

          ],
        ),
      ),
    );
  }
}