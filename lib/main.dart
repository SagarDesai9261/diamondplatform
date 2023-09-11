
import 'dart:convert';

import 'package:diamondplatform/NotificationService.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Pages/splash_screen.dart';
import 'model/service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    importance: Importance.high,
    playSound: true);
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
 // print(message.notification!.title);
  print('A Background message just showed up :  ${message.messageId}');
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

// Firebase local notification plugin
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

//Firebase messaging
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en','US'), Locale('hi', 'IN'), Locale('gu', 'IN')],
      path: 'assets/translations', // <-- change the path of the translation files
      fallbackLocale: Locale('en', 'US'), // Default fallback locale
      child: MultiProvider(providers: [
        ChangeNotifierProvider(create: (context)=>BannerDataProvider()),
        ChangeNotifierProvider(create: (context)=>CurrentSlideProvider()),
        StreamProvider(create: (context)=> NetworkService().controller.stream, initialData: NetworkStatus.online),
        ChangeNotifierProvider(create: (context)=>MyListTileState()),
        ChangeNotifierProvider(create: (context)=>CompanyProfileProvider()),
        ChangeNotifierProvider(create: (context)=>EmployeeProfileProvider())
       // ChangeNotifierProvider(create: (context)=>DiamondProvider())
      
      ],
      child: MyApp()),
    ),
  );
}



class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    NotificationService().requestNotificationPermission();
    var token = NotificationService().getDeviceToken();
    print(token.toString());
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> list;
      if (prefs.getStringList("notification_data") != null) {
        list = prefs.getStringList("notification_data")!;
      } else {
        list = [];
      }
      RemoteNotification notification = message.notification!;
      AndroidNotification android = message.notification!.android!;
      String date = DateTime.now().toString();
      if (notification != null && android != null) {
        list.add(json.encode({
          'notification_hascode':notification.hashCode,
          'notification_title':notification.title,
          'notification_body':notification.body,
          'notification_time':date
        }));
        prefs.setStringList("notification_data", list);
        print(list);
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher',
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      print('A new messageopen app event was published');
      //SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> list;
      if (prefs.getStringList("notification_data") != null) {
        list = prefs.getStringList("notification_data")!;
      } else {
        list = [];
      }
      RemoteNotification notification = message.notification!;
      //RemoteNotification notification = message.notification!;
      AndroidNotification android = message.notification!.android!;
      if (notification != null && android != null) {
        DateTime now = DateTime.now();
        String formattedDate = DateFormat('d MMM yyyy HH:mm:ss').format(now);
        print(formattedDate);
        String date = DateTime.now().toString();
        list.add(json.encode({
          'notification_hascode':notification.hashCode,
          'notification_title':notification.title,
          'notification_body':notification.body,
          'notification_time':date
        }));
        prefs.setStringList("notification_data", list);
        print(list);
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title!),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(notification.body!)],
                  ),
                ),
              );
            });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      themeMode: ThemeMode.system, // Automatically switch between light and dark based on system
      darkTheme: ThemeData.dark(), // Dark theme data
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          centerTitle: true,
          foregroundColor: Colors.black,
          elevation: 0.5,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
