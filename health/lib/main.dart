import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:health/mainpage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyB_mchtyVvg6O2KJq8EsbopItF2x2r5_t0',
      authDomain: 'health-check-48e20.firebaseapp.com',
      storageBucket: 'health-check-48e20.appspot.com',
      appId: '1:264993935986:web:e984d5841065fcda1d28eb',
      messagingSenderId: '264993935986',
      projectId: 'health-check-48e20',
      measurementId: 'G-RDK7T190W3',
      databaseURL: "https://health-check-48e20-default-rtdb.firebaseio.com",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Dashboard(),
    );
  }
}
