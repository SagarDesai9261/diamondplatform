import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'Pages/splash_screen.dart';
import 'model/service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'NotificationService.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  importance: Importance.high,
  playSound: true,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('A Background message just showed up: ${message.messageId}');
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();


  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Firebase local notification plugin
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Firebase messaging
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  final languageService = LanguageService();
  final localizationService = LocalizationService();
  final codes = await languageService.fetchLanguageCodes();
  final data1 = await localizationService.fetchLocalizationData();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AppLocalizations(
              Locale("en"), codes, data1), // Initialize with the default locale
        ),
        ChangeNotifierProvider(create: (context) => BannerDataProvider()),
        ChangeNotifierProvider(create: (context) => CurrentSlideProvider()),
        StreamProvider(
          create: (context) => NetworkService().controller.stream,
          initialData: NetworkStatus.online,
        ),
        ChangeNotifierProvider(create: (context) => MyListTileState()),
        ChangeNotifierProvider(create: (context) => CompanyProfileProvider()),
        ChangeNotifierProvider(create: (context) => EmployeeProfileProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class LanguageService {
  static const String apiUrl = 'https://diamond-server.vercel.app/language';

  Future<Map<String, dynamic>> fetchLanguageCodes() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final languages = data['data'] as List;
      return Map.fromIterable(languages,
          key: (lang) => lang['code'], value: (lang) => lang['name']);
    } else {
      throw Exception('Failed to fetch language codes');
    }
  }
}

class LocalizationService {
  static const String apiUrl = 'https://diamond-server.vercel.app/keys/keys';

  Future<Map<String, Map<String, dynamic>>> fetchLocalizationData() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Map<String, Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception('Failed to fetch localization data');
    }
  }
}

class AppLocalizations extends ChangeNotifier {
  Locale locale;
  final Map<String, dynamic> languageCodes;
  final Map<String, Map<String, dynamic>> localizationData;

  AppLocalizations(this.locale, this.languageCodes, this.localizationData);

  void setLocale(Locale newLocale) {
    locale = newLocale;
    notifyListeners(); // Notify listeners when the locale changes
  }

  static List<Locale> get supportedLocales {
    return [
      Locale('en'), // English
      Locale('es'), // Spanish
      Locale('fr'), // French
      Locale('de'), // German
      Locale('it'), // Italian
      Locale('pt'), // Portuguese
      Locale('zh'), // Chinese (Simplified)
      Locale('ja'), // Japanese
      Locale('ko'), // Korean
      Locale('ru'), // Russian
      Locale('ar'), // Arabic
      Locale('hi'), // Hindi
      Locale('tr'), // Turkish
      Locale('nl'), // Dutch
      Locale('sv'), // Swedish
      Locale('no'), // Norwegian
      Locale('da'), // Danish
      Locale('fi'), // Finnish
      Locale('el'), // Greek
      Locale('he'), // Hebrew
      Locale('th'), // Thai
      Locale('vi'), // Vietnamese
      Locale('cs'), // Czech
      Locale('hu'), // Hungarian
      Locale('pl'), // Polish
      Locale('ro'), // Romanian
      Locale('sk'), // Slovak
      Locale('sl'), // Slovenian
      Locale('bg'), // Bulgarian
      Locale('uk'), // Ukrainian
      Locale('hr'), // Croatian
      Locale('sr'), // Serbian
      Locale('et'), // Estonian
      Locale('lv'), // Latvian
      Locale('lt'), // Lithuanian
      Locale('ms'), // Malay
      Locale('id'), // Indonesian
      Locale('fil'), // Filipino
      Locale('sw'), // Swahili
      Locale('ta'), // Tamil
      Locale('te'), // Telugu
      Locale('ml'), // Malayalam
      Locale('kn'), // Kannada
      Locale('gu'), // Gujarati
      Locale('mr'), // Marathi
      Locale('bn'), // Bengali
      Locale('pa'), // Punjabi
      Locale('ur'), // Urdu
    ];
  }

  static AppLocalizations? of(BuildContext context) {
    return Provider.of<AppLocalizations>(context, listen: false);
  }

  static AppLocalizations watch(BuildContext context) {
    return Provider.of<AppLocalizations>(context, listen: true);
  }

  String? translate(String key) {
    final langCode = locale.languageCode;
    final localizedStrings = localizationData[langCode] ?? {};
    return localizedStrings[key];
  }

  static LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  final LanguageService languageService = LanguageService();
  final LocalizationService localizationService = LocalizationService();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.contains(locale);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final codes = await languageService.fetchLanguageCodes();
    final Map<String, Map<String, dynamic>> data =
        await localizationService.fetchLocalizationData();
    return AppLocalizations(locale, codes, data);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    NotificationService().requestNotificationPermission();
    var token = NotificationService().getDeviceToken();
    print(token.toString());
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
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
          'notification_hascode': notification.hashCode,
          'notification_title': notification.title,
          'notification_body': notification.body,
          'notification_time': date,
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
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      print('A new message open app event was published');
      List<String> list;
      if (prefs.getStringList("notification_data") != null) {
        list = prefs.getStringList("notification_data")!;
      } else {
        list = [];
      }
      RemoteNotification notification = message.notification!;
      AndroidNotification android = message.notification!.android!;
      if (notification != null && android != null) {
        DateTime now = DateTime.now();
        String date = DateTime.now().toString();
        list.add(json.encode({
          'notification_hascode': notification.hashCode,
          'notification_title': notification.title,
          'notification_body': notification.body,
          'notification_time': date,
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
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    FlutterNativeSplash.remove();
    return ChangeNotifierProvider<AppLocalizations>.value(
      value: AppLocalizations.watch(context),
      child: Consumer<AppLocalizations>(
        builder: (context, appLocalizations, child) {
          return MaterialApp(
            localizationsDelegates: [
              // Add your custom AppLocalizations.delegate here
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: appLocalizations
                .locale, // Use the current locale from the provider
            themeMode: ThemeMode
                .system, // Automatically switch between light and dark based on system
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
        },
      ),
    );
  }
}
