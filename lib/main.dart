import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_market/controllers/invereters/fetch_inverters_controller.dart';
import 'package:solar_market/controllers/panels/fetch_panels_controller.dart';
import 'package:solar_market/firebase_options.dart';
import 'package:solar_market/screens/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'controllers/lithium/fetch_lithium_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Request App Tracking Transparency permission
  await requestTrackingPermission();
  Get.put(FetchPanelsController());
  Get.put(FetchInvertersController());
  Get.put(FetchLithiumController());


  // Run the app
  runApp(const MyApp());
}

/// Request App Tracking Transparency permission
Future<void> requestTrackingPermission() async {
  // Get the current tracking status
  final status = await AppTrackingTransparency.trackingAuthorizationStatus;

  // If the status is not determined, request permission
  if (status == TrackingStatus.notDetermined) {
    final result = await AppTrackingTransparency.requestTrackingAuthorization();
    if (result == TrackingStatus.authorized) {
      print('Tracking authorized');
      // Proceed with tracking features
    } else {
      print('Tracking denied');
      // Handle denial (e.g., disable tracking features)
    }
  } else {
    print('Tracking status: $status');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(
          MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Pakistan Solar Market',
          theme: ThemeData(
            useMaterial3: true,
          ),
          builder: (context, child) {
            return MediaQuery(
              child: child!,
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.noScaling),
            );
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}
