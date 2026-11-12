import 'package:compass_measurement/src/screen/home/weather_station.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 1));
    // Get.to(const HomeScreen());
    Get.to(const WeatherStationScreen());
  }

  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.cyan,
      body: Center(
          child: CircularProgressIndicator(
        color: Colors.cyanAccent,
      )),
    );
  }
}
