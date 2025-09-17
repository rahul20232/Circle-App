import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:timeleft_clone/screens/main_screen.dart';
import 'package:timeleft_clone/services/push_notification_service.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screens/Onboarding/login_screen.dart';
import 'package:camera/camera.dart';
import 'screens/Profile/EditProfile/reset_password_screen.dart';
import 'package:permission_handler/permission_handler.dart';

List<CameraDescription> cameras = [];

// Add this function to check camera permissions
Future<bool> checkCameraPermission() async {
  final status = await Permission.camera.status;

  if (status.isGranted) {
    return true;
  } else if (status.isDenied) {
    final result = await Permission.camera.request();
    return result.isGranted;
  } else if (status.isPermanentlyDenied) {
    // Open app settings
    await openAppSettings();
    return false;
  }

  return false;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isIOS) {
    try {
      final bundle = await rootBundle.loadString('ios/Runner/Info.plist');
      print(
          '📋 Info.plist contains camera description: ${bundle.contains('NSCameraUsageDescription')}');
    } catch (e) {
      print('❌ Could not read Info.plist: $e');
    }
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    await PushNotificationService.initialize();
    print('✅ Notifications initialized successfully in main()');
  } catch (e) {
    print('❌ Failed to initialize notifications in main(): $e');
  }

  await AuthService.loadUserSession();

  final cameraStatus = await Permission.camera.status;
  print('📷 Camera permission status at startup: $cameraStatus');

  try {
    cameras = await availableCameras();
    print('📷 Available cameras: ${cameras.length}');
    for (int i = 0; i < cameras.length; i++) {
      print('   Camera $i: ${cameras[i].name} - ${cameras[i].lensDirection}');
    }
  } catch (e) {
    print('❌ Error getting available cameras: $e');
    cameras = [];
  }

  runApp(MyApp());
}

Future<bool> requestCameraPermissionAndInitialize() async {
  final status = await Permission.camera.status;

  if (status.isGranted) {
    return true;
  } else if (status.isDenied) {
    final result = await Permission.camera.request();
    return result.isGranted;
  } else if (status.isPermanentlyDenied) {
    await openAppSettings();
    return false;
  }

  return false;
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TimeLeft Clone',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: ValueListenableBuilder(
        valueListenable: AuthService.currentUserNotifier,
        builder: (context, user, _) {
          return user != null ? MainScreen() : LoginScreen();
        },
      ),
      routes: {
        '/reset-password': (context) {
          return ResetPasswordScreen();
        },
      },
    );
  }
}
