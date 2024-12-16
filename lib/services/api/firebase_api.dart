


import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Navigator key for navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Initialize the local notification plugin
  Future<void> initNotifications() async {
    // Request permissions for notifications
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Print FCM token for debugging
    final fcmToken = await _firebaseMessaging.getToken();
    print('FCM Token: $fcmToken');

    // Initialize local notifications
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse, // Callback for notification click
    );


    // Initialize Firebase push notifications
    await initPushNotifications();
  }

  // Function to initialize Firebase push notifications
  Future<void> initPushNotifications() async {
    FirebaseMessaging.instance.setAutoInitEnabled(true);

    // Handle foreground notification presentation
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle notification when the app is terminated and opened via notification
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleNotificationClick(message);
      }
    });

    // Handle notification click when the app is in background or foreground
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message);
    });

    // Handle notification in foreground (show local notification)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground notification received: ${message.notification?.title}');
      _showLocalNotification(message); // Show local notification
    });
  }

  // Handle notification clicks
  void _handleNotificationClick(RemoteMessage message) {
    // convert the message object into the Map<String, dynamic>
    Map<String, dynamic> messageMap = remoteMessageToMap(message);
    if (message.notification != null) {
      navigatorKey.currentState?.pushNamed(
        '/notification_page',
        arguments: messageMap, // Pass notification data as arguments
      );
    }
  }

  // Handle local notification click
  void _onNotificationResponse(NotificationResponse notificationResponse) {
    if (notificationResponse.payload != null) {
      print('Notification Payload: ${notificationResponse.payload}');
      Map<String, dynamic> notificationData = notificationResponseToMap(notificationResponse);

      // Navigate based on the payload
      navigatorKey.currentState?.pushNamed(
        '/notification_page',
        arguments: notificationData, // Pass payload
      );
    }
  }

  // Function to show a local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'default_channel', // Channel ID
      'Default Channel', // Channel name
      channelDescription: 'This is the default notification channel',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    Map<String, dynamic> messageMap = remoteMessageToMap(message);

    // Show the notification
    await flutterLocalNotificationsPlugin.show(
      message.hashCode, // Unique ID for each notification
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
      payload: json.encode(messageMap), // Pass route or other custom data
    );
  }

  // converting the Remote Message to Map
  Map<String, dynamic> remoteMessageToMap(RemoteMessage message) {
    return {
      'title': message.notification?.title ?? '',
      'body': message.notification?.body ?? '',
      'data': message.data, // Directly include the data map
      'messageId': message.messageId ?? '',
      'senderId': message.senderId ?? '',
      'sentTime': message.sentTime?.toIso8601String() ?? '',
      'collapseKey': message.collapseKey ?? '',
      'from': message.from ?? '',
      'category': message.category ?? '',
      'contentAvailable': message.contentAvailable,
      'mutableContent': message.mutableContent,
    };
  }

  // converting the notification response to Map
  Map<String, dynamic> notificationResponseToMap(NotificationResponse response) {
  // Decode the payload (if it's JSON encoded)
    Map<String, dynamic> data = {};
    if (response.payload != null) {
      try {
        data = json.decode(response.payload!);
      } catch (e) {
        print('Error decoding notification payload: $e');
      }
    }

    // Return the map in the desired format
    return {
      'title': data['title'] ?? '',
      'body': data['body'] ?? '',
      'data': data['data'] ?? {},
      'messageId': data['messageId'] ?? '',
      'senderId': data['senderId'] ?? '',
      'sentTime': data['sentTime'] ?? '',
      'collapseKey': data['collapseKey'] ?? '',
      'from': data['from'] ?? '',
      'category': data['category'] ?? '',
      'contentAvailable': data['contentAvailable'] ?? false,
      'mutableContent': data['mutableContent'] ?? false,
    };
  }
}





// class FirebaseApi {
//   final _firebaseMessaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

//   // Initialize the local notification plugin
//   Future<void> initNotifications() async {
//     // Initialize the Firebase Messaging
//     await _firebaseMessaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     final fcmToken = await _firebaseMessaging.getToken();
//     print('FCM Token : $fcmToken');

//     // Initialize local notifications
//     const AndroidInitializationSettings androidInitializationSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher'); // Your app icon
//     const InitializationSettings initializationSettings =
//         InitializationSettings(android: androidInitializationSettings);

//     await flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,

//     );

//     // Initialize further settings for push notifications
//     await initPushNotifications();
//   }

//   // Function to initialize background notifications
//   Future<void> initPushNotifications() async {
//     FirebaseMessaging.instance.setAutoInitEnabled(false);

//     await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     // // Handle notification when the app is in the foreground
//     // FirebaseMessaging.onMessage.listen(handleMessage);

//     // // Handle notification when the app is opened from a background state
//     // FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

//     // // Handle notification when the app is terminated and opened
//     // FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

//      // Handle notification when the app is terminated and opened via notification
//   FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
//     if (message != null) {
//       // Navigate to the notification page if the app was terminated
//       _handleNotificationClick(message);
//     }
//   });

//   // Handle notification click when the app is in background or foreground
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     _handleNotificationClick(message);
//   });

//   // Foreground notifications (no navigation here)
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     print('Foreground notification received: ${message.notification?.title}');
//     _showLocalNotification(message); // Show the notification locally
//   });
//   }

//   // Function to handle the incoming notification
//   void _handleNotificationClick(RemoteMessage? message) {
//     if (message == null) return;
//     navigatorKey.currentState?.pushNamed(
//       '/notification_page',
//       arguments: message,
//     );
//   }

//   // Function to show a local notification
//   Future<void> _showLocalNotification(RemoteMessage message) async {
//     const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
//       'default_channel', // channel ID
//       'Default Channel', // channel name
//       importance: Importance.high,
//       priority: Priority.high,
//       ticker: 'ticker',
//     );

//     const NotificationDetails notificationDetails = NotificationDetails(
//       android: androidNotificationDetails,
//     );

//     // Show the notification
//     await flutterLocalNotificationsPlugin.show(
//       0, // notification ID
//       message.notification?.title,
//       message.notification?.body,
//       notificationDetails,
//       payload: message.data['route'], // Optional: add data to pass in the notification
//     );
//   }
// }
