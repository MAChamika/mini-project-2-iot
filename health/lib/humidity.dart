import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Humidity extends StatefulWidget {
  const Humidity({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HumidityState createState() => _HumidityState();
}

class _HumidityState extends State<Humidity> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  List<Map<String, dynamic>> humidityData = [];

  @override
  void initState() {
    super.initState();
    _listenToDataChanges();
  }

  void _listenToDataChanges() {
    _databaseReference.child('humidity').onValue.listen((event) {
      if (event.snapshot.value != null) {
        final dynamic rawData = event.snapshot.value;

        if (rawData is List<dynamic>) {
          setState(() {
            final List<Map<String, dynamic>> newHumidityData = [];

            // Get the recent 20 values or less if there are fewer than 20
            final int startIndex =
                (rawData.length > 20) ? rawData.length - 20 : 0;

            for (int i = startIndex; i < rawData.length; i++) {
              final int timestamp = rawData[i]['timestamp'];
              final double humidityValue = rawData[i]['humidity'].toDouble();

              newHumidityData.add({
                'timestamp': DateTime.fromMillisecondsSinceEpoch(timestamp),
                'humidity': humidityValue,
              });
            }

            humidityData = newHumidityData;
          });
        } else {
          print('Invalid data format received from Firebase: $rawData');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text('Realtime Humidity Data'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/humid.jpg"),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: humidityData.length,
                itemBuilder: (context, index) {
                  final entry = humidityData[index];
                  final humidityValue = entry['humidity'];
                  return Container(
                    margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    color: Colors.blueAccent.withOpacity(0.2),
                    child: ListTile(
                      title: Text('Humidity: $humidityValue'),
                      subtitle: Text('Timestamp: ${entry['timestamp']}'),
                    ),
                  );
                },
              ),
            ),

            // Display Humidity data in a LineChart
            Container(
              height: 200,
              padding: const EdgeInsets.all(16.0),
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: true),
                  borderData: FlBorderData(
                    show: true,
                    border:
                        Border.all(color: const Color(0xff37434d), width: 1),
                  ),
                  minX: 0,
                  maxX: humidityData.length.toDouble() - 1,
                  minY: 2,
                  maxY: 40,
                  lineBarsData: [
                    LineChartBarData(
                      spots: humidityData
                          .asMap()
                          .entries
                          .map((entry) => FlSpot(entry.key.toDouble(),
                              entry.value['humidity'] as double))
                          .toList(),
                      isCurved: true,
                      color: Colors.blue,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
