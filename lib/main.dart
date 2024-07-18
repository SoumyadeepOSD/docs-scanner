import 'package:docs_scanner/demo_file.dart';
import 'package:docs_scanner/screens/onboarding/onboarding.dart';
import 'package:docs_scanner/screens/splash_screen.dart';
import 'package:docs_scanner/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'providers/state_providers.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
  runApp(
    ChangeNotifierProvider(
      create: (context) => CameraImageProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late CameraController controller;

  @override
  void initState() {
    super.initState();
    controller = CameraController(_cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            break;
          default:
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return ToastificationWrapper(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routes: {
          "/spash": (context) => const SplashScreen(),
          "/onboarding": (context) => const Onboarding(),
          "/home": (context) => const HomeScreen()
        },
        home: const SplashScreen(),
      ),
    );
  }
}
