import 'package:docs_scanner/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:google_fonts/google_fonts.dart';

class Onboarding extends StatelessWidget {
  const Onboarding({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    TextSpan customTextSpan(String text, Color color) => TextSpan(
          text: text,
          style: GoogleFonts.roboto(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        );

    TextSpan spacing() => const TextSpan(text: ' ');
    return Scaffold(
      body: OnBoardingSlider(
        headerBackgroundColor: Colors.white,
        finishButtonText: 'Get Started',
        finishButtonStyle: FinishButtonStyle(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            )),
        skipTextButton: const Text('Skip'),
        onFinish: () {
          Navigator.pushReplacementNamed(context, '/home');
        },
        indicatorAbove: true,
        background: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 200),
            child: Image.asset(
              'assets/images/first_onb.png',
              fit: BoxFit.cover,
              height: height * 0.3,
              width: 400,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 200),
            child: Image.asset(
              'assets/images/second_onb.png',
              fit: BoxFit.cover,
              height: height * 0.3,
              width: 400,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 200),
            child: Image.asset(
              'assets/images/third_onb.png',
              fit: BoxFit.cover,
              height: height * 0.3,
              width: 400,
            ),
          ),
        ],
        totalPage: 3,
        speed: 1.8,
        pageBodies: [
          // *First Page
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 480,
                ),
                RichText(
                  text: TextSpan(
                    text: "Transform",
                    style: GoogleFonts.roboto(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                    children: [
                      spacing(),
                      customTextSpan("Photos", Colors.blue),
                      spacing(),
                      customTextSpan("to", Colors.black),
                      spacing(),
                      customTextSpan("PDFs", Colors.blue),
                      spacing(),
                      customTextSpan("in a Snap!", Colors.black),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // *Second Page
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 480,
                ),
                RichText(
                  text: TextSpan(
                    text: "Your Mobile",
                    style: GoogleFonts.roboto(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                    children: [
                      spacing(),
                      customTextSpan("PDF", Colors.blue),
                      spacing(),
                      customTextSpan("Powerhouse!", Colors.black),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // *Third Page
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 480,
                ),
                RichText(
                  text: TextSpan(
                    text: "Scan,",
                    style: GoogleFonts.roboto(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.orange,
                    ),
                    children: [
                      spacing(),
                      customTextSpan("Edit,", Colors.blue),
                      spacing(),
                      customTextSpan("and", Colors.black),
                      spacing(),
                      customTextSpan("Share", Colors.green),
                      spacing(),
                      customTextSpan("– All in One Place!", Colors.black),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
