import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Set the status bar color to match your splash screen background
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
    ));

    return Scaffold(
      backgroundColor:
          Colors.grey[300], // Set your splash screen background color
      body: const Center(
        child: Text(
          'HOLD IT',
          style: TextStyle(
              color: Colors.black, fontFamily: 'HeaderFont', fontSize: 100),
        ), // Replace with your splash screen image
      ),
    );
  }
}
