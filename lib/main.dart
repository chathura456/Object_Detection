import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:object_detection2/home_page.dart';
import 'package:object_detection2/next_page.dart';
import 'package:object_detection2/rep_select.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const PoseDetector(),
    );
  }
}

