// ignore_for_file: argument_type_not_assignable_to_error_handler, invalid_return_type_for_catch_error, unused_local_variable

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:http/http.dart';
import 'package:news/Helper/FbAdHelper.dart'; //fbAud
import 'package:flutter/material.dart';

// import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:location/location.dart' as loc;
import 'package:news/Helper/AdHelper.dart';
import 'package:news/Helper/Color.dart';
import 'package:news/Helper/Constant.dart';
import 'package:news/Helper/Session.dart';
import 'package:news/Helper/String.dart';
import 'package:news/Helper/Widgets.dart';
import 'package:news/Helper/unityAdHelper.dart';
import 'package:news/Home.dart';
import 'package:news/Model/BreakingNews.dart';
import 'package:news/Model/LiveStreaming.dart';
import 'package:news/Model/News.dart';
import 'package:news/NewsTag.dart';
import 'package:news/NewsVideo.dart';
import 'package:news/Search.dart';

// import 'package:news/SubHome.dart';
import 'package:news/Videos.dart';
import 'package:news/subCategories.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'Live.dart';
import 'Model/Category.dart';
import 'Model/WeatherData.dart';
import 'NewsDetails.dart';
import 'ShowMoreNewsList.dart';

// StreamController<List<Category>>? chatstreamdata;

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  List<News> tempList = [];
  List<News> mainlist = [];
  List<BreakingNewsModel> tempBreakList = [];
  List<BreakingNewsModel> breakingNewsList = [];
  WeatherData? weatherData;
  loc.Location _location = new loc.Location();
  String? error;
  bool? _serviceEnabled;
  loc.PermissionStatus? _permissionGranted;
  final TextEditingController textController = TextEditingController();
  int totalRecent = 0;
  int offsetUser = 0;
  int totalUser = 0;
  String? catId = "";
  List<News> recentNewsList = [];
  List<News> normalNewsList = [];
  List<News> recenttempList = [];
  List<News> tempUserNews = [];
  List<News> userNewsList = [];
  List<News> catNewsList = [];
  List<News> bookmarkList = [];
  List<News> newsList = [];
  List<News> tempNewsList = [];
  List<News> tempNews2AllList = [];
  List<LiveStreamingModel> liveList = [];

  // List<String> tagId = [];
  // List<String> tagList = [];

  bool _isBreakLoading = true;
  bool _isUserLoading = true;
  bool _isUserLoadMore = true;
  bool _isRecentLoading = true;
  bool _isRecentLoadMore = true;
  bool isVideoLoading = false;
  int offsetVal = 0;
  bool isLoading = true;
  bool isLoadingMore = true;
  bool _isNetworkAvail = true;
  bool weatherLoad = true;
  List<Category> catList = [];
  int tcIndex = 0;
  int fbAdIndex = 5;
  int goAdIndex = 5;
  var scrollController = ScrollController();
  List bookMarkValue = [];
  List<String> allImage = [];
  int? selectSubCat = 0;
  bool isFirst = false;
  bool? isliveNews = false;

  int offset = 0;
  int total = 0;
  bool enabled = true;
  ScrollController controller = new ScrollController();
  bool isTab = true;
  var dataa;
  final _controller = PageController();
  List<String> coverageImage = [];
  int sliderIndex = 0;
  late BannerAd _bannerAd; //fbAud
  // bool isTapped = false;
  // bool isTapped2 = false;

  int len = 2;
  var subCat = <Category, List<News>>{};

  // ignore: unused_field
  bool _isBannerAdReady = true; //false;

  @override
  void initState() {
    super.initState();
    loadWeather();
    callApi();
    //check if ads are Enabled or not !!
    if (in_app_ads_mode == "1") {
      if (Platform.isIOS) {
        if (ios_ads_type == "1") {
          //google ads
          adv_type = "google";
        } else if (ios_ads_type == "2") {
          //fb ads
          adv_type = "fb";
        } else {
          adv_type = "unity";
        }
      } else {
        if (ads_type == "1") {
          //google ads
          adv_type = "google";
        } else if (ads_type == "2") {
          //fb ads
          adv_type = "fb";
        } else {
          adv_type = "unity";
        }
      }
    }

    print(" adv_type is - ${adv_type}");
    if (adv_type == "google") {
      if (AdHelper.bannerAdUnitId != "") {
        createBannerAd();
      }
    }
    if (adv_type == "fb") {
      FbAdHelper.fbInit(); //fbAud
    }
  }

  @override
  void dispose() {
    // if (_isBannerAdReady) _bannerAd.dispose(); //fbAud
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /* !isDark!
        ? SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark)
        : SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light); */
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        key: _scaffoldKey,
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refresh,
          child: ListView(
            padding: EdgeInsetsDirectional.only(
                top: MediaQuery.of(context).padding.top,
                start: 15.0,
                end: 15.0,
                bottom: 10.0),
            children: [
              liveWithSearchView(),
              weatherDataView(),
              if (breakingNews_mode == "1") viewBreakingNews(),
              //show only if Breaking News Enabled from admin panel > System Settings
              viewRecentContent(),
              if (CUR_USERID != "" && CATID != "" && userNewsList.length > 0)
                viewUserNewsContent(),
              //For You
              // : SizedBox.shrink(),
              getNewsList(),
              getNormalNewsList2(),
              if (category_mode == "1") showCategoriesData(0),
              Divider(),
              showCoverage(),
              showVideos(),
              if (category_mode == "1") showCategoriesData(1),
              Divider(),
              getNormalNewsList(),
              SizedBox(height: MediaQuery.of(context).size.height / 10.0),
            ],
          ),
        ));
  }

  //refresh function to refresh page
  Future<String> _refresh() async {
    setState(() {
      isLoading = true;
    });
    return reCallAPI();
  }

  reCallAPI() {
    offset = 0;
    total = 0;
    catList.clear(); //to reload getCat()
    callApi();
  }

//fbAud
  /*  void _createBottomBannerAd() {
    if (goBannerId != "" || iosGoBannerId != "") {
      print("in banner");
      _bannerAd = BannerAd(
        adUnitId: AdHelper.bannerAdUnitId,
        request: AdRequest(),
        size: AdSize.fullBanner,
        listener: BannerAdListener(
          onAdLoaded: (_) {
            setState(() {
              _isBannerAdReady = true;
            });
          },
          onAdFailedToLoad: (ad, err) {
            _isBannerAdReady = false;
            ad.dispose();
          },
        ),
      );

      _bannerAd.load();
    }
  } */
//fbAud
  BannerAd createBannerAd() {
    // if (AdHelper.bannerAdUnitId != "") {
    _bannerAd = BannerAd(
      adUnitId:
          AdHelper.bannerAdUnitId, //'ca-app-pub-3940256099942544/6300978111',
      request: AdRequest(),
      size: AdSize.mediumRectangle, //fullBanner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          // setState(() {
          //   _isBannerAdReady = true;
          print("Native ad is Loaded !!!");
          // });
        },
        onAdFailedToLoad: (ad, err) {
          setState(() {
            _isBannerAdReady = false;
          });
          print("error in loading Native ad $err");
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('Native ad opened.'),
        // Called when an ad opens an overlay that covers the screen.
        onAdClosed: (Ad ad) => print('Native ad closed.'),
        // Called when an ad removes an overlay that covers the screen.
        onAdImpression: (Ad ad) => print('Native ad impression.'),
      ),
    );

    // _bannerAd.load();
    // }
    print("banner ad ready bool - $_isBannerAdReady");
    return _bannerAd;
  }

//fbAud
  /*  Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // Unique ID on iOS
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // Unique ID on Android
    }
  } */

  /* fbInit() async {
    String? deviceId = await _getId();
    List<String> testDeviceIds = [deviceId!];
    FacebookAudienceNetwork.init(
        iOSAdvertiserTrackingEnabled: true, testingId: deviceId);
  } */
  //fbAud

  loadWeather() async {
    loc.LocationData locationData;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled!) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled!) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }
    locationData = await _location.getLocation();

    error = null;

    final lat = locationData.latitude;
    final lon = locationData.longitude;
    final weatherResponse = await http.get(Uri.parse(
        'https://api.weatherapi.com/v1/forecast.json?key=d0f2f4dbecc043e78d6123135212408&q=${lat.toString()},${lon.toString()}&days=1&aqi=no&alerts=no'));

    if (weatherResponse.statusCode == 200) {
      if (this.mounted)
        return setState(() {
          weatherData =
              new WeatherData.fromJson(jsonDecode(weatherResponse.body));
          weatherLoad = false;
        });
    }

    setState(() {
      weatherLoad = false;
    });
  }

  void _animateSlider() {
    Future.delayed(const Duration(seconds: 10)).then((_) {
      if (mounted) {
        int nextPage = _controller.hasClients
            ? _controller.page!.round() + 1
            : _controller.initialPage;

        if (nextPage == normalNewsList.length) {
          nextPage = 0;
        }
        if (_controller.hasClients) {
          _controller
              .animateToPage(nextPage,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.linear)
              .then((_) {
            _animateSlider();
          });
        }
      }
    });
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  Widget showCoverage() {
    return Column(
      children: [
        Stack(
          children: [
            SizedBox(
              height: deviceHeight! / 2.9,
              width: double.infinity,
              child: PageView.builder(
                itemCount: normalNewsList.length,
                scrollDirection: Axis.horizontal,
                physics: const AlwaysScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    sliderIndex = index;
                  });
                },
                itemBuilder: (BuildContext context, int index) {
                  return Stack(
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15.0),
                              topRight: Radius.circular(15.0)),
                          child: ShaderMask(
                            shaderCallback: (rect) {
                              return LinearGradient(
                                begin: Alignment.center,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  colors.secondaryColor.withOpacity(0.85)
                                ],
                              ).createShader(rect);
                            },
                            blendMode: BlendMode.darken,
                            child: GestureDetector(
                              child: CachedNetworkImage(
                                fadeInDuration: Duration(milliseconds: 150),
                                imageUrl: normalNewsList[index].image!,
                                height: deviceHeight! / 2.9,
                                width: deviceWidth!,
                                fit: BoxFit.cover,
                                errorWidget: (context, error, stackTrace) =>
                                    errorWidget(deviceHeight! / 5.9,
                                        deviceWidth! / 2.2),
                                placeholder: (context, url) {
                                  return placeHolder();
                                },
                              ),
                              onTap: () {
                                //goto DetailsScreen
                                News model = normalNewsList[index];
                                List<News> newsList = [];
                                newsList.addAll(normalNewsList);
                                newsList.removeAt(index);
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        NewsDetails(
                                          model: model,
                                          index: index,
                                          updateParent: updateHomePage,
                                          id: model.id,
                                          //isFav: false,
                                          isDetails: true,
                                          news: newsList,
                                        )));
                              },
                            ),
                          )),
                      Align(
                          //text
                          alignment: Alignment.bottomLeft, //bottomCenter,
                          child: Container(
                              padding: EdgeInsetsDirectional.only(
                                  bottom: deviceHeight! / 18.9,
                                  start: deviceWidth! / 20.0,
                                  end: 5.0),
                              width: deviceWidth,
                              //TITLE
                              child: Text(
                                normalNewsList[index].title!,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2
                                    ?.copyWith(
                                        color: colors.tempboxColor,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12.5,
                                        height: 1.0),
                                maxLines: 1,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ))),
                    ],
                  );
                },
              ),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(top: deviceHeight! / 3.3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: map<Widget>(
                      normalNewsList,
                      (index, url) {
                        return AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            width: sliderIndex == index
                                ? deviceWidth! / 15.0
                                : deviceWidth! / 15.0,
                            height: 5.0,
                            margin: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 2.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: sliderIndex == index
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary //.fontColor
                                  : /* Theme.of(context)
                                      .colorScheme
                                      .agoLabel */
                                  colors.coverageUnSelColor.withOpacity(0.7),
                            ));
                      },
                    ),
                  ),
                )),
          ],
        ),
        Container(
            height: 38.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15.0),
                  bottomRight: Radius.circular(15.0)),
              color: Theme.of(context).colorScheme.coverage.withOpacity(0.9),
              boxShadow: [
                BoxShadow(
                    color: colors.shadowColor,
                    offset: const Offset(0.0, 2.0),
                    blurRadius: 6.0,
                    spreadRadius: 0)
              ],
            ),
            child: ElevatedButton.icon(
              icon: setCoverageIcon(context),
              label: setCoverageText(context),
              onPressed: () {
                //goto ShowMoreNewsList
                News model = normalNewsList[0];
                List<News> newsList = [];
                newsList.addAll(normalNewsList);
                String str1 = getTranslated(context, 'all_lbl')!;
                String str2 = getTranslated(context, 'news_lbl')!;
                String concatStr = str1 + " " + str2;
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => ShowMoreNewsList(
                          model: model,
                          index: 0,
                          updateParent: updateHomePage,
                          id: model.id,
                          //isFav: false,
                          isDetails: true,
                          news: newsList,
                          newsType: concatStr,
                        )));
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.transparent,
                onPrimary: colors.primary,
                shadowColor: Colors.transparent,
              ),
            )),
      ],
    );
  }

  Future<void> callApi() async {
    getUserByID();
    await getLiveNews();
    if (breakingNews_mode == "1")
      await getBreakingNews(); //show only if Breaking News Enabled from admin panel > System Settings
    await getNews();
    await getCatNewsByUser();
    await getNewsVideoURL();
    await getCat();
    await _getBookmark();
    _animateSlider();
  }

  Future<void> getUserByID() async {
    if (CUR_USERID != "") {
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        var param = {
          ACCESS_KEY: access_key,
          USER_ID: CUR_USERID,
        };
        Response response =
            await post(Uri.parse(getUserByIdApi), body: param, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        String error = getdata["error"];
        if (error == "false") {
          var data = getdata["data"];
          setState(() {
            String catId = data[0]["category_id"];
            setPrefrence(cur_catId, catId);
          });
          CUR_USERID = data[0][ID];
          CUR_USERNAME = data[0][NAME];
          CUR_USEREMAIL = data[0][EMAIL];
          saveUserDetail(
              data[0][ID],
              data[0][NAME],
              data[0][EMAIL],
              data[0][MOBILE],
              data[0][PROFILE],
              data[0][TYPE],
              data[0][STATUS],
              data[0][ROLE]);
        }
      } else {
        showSnackBar(getTranslated(context, 'internetmsg')!, context);
      }
    }
  }

//Widgets
  Widget liveWithSearchView() {
    return Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: Row(
          children: [
            /* liveStreaming_mode == "1" &&
                    isliveNews != "" &&
                    isliveNews != null //whether Live button is present or not
                ? */
            Expanded(
                //Live button is present
                flex: 9,
                child: InkWell(
                  child: Container(
                      alignment: Alignment.centerLeft,
                      height: (isliveNews! || isliveNews != null) ? 40 : 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        color: Theme.of(context).colorScheme.controlBGColor,
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.only(start: 10.0),
                            child: Icon(Icons.search_rounded,
                                color: Theme.of(context)
                                    .colorScheme
                                    .fontColor
                                    .withOpacity(0.4)),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.only(start: 10.0),
                            child: Text(
                              getTranslated(context, 'search_home_news')!,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .fontColor
                                      .withOpacity(0.4)),
                            ),
                          ),
                        ],
                      )),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => Search()));
                  },
                )),
            /*  : InkWell(
                    //Live button is not present
                    child: Container(
                        alignment: Alignment.center,
                        height: 60,
                        width: deviceWidth! - 30,
                        child: Padding(
                            padding: EdgeInsetsDirectional.only(start: 0.0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_rounded),
                                ]))),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => Search()));
                    },
                  ), */
            if (liveStreaming_mode == "1" && isliveNews! && isliveNews != null)
              Expanded(
                  flex: 3,
                  child: InkWell(
                    child: Padding(
                        padding: EdgeInsetsDirectional.only(start: 10.0),
                        child: Container(
                            height: 60,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  isDark!
                                      ? "assets/images/live_news_dark.svg"
                                      : "assets/images/live_news.svg",
                                  height: 30.0,
                                  width: 54.0,
                                ),
                              ],
                            ))),
                    onTap: () {
                      if (_isNetworkAvail) {
                        if (isliveNews! && isliveNews != null) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Live(liveNews: liveList),
                              ));
                        }
                      } else {
                        showSnackBar(
                            getTranslated(context, 'internetmsg')!, context);
                      }
                    },
                  ))
            // : SizedBox.shrink(),
          ],
        ));
  }

  Widget weatherDataView() {
    DateTime now = DateTime.now();
    String day = DateFormat('EEEE').format(now);
    return !weatherLoad
        ? Container(
            margin: EdgeInsetsDirectional.only(top: 15.0),
            padding: EdgeInsets.all(15.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Theme.of(context).colorScheme.controlBGColor,
            ),
            height: 110,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Column(
                    children: <Widget>[
                      Text(
                        getTranslated(context, 'weather_lbl')!,
                        style: Theme.of(this.context)
                            .textTheme
                            .subtitle2
                            ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .fontColor
                                  .withOpacity(0.8),
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                      if (weatherData != null)
                        Row(
                          children: <Widget>[
                            Image.network(
                              "https:${weatherData!.icon!}",
                              width: 40.0,
                              height: 40.0,
                            ),
                            Padding(
                                padding: EdgeInsetsDirectional.only(start: 7.0),
                                child: Text(
                                  "${weatherData!.tempC!.toString()}\u2103",
                                  style: Theme.of(this.context)
                                      .textTheme
                                      .headline6
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor
                                            .withOpacity(0.8),
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  maxLines: 1,
                                ))
                          ],
                        )
                      // : SizedBox.shrink()
                    ],
                  ),
                ),
                Spacer(),
                if (weatherData != null)
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          "${weatherData!.name!},${weatherData!.region!},${weatherData!.country!}",
                          style: Theme.of(this.context)
                              .textTheme
                              .subtitle2
                              ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.fontColor,
                                  fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          maxLines: 1,
                        ),
                        Padding(
                            padding: EdgeInsetsDirectional.only(top: 3.0),
                            child: Text(
                              day,
                              style: Theme.of(this.context)
                                  .textTheme
                                  .caption
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .fontColor
                                        .withOpacity(0.8),
                                  ),
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              maxLines: 1,
                            )),
                        Padding(
                            padding: EdgeInsetsDirectional.only(top: 3.0),
                            child: Text(
                              weatherData!.text!,
                              style: Theme.of(this.context)
                                  .textTheme
                                  .caption
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .fontColor
                                        .withOpacity(0.8),
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            )),
                        Expanded(
                          child: Padding(
                              padding: EdgeInsetsDirectional.only(top: 3.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Icon(Icons.arrow_upward_outlined,
                                      size: 13.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .fontColor),
                                  Text(
                                    "H:${weatherData!.maxTempC!.toString()}\u2103",
                                    style: Theme.of(this.context)
                                        .textTheme
                                        .caption
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .fontColor
                                              .withOpacity(0.8),
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                  ),
                                  Padding(
                                      padding: EdgeInsetsDirectional.only(
                                          start: 8.0),
                                      child: Icon(Icons.arrow_downward_outlined,
                                          size: 13.0,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .fontColor)),
                                  Text(
                                    "L:${weatherData!.minTempC!.toString()}\u2103",
                                    style: Theme.of(this.context)
                                        .textTheme
                                        .caption
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .fontColor
                                              .withOpacity(0.8),
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                  ),
                                ],
                              )),
                        )
                      ],
                    ),
                  )
                //: SizedBox.shrink()
              ],
            ))
        : SizedBox.shrink(); //weatherShimmer();
  }

  //supported Function
  weatherShimmer() {
    return Container(
      margin: EdgeInsetsDirectional.only(top: 15.0),
      child: Shimmer.fromColors(
          baseColor: Colors.grey.withOpacity(0.4),
          highlightColor: Colors.grey.withOpacity(0.4),
          child: Container(
            height: 98,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Theme.of(context).colorScheme.lightColor,
            ),
          )),
    );
  }

  breakingNewsItem(int index) {
    //breaking News Data
    return Padding(
      padding: EdgeInsetsDirectional.only(
          top: 15.0, start: index == 0 ? 0 : deviceWidth! / 20.0),
      child: InkWell(
        child: Stack(
          children: <Widget>[
            ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: ShaderMask(
                  shaderCallback: (rect) {
                    return LinearGradient(
                      begin: Alignment.center,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        colors.secondaryColor.withOpacity(0.85)
                      ],
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.darken,
                  child: CachedNetworkImage(
                    fadeInDuration: Duration(milliseconds: 150),
                    imageUrl: breakingNewsList[index].image!,
                    height: deviceHeight! / 5.9,
                    width: deviceWidth! / 2.2,
                    fit: BoxFit.cover,
                    errorWidget: (context, error, stackTrace) =>
                        errorWidget(deviceHeight! / 5.9, deviceWidth! / 2.2),
                    placeholder: (context, url) {
                      return placeHolder();
                    },
                  ),
                )),
            Positioned.directional(
                textDirection: Directionality.of(context),
                bottom: 7.0,
                start: 7,
                end: 7,
                height: 62,
                child: Container(
                  alignment: Alignment.bottomLeft, //bottomCenter,
                  padding: EdgeInsetsDirectional.only(start: 10.0, end: 10.0),
                  child: Text(
                    breakingNewsList[index].title!,
                    style: Theme.of(context).textTheme.subtitle2?.copyWith(
                        color: colors.tempboxColor.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                        height: 1.0),
                    maxLines: 3,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
          ],
        ),
        onTap: () {
          BreakingNewsModel model = breakingNewsList[index];
          List<BreakingNewsModel> tempBreak = [];
          tempBreak.addAll(breakingNewsList);
          tempBreak.removeAt(index);
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => NewsDetails(
                    model1: model,
                    index: index,
                    updateParent: updateHomePage,
                    id: model.id,
                    //isFav: false,
                    isDetails: false,
                    news1: tempBreak,
                  )));
        },
      ),
    );
  }

  Widget viewBreakingNews() {
    //Breaking news Section
    return Padding(
        padding: EdgeInsetsDirectional.only(
          top: 15.0,
        ),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                      padding: EdgeInsetsDirectional.zero, //.only(start: 8.0),
                      child: Text(
                        getTranslated(context, 'breakingNews_lbl')!,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .fontColor
                                    .withOpacity(0.9),
                                fontWeight: FontWeight.w600),
                      )),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      //goto ShowMoreNewsList
                      BreakingNewsModel model = breakingNewsList[0];
                      List<BreakingNewsModel> tempBreak = [];
                      tempBreak.addAll(breakingNewsList);
                      // tempBreak.remove(0);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => ShowMoreNewsList(
                                model1: model,
                                index: 0,
                                updateParent: updateHomePage,
                                id: model.id,
                                //isFav: false,
                                isDetails: false,
                                news1: tempBreak,
                                newsType:
                                    getTranslated(context, 'breakingNews_lbl')!,
                              )));
                    },
                    child: viewMoreButton(),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.transparent,
                      onPrimary: colors.primary,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                    ),
                  ),
                  /* GestureDetector(
                    onTap: () {
                      //goto ShowMoreNewsList
                      BreakingNewsModel model = breakingNewsList[0];
                      List<BreakingNewsModel> tempBreak = [];
                      tempBreak.addAll(breakingNewsList);
                      // tempBreak.remove(0);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => ShowMoreNewsList(
                                model1: model,
                                index: 0,
                                updateParent: updateHomePage,
                                id: model.id,
                                //isFav: false,
                                isDetails: false,
                                news1: tempBreak,
                                newsType:
                                    getTranslated(context, 'breakingNews_lbl')!,
                              )));
                    },
                    child: Padding(
                        padding: EdgeInsetsDirectional.all(
                            5.0) /* only(
                            end: 5.0, start: 5.0) */
                        , //start: 8.0
                        child: viewMoreButton()),
                  ), */
                ],
              ),
              _isBreakLoading
                  ? newsShimmer()
                  : breakingNewsList.length == 0
                      ? Center(
                          child: Text(
                              getTranslated(context, 'breaking_not_avail')!,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .fontColor
                                          .withOpacity(0.8))))
                      : SizedBox(
                          height: deviceHeight! / 5.9,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: breakingNewsList.length,
                            itemBuilder: (context, index) {
                              return breakingNewsItem(index);
                            },
                          ))
            ]));
  }

  viewMoreButton() {
    return Text(
      getTranslated(context, 'view_more')!,
      style: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(color: colors.primary, fontWeight: FontWeight.normal),
    );
  }

  Widget getNewsList() {
    return Container(
      margin: EdgeInsetsDirectional.only(top: deviceHeight! / 35.0),
      child: Column(
        children: List.generate(
            normalNewsList.length > 5 ? 5 : normalNewsList.length, (index) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              getNewsItems(index),
              Divider(),
            ],
          );
        }),
      ),
    );
  }

  Widget getNewsItems(int index) {
    List<News> temp = List.of(normalNewsList);
    var lenList = temp.length - 1;
    News model = temp.elementAt(lenList - index);
    DateTime time1 = DateTime.parse(model.date!);
    return InkWell(
      child: Container(
        child: Row(
          children: <Widget>[
            Expanded(
                child: Padding(
              padding: EdgeInsetsDirectional.only(start: 5.0, end: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${index + 1}. ",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              ?.copyWith(
                                  fontWeight: FontWeight.normal,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .fontColor
                                      .withOpacity(0.9),
                                  fontSize: 14.0,
                                  letterSpacing: 0.1)),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(model.title!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    ?.copyWith(
                                        fontWeight: FontWeight.normal,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor
                                            .withOpacity(0.9),
                                        fontSize: 14.0,
                                        letterSpacing: 0.1)),
                            Padding(
                                padding: EdgeInsetsDirectional.only(top: 8.0),
                                child: Text(convertToAgo(context, time1, 0)!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .agoLabel
                                                .withOpacity(0.8)))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
            if (model.image != null || model.image != '')
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: model.image! != ""
                    ? CachedNetworkImage(
                        fadeInDuration: Duration(milliseconds: 150),
                        imageUrl: model.image!,
                        height: deviceHeight! / 14.5,
                        width: deviceWidth! / 5.5,
                        fit: BoxFit.cover,
                        placeholder: (context, url) {
                          return placeHolder();
                        },
                        errorWidget: (context, error, stackTrace) {
                          return errorWidget(
                              deviceHeight! / 14.5, deviceWidth! / 5.5);
                        },
                      )
                    : Image.asset(
                        "assets/images/splash_Icon.png",
                        height: deviceHeight! / 14.5,
                        width: deviceWidth! / 5.5,
                        fit: BoxFit.cover,
                      ),
              )
            // : SizedBox.shrink(),
          ],
        ),
      ),
      onTap: () {
        //goto DetailsScreen
        List<News> normalNewsListt = [];
        normalNewsListt.addAll(normalNewsListt);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => NewsDetails(
                  model: model,
                  index: index,
                  updateParent: updateHomePage,
                  id: model.id,
                  //isFav: false,
                  isDetails: true,
                  news: normalNewsListt,
                )));
      },
    );
  }

  recentNewsItem(int index) {
    DateTime time1 = DateTime.parse(recentNewsList[index].date!);
    allImage.clear();
    allImage.add(recentNewsList[index].image!);
    if (recentNewsList[index].imageDataList!.length != 0) {
      for (int i = 0; i < recentNewsList[index].imageDataList!.length; i++) {
        allImage.add(recentNewsList[index].imageDataList![i].otherImage!);
      }
    }
    // addImages(recentNewsList, index);

    return Padding(
      padding: EdgeInsetsDirectional.only(
          top: 15.0, start: index == 0 ? 0 : deviceWidth! / 20.0),
      child: InkWell(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Stack(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: CachedNetworkImage(
                      fadeInDuration: Duration(milliseconds: 150),
                      imageUrl: recentNewsList[index].image!,
                      height: deviceHeight! / 7.2,
                      width: deviceWidth! / 2.2,
                      fit: BoxFit.cover,
                      errorWidget: (context, error, stackTrace) =>
                          errorWidget(deviceHeight! / 7.2, deviceWidth! / 2.2),
                      placeholder: (context, url) {
                        return placeHolder();
                      },
                    )),
              ],
            ),
            Container(
                width: deviceWidth! / 2.2,
                padding:
                    EdgeInsetsDirectional.only(top: 4.0, start: 5.0, end: 5.0),
                child: Text(
                  recentNewsList[index].title!,
                  style: Theme.of(context).textTheme.subtitle2?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .fontColor
                          .withOpacity(0.9),
                      fontWeight: FontWeight.normal,
                      fontSize: 12.5,
                      height: 1.0),
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                )),
            Container(
              width: deviceWidth! / 2.2,
              padding:
                  EdgeInsetsDirectional.only(top: 4.0, start: 5.0, end: 5.0),
              child: Text(convertToAgo(context, time1, 0)!,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .agoLabel
                          .withOpacity(0.8))),
            ),
          ],
        ),
        onTap: () {
          News model = recentNewsList[index];
          List<News> recList = [];
          recList.addAll(recentNewsList);
          recList.removeAt(index);
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => NewsDetails(
                    model: model,
                    index: index,
                    updateParent: updateHomePage,
                    id: model.id,
                    //isFav: false,
                    isDetails: true,
                    news: recList,
                  )));
        },
      ),
    );
  }

  Widget getNormalNewsList() {
    return Container(
      child: Column(
        children: List.generate(
            normalNewsList.length > 2 ? 2 : normalNewsList.length, (index) {
          return normalNewsItem(index);
        }),
      ),
    );
  }

  Widget getNormalNewsList2() {
    return Container(
      child: Column(
        children: List.generate(
            normalNewsList.length > 2 ? 2 : normalNewsList.length, (index) {
          return normalNewsItem2(index);
        }),
      ),
    );
  }

  /* setTagList(List responseList, int index) {
    tagList.clear();
    tagId.clear();
    if (responseList[index].tagName! != "") {
      final tagName = responseList[index].tagName!;
      tagList = tagName.split(',');
    }

    if (responseList[index].tagId! != "") {
      tagId = responseList[index].tagId!.split(",");
    }
    print("tag id ${tagId[index]} & name ${tagList[index]} @ index ${index}");
  } */
/*
  addImages(List imgList, int index) {
    allImage.clear();

    allImage.add(imgList[index].image!);
    if (imgList[index].imageDataList!.length != 0) {
      for (int i = 0; i < imgList[index].imageDataList!.length; i++) {
        allImage.add(imgList[index].imageDataList![i].otherImage!);
      }
    }
  }
 */
  normalNewsItem(int index) {
    DateTime time1 = DateTime.parse(normalNewsList[index].date!);
    List<String> tagList = [];

    if (normalNewsList[index].tagName! != "") {
      final tagName = normalNewsList[index].tagName!;
      tagList = tagName.split(',');
    }
    List<String> tagId = [];
    if (normalNewsList[index].tagId! != "") {
      tagId = normalNewsList[index].tagId!.split(",");
    }
    allImage.clear();

    allImage.add(normalNewsList[index].image!);
    if (normalNewsList[index].imageDataList!.length != 0) {
      for (int i = 0; i < normalNewsList[index].imageDataList!.length; i++) {
        allImage.add(normalNewsList[index].imageDataList![i].otherImage!);
      }
    }

    // setTagList(normalNewsList, index);
    // addImages(normalNewsList, index);
    // print(
    //     "Tags --- ${normalNewsList[index].tagId} -- ${normalNewsList[index].tagName} & tagList.length is ${tagList.length}");

    return Padding(
      padding: EdgeInsetsDirectional.only(top: deviceHeight! / 35.0),
      child: InkWell(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: ContainerHeight, //deviceHeight! / 4.2,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: CachedNetworkImage(
                        fadeInDuration: Duration(milliseconds: 150),
                        imageUrl: normalNewsList[index].image!,
                        height: ContainerHeight,
                        // deviceHeight! / 4.2,
                        width: deviceWidth,
                        fit: BoxFit.cover,
                        errorWidget: (context, error, stackTrace) =>
                            errorWidget(deviceHeight! / 7.2, deviceWidth!),
                        placeholder: (context, url) {
                          return placeHolder();
                        },
                      )),
                  if (normalNewsList[index].tagName! != "")
                    Container(
                      margin:
                          EdgeInsets.only(bottom: 5.0, left: 5.0, right: 5.0),
                      child: SizedBox(
                          height: 16.0,
                          child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount:
                                  /*  tagList.length >= 2 ? 2 : */ tagList
                                      .length,
                              itemBuilder: (context, index) {
                                return Padding(
                                    padding: EdgeInsetsDirectional.only(
                                        start: index == 0 ? 0 : 5.5),
                                    child: InkWell(
                                      child: Container(
                                          height: 20.0,
                                          width: 65,
                                          /* height: 16.0,
                                            width: 45, */
                                          alignment: Alignment.center,
                                          padding: EdgeInsetsDirectional.only(
                                              start: 3.0, end: 3.0),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10.0),
                                                bottomRight:
                                                    Radius.circular(10.0)),
                                            color: colors.tempboxColor
                                                .withOpacity(0.85),
                                          ),
                                          child: Text(
                                            tagList[index],
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                ?.copyWith(
                                                  color: colors.secondaryColor,
                                                  fontSize: 9.5,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                          )),
                                      onTap: () async {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => NewsTag(
                                                tagId: tagId[index],
                                                tagName: tagList[index],
                                                updateParent: updateHomePage,
                                              ),
                                            ));
                                      },
                                    ));
                              })),
                    )
                ],
              ),
            ),
            Container(
                padding:
                    EdgeInsetsDirectional.only(top: 4.0, start: 5.0, end: 5.0),
                child: Text(
                  normalNewsList[index].title!,
                  style: Theme.of(context).textTheme.subtitle2?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .fontColor
                          .withOpacity(0.9)),
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                )),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                        top: 4.0, start: 5.0, end: 5.0),
                    child: Text(convertToAgo(context, time1, 0)!,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .agoLabel
                                .withOpacity(0.8))),
                  ),
                ),
                Row(
                  children: [
                    InkWell(
                      child: Icon(Icons.share_rounded),
                      onTap: () async {
                        if (isRedundentClick(DateTime.now(), diff)) {
                          //inBetweenClicks
                          print('hold on, processing');
                          /* showSnackBar(
                              getTranslated(context, 'processing')!, context); */
                          return;
                        }
                        _isNetworkAvail = await isNetworkAvailable();
                        if (_isNetworkAvail) {
                          createDynamicLink(
                              context,
                              normalNewsList[index].id!,
                              index,
                              normalNewsList[index].title!,
                              false,
                              false);
                        } else {
                          showSnackBar(
                              getTranslated(context, 'internetmsg')!, context);
                        }
                        diff = resetDiff;
                      },
                    ),
                    SizedBox(width: deviceWidth! / 99.0),
                    InkWell(
                      child: bookMarkValue.contains(normalNewsList[index].id)
                          ? Icon(Icons.bookmark_added_rounded)
                          : Icon(Icons.bookmark_add_outlined),
                      onTap: () async {
                        if (isRedundentClick(DateTime.now(), diff)) {
                          //inBetweenClicks
                          print('hold on, processing');
                          /* showSnackBar(
                              getTranslated(context, 'processing')!, context); */
                          return;
                        }
                        _isNetworkAvail = await isNetworkAvailable();
                        if (_isNetworkAvail) {
                          if (CUR_USERID != "") {
                            setState(() {
                              bookMarkValue.contains(normalNewsList[index].id!)
                                  ? _setBookmark("0", normalNewsList[index].id!)
                                  : _setBookmark(
                                      "1", normalNewsList[index].id!);
                            });
                          } else {
                            //if (!isTapped) {
                            loginRequired(context);
                            // isTapped = true;
                            // }
                          }
                        } else {
                          showSnackBar(
                              getTranslated(context, 'internetmsg')!, context);
                        }
                        diff = resetDiff;
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          News model = normalNewsList[index];
          List<News> recList = [];
          recList.addAll(normalNewsList);
          recList.removeAt(index);
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => NewsDetails(
                    model: model,
                    index: index,
                    updateParent: updateHomePage,
                    id: model.id,
                    // isFav: false,
                    isbookmarked:
                        (bookMarkValue.contains(normalNewsList[index].id))
                            ? true
                            : false,
                    isDetails: true,
                    news: recList,
                  )));
        },
      ),
    );
  }

  normalNewsItem2(int index) {
    //Normal / General News Data
/*     List<News> tempNews2AllList = List.of(normalNewsList);
    tempNews2AllList.shuffle(); */
    // print("Tag--Normal News2- ${tempNews2AllList[index].tagId} - ${tempNews2AllList[index].tagName}");
    DateTime time1 = DateTime.parse(tempNews2AllList[index].date!);
    List<String> tagList = [];

    if (tempNews2AllList[index].tagName! != "") {
      final tagName = tempNews2AllList[index].tagName!;
      tagList = tagName.split(',');
    }

    List<String> tagId = [];

    if (tempNews2AllList[index].tagId! != "") {
      tagId = tempNews2AllList[index].tagId!.split(",");
    }
    // setTagList(tempNews2AllList, index);

    allImage.clear();

    allImage.add(tempNews2AllList[index].image!);
    if (tempNews2AllList[index].imageDataList!.length != 0) {
      for (int i = 0; i < tempNews2AllList[index].imageDataList!.length; i++) {
        allImage.add(tempNews2AllList[index].imageDataList![i].otherImage!);
      }
    }
    // addImages(tempNews2AllList, index);

    return Padding(
      padding: EdgeInsetsDirectional.only(top: deviceHeight! / 35.0),
      child: InkWell(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: ContainerHeight, // deviceHeight! / 4.2,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: CachedNetworkImage(
                        fadeInDuration: Duration(milliseconds: 150),
                        imageUrl: tempNews2AllList[index].image!,
                        height: ContainerHeight,
                        // deviceHeight! / 4.2,
                        width: deviceWidth,
                        fit: BoxFit.cover,
                        errorWidget: (context, error, stackTrace) =>
                            errorWidget(
                                ContainerHeight /* deviceHeight! / 4.2 */,
                                deviceWidth!),
                        placeholder: (context, url) {
                          return placeHolder();
                        },
                      )),
                  /* Positioned.directional(
                    textDirection: Directionality.of(context),
                    bottom: 7.0,
                    end: 7.0,
                    child: */

                  if (tempNews2AllList[index].tagName! != "")
                    Container(
                      margin:
                          EdgeInsets.only(bottom: 5.0, left: 5.0, right: 5.0),
                      child: SizedBox(
                          height: 16.0,
                          child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: /* tagList.length >= 2 ? 2 : */ tagList
                                  .length,
                              itemBuilder: (context, index) {
                                return Padding(
                                    padding: EdgeInsetsDirectional.only(
                                        start: index == 0 ? 0 : 5.5),
                                    child: InkWell(
                                      child: Container(
                                          height: 20.0,
                                          width: 65,
                                          /* height: 16.0,
                                              width: 45, */
                                          alignment: Alignment.center,
                                          padding: EdgeInsetsDirectional.only(
                                              start: 3.0, end: 3.0),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10.0),
                                                bottomRight:
                                                    Radius.circular(10.0)),
                                            color: colors.tempboxColor
                                                .withOpacity(0.85),
                                          ),
                                          child: Text(
                                            tagList[index],
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                ?.copyWith(
                                                  color: colors.secondaryColor,
                                                  fontSize: 9.5,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                          )),
                                      onTap: () async {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => NewsTag(
                                                tagId: tagId[index],
                                                tagName: tagList[index],
                                                updateParent: updateHomePage,
                                              ),
                                            ));
                                      },
                                    ));
                              })),
                    )
                  //: SizedBox.shrink(),
                  // ),
                ],
              ),
            ),
            Container(
                padding:
                    EdgeInsetsDirectional.only(top: 4.0, start: 5.0, end: 5.0),
                child: Text(
                  tempNews2AllList[index].title!,
                  style: Theme.of(context).textTheme.subtitle2?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .fontColor
                          .withOpacity(0.9)),
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                )),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                        top: 4.0, start: 5.0, end: 5.0),
                    child: Text(convertToAgo(context, time1, 0)!,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .agoLabel
                                .withOpacity(0.8))),
                  ),
                ),
                Row(
                  children: [
                    InkWell(
                      child: Icon(Icons.share_rounded),
                      onTap: () async {
                        if (isRedundentClick(DateTime.now(), diff)) {
                          //inBetweenClicks
                          print('hold on, processing');
                          /* showSnackBar(
                              getTranslated(context, 'processing')!, context); */
                          return;
                        }
                        _isNetworkAvail = await isNetworkAvailable();
                        if (_isNetworkAvail) {
                          createDynamicLink(
                              context,
                              tempNews2AllList[index].id!,
                              index,
                              tempNews2AllList[index].title!,
                              false,
                              false);
                        } else {
                          showSnackBar(
                              getTranslated(context, 'internetmsg')!, context);
                        }
                        diff = resetDiff;
                      },
                    ),
                    SizedBox(width: deviceWidth! / 99.0),
                    InkWell(
                      child: bookMarkValue.contains(tempNews2AllList[index].id)
                          ? Icon(Icons.bookmark_added_rounded)
                          : Icon(Icons.bookmark_add_outlined),
                      onTap: () async {
                        if (isRedundentClick(DateTime.now(), diff)) {
                          //inBetweenClicks
                          print('hold on, processing');
                          /* showSnackBar(
                              getTranslated(context, 'processing')!, context); */
                          return;
                        }
                        _isNetworkAvail = await isNetworkAvailable();
                        if (_isNetworkAvail) {
                          if (CUR_USERID != "") {
                            setState(() {
                              bookMarkValue
                                      .contains(tempNews2AllList[index].id!)
                                  ? _setBookmark(
                                      "0", tempNews2AllList[index].id!)
                                  : _setBookmark(
                                      "1", tempNews2AllList[index].id!);
                            });
                          } else {
                            // if (!isTapped2) {
                            loginRequired(context);
                            //   isTapped2 = true;
                            // }
                          }
                        } else {
                          showSnackBar(
                              getTranslated(context, 'internetmsg')!, context);
                        }
                        diff = resetDiff;
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          /*  print("index & title is -- ${tempNews2AllList[index].title} -- ${index} "); */
          News model = tempNews2AllList[index];
          List<News> recList = [];
          recList.addAll(tempNews2AllList);
          recList.removeAt(index);
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => NewsDetails(
                    model: model,
                    index: index,
                    updateParent: updateHomePage,
                    id: model.id,
                    // isFav: false,
                    isbookmarked:
                        (bookMarkValue.contains(tempNews2AllList[index].id))
                            ? true
                            : false,
                    isDetails: true,
                    news: recList,
                  )));
        },
      ),
    );
  }

  Widget viewRecentContent() {
    //Recent section
    return Padding(
        padding: EdgeInsetsDirectional.only(
          top: 15.0,
        ),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                      padding: EdgeInsetsDirectional.zero, // .only(start: 8.0),
                      child: Text(
                        getTranslated(context, 'recentNews_lbl')!,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .fontColor
                                    .withOpacity(0.9),
                                fontWeight: FontWeight.w600),
                      )),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      //goto ShowMoreNewsList
                      News model = recentNewsList[0];
                      List<News> recList = [];
                      recList.addAll(recentNewsList);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => ShowMoreNewsList(
                                model: model,
                                index: 0,
                                updateParent: updateHomePage,
                                id: model.id,
                                // isFav: false,
                                isDetails: true,
                                news: recList,
                                newsType:
                                    getTranslated(context, 'recentNews_lbl')!,
                              )));
                    },
                    child: viewMoreButton(),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.transparent,
                      onPrimary: colors.primary,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                    ),
                  ),
                  /*  GestureDetector(
                    onTap: () {
                      //goto ShowMoreNewsList
                      News model = recentNewsList[0];
                      List<News> recList = [];
                      recList.addAll(recentNewsList);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => ShowMoreNewsList(
                                model: model,
                                index: 0,
                                updateParent: updateHomePage,
                                id: model.id,
                                // isFav: false,
                                isDetails: true,
                                news: recList,
                                newsType:
                                    getTranslated(context, 'recentNews_lbl')!,
                              )));
                    },
                    child: Padding(
                        padding:
                            EdgeInsetsDirectional.only(end: 5.0, start: 5.0),
                        child: viewMoreButton()),
                  ),*/
                ],
              ),
              _isRecentLoading
                  ? newsShimmer()
                  : recentNewsList.length == 0
                      ? Center(
                          child: Text(getTranslated(context, 'recent_no_news')!,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .fontColor
                                          .withOpacity(0.8))))
                      : SizedBox(
                          height: deviceHeight! / 4.22, //4.32,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: recentNewsList.length,
                            itemBuilder: (context, index) {
                              return (index == recentNewsList.length &&
                                      _isRecentLoadMore)
                                  ? Center(child: CircularProgressIndicator())
                                  : recentNewsItem(index);
                            },
                          ))
            ]));
  }

  userNewsItem(int index) {
    //For you Data
    // print( "Tag -- User News - ${userNewsList[index].tagId} -- ${userNewsList[index].tagName}");
    List<String> tagList = [];

    if (userNewsList[index].tagName! != "") {
      final tagName = userNewsList[index].tagName!;
      tagList = tagName.split(',');
    }

    List<String> tagId = [];

    if (userNewsList[index].tagId! != "") {
      tagId = userNewsList[index].tagId!.split(",");
    }
    // setTagList(userNewsList, index);

    allImage.clear();

    allImage.add(userNewsList[index].image!);
    if (userNewsList[index].imageDataList!.length != 0) {
      for (int i = 0; i < userNewsList[index].imageDataList!.length; i++) {
        allImage.add(userNewsList[index].imageDataList![i].otherImage!);
      }
    }
    // addImages(userNewsList, index);

    return Padding(
      padding: EdgeInsetsDirectional.only(
          top: 15.0, start: index == 0 ? 0 : deviceWidth! / 20.0),
      child: InkWell(
        child: Column(
          children: <Widget>[
            Stack(
              children: [
                ClipRRect(
                    //IMAGE
                    borderRadius: BorderRadius.circular(10.0),
                    child: ShaderMask(
                      shaderCallback: (rect) {
                        return LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            colors.secondaryColor.withOpacity(0.85)
                          ],
                        ).createShader(rect);
                      },
                      blendMode: BlendMode.darken,
                      child: CachedNetworkImage(
                        fadeInDuration: Duration(milliseconds: 150),
                        imageUrl: userNewsList[index].image!,
                        height: 137.0,
                        width: deviceWidth! / 2.2,
                        fit: BoxFit.cover,
                        errorWidget: (context, error, stackTrace) =>
                            errorWidget(
                                deviceHeight! / 7.2, deviceWidth! / 2.2),
                        placeholder: (context, url) {
                          return placeHolder();
                        },
                      ),
                    )),
                Positioned.directional(
                  textDirection: Directionality.of(context),
                  bottom: userNewsList[index].tagName! != ""
                      ? deviceHeight! / 32.0
                      : 7.0,
                  start: 7.0,
                  child: Container(
                      width: deviceWidth! / 2.2,
                      //TITLE
                      padding: EdgeInsetsDirectional.only(
                          top: 4.0, start: 5.0, end: 5.0),
                      child: Text(
                        userNewsList[index].title!,
                        style: Theme.of(context).textTheme.subtitle2?.copyWith(
                            color: colors.tempboxColor,
                            fontWeight: FontWeight.normal,
                            fontSize: 12.5,
                            height: 1.0),
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      )),
                ),
                Positioned.directional(
                    textDirection: Directionality.of(context),
                    bottom: 7.0,
                    start: 7.0,
                    child: userNewsList[index].tagName! != ""
                        ? SizedBox(
                            height: 16.0,
                            child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount:
                                    /*  tagList.length >= 2 ? 2 : */ tagList
                                        .length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                      padding: EdgeInsetsDirectional.only(
                                          start: index == 0 ? 0 : 5.5),
                                      child: InkWell(
                                        child: Container(
                                            /* height: 16.0,
                                          width: 45, */
                                            height: 20.0,
                                            width: 65,
                                            alignment: Alignment.center,
                                            padding: EdgeInsetsDirectional.only(
                                                start: 3.0, end: 3.0),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(10.0),
                                                  bottomRight:
                                                      Radius.circular(10.0)),
                                              color: colors.tempboxColor
                                                  .withOpacity(0.85),
                                            ),
                                            child: Text(
                                              tagList[index],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2
                                                  ?.copyWith(
                                                    color:
                                                        colors.secondaryColor,
                                                    fontSize: 9.5,
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: true,
                                            )),
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => NewsTag(
                                                  tagId: tagId[index],
                                                  tagName: tagList[index],
                                                  updateParent: updateHomePage,
                                                ),
                                              ));
                                        },
                                      ));
                                }))
                        : SizedBox.shrink()),
              ],
            ),
          ],
        ),
        onTap: () {
          News model = userNewsList[index];
          List<News> usList = [];
          usList.addAll(userNewsList);
          usList.removeAt(index);
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => NewsDetails(
                    model: model,
                    index: index,
                    updateParent: updateHomePage,
                    id: model.id,
                    // isFav: false,
                    isDetails: true,
                    news: usList,
                  )));
        },
      ),
    );
  }

  Widget viewUserNewsContent() {
    //For You Section
    return Padding(
        padding: EdgeInsetsDirectional.only(
          top: 15.0,
        ),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                      //For you News
                      padding: EdgeInsetsDirectional.zero, // .only(start: 8.0),
                      child: Text(
                        getTranslated(context, 'forYou_lbl')!,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .fontColor
                                    .withOpacity(0.9),
                                fontWeight: FontWeight.w600),
                      )),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      //goto ShowMoreNewsList
                      News model = userNewsList[0];
                      List<News> usList = [];
                      usList.addAll(userNewsList);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => ShowMoreNewsList(
                                model: model,
                                index: 0,
                                updateParent: updateHomePage,
                                id: model.id,
                                // isFav: false,
                                isDetails: true,
                                news: usList,
                                newsType: getTranslated(context, 'forYou_lbl')!,
                              )));
                    },
                    child: viewMoreButton(),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.transparent,
                      onPrimary: colors.primary,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                    ),
                  ),
                  /*  GestureDetector(
                    onTap: () {
                      //goto ShowMoreNewsList
                      News model = userNewsList[0];
                      List<News> usList = [];
                      usList.addAll(userNewsList);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => ShowMoreNewsList(
                                model: model,
                                index: 0,
                                updateParent: updateHomePage,
                                id: model.id,
                                // isFav: false,
                                isDetails: true,
                                news: usList,
                                newsType: getTranslated(context, 'forYou_lbl')!,
                              )));
                    },
                    child: Padding(
                        padding:
                            EdgeInsetsDirectional.only(end: 5.0, start: 5.0),
                        child: viewMoreButton()),
                  ), */
                ],
              ),
              _isUserLoading
                  ? newsShimmer()
                  : userNewsList.length == 0
                      ? Center(
                          child: Text(
                              getTranslated(context, 'userNews_not_avail')!,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .fontColor
                                          .withOpacity(0.8))))
                      : SizedBox(
                          height: deviceHeight! / 4.3,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: userNewsList.length,
                            itemBuilder: (context, index) {
                              return (index == userNewsList.length &&
                                      _isUserLoadMore)
                                  ? Center(child: CircularProgressIndicator())
                                  : userNewsItem(index);
                            },
                          ))
            ]));
  }

  Widget showCategoriesData(int indexValue) {
    Category? category = subCat.isEmpty || indexValue > subCat.length - 1
        ? null
        : subCat.keys.elementAt(indexValue);
    // print("length of subcat - ${subCat.length} -- ${category} ");
    // print( "subcategory details - ${subCat[category]!.first.tagId} - ${subCat[category]!.first.tagName}");
    return subCat.isEmpty || category == null
        ? SizedBox.shrink()
        : Column(
            children: <Widget>[
              //title of Category
              Padding(
                //Category Title
                padding: EdgeInsetsDirectional.only(
                    top: deviceHeight! / 45.0,
                    bottom: deviceHeight! / 45.0), //start: 8.0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(category.categoryName!,
                      style: Theme.of(context).textTheme.subtitle1?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .fontColor
                              .withOpacity(0.9),
                          fontWeight: FontWeight.w600)),
                ),
              ),
              //details- categoryData
              showCatData(subCat[category]!),
              //ViewMoreStories
              GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => SubCategories(
                              //pass Selected CatId to Get details of Subcategory Or containing news details.
                              catId: catList[indexValue].id,
                              catName: catList[indexValue].categoryName,
                              catList: catList,
                              curTabId: catList[indexValue].id,
                              isSubCat:
                                  (catList[indexValue].subData!.length > 0)
                                      ? true
                                      : false,
                              index: indexValue,
                              subCatId: '0',
                            )));
                  },
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        getTranslated(context, 'more_stories')!,
                        textAlign: TextAlign.center,
                        style: Theme.of(this.context)
                            .textTheme
                            .subtitle2
                            ?.copyWith(
                                color: colors.primary,
                                fontSize: 16.0,
                                fontWeight: FontWeight.normal,
                                letterSpacing: 0.6),
                      ),
                    ),
                  )),
            ],
          );
  }

  Widget showCatData(List<News> newsCatlist) {
    return subCat.isEmpty
        ? SizedBox.shrink()
        : Column(
            children: List.generate(
                newsCatlist.length > 3 ? 3 : newsCatlist.length, (index) {
              DateTime time1 = DateTime.parse(newsCatlist[index].date!);
              // print( "${newsCatlist[index].title} --  ${newsCatlist[index].tagId}");
              return Column(
                children: [
                  InkWell(
                    child: index == 0
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Stack(
                                children: [
                                  ClipRRect(
                                      //IMAGE
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: CachedNetworkImage(
                                        fadeInDuration:
                                            Duration(milliseconds: 150),
                                        imageUrl: newsCatlist[index].image!,
                                        height: ContainerHeight,
                                        //deviceHeight! / 4.2,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorWidget: (context, error,
                                                stackTrace) =>
                                            errorWidget(
                                                ContainerHeight /* deviceHeight! / 4.2 */,
                                                double.infinity),
                                        placeholder: (context, url) {
                                          return placeHolder();
                                        },
                                      )),
                                ],
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                      //TITLE
                                      padding: EdgeInsetsDirectional.only(
                                          top: 4.0, start: 5.0, end: 5.0),
                                      child: Text(
                                        newsCatlist[index].title!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2
                                            ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .fontColor
                                                    .withOpacity(0.9),
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14.0,
                                                height: 1.0),
                                        maxLines: 3,
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                      )),
                                  Padding(
                                      //Ago label
                                      padding: EdgeInsetsDirectional.only(
                                          top: 4.0, start: 5.0, end: 5.0),
                                      child: Text(
                                        convertToAgo(context, time1, 0)!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .agoLabel
                                                    .withOpacity(0.8)),
                                        maxLines: 3,
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                      )),
                                ],
                              ),
                              Divider(),
                              //fbAud
                              if (adv_type != "" &&
                                  adv_type !=
                                      "unity" && //as unity doesn't support native ads
                                  (index % fbAdIndex == 0 &&
                                      index % goAdIndex == 0))
                                /* fbNativeUnitId != "" || iosFbNativeUnitId != "" */
                                // ? _isNetworkAvail
                                Container(
                                    padding: EdgeInsets.all(7.0),
                                    margin: EdgeInsetsDirectional.only(
                                        bottom: 10.0),
                                    height: 320,
                                    //120,// deviceHeight! / 2.0,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors
                                          .white, //to match it with default ads Bgcolor
                                      /* Theme.of(context)
                                                .colorScheme
                                                .boxColor, */
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: showNativeAds())
                            ],
                          )
                        : Column(
                            children: [
                              Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                              //TITLE
                                              padding:
                                                  EdgeInsetsDirectional.only(
                                                      top: 4.0,
                                                      start: 5.0,
                                                      end: 5.0),
                                              child: Text(
                                                newsCatlist[index].title!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle2
                                                    ?.copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .fontColor
                                                            .withOpacity(0.9),
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        height: 1.0),
                                                maxLines: 3,
                                                softWrap: true,
                                                overflow: TextOverflow.ellipsis,
                                              )),
                                          Padding(
                                              //Ago label
                                              padding:
                                                  EdgeInsetsDirectional.only(
                                                      top: 4.0,
                                                      start: 5.0,
                                                      end: 5.0),
                                              child: Text(
                                                convertToAgo(
                                                    context, time1, 0)!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .agoLabel
                                                            .withOpacity(0.8)),
                                                maxLines: 3,
                                                softWrap: true,
                                                overflow: TextOverflow.ellipsis,
                                              )),
                                        ],
                                      ),
                                    ),
                                    ClipRRect(
                                        //IMAGE
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: CachedNetworkImage(
                                          fadeInDuration:
                                              Duration(milliseconds: 150),
                                          imageUrl: newsCatlist[index].image!,
                                          height: deviceHeight! / 10.9,
                                          width: deviceWidth! / 5.0,
                                          fit: BoxFit.cover,
                                          errorWidget:
                                              (context, error, stackTrace) =>
                                                  errorWidget(
                                                      deviceHeight! / 10.9,
                                                      deviceWidth! / 5.0),
                                          placeholder: (context, url) {
                                            return placeHolder();
                                          },
                                        )),
                                  ]),
                              Divider(),
                            ],
                          ),
                    onTap: () {
                      News model = newsCatlist[index];
                      List<News> usList = [];
                      usList.addAll(newsCatlist);
                      usList.removeAt(index);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => NewsDetails(
                                model: model,
                                index: index,
                                updateParent: updateHomePage,
                                id: model.id,
                                // isFav: false,
                                isDetails: true,
                                news: usList,
                              )));
                    },
                  )
                ],
              );
            }),
          );
  }

  showNativeAds() {
    if (adv_type == "google") {
      if (_isBannerAdReady)
        return AdWidget(key: UniqueKey(), ad: createBannerAd()..load());
    }
    if (adv_type == "fb") {
      if (FbAdHelper.nativeAdUnitId != "")
        return FacebookNativeAd(
          /*  backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .boxColor, */
          placementId: FbAdHelper.nativeAdUnitId,
          adType: Platform.isAndroid
              ? NativeAdType.NATIVE_AD
              : NativeAdType.NATIVE_AD_VERTICAL,
          width: double.infinity,
          height: deviceHeight! / 2.0,
          keepAlive: true,
          keepExpandedWhileLoading: false,
          expandAnimationDuraion: 300,
          listener: (result, value) {
            print("Native Ad: $result --> $value");
          },
        );
    }
  }

  videoItem(int index) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
          start: index == 0 ? 0 : deviceWidth! / 30.0),
      child: InkWell(
        child: Column(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  (videoItems[index].contentType == 'video_youtube')
                      ? Container(
                          width: deviceWidth! / 2.6, //3.2,
                          height: deviceHeight! / 6.5,
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.network(
                              videoItems[index].img!,
                              fit: BoxFit.fill,
                              errorBuilder: (BuildContext context,
                                  Object exception, StackTrace? stackTrace) {
                                return Image.asset(
                                  'assets/images/Placeholder_video.jpg',
                                  width: deviceWidth! / 2.6, //3.2,
                                  height: deviceHeight! / 6.5,
                                );
                              },
                            ),
                          ),
                        )
                      : ((videoItems[index].contentType == 'video_upload')
                          ? Image.file(
                              File(videoItems[index].img!),
                              width: deviceWidth! / 2.6, //3.2,
                              height: deviceHeight! / 6.5,
                              fit: BoxFit.fill,
                              errorBuilder: (BuildContext context,
                                  Object exception, StackTrace? stackTrace) {
                                return Image.asset(
                                  'assets/images/Placeholder_video.jpg',
                                  width: deviceWidth! / 2.6, //3.2,
                                  height: deviceHeight! / 6.5,
                                );
                              },
                            )
                          : Image.asset(videoItems[index].img!,
                              width: deviceWidth! / 2.6, //3.2,
                              height: deviceHeight! / 6.5,
                              fit: BoxFit.cover)),
                  CircleAvatar(
                      //play button
                      radius: 30,
                      backgroundColor: Colors.transparent,
                      child: InkWell(
                        child: Icon(
                          Icons.play_circle_outline_rounded,
                          size: 50,
                          color: Colors.white,
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NewsVideo(
                                        model: videoItems[index],
                                        from: 1,
                                      )));
                        }, //redirect to Next screen,
                      ))
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10), //.all(10),
              width: deviceWidth! / 2.6, //3.2,
              child: Text(
                videoItems[index].title!,
                style: Theme.of(context).textTheme.subtitle2?.copyWith(
                    color: Theme.of(context).colorScheme.skipColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                    height: 1.0),
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        onTap: () {
          List<News> vidList = [];
          vidList.addAll(videoItems);
          vidList.removeAt(index);
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => NewsVideo(
                    model: videoItems[index],
                    from: 1,
                  ))); //pass index to NewsVideo page
        },
      ),
    );
  }

  Widget showVideos() {
    //Videos section
    return Padding(
        padding: EdgeInsetsDirectional.only(
          top: 0.0,
        ),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                      padding: EdgeInsetsDirectional.zero, // .only(start: 8.0),
                      child: Text(
                        getTranslated(context, 'videos_lbl')!,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .fontColor
                                    .withOpacity(0.9),
                                fontWeight: FontWeight.w600),
                      )),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      //goto Videos Screen
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => Videos(
                                isBackRequired: true,
                              )));
                    },
                    child: viewMoreButton(),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.transparent,
                      onPrimary: colors.primary,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                    ),
                  ),
                  /* TextButton(
                      //View More button
                      style: ButtonStyle(
                        overlayColor:
                            MaterialStateProperty.all(colors.transparentColor),
                        foregroundColor:
                            MaterialStateProperty.all(colors.primary),
                      ),
                      onPressed: () {
                        //goto Videos Screen
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => Videos(
                                  isBackRequired: true,
                                )));
                      },
                      child: viewMoreButton()) */
                ],
              ),
              if (videoItems.length != 0)
                SizedBox(
                    height: deviceHeight! / 4.4,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: videoItems.length,
                      itemBuilder: (context, index) {
                        return (index == videoItems.length && _isRecentLoadMore)
                            ? Center(child: CircularProgressIndicator())
                            : videoItem(index);
                      },
                    ))
            ]));
  }

  Future<String>? getThumbnailImage(String url) async {
    final fileName = await VideoThumbnail.thumbnailFile(
      video: url,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.WEBP,
      maxHeight: 64,
      // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 75,
    ).catchError((Error) => print("Error !!!!! $Error"));
    return fileName!;
  }

  newsShimmer() {
    return Shimmer.fromColors(
        baseColor: Colors.grey.withOpacity(0.6),
        highlightColor: Colors.grey,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
              children: [0, 1, 2, 3, 4, 5, 6]
                  .map((i) => Padding(
                      padding: EdgeInsetsDirectional.only(
                          top: 15.0, start: i == 0 ? 0 : deviceWidth! / 20.0),
                      child: Stack(children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.grey.withOpacity(0.6)),
                          height: deviceHeight! / 7.2,
                          width: deviceWidth! / 2.2,
                        ),
                      ])))
                  .toList()),
        ));
  }

  updateHomePage() {
    setState(() {
      // bookmarkList.clear();//already cleared in Function below
      // bookMarkValue.clear();//already cleared in Function below
      _getBookmark();
    });
  }

//API Calls
  //get user selected category newslist
  Future<void> getCatNewsByUser() async {
    /*  if (CUR_USERID != "" && CATID != "") { */
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var param = {
          ACCESS_KEY: access_key,
          CATEGORY_ID: CATID != "" ? CATID : "0", //CATID,
          USER_ID: CUR_USERID != "" ? CUR_USERID : "0", //CUR_USERID,
          LIMIT: perPage.toString(),
          OFFSET: offsetUser.toString(),
        };
        http.Response response = await http
            .post(Uri.parse(getNewsByUserCatApi), body: param, headers: headers)
            .timeout(Duration(seconds: timeOut));
        if (response.statusCode == 200) {
          var getData = json.decode(response.body);
          String error = getData["error"];
          if (error == "false") {
            totalUser = int.parse(getData["total"]);
            userNewsList.clear();
            tempUserNews.clear();

            var data = getData["data"];
            tempUserNews =
                (data as List).map((data) => new News.fromJson(data)).toList();
            userNewsList.addAll(tempUserNews);
          } else {
            _isUserLoadMore = false;
          }
          if (mounted)
            setState(() {
              _isUserLoading = false;
            });
        }
      } on TimeoutException catch (_) {
        showSnackBar(getTranslated(context, 'somethingMSg')!, context);
        setState(() {
          _isUserLoading = false;
          _isUserLoadMore = false;
        });
      }
    } else {
      showSnackBar(getTranslated(context, 'internetmsg')!, context);
      setState(() {
        _isUserLoading = false;
        _isUserLoadMore = false;
      });
    }
    /* } else {
      print("either User Id or category Id not found");
    } */
  }

  //used for mapping of Category wise News
  Future<List<News>> getCatNews(String catID) async {
    catNewsList.clear();
    if (catID != "") {
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        try {
          var param = {
            ACCESS_KEY: access_key,
            CATEGORY_ID: catID,
            USER_ID: CUR_USERID != "" ? CUR_USERID : "0",
            LIMIT: perPage.toString(),
            OFFSET: offsetUser.toString(),
          };
          // print(param);
          http.Response response = await http
              .post(Uri.parse(getNewsByCatApi), body: param, headers: headers)
              .timeout(Duration(seconds: timeOut));
          if (response.statusCode == 200) {
            var getData = json.decode(response.body);
            String error = getData["error"];
            if (error == "false") {
              var data = getData["data"];
              var tempCatNews = (data as List)
                  .map((data) => new News.fromJson(data))
                  .toList();
              catNewsList.addAll(tempCatNews);
              // print("subcat 1st element ${catNewsList[0].tagId}");
            } else {
              _isUserLoadMore = false;
            }
            if (mounted)
              setState(() {
                _isUserLoading = false;
              });
          }
        } on TimeoutException catch (_) {
          showSnackBar(getTranslated(context, 'somethingMSg')!, context);
          setState(() {
            _isUserLoading = false;
            _isUserLoadMore = false;
          });
        }
      } else {
        showSnackBar(getTranslated(context, 'internetmsg')!, context);
        setState(() {
          _isUserLoading = false;
          _isUserLoadMore = false;
        });
      }
    }
    return catNewsList;
  }

  //set bookmark of news using api
  _setBookmark(String status, String id) async {
    if (bookMarkValue.contains(id)) {
      // setState(() {
      bookMarkValue = List.from(bookMarkValue)..remove(id);
      // });
    } else {
      // setState(() {
      bookMarkValue = List.from(bookMarkValue)..add(id);
      //  });
    }

    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      var param = {
        ACCESS_KEY: access_key,
        USER_ID: CUR_USERID,
        NEWS_ID: id,
        STATUS: status,
      };

      http.Response response = await http
          .post(Uri.parse(setBookmarkApi), body: param, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      String error = getdata["error"];

      String msg = getdata["message"];

      if (error == "false") {
        /*  if (status == "0") {
          showSnackBar(msg, context);
        } else {
          showSnackBar(msg, context);
        } */
      }
    } else {
      showSnackBar(getTranslated(context, 'internetmsg')!, context);
    }
  }

//get latest news data list
  Future<void> getNews() async {
    //RecentNews
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var param = {
          ACCESS_KEY: access_key,
          LIMIT: perPage.toString(),
          USER_ID: CUR_USERID != "" ? CUR_USERID : "0"
        };

        http.Response response = await http
            .post(Uri.parse(getNewsApi), body: param, headers: headers)
            .timeout(Duration(seconds: timeOut));
        if (response.statusCode == 200) {
          var getData = json.decode(response.body);

          String error = getData["error"];
          if (error == "false") {
            normalNewsList.clear();
            recentNewsList.clear();

            totalRecent = int.parse(getData["total"]);

            tempList.clear();
            dataa = getData["data"];
            tempList =
                (dataa as List).map((data) => new News.fromJson(data)).toList();

            var copyList =
                (dataa as List).map((data) => new News.fromJson(data)).toList();
            copyList.toSet().toList();
            normalNewsList.addAll(copyList);

            tempNews2AllList = List.of(normalNewsList);
            if (tempNews2AllList.length != 0) tempNews2AllList.shuffle();

            recentNewsList.addAll(tempList);
          } else {
            _isRecentLoadMore = false;
          }
          if (mounted)
            setState(() {
              _isRecentLoading = false;
            });
        }
      } on TimeoutException catch (_) {
        showSnackBar(getTranslated(context, 'somethingMSg')!, context);
        setState(() {
          _isRecentLoading = false;
          _isRecentLoadMore = false;
        });
      }
    } else {
      showSnackBar(getTranslated(context, 'internetmsg')!, context);
      setState(() {
        _isRecentLoading = false;
        _isRecentLoadMore = false;
      });
    }
  }

  //get live news video
  Future<void> getLiveNews() async {
    //getLIVE News API
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      var parameter = {ACCESS_KEY: access_key};

      http.Response response = await http
          .post(Uri.parse(getLiveStreamingApi),
              body: parameter, headers: headers)
          .timeout(Duration(seconds: timeOut));
      var getdata = json.decode(response.body);
      String error = getdata["error"];
      var data = getdata["data"];
      if (error == "false") {
        liveList.clear();
        var tempLive = (data as List)
            .map((data) => LiveStreamingModel.fromJson(data))
            .toList();
        liveList.addAll(tempLive);
        isliveNews = true;
      } else {
        isliveNews = false;
      }
    } else
      showSnackBar(getTranslated(context, 'internetmsg')!, context);
  }

  Future<void> getCat() async {
    if (catList.isEmpty) {
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        if (!isLoading && mounted)
          setState(() {
            isLoading = true;
          });
        var param = {
          ACCESS_KEY: access_key,
        };
        http.Response response = await http
            .post(Uri.parse(getCatApi), body: param, headers: headers)
            .timeout(Duration(seconds: timeOut));
        var getdata = json.decode(response.body);
        String error = getdata["error"];
        if (error == "false") {
          catList.clear();
          subCat.clear();

          var data = getdata["data"];
          // print("data subcat - cat -- $data");
          var tempCategories = (data as List)
              .map((data) => new Category.fromJson(data))
              .toList();

          catList.addAll(tempCategories);
          // print(catList.length);
          for (int i = 0;
              i < (catList.length > len ? len : catList.length);
              i++) {
            List<News> tempList = await getCatNews(catList[i].id!);
            for (var j in tempList) {
              subCat.putIfAbsent(catList[i], () => <News>[]).add(j);
              // print( "subcat tag values - ${tempList[i].tagId} & ${tempList[i].tagName}");
            }
            tempList.clear();
          }
        }
        if (isLoading && mounted)
          setState(() {
            isLoading = false;
          });
      } else {
        setState(() {
          isLoading = false;
        });
        showSnackBar(getTranslated(context, 'internetmsg')!, context)!;
      }
    }
  }

  //get bookmark news list id using api
  Future<void> _getBookmark() async {
    //API-getBookmarkApi
    if (CUR_USERID != "") {
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        try {
          var param = {
            ACCESS_KEY: access_key,
            USER_ID: CUR_USERID,
          };
          http.Response response = await http
              .post(Uri.parse(getBookmarkApi), body: param, headers: headers)
              .timeout(Duration(seconds: timeOut));
          print("responce code****${response.statusCode}");

          var getdata = json.decode(response.body);

          String error = getdata["error"];
          if (error == "false") {
            bookmarkList.clear();
            var data = getdata["data"];

            bookmarkList =
                (data as List).map((data) => new News.fromJson(data)).toList();
            bookMarkValue.clear();

            for (int i = 0; i < bookmarkList.length; i++) {
              setState(() {
                bookMarkValue.add(bookmarkList[i].newsId);
                // print( "values in list of Bookmarks ${bookMarkValue[i].toString()}");
              });
            }
            if (mounted)
              setState(() {
                isLoading = false;
              });
          } else {
            setState(() {
              isLoadingMore = false;
              isLoading = false;
            });
          }
        } on TimeoutException catch (_) {
          showSnackBar(getTranslated(context, 'somethingMSg')!, context);
          setState(() {
            isLoading = false;
          });
        }
      } else {
        showSnackBar(getTranslated(context, 'internetmsg')!, context);
      }
    }
  }

  //get breaking news data list
  Future<void> getBreakingNews() async {
    //GetBreakingNews - API
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var param = {
          ACCESS_KEY: access_key,
        };
        http.Response response = await http
            .post(Uri.parse(getBreakingNewsApi), body: param, headers: headers)
            .timeout(Duration(seconds: timeOut));
        if (response.statusCode == 200) {
          var getData = json.decode(response.body);
          String error = getData["error"];
          if (error == "false") {
            breakingNewsList.clear();
            tempBreakList.clear();
            var data = getData["data"];
            // print("breaking news data $data");
            tempBreakList = (data as List)
                .map((data) => new BreakingNewsModel.fromJson(data))
                .toList();

            breakingNewsList.addAll(tempBreakList);
          }
          setState(() {
            _isBreakLoading = false;
          });
        }
      } on TimeoutException catch (_) {
        showSnackBar(getTranslated(context, 'somethingMSg')!, context);
        setState(() {
          _isBreakLoading = false;
        });
      }
    } else {
      showSnackBar(getTranslated(context, 'internetmsg')!, context);
      setState(() {
        _isBreakLoading = false;
      });
    }
  }

//get Video URL
  Future getNewsVideoURL() async {
    if (videoItems.isNotEmpty) return;
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        setState(() {
          isVideoLoading = true;
        });
        var parameter = {
          ACCESS_KEY: access_key,
          LIMIT: vidCount.toString(),
          OFFSET: offsetVal.toString(),
          USER_ID: CUR_USERID != "" ? CUR_USERID : "0"
        };
        // print(parameter);
        http.Response response = await http
            .post(Uri.parse(getNewsApi), headers: headers, body: parameter)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        String error = getdata["error"];

        if (error == "false") {
          // print("General News Data-  $getdata");
          if (mounted) {
            new Future.delayed(Duration.zero, () async {
              var newsData = getdata['data'];
              videoItems.clear();
              mainlist = (newsData as List)
                  .map((data) => new News.fromJson(data))
                  .toList();

              if (mainlist.length != 0) {
                int ii = 0;
                for (int i = 0; i < mainlist.length; i++) {
                  if ((mainlist[i].contentType == 'video_other') ||
                      (mainlist[i].contentType == 'video_upload') ||
                      (mainlist[i].contentType == 'video_youtube')) {
                    // print( "URLs - ${mainlist[i].contentValue} - ${mainlist[i].id}");
                    videoItems.add(mainlist[i]);
                    if (videoItems.length > 0 && ii < videoItems.length) {
                      if (mainlist[i].contentType != 'video_youtube') {
                        if (mainlist[i].contentType == 'video_upload') {
                          String? image = await getThumbnailImage(
                              videoItems[ii].contentValue!);
                          videoItems[ii].img = image;
                        } else {
                          videoItems[ii].img =
                              'assets/images/Placeholder_video.jpg';
                        }
                        ii++;
                      } else if (mainlist[i].contentType == 'video_youtube') {
                        String? videoId =
                            convertUrlToId(videoItems[ii].contentValue!);
                        String thumbnailUrl =
                            getThumbnail(videoId: videoId ?? "");
                        videoItems[ii].img = thumbnailUrl;
                        ii++;
                      }
                    }
                  }
                }
                offsetVal = offsetVal + vidCount;
              }
            }).then((value) {
              if (mounted)
                setState(() {
                  isVideoLoading = false;
                });
            });
          }
        } else {
          print("error in response");
        }
      } on TimeoutException catch (_) {
        showSnackBar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }
}
