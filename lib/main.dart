import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:news/Helper/Color.dart';
import 'package:news/Helper/Demo_Localization.dart';
import 'package:news/Helper/Session.dart';
import 'package:news/Helper/Theme.dart';
import 'package:news/Home.dart';
import 'package:news/Splash.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Helper/Constant.dart';
import 'Helper/PushNotificationService.dart';
import 'Helper/String.dart';
import 'Home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  MobileAds.instance.initialize();
  /* await MobileAds.instance
    ..initialize()
    ..updateRequestConfiguration(RequestConfiguration(
      testDeviceIds: <String>['BFD1F931B199DECC945563CDCB33971B'],
    )); */

  await Firebase.initializeApp();
  /* SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // status bar color
  )); */
  SharedPreferences prefs = await SharedPreferences.getInstance();

  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeNotifier>(create: (BuildContext context) {
          String? theme = prefs.getString(APP_THEME);
          if (theme == DARK) {
            isDark = true;
            prefs.setString(APP_THEME, DARK);
          } else if (theme == LIGHT) {
            isDark = false;
            prefs.setString(APP_THEME, LIGHT);
          }

          if (theme == null || theme == "" || theme == SYSTEM) {
            prefs.setString(APP_THEME, SYSTEM);
            var brightness =
                SchedulerBinding.instance.window.platformBrightness;
            print(
                "@Start - ${brightness} & theme mode is ${ThemeMode.system} ");
            isDark = brightness == Brightness.dark;
            return ThemeNotifier(ThemeMode.system);
          }
          return ThemeNotifier(
              theme == LIGHT ? ThemeMode.light : ThemeMode.dark);
        }),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    super.initState();
    Future<SharedPreferences> prefs = SharedPreferences.getInstance();
    prefs.then((value) {
      bool? noti = value.getBool(NOTIENABLE);
      if (noti == null || noti == true) {
        notiEnable = true;
        value.setBool(NOTIENABLE, true);
      } else {
        notiEnable = false;
        value.setBool(NOTIENABLE, false);
      }
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    //uiOverlayStyle
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: (isDark != null && isDark == true)
            ? Brightness.dark
            : Brightness.light,
        statusBarIconBrightness: (isDark != null && isDark == true)
            ? Brightness.light
            : Brightness.dark,
        statusBarColor: colors.transparentColor));
    //notification service
    final pushNotificationService = PushNotificationService(_firebaseMessaging);
    pushNotificationService.initialise();
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    if (this._locale == null) {
      return Container(
        child: Center(child: CircularProgressIndicator()),
      );
    } else {
      return MaterialApp(
        locale: _locale,
        supportedLocales: [
          Locale("en", "US"),
          Locale("es", "ES"),
          Locale("hi", "IN"),
          Locale("tr", "TR"),
          Locale("pt", "PT"),
          Locale('ar', 'DZ'),
          Locale("he", "HE"),
          /* Locale("bn", "ES"),
          Locale("de", "IN"),
          Locale("id", "TR"),
          Locale("it", "PT"),
          Locale('ko', 'DZ'),
          Locale("ru", "US"),
          Locale("ta", "ES"),
          Locale("uk", "IN"),
          Locale("ur", "UR"),
          Locale("zh", "PT"),*/
        ],
        localizationsDelegates: [
          DemoLocalization.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale!.languageCode &&
                supportedLocale.countryCode == locale.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        title: appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: colors.primary,
          splashColor: colors.primary,
          fontFamily: 'Sarabun',
          //'Neue Helvetica',
          canvasColor: colors.bgColor,
          brightness: Brightness.light,
          scaffoldBackgroundColor: colors.bgColor,
          appBarTheme: AppBarTheme(
              elevation: 0.0,
              backgroundColor: colors.transparentColor,
              systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarBrightness: Brightness.light,
                  statusBarIconBrightness: Brightness.dark,
                  statusBarColor: colors.transparentColor)),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: colors.primaryApp)
              .copyWith(
                  secondary: colors.primary, brightness: Brightness.light),
        ),
        darkTheme: ThemeData(
          fontFamily: 'Sarabun',
          primaryColor: colors.secondaryColor,
          splashColor: colors.primary,
          brightness: Brightness.dark,
          canvasColor: colors.darkModeColor,
          scaffoldBackgroundColor: colors.darkModeColor,
          appBarTheme: AppBarTheme(
              elevation: 0.0,
              backgroundColor: colors.transparentColor,
              systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarBrightness: Brightness.dark,
                  statusBarIconBrightness: Brightness.light,
                  statusBarColor: colors.transparentColor)),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: colors.primaryApp)
              .copyWith(secondary: colors.primary, brightness: Brightness.dark),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => Splash(),
          '/home': (context) => Home(),
        },
        themeMode: themeNotifier.getThemeMode(),
      );
    }
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
