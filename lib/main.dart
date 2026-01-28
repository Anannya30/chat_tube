import 'package:flutter/material.dart';
import 'features/home/screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print('Firebase initialized successfully');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatTube',
      theme: ThemeData(primarySwatch: Colors.red, brightness: Brightness.light),
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
