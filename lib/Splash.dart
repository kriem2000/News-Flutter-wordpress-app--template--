import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:news/Helper/Color.dart';
import 'package:news/Helper/Constant.dart';
import 'package:news/Helper/String.dart';
import 'package:news/Home.dart';
import 'package:news/IntroPage.dart';

import 'Helper/Session.dart';
import 'Helper/Slideanimation.dart';
import 'package:http/http.dart' as http;

// import 'LanguageList.dart';

class Splash extends StatefulWidget {
  @override
  SplashState createState() => SplashState();
}

class SplashState extends State<Splash> with TickerProviderStateMixin {
  AnimationController? _splashIconController;
  AnimationController? _newsImgController;
  AnimationController? _slideControllerBottom;
  bool isFirst = true;

  double scale = 0;

  String str = "Trending News !!!";
  bool _isNetworkAvail = true;

  double opacity = 0.0;
  Image splashImg = Image.asset(
    "assets/images/splash_Icon.png",
    height: 60.0,
    fit: BoxFit.fill,
  );

  @override
  void initState() {
    super.initState();
    _slideControllerBottom = AnimationController(
        vsync: this, duration: const Duration(seconds: 3)); //4
    _splashIconController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _newsImgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));

    FirebaseMessaging.instance.getToken().then((token) async {
      if (token1 != token) {
        _registerToken(token);
      }
    });
    changeOpacity();
    getSetting();
  }

  changeOpacity() {
    Future.delayed(Duration(milliseconds: 2000), () {
      //2500
      setState(() {
        opacity = opacity == 0.0 ? 1.0 : 0.0;
        navigationPage();
      });
    });
  }

  @override
  void dispose() {
    /*  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]); */
    /*  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values); */
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: (isDark != null && isDark == true)
            ? Brightness.dark
            : Brightness.light,
        statusBarIconBrightness: (isDark != null && isDark == true)
            ? Brightness.light
            : Brightness.dark,
        statusBarColor: colors.transparentColor));
    _splashIconController!.dispose();
    _newsImgController!.dispose();
    _slideControllerBottom!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    str = getTranslated(context, 'fast_trend_news_lbl')!;
    /*  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]); */
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(backgroundColor: colors.bgColor, body: buildScale());
  }

  //navigate page route
  Future<void> navigationPage() async {
    Future.delayed(Duration(seconds: 3), () async {
      bool isFirstTime = await getPrefrenceBool(ISFIRSTTIME);
      if (isFirstTime) {
        Navigator.pushReplacement(
            context, CupertinoPageRoute(builder: (context) => Home()));
      } else {
        Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
                builder: (context) =>
                    IntroSliderScreen() /* LanguageList(from: 1,)) */));
      }
    });
  }

  Widget buildScale() {
    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.only(top: 2 * kToolbarHeight),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topRight: Radius.circular(200)),
        color: colors.secondaryColor,
      ),
      child: Column(children: [
        SizedBox(height: 100),
        Padding(
            //splash Icon
            padding: EdgeInsetsDirectional.only(end: 50.0),
            child: SlideAnimation(
              position: 2,
              itemCount: 3,
              slideDirection: SlideDirection.fromRight,
              animationController: _splashIconController!,
              child: splashImg,
            )),
        Padding(
            //News Image
            padding: EdgeInsetsDirectional.only(end: 30.0),
            child: Padding(
                padding: EdgeInsets.only(top: 11.0), //7.0
                child: SlideAnimation(
                    position: 3,
                    itemCount: 4,
                    slideDirection: SlideDirection.fromLeft,
                    animationController: _newsImgController!,
                    child: Image.asset(
                      "assets/images/news.png",
                      height: 30.0, //40.0,
                      fit: BoxFit.fill,
                      color: colors.tempboxColor,
                    )))),
        AnimatedOpacity(
            opacity: opacity,
            duration: Duration(seconds: 1), //2
            child: Container(
              margin: new EdgeInsetsDirectional.only(top: 20.0), //25.0
              child: Text(str,
                  style: Theme.of(context)
                      .textTheme
                      .headline5!
                      .copyWith(color: colors.tempboxColor)),
            )),
        Spacer(),
        Container(
            //WRTeam logo & text @ bottom
            margin: EdgeInsetsDirectional.only(bottom: 20),
            child: Column(
              children: [
                SlideAnimation(
                  position: 1,
                  itemCount: 2,
                  slideDirection: SlideDirection.fromBottom,
                  animationController: _slideControllerBottom!,
                  child: new Text(
                    getTranslated(context, 'madeBy')!,
                    style: TextStyle(
                      color: colors.tempBorderColor, //lightTextColor,
                    ),
                  ),
                ),
                SizedBox(height: 5),
                SlideAnimation(
                    position: 1,
                    itemCount: 2,
                    slideDirection: SlideDirection.fromBottom,
                    animationController: _slideControllerBottom!,
                    child: Image.asset(
                      "assets/images/wrteam_logo.png",
                      height: 25.0,
                      fit: BoxFit.fill,
                    ))
              ],
            ))
      ]),
    );
  }

  getTextAnim() {
    return Container(
      margin: new EdgeInsetsDirectional.only(top: 25.0),
      child: TweenAnimationBuilder<int>(
        builder: (context, value, child) {
          return Text(
            str.substring(0, value),
            style: Theme.of(context)
                .textTheme
                .headline5!
                .copyWith(color: colors.tempboxColor),
          );
        },
        duration: Duration(seconds: 3),
        tween: IntTween(begin: 0, end: str.length),
      ),
    );
  }

  void _registerToken(String? token) async {
    try {
      Map<String, String> body = {
        ACCESS_KEY: access_key,
        "token": token!,
      };
      Response response =
          await post(Uri.parse(setRegisterToken), body: body, headers: headers)
              .timeout(Duration(seconds: timeOut));
      var getdata = json.decode(response.body);
      print(getdata);
      token1 = token;
    } on Exception catch (_) {}
  }

  Future<void> getSetting() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var param = {
          ACCESS_KEY: access_key,
        };
        http.Response response = await http
            .post(Uri.parse(getSettingApi), body: param, headers: headers)
            .timeout(Duration(seconds: timeOut));
        // print("Params ->  ${response.request}");
        if (response.statusCode == 200) {
          var getData = json.decode(response.body);
          String error = getData["error"];
          if (error == "false") {
            var data = getData["data"];
            // print("Settings API Response = $data");
            breakingNews_mode = data[BREAK_NEWS_MODE];
            liveStreaming_mode = data[LIVE_STREAM_MODE];
            category_mode = data[CATEGORY_MODE];
            subCategory_mode = data[SUBCAT_MODE];
            // print("Category mode is enabled/Disabled -- $category_mode");
            comments_mode = data[COMM_MODE];
            in_app_ads_mode = data[ADS_MODE];
            ios_in_app_ads_mode = data[IOS_ADS_MODE];

            if (in_app_ads_mode != "0") {
              print("data adstype*****${data[ADS_TYPE]}");
              ads_type = data[ADS_TYPE];
              print("ads type*****$ads_type");
              if (ads_type == "2") {
                //FB ADS
                if (data.toString().contains(FB_REWARDED_ID)) {
                  fbRewardedVideoId = data[FB_REWARDED_ID];
                }
                if (data.toString().contains(FB_INTER_ID)) {
                  fbInterstitialId = data[FB_INTER_ID];
                }
                if (data.toString().contains(FB_BANNER_ID)) {
                  fbBannerId = data[FB_BANNER_ID];
                }
                if (data.toString().contains(FB_NATIVE_ID)) {
                  fbNativeUnitId = data[FB_NATIVE_ID];
                }
              } else if (ads_type == "1") {
                //GOOGLE ADMOB ADS
                if (data.toString().contains(GO_REWARDED_ID)) {
                  goRewardedVideoId = data[GO_REWARDED_ID];
                }
                if (data.toString().contains(GO_INTER_ID)) {
                  goInterstitialId = data[GO_INTER_ID];
                }
                if (data.toString().contains(GO_BANNER_ID)) {
                  goBannerId = data[GO_BANNER_ID];
                }
                if (data.toString().contains(GO_NATIVE_ID)) {
                  goNativeUnitId = data[GO_NATIVE_ID];
                }
              } else {
               /* ads_type =
                "3";*/
                //UNITY ADS
                 if (data.toString().contains(U_REWARDED_ID)) {
                  unityRewardedVideoId = data[U_REWARDED_ID];
                }
                if (data.toString().contains(U_INTER_ID)) {
                  unityInterstitialId = data[U_INTER_ID];
                }
                if (data.toString().contains(GO_BANNER_ID)) {
                  unityBannerId = data[U_BANNER_ID];
                }
                 if (data.toString().contains(U_AND_GAME_ID)) {
                   unityGameID = data[U_AND_GAME_ID];
                 }
                //unComment once setting done @ Backend
              }
            }
             //temp //unComment if wants to use Ads as set @ Backend
            if (ios_in_app_ads_mode != "0") {
              ios_ads_type = data[IOS_ADS_TYPE];
              if (ios_ads_type == "2") {
                //FB ADS
                if (data.toString().contains(IOS_FB_REWARDED_ID)) {
                  iosFbRewardedVideoId = data[IOS_FB_REWARDED_ID];
                }
                if (data.toString().contains(IOS_FB_INTER_ID)) {
                  iosFbInterstitialId = data[IOS_FB_INTER_ID];
                }
                if (data.toString().contains(IOS_FB_BANNER_ID)) {
                  iosFbBannerId = data[IOS_FB_BANNER_ID];
                }
                if (data.toString().contains(IOS_FB_NATIVE_ID)) {
                  iosFbNativeUnitId = data[IOS_FB_NATIVE_ID];
                }
              } else if (ios_ads_type == "1") {
                //GOOGLE ADMOB ADS
                if (data.toString().contains(IOS_GO_REWARDED_ID)) {
                  iosGoRewardedVideoId = data[IOS_GO_REWARDED_ID];
                }
                if (data.toString().contains(IOS_GO_INTER_ID)) {
                  iosGoInterstitialId = data[IOS_GO_INTER_ID];
                }
                if (data.toString().contains(IOS_GO_BANNER_ID)) {
                  iosGoBannerId = data[IOS_GO_BANNER_ID];
                }
                if (data.toString().contains(IOS_GO_NATIVE_ID)) {
                  iosGoNativeUnitId = data[IOS_GO_NATIVE_ID];
                }
              } else {
                //UNITY ADS
                if (data.toString().contains(IOS_U_REWARDED_ID)) {
                  iosUnityRewardedVideoId = data[IOS_U_REWARDED_ID];
                }
                if (data.toString().contains(IOS_U_INTER_ID)) {
                  iosUnityInterstitialId = data[IOS_U_INTER_ID];
                }
                if (data.toString().contains(IOS_U_BANNER_ID)) {
                  iosUnityBannerId = data[IOS_U_BANNER_ID];
                }
                if (data.toString().contains(IOS_U_GAME_ID)) {
                  iosUnityGameID = data[IOS_U_GAME_ID];
                }
              }
            }
          }
        }
      } on TimeoutException catch (_) {
        showSnackBar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      showSnackBar(getTranslated(context, 'internetmsg')!, context);
    }
  }
}
