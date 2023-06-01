import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
          child: SizedBox(
        width: 200,
        child: Lottie.network(
            'https://assets8.lottiefiles.com/packages/lf20_pQChF8.json'),
      )),
    );
  }
}
