import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone_v/firebase_options.dart';
import 'package:twitter_clone_v/pages/notification_page.dart';
import 'package:twitter_clone_v/services/api/firebase_api.dart';
import 'package:twitter_clone_v/services/auth/auth_gate.dart';
import 'package:twitter_clone_v/services/database/database_provider.dart';
import 'package:twitter_clone_v/theming/theme_provider.dart';

void main() async {

  // firebase setup
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  // initialisation for notifications
  await FirebaseApi().initNotifications();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context)=> MyThemeProvider()),
        ChangeNotifierProvider(create: (context)=> DatabaseProvider()),
      ],
      child: const MyApp(),
    )
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: const AuthGate(),
      navigatorKey: navigatorKey,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        '/notification_page': (context)=> NotificationPage()
      },
      theme: Provider.of<MyThemeProvider>(context).getThemeData,
    );
  }
}