import 'dart:async';
import 'dart:convert';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:http/http.dart' as http;
import 'package:news/Model/BreakingNews.dart';
import 'package:news/NewsVideo.dart';

import 'package:news/Videos.dart';
import 'package:news/Helper/Color.dart';
import 'package:news/Helper/Constant.dart';
import 'package:news/Helper/Session.dart';
import 'package:news/Helper/String.dart';
import 'package:news/HomePage.dart';
import 'package:news/Model/News.dart';
import 'package:news/NotificationList.dart';
import 'package:news/Setting.dart';
import 'package:news/categories.dart';
import 'Helper/PushNotificationService.dart';
import 'Model/Category.dart';
import 'NewsDetails.dart';
import 'main.dart';

List<News> videoItems = [];
List<Category> catList = [];

String adv_type = "";
// late BannerAd bannerAd;

DateTime loginClickTime = DateTime.now();

class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Widget> fragments = [];
  DateTime? currentBackPressTime;
  bool _isNetworkAvail = true;

  int _selectedIndex = 0;

  List<IconData> iconList = [
    Icons.home_rounded,
    Icons.video_collection_rounded,
    if (category_mode == "1") Icons.grid_view_rounded,
    //Add only if Category Mode is enabled From Admin panel.
    Icons.notifications_rounded,
    Icons.settings_rounded,
  ];

  bool isLoading = true;
  String isBrNews = "false";

  @override
  void initState() {
    super.initState();
    // getSetting();
    getUserDetails();
    initDynamicLinks();
    fragments = [
      HomePage(),
      Videos(
        isBackRequired: false,
      ),
      if (category_mode == "1") Categories(),
      //Add only if Category Mode is enabled From Admin panel.//DemoVideos(),
      NotificationList(),
      Setting(),
    ];
    firNotificationInitialize();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getUserDetails() async {
    CUR_USERID = (await getPrefrence(ID)) ?? "";
    CATID = (await getPrefrence(cur_catId)) ?? "";

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    /* SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]); */
    /*  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: (isDark != null && isDark == true)
            ? Brightness.dark
            : Brightness.light,
        statusBarIconBrightness: (isDark != null && isDark == true)
            ? Brightness.light
            : Brightness.dark,
        statusBarColor: colors.transparentColor)); */
    return WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: colors.bgColor,
          extendBody: true,
          bottomNavigationBar: bottomBar(),
          body: IndexedStack(
            children: fragments,
            index: _selectedIndex,
          ),
        ));
  }

  void firNotificationInitialize() {
    //for firebase push notification
    FlutterLocalNotificationsPlugin();
// initialise the plugin. ic_launcher needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true);
    final MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: initializationSettingsMacOS);

    PushNotificationService.flutterLocalNotificationsPlugin.initialize(
        initializationSettings, onSelectNotification: (String? payload) async {
      if (payload != null && payload != "") {
        debugPrint('notification payload: $payload');
        getNewsById(payload, "0", isBrNews);
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
        );
      }
    });
  }

  //when home page in back click press
  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (_selectedIndex != 0) {
      _selectedIndex = 0;

      return Future.value(false);
    } else if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      showSnackBar(getTranslated(context, 'EXIT_WR')!, context);

      return Future.value(false);
    }
    return Future.value(true);
  }

  /* onItemTapped(index) async {
    print("function called ONTAP");
    setState(() {
      _selectedIndex = index;
    });
  } */

  //when dynamic link share that's open in app used this function
  void initDynamicLinks() async {
    // when app is open or in background then this method will be called
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLink) {
      final Uri? deepLink = dynamicLink.link;

      if (deepLink != null) {
        if (deepLink.queryParameters.length > 0) {
          String id = deepLink.queryParameters['id']!;
          String index = deepLink.queryParameters['index']!;
          String isVideoID = deepLink.queryParameters['isVideoId']!;
          String isBreakingNews = deepLink.queryParameters['isBreakingNews']!;
          isBrNews = isBreakingNews;
          //to use it in Firebase payload in same file
          getNewsById(id, index, isBreakingNews, isVideoID: isVideoID);
        }
      }
    }, onError: (e) async {
      print(e.toString());
    });

    // when your App Is Killed Or Open From Play store then this method will be called
    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();

    if (data != null) {
      final Uri deepLink = data.link;
      if (deepLink.queryParameters.length > 0) {
        String id = deepLink.queryParameters['id']!;
        String index = deepLink.queryParameters['index']!;
        String isVideoID = deepLink.queryParameters['isVideoId']!;
        String isBreakingNews = deepLink.queryParameters['isBreakingNews']!;
        isBrNews = isBreakingNews;
        getNewsById(id, index, isBreakingNews, isVideoID: isVideoID);
      }
    }
  }

  //when open dynamic link news index and id can used for fetch specific news
  Future<void> getNewsById(String id, String index, String isBreakingNews,
      {String? isVideoID}) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      var param = (isBreakingNews == "true")
          ? {ACCESS_KEY: access_key}
          : {
              NEWS_ID: id,
              ACCESS_KEY: access_key,
              // ignore: unnecessary_null_comparison
              USER_ID: CUR_USERID != null && CUR_USERID != "" ? CUR_USERID : "0"
            };
      var apiName =
          (isBreakingNews == "true") ? getBreakingNewsApi : getNewsByIdApi;
      http.Response response = await http
          .post(Uri.parse(apiName), body: param, headers: headers)
          .timeout(Duration(seconds: timeOut));
      var getdata = json.decode(response.body);

      String error = getdata["error"];

      if (error == "false") {
        var data = getdata["data"];

        List<News> news = [];
        List<BreakingNewsModel> brNews = [];
        (isBreakingNews == "true")
            ? brNews = (data as List)
                .map((data) => new BreakingNewsModel.fromJson(data))
                .toList()
            : news =
                (data as List).map((data) => new News.fromJson(data)).toList();

        if (isVideoID == 'true') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NewsVideo(model: news[0],from: 1,)));
        } else if (isBreakingNews == "true") {
          // int indexVal = index;
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => NewsDetails(
                    model1: brNews[int.parse(index)],
                    index: int.parse(index), //int.parse(id),
                    id: id, //brNews[0].id,
                    isDetails: false,
                    news1: [],
                  )));
        } else {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => NewsDetails(
                    model: news[0],
                    index: int.parse(index), //int.parse(id),
                    id: news[0].id,
                    // isFav: false,
                    isDetails: true,
                    news: [],
                  )));
        }
      }
    } else {
      showSnackBar(getTranslated(context, 'internetmsg')!, context);
    }
  }

  Widget buildNavBarItem(IconData icon, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        height: 60,
        width: MediaQuery.of(context).size.width / iconList.length,
        decoration: index == _selectedIndex
            ? BoxDecoration(
                border: Border(
                  top: BorderSide(width: 3, color: colors.primary),
                ),
              )
            : BoxDecoration(),
        child: Icon(
          icon,
          color:
              index == _selectedIndex ? colors.primary : colors.disabledColor,
        ),
      ),
    );
  }

  bottomBar() {
    List<Widget> _navBarItemList = [];
    for (var i = 0; i < iconList.length; i++) {
      _navBarItemList.add(buildNavBarItem(iconList[i], i));
    }

    return Padding(
        padding: EdgeInsetsDirectional.zero,
        child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.lightColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0)),
              boxShadow: [
                BoxShadow(
                    blurRadius: 6, //10.0,
                    offset: const Offset(5.0, 5.0),
                    color: Theme.of(context)
                        .colorScheme
                        .fontColor
                        .withOpacity(0.4),
                    spreadRadius: 0),
              ],
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0)),
                child: Row(
                  children: _navBarItemList,
                ))));
  }
}
