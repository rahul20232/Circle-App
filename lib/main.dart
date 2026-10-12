import 'dart:io';
import 'package:circle_app/theme/app_colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:circle_app/screens/Profile/EditProfile/forgot_password_screen.dart';
import 'package:circle_app/screens/main_screen.dart';
import 'package:circle_app/screens/splash_screen.dart'; // ADD THIS
import 'package:circle_app/screens/Onboarding/initial_onboarding_screen.dart';
import 'package:circle_app/services/core/token_manager.dart';
import 'package:circle_app/services/deep_link_handler.dart';
import 'package:circle_app/services/push_notification_service.dart';
import 'package:circle_app/services/supabase_service.dart';
import 'package:circle_app/demo/demo_mode.dart';
import 'package:circle_app/theme/app_theme.dart';
import 'package:http/http.dart' as http;
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
  // Demo build (--dart-define=DEMO=true): sign in a demo user and answer every
  // API call from bundled JSON instead of the live backend.
  // Flutter must be initialised *inside* the client zone, otherwise taps and
  // other engine callbacks run outside it and would bypass the demo client.
  if (kDemoMode) {
    return http.runWithClient(() async {
      WidgetsFlutterBinding.ensureInitialized();
      await DemoStore.init();
      await _start();
    }, DemoClient.new);
  }
  WidgetsFlutterBinding.ensureInitialized();
  return _start();
}

Future<void> _start() async {
  await SupabaseService.initialize();

  await DeepLinkHandler.initialize(navigatorKey);

  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    print('Auth state changed: ${data.event}');
    print('User: ${data.session?.user?.id}');
  });

  final token = await TokenManager.instance.getToken();
  print("DEBUG: Current token: ${token != null ? 'EXISTS' : 'NULL'}");
  print("DEBUG: Token length: ${token?.length ?? 0}");

  if (!kIsWeb && Platform.isIOS) {
    try {
      final bundle = await rootBundle.loadString('ios/Runner/Info.plist');
      print(
          'Info.plist contains camera description: ${bundle.contains('NSCameraUsageDescription')}');
    } catch (e) {
      print('Could not read Info.plist: $e');
    }
  }

  // Firebase is only used for push notifications, which the demo skips.
  if (!kDemoMode) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Push needs a real device token and backend — skip it in the demo.
  if (!kDemoMode) {
    try {
      await PushNotificationService.initialize();
      print('Notifications initialized successfully in main()');
    } catch (e) {
      print('Failed to initialize notifications in main(): $e');
    }
  }

  await AuthService.loadUserSession();

  // Camera is only needed for card scanning; skip on web and in the demo.
  if (!kIsWeb && !kDemoMode) {
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
      title: 'Circle',
      debugShowCheckedModeBanner: !kDemoMode,
      theme: AppTheme.light,
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
