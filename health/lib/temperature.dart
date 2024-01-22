import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Temperature extends StatefulWidget {
  const Temperature({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _TemperatureState createState() => _TemperatureState();
}

class _TemperatureState extends State<Temperature> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  List<Map<String, dynamic>> temperatureData = [];

  @override
  void initState() {
    super.initState();
    _listenToDataChanges();
  }

  void _listenToDataChanges() {
    _databaseReference.child('temperature').onValue.listen((event) {
      if (event.snapshot.value != null) {
        final dynamic rawData = event.snapshot.value;

        if (rawData is List<dynamic>) {
          setState(() {
            final List<Map<String, dynamic>> newtemperatureData = [];

            // Get the recent 20 values or less if there are fewer than 20
            final int startIndex =
                (rawData.length > 20) ? rawData.length - 20 : 0;

            for (int i = startIndex; i < rawData.length; i++) {
              final int timestamp = rawData[i]['timestamp'];
              final double temperatureValue =
                  rawData[i]['temperature'].toDouble();

              newtemperatureData.add({
                'timestamp': DateTime.fromMillisecondsSinceEpoch(timestamp),
                'temperature': temperatureValue,
              });
            }

            temperatureData = newtemperatureData;
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
        title: const Text('Realtime Temperature Data'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/humid.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Display temperature data as a list
            Expanded(
              child: ListView.builder(
                itemCount: temperatureData.length,
                itemBuilder: (context, index) {
                  final entry = temperatureData[index];
                  final temperatureValue = entry['temperature'];
                  return Container(
                    margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    color: Colors.blueAccent.withOpacity(0.2),
                    child: ListTile(
                      title: Text('temperature: $temperatureValue'),
                      subtitle: Text('Timestamp: ${entry['timestamp']}'),
                    ),
                  );
                },
              ),
            ),

            // Display temperature data in a LineChart
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
                  maxX: temperatureData.length.toDouble() - 1,
                  minY: 10,
                  maxY: 30,
                  lineBarsData: [
                    LineChartBarData(
                      spots: temperatureData
                          .asMap()
                          .entries
                          .map((entry) => FlSpot(entry.key.toDouble(),
                              entry.value['temperature'] as double))
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
