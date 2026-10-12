import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeleft_clone/screens/Profile/EditProfile/forgot_password_screen.dart';
import 'package:timeleft_clone/screens/main_screen.dart';
import 'package:timeleft_clone/screens/splash_screen.dart'; // ADD THIS
import 'package:timeleft_clone/screens/Onboarding/initial_onboarding_screen.dart';
import 'package:timeleft_clone/services/core/token_manager.dart';
import 'package:timeleft_clone/services/deep_link_handler.dart';
import 'package:timeleft_clone/services/push_notification_service.dart';
import 'package:timeleft_clone/services/supabase_service.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screens/Auth/login_screen.dart';
import 'package:camera/camera.dart';
import 'screens/Profile/EditProfile/reset_password_screen.dart';
import 'package:permission_handler/permission_handler.dart';

List<CameraDescription> cameras = [];

Future<bool> checkCameraPermission() async {
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.initialize();

  await DeepLinkHandler.initialize(navigatorKey);

  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    print('Auth state changed: ${data.event}');
    print('User: ${data.session?.user?.id}');
  });

  final token = await TokenManager.instance.getToken();
  print("DEBUG: Current token: ${token != null ? 'EXISTS' : 'NULL'}");
  print("DEBUG: Token length: ${token?.length ?? 0}");

  if (Platform.isIOS) {
    try {
      final bundle = await rootBundle.loadString('ios/Runner/Info.plist');
      print(
          'Info.plist contains camera description: ${bundle.contains('NSCameraUsageDescription')}');
    } catch (e) {
      print('Could not read Info.plist: $e');
    }
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    await PushNotificationService.initialize();
    print('Notifications initialized successfully in main()');
  } catch (e) {
    print('Failed to initialize notifications in main(): $e');
  }

  await AuthService.loadUserSession();

  final cameraStatus = await Permission.camera.status;
  print('Camera permission status at startup: $cameraStatus');

  try {
    cameras = await availableCameras();
    print('Available cameras: ${cameras.length}');
    for (int i = 0; i < cameras.length; i++) {
      print('   Camera $i: ${cameras[i].name} - ${cameras[i].lensDirection}');
    }
  } catch (e) {
    print('Error getting available cameras: $e');
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

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'TimeLeft Clone',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: AnimatedSwitcher(
        duration: Duration(milliseconds: 600),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: _showSplash
            ? SplashScreen(
                key: ValueKey('splash'),
                onComplete: () {
                  setState(() {
                    _showSplash = false;
                  });
                },
              )
            : ValueListenableBuilder(
                key: ValueKey('main'),
                valueListenable: AuthService.currentUserNotifier,
                builder: (context, user, _) {
                  return user != null
                      ? MainScreen()
                      : InitialOnboardingScreen();
                },
              ),
      ),
      routes: {
        '/forgot-password': (context) => ForgotPasswordScreen(
              email: 'rahul20232@iiitd.ac.in',
            ),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}
