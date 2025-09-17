import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timeleft_clone/services/api_service.dart';
import 'package:timeleft_clone/services/notification_service.dart';

class PushNotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Track initialization state
  static bool _isInitialized = false;
  static bool _hasValidCredentials = false;

  // Add context tracking for in-app notifications
  static BuildContext? _currentContext;

  // Add app state tracking
  static bool _isAppInForeground = true;

  static Future<void> initialize() async {
    if (_isInitialized) {
      print('Push notifications already initialized');
      return;
    }

    try {
      print('🔔 Initializing notification system...');

      // Initialize timezone data for scheduled notifications
      tz_data.initializeTimeZones();

      // Request permissions (works regardless of credentials)
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ User granted notification permission');

        // Initialize local notifications (always works)
        await _initializeLocalNotifications();

        // Check if we can handle remote notifications
        bool canHandleRemote = await _checkRemoteNotificationSupport();

        if (canHandleRemote) {
          print('🌐 Remote notifications supported - setting up FCM');
          _hasValidCredentials = true;
          _setupMessageHandlers();
          await _handleFCMToken();

          // Handle token refresh
          _firebaseMessaging.onTokenRefresh.listen((newToken) async {
            print('FCM Token refreshed: $newToken');
            try {
              await ApiService.updateFCMToken(newToken);
            } catch (e) {
              print('Failed to update FCM token: $e');
            }
          });
        } else {
          print(
              '📱 Remote notifications not available - using local notifications only');
          print('💡 To enable remote notifications:');
          if (Platform.isIOS) {
            print('   - Get Apple Developer Program (99/year)');
            print('   - Upload APNs certificates to Firebase');
          } else {
            print('   - Check Firebase configuration');
          }
        }

        _isInitialized = true;
      } else {
        print('❌ User denied notification permission');
      }
    } catch (e) {
      print('⚠️ Error initializing notifications: $e');
      // Continue app initialization - local notifications might still work
      _isInitialized = true;
    }
  }

  // Add context management
  static void setContext(BuildContext context) {
    _currentContext = context;
  }

  // Add app lifecycle management
  static void setAppForegroundState(bool isInForeground) {
    _isAppInForeground = isInForeground;
    print(
        '📱 App state changed: ${isInForeground ? 'Foreground' : 'Background'}');
  }

  // Enhanced in-app notification with better styling
  static void showInAppNotification(
    String title,
    String body, {
    Duration duration = const Duration(seconds: 4),
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
    IconData icon = Icons.notifications,
  }) {
    if (_currentContext == null) return;

    final overlay = Overlay.of(_currentContext!);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: textColor, size: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (body.isNotEmpty) ...[
                        SizedBox(height: 2),
                        Text(
                          body,
                          style: TextStyle(
                            color: textColor.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => overlayEntry.remove(),
                  child: Container(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      color: textColor.withOpacity(0.6),
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Timer(duration, () {
      try {
        overlayEntry.remove();
      } catch (e) {
        // Overlay entry might already be removed
      }
    });
  }

  static Future<bool> _checkRemoteNotificationSupport() async {
    try {
      if (Platform.isIOS) {
        // Check if we can get APNS token (indicates proper setup)
        print('🍎 Checking iOS remote notification support...');

        // Quick check - if we can't get APNS token, remote notifications won't work
        String? apnsToken = await _firebaseMessaging
            .getAPNSToken()
            .timeout(Duration(seconds: 5));

        if (apnsToken != null) {
          print('✅ APNS token available - remote notifications supported');
          return true;
        } else {
          print('❌ No APNS token - missing Apple Developer certificates');
          return false;
        }
      } else {
        // Android - usually works if Firebase is configured
        print('🤖 Checking Android remote notification support...');
        String? token =
            await _firebaseMessaging.getToken().timeout(Duration(seconds: 5));
        return token != null;
      }
    } catch (e) {
      print('❌ Remote notification check failed: $e');
      return false;
    }
  }

  static Future<void> _handleFCMToken() async {
    if (!_hasValidCredentials) {
      print('⏭️ Skipping FCM token - credentials not available');
      return;
    }

    try {
      if (Platform.isIOS) {
        await _handleIOSToken();
      } else {
        await _getFCMToken();
      }
    } catch (e) {
      print('Error handling FCM token: $e');
    }
  }

  static Future<void> _handleIOSToken() async {
    print('🍎 Getting iOS FCM token...');

    try {
      // Since we already verified APNS token exists, directly get FCM token
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        print('✅ FCM Token obtained: ${token.substring(0, 20)}...');
        await ApiService.updateFCMToken(token);
        print("TOKEN RECEIVED: $token");
      } else {
        print('❌ FCM token is null');
      }
    } catch (e) {
      print('❌ Error getting iOS FCM token: $e');
    }
  }

  static Future<void> _getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        await ApiService.updateFCMToken(token);
        print('FCM Token: $token');
      } else {
        print('FCM Token is null');
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  static Future<void> _initializeLocalNotifications() async {
    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // Create notification channel for Android
      if (Platform.isAndroid) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(
              const AndroidNotificationChannel(
                'timeleft_notifications',
                'TimeLeft Notifications',
                description: 'Notifications for TimeLeft app',
                importance: Importance.high,
              ),
            );
      }

      print('✅ Local notifications initialized successfully');
    } catch (e) {
      print('❌ Error initializing local notifications: $e');
    }
  }

  static void _setupMessageHandlers() {
    if (!_hasValidCredentials) return;

    try {
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        print('📨 Foreground message: ${message.messageId}');
        await _showLocalNotification(message);

        try {
          NotificationEventService().refreshNotifications();
        } catch (e) {
          print('Error refreshing notifications: $e');
        }
      });

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('👆 Message clicked: ${message.messageId}');
        _handleNotificationTap(message);
      });

      // Handle notification tap when app is terminated
      _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
          print('🚀 App launched from notification: ${message.messageId}');
          _handleNotificationTap(message);
        }
      });

      print('✅ Message handlers set up successfully');
    } catch (e) {
      print('❌ Error setting up message handlers: $e');
    }
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'timeleft_notifications',
        'TimeLeft Notifications',
        channelDescription: 'Notifications for TimeLeft app',
        importance: Importance.high,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        message.hashCode,
        message.notification?.title ?? 'TimeLeft',
        message.notification?.body ?? 'You have a new notification',
        details,
        payload: message.data.toString(),
      );

      print('✅ Local notification shown successfully');
    } catch (e) {
      print('❌ Error showing local notification: $e');
    }
  }

  static void _handleNotificationTap(RemoteMessage message) {
    try {
      final notificationType = message.data['notification_type'];
      print('👆 Notification tapped with type: $notificationType');
    } catch (e) {
      print('❌ Error handling notification tap: $e');
    }
  }

  static void _onNotificationTap(NotificationResponse response) {
    try {
      print('👆 Local notification tapped: ${response.payload}');
    } catch (e) {
      print('❌ Error handling local notification tap: $e');
    }
  }

  // SOLUTION 1: Force notification to appear after minimal delay
  static Future<void> testLocalNotification({
    String title = 'Test Notification',
    String body = 'This is a test local notification',
    int? scheduleAfterSeconds,
    bool forceInApp = false,
    bool forceForegroundNotification = false,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'timeleft_notifications',
        'TimeLeft Notifications',
        channelDescription: 'Notifications for TimeLeft app',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        when: null,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      int notificationId =
          DateTime.now().millisecondsSinceEpoch.remainder(100000);

      if (scheduleAfterSeconds != null) {
        // Schedule notification using zonedSchedule
        await _localNotifications.zonedSchedule(
          notificationId,
          title,
          body,
          tz.TZDateTime.now(tz.local)
              .add(Duration(seconds: scheduleAfterSeconds)),
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        print('✅ Local notification scheduled for ${scheduleAfterSeconds}s');

        // Also show in-app notification
        showInAppNotification(
          'Scheduled!',
          'Notification scheduled for ${scheduleAfterSeconds}s. Minimize app to see it.',
          backgroundColor: Colors.orange,
        );
      } else {
        // SOLUTION: Immediate + micro-delayed notifications

        // 1. Show in-app notification immediately (always visible)
        showInAppNotification(
          title,
          body,
          backgroundColor: Colors.green,
        );

        if (forceForegroundNotification) {
          // SOLUTION 1: Use a very short delay to bypass foreground suppression
          await _localNotifications.zonedSchedule(
            notificationId,
            title,
            '$body (Forced)',
            tz.TZDateTime.now(tz.local).add(Duration(milliseconds: 100)),
            details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );

          showInAppNotification(
            'Force Mode!',
            'Native notification scheduled for 100ms delay to bypass foreground suppression',
            backgroundColor: Colors.purple,
            icon: Icons.rocket_launch,
          );
        } else {
          // 2. Send native notification (may be suppressed in foreground)
          await _localNotifications.show(notificationId, title, body, details);

          // 3. Also schedule a background demonstration
          await Future.delayed(Duration(milliseconds: 500));
          await _localNotifications.zonedSchedule(
            notificationId + 1,
            'Background Demo',
            'This appears when app is backgrounded (2s delay)',
            tz.TZDateTime.now(tz.local).add(Duration(seconds: 2)),
            details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        }

        print('✅ Notification strategy executed');
      }
    } catch (e) {
      print('❌ Error sending test notification: $e');
      // Show error in-app
      showInAppNotification(
        'Error',
        'Failed to send notification: $e',
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
    }
  }

  // SOLUTION 2: Smart notification that adapts to app state
  static Future<void> sendSmartNotification({
    required String title,
    required String body,
    Duration delayIfForeground = const Duration(milliseconds: 500),
  }) async {
    if (_isAppInForeground) {
      // App is in foreground - show in-app notification and schedule native with delay
      showInAppNotification(title, body, backgroundColor: Colors.blue);

      // Schedule native notification with small delay to appear when user backgrounds app
      await _localNotifications.zonedSchedule(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        '$body (Smart)',
        tz.TZDateTime.now(tz.local).add(delayIfForeground),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'timeleft_notifications',
            'TimeLeft Notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      showInAppNotification(
        'Smart Mode',
        'In-app shown immediately. Native scheduled for when you background the app.',
        backgroundColor: Colors.teal,
        icon: Icons.psychology,
      );
    } else {
      // App is in background - send native notification immediately
      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'timeleft_notifications',
            'TimeLeft Notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    }
  }

  // Utility methods
  static bool get hasRemoteNotifications => _hasValidCredentials;
  static bool get isInitialized => _isInitialized;

  // Schedule dinner reminders (example of local notification usage)
  static Future<void> scheduleDinnerReminder({
    required DateTime dinnerTime,
    required String restaurantName,
    int hoursBeforeReminder = 2,
  }) async {
    try {
      DateTime reminderTime =
          dinnerTime.subtract(Duration(hours: hoursBeforeReminder));

      if (reminderTime.isBefore(DateTime.now())) {
        print('⏰ Reminder time is in the past, skipping');
        showInAppNotification(
          'Reminder Skipped',
          'The reminder time is in the past',
          backgroundColor: Colors.orange,
          icon: Icons.schedule,
        );
        return;
      }

      await _localNotifications.zonedSchedule(
        dinnerTime.millisecondsSinceEpoch.remainder(100000),
        'Dinner Reminder',
        'Your reservation at $restaurantName is in $hoursBeforeReminder hours',
        tz.TZDateTime.from(reminderTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'timeleft_notifications',
            'TimeLeft Notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      print('✅ Dinner reminder scheduled for $reminderTime');

      // Show confirmation in-app
      showInAppNotification(
        'Reminder Set!',
        'Dinner reminder scheduled for ${reminderTime.hour.toString().padLeft(2, '0')}:${reminderTime.minute.toString().padLeft(2, '0')}',
        backgroundColor: Colors.blue,
        icon: Icons.restaurant,
      );
    } catch (e) {
      print('❌ Error scheduling dinner reminder: $e');
      showInAppNotification(
        'Error',
        'Failed to schedule reminder: $e',
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
    }
  }
}
