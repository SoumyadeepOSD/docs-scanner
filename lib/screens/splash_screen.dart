import 'package:camera/camera.dart';
import 'package:docs_scanner/screens/onboarding/onboarding.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const Onboarding();
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        color: Colors.white,
        height: height,
        width: width,
        child: Center(
          child: Column(
            children: [
              SizedBox(height: height * 0.4),
              Image.asset(
                "assets/images/splash_screen_logo.png",
                height: height * 0.2,
                width: width * 0.2,
              ),
              SizedBox(height: height * 0.2),
              Text(
                "Solid Scanner",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Colors.blue.shade800),
              ),
              const Text(
                "An all in one scanning companion",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              )
            ],
          ),
        ),
      ),
    );
  }
}
