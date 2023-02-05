// ignore_for_file: unused_field, must_be_immutable, unused_local_variable

import 'dart:async';
import 'dart:convert';

// import 'package:facebook_audience_network/ad/ad_native.dart';
//fbAud
import 'dart:io';

// import 'package:device_info_plus/device_info_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:news/Helper/FbAdHelper.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart'; //fbAud
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:news/Helper/AdHelper.dart';
import 'package:news/Helper/Widgets.dart';
import 'package:news/Home.dart';

// import 'package:news/ShowMoreNewsList.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:news/Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';

// import 'Login.dart';
import 'Model/Category.dart';
import 'Model/News.dart';
import 'NewsDetails.dart';
import 'NewsTag.dart';

class SubHome extends StatefulWidget {
  SubHome({
    this.scrollController,
    this.catList,
    this.curTabId,
    this.isSubCat,
    this.index,
    this.subCatId,
    required this.newsList,
  });

  ScrollController? scrollController;

  List<Category>? catList;
  String? curTabId;
  bool? isSubCat;
  int? index;
  String? subCatId;
  List<News> newsList = [];

  SubHomeState createState() => new SubHomeState();
}

class SubHomeState extends State<SubHome> {
  Key _key = new PageStorageKey({});
  bool _innerListIsScrolled = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isNetworkAvail = true;

  // bool enabled = true;
  // bool isProcessing = true;
  // bool isBookmarked = true;
  // bool isLiked = true;
  // bool isSubmitted = true;
  // bool isTagOpened = true;
  // bool isShared = true;
  // bool isSurvey = true;

  List<News> tempList = [];

  // List likeDislikeValue = [];
  List bookMarkValue = [];
  List<News> bookmarkList = [];
  double progress = 0;
  String fileSave = "";
  String otherImageSave = "";

  // var isDarkTheme;
  List<News> tempNewsList = [];
  int offset = 0;
  int total = 0;
  int? from;
  String? curTabId;

  // bool isFirst = false;
  bool _isLoading = true;
  bool _isLoadingMore = true;

  List<News> questionList = [];
  String? optId;
  int surveyIndex = 4; //3
  int fbAdIndex = 3; //5;
  int goAdIndex = 3;
  List<News> queResultList = [];
  List<News> tempResult = [];
  bool isClickable = false;
  List<News> comList = [];
  bool isFrom = false;
  late BannerAd _bannerAd;

  // String adv_type = "";

  bool _isBannerAdReady = true; //false;

  void _updateScrollPosition() {
    if (!_innerListIsScrolled &&
        widget.scrollController!.position.extentAfter == 0.0) {
      setState(() {
        _innerListIsScrolled = true;
      });
    } else if (_innerListIsScrolled &&
        widget.scrollController!.position.extentAfter > 0.0) {
      setState(() {
        _innerListIsScrolled = false;
        // Reset scroll positions of the TabBarView pages
        _key = new PageStorageKey({});
      });
    }
  }

  BannerAd createBannerAd() {
    // if (AdHelper.bannerAdUnitId != "") {
    _bannerAd = BannerAd(
      adUnitId:
          AdHelper.bannerAdUnitId, //'ca-app-pub-3940256099942544/6300978111',
      request: AdRequest(),
      size: AdSize.mediumRectangle, //mediumRectangle, //fullBanner,
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

  @override
  void initState() {
    super.initState();
    print("ads type = $adv_type");

    if (adv_type == "fb") {
      FbAdHelper.fbInit(); //fbAud
    }
    if (adv_type == "google") {
      if (AdHelper.bannerAdUnitId != "") {
        createBannerAd();
      }
    }
    getUserDetails();
    if (!widget.isSubCat!) {
      getNews();
    }
    callApi();
  }

  @override
  void dispose() {
    widget.scrollController!.removeListener(_updateScrollPosition);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SubHome oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subCatId != widget.subCatId) {
      updateData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: viewContent(),
    );
  }

  callApi() async {
    await _getBookmark();
  }

  Future<void> getUserDetails() async {
    CUR_USERID = (await getPrefrence(ID)) ?? "";

    setState(() {});
  }

  updateData() async {
    _isLoading = true;
    widget.newsList.clear();
    comList.clear();
    tempList.clear();
    _isLoadingMore = true;
    offset = 0;
    total = 0;
    getNews();
  }

  void loadMoreNews() {
    if (this.mounted) {
      setState(() {
        _isLoadingMore = true;
        if (offset < total) getNews();
      });
    }
  }

  viewContent() {
    return _isLoading
        ? contentWithBottomTextShimmer(context)
        : widget.newsList.length == 0 && !_isLoading
            ? Center(
                child: Text(getTranslated(context, 'no_news')!,
                    style: Theme.of(context).textTheme.subtitle1?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .fontColor
                            .withOpacity(0.8))))
            : Padding(
                padding: EdgeInsetsDirectional.only(top: 15.0, bottom: 5.0),
                child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                        loadMoreNews();
                      }
                      return true;
                    },
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: //widget.newsList.length + comList.length,
                          (offset < total)
                              ? comList.length + 1
                              : comList.length,
                      itemBuilder: (context, index) {
                        return (index == comList.length && _isLoadingMore)
                            ? Center(child: CircularProgressIndicator())
                            : comList[index].type == "survey"
                                ? comList[index].from == 2
                                    ? showSurveyQueResult(index)
                                    : showSurveyQue(index)
                                : newsItem(index);
                      },
                    )));
  }

//set likes of news using api
  _setLikesDisLikes(String status, String id, int index) async {
    /*  if (likeDislikeValue.contains(id)) {
      setState(() {
        likeDislikeValue = List.from(likeDislikeValue)..remove(id);
      });
    } else {
      setState(() {
        likeDislikeValue = List.from(likeDislikeValue)..add(id);
      });
    } */
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      var param = {
        ACCESS_KEY: access_key,
        USER_ID: CUR_USERID,
        NEWS_ID: id,
        STATUS: status,
      };

      Response response = await post(Uri.parse(setLikesDislikesApi),
              body: param, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      String error = getdata["error"];

      String msg = getdata["message"];
      print("$msg");

      if (error == "false") {
        if (status == "1") {
          comList[index].like = "1";
          comList[index].totalLikes =
              (int.parse(comList[index].totalLikes!) + 1).toString();
          /* widget.newsList[index].like = "1";
          widget.newsList[index].totalLikes =
              (int.parse(widget.newsList[index].totalLikes!) + 1).toString(); */
          // showSnackBar(getTranslated(context, 'like_succ')!, context);
        } else if (status == "0") {
          comList[index].like = "0";
          comList[index].totalLikes =
              (int.parse(comList[index].totalLikes!) - 1).toString();
          /* widget.newsList[index].like = "0";
          widget.newsList[index].totalLikes =
              (int.parse(widget.newsList[index].totalLikes!) - 1).toString(); */
          // showSnackBar(getTranslated(context, 'dislike_succ')!, context);
        }
        /* setState(() {
          isFirst = false;
        }); */
      }
    } else {
      showSnackBar(getTranslated(context, 'internetmsg')!, context);
    }
  }

  updateHomePage() {
    setState(() {
      bookmarkList.clear();
      bookMarkValue.clear();
      // likeDislikeValue.clear();
      // combineList(); //for likeDislike
      _getBookmark();
    });
  }

//set bookmark of news using api
  _setBookmark(String status, String id) async {
    if (bookMarkValue.contains(id)) {
      setState(() {
        bookMarkValue = List.from(bookMarkValue)..remove(id);
      });
    } else {
      setState(() {
        bookMarkValue = List.from(bookMarkValue)..add(id);
      });
    }

    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      var param = {
        ACCESS_KEY: access_key,
        USER_ID: CUR_USERID,
        NEWS_ID: id,
        STATUS: status,
      };

      Response response =
          await post(Uri.parse(setBookmarkApi), body: param, headers: headers)
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

//get bookmark news list id using api
  Future<void> _getBookmark() async {
    if (CUR_USERID != "") {
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        try {
          var param = {
            ACCESS_KEY: access_key,
            USER_ID: CUR_USERID,
          };
          Response response = await post(Uri.parse(getBookmarkApi),
                  body: param, headers: headers)
              .timeout(Duration(seconds: timeOut));

          var getdata = json.decode(response.body);

          String error = getdata["error"];
          if (error == "false") {
            bookmarkList.clear();
            var data = getdata["data"];

            bookmarkList =
                (data as List).map((data) => new News.fromJson(data)).toList();
            bookMarkValue.clear();

            for (int i = 0; i < bookmarkList.length; i++) {
              bookMarkValue.add(bookmarkList[i].newsId);
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

//get latest news data list
  Future<void> getNews() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var param = {
          ACCESS_KEY: access_key,
          LIMIT: perPage.toString(),
          OFFSET: offset.toString(),
          USER_ID: CUR_USERID != "" ? CUR_USERID : "0",
        };

        if (widget.subCatId == "0") {
          param[CATEGORY_ID] = widget.curTabId!;
        } else {
          param[SUBCAT_ID] = widget.subCatId!;
        }

        Response response = await post(Uri.parse(getNewsByCatApi),
                body: param, headers: headers)
            .timeout(Duration(seconds: timeOut));
        if (response.statusCode == 200) {
          var getData = json.decode(response.body);
          String error = getData["error"];
          if (error == "false") {
            total = int.parse(getData["total"]);
            if ((offset) < total) {
              tempList.clear();
              var data = getData["data"];
              tempList = (data as List)
                  .map((data) => new News.fromJson(data))
                  .toList();
              widget.newsList.addAll(tempList);

              offset = offset + perPage;

              await getQuestion();
            }
          } else {
            if (this.mounted)
              setState(() {
                _isLoadingMore = false;
                _isLoading = false;
              });
          }
        }
      } on TimeoutException catch (_) {
        showSnackBar(getTranslated(context, 'somethingMSg')!, context);
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } else {
      showSnackBar(getTranslated(context, 'internetmsg')!, context);
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  //get survey questions using api
  Future<void> getQuestion() async {
    if (CUR_USERID != "") {
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        try {
          var param = {ACCESS_KEY: access_key, USER_ID: CUR_USERID};

          Response response =
              await post(Uri.parse(getQueApi), body: param, headers: headers)
                  .timeout(Duration(seconds: timeOut));
          var getData = json.decode(response.body);

          String error = getData["error"];

          if (error == "false") {
            questionList.clear();
            var data = getData["data"];
            questionList = (data as List)
                .map((data) => new News.fromSurvey(data))
                .toList();
            combineList();

            if (this.mounted)
              setState(() {
                _isLoading = false;
              });
          } else {
            combineList();
            if (this.mounted)
              setState(() {
                _isLoading = false;
              });
          }
        } on TimeoutException catch (_) {
          showSnackBar(getTranslated(context, 'somethingMSg')!, context);
        }
      } else {
        showSnackBar(getTranslated(context, 'internetmsg')!, context);
      }
    } else {
      combineList();
      if (this.mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  combineList() {
    comList.clear();
    int cur = 0;
    for (int i = 0; i < widget.newsList.length; i++) {
      if (i != 0 && i % surveyIndex == 0) {
        if (questionList.length != 0 && questionList.length > cur) {
          comList.add(questionList[cur]);
          cur++;
        }
      }
      comList.add(widget.newsList[i]);

      /* likeDislikeValue.clear();
      for (int i = 0; i < comList.length; i++) {
        likeDislikeValue.add(comList[i].newsId);
      } */
    }
    /* for (int i = 0; i == comList.length; i++) {
      print("value of Like - ${comList[i].like}");
    } */
    print(
        "Length of ComList - ${comList.length} & questionList length is ${questionList.length} & length of News Widget list ${widget.newsList.length}");
  }

  _setQueResult(String queId, String optId, int index) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      var param = {
        ACCESS_KEY: access_key,
        USER_ID: CUR_USERID,
        QUESTION_ID: queId,
        OPTION_ID: optId
      };

      Response response =
          await post(Uri.parse(setQueResultApi), body: param, headers: headers)
              .timeout(Duration(seconds: timeOut));

      var getData = json.decode(response.body);

      String error = getData["error"];

      if (error == "false") {
        // showSnackBar(getTranslated(context, 'survey_sub_succ')!, context);
        setState(() {
          questionList.removeWhere((item) => item.id == queId);
          _getQueResult(queId, index);
        });
      }
    } else {
      showSnackBar(getTranslated(context, 'internetmsg')!, context);
    }
  }

  //get Question result list using api
  Future<void> _getQueResult(String queId, int index) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var param = {ACCESS_KEY: access_key, USER_ID: CUR_USERID};

        Response response = await post(Uri.parse(getQueResultApi),
                body: param, headers: headers)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        String error = getdata["error"];
        if (error == "false") {
          total = int.parse(getdata["total"]);
          tempResult.clear();
          var data = getdata["data"];
          tempResult =
              (data as List).map((data) => new News.fromSurvey(data)).toList();
          queResultList.addAll(tempResult);

          News model = queResultList.where((item) => item.id == queId).first;
          model.from = 2;

          setState(() {
            comList[index] = model;
          });
        }
      } on TimeoutException catch (_) {
        showSnackBar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      showSnackBar(getTranslated(context, 'internetmsg')!, context);
    }
  }

  showSurveyQue(int i) {
    return Padding(
        padding: EdgeInsets.only(top: 15.0),
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Theme.of(context).colorScheme.lightColor,
            ),
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: [
                Text(
                  comList[i].question!,
                  style: Theme.of(context).textTheme.headline6?.copyWith(
                      color: Theme.of(context).colorScheme.darkColor,
                      height: 1.0),
                ),
                Padding(
                    padding: EdgeInsetsDirectional.only(
                        top: 15.0, start: 7.0, end: 7.0),
                    child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comList[i].optionDataList!.length,
                        itemBuilder: (context, j) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 10.0),
                            child: /* AbsorbPointer(
                                absorbing: !isProcessing,
                                child: */
                                InkWell(
                              child: Container(
                                  height: 50,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: optId ==
                                              comList[i].optionDataList![j].id
                                          ? colors.primary.withOpacity(0.1)
                                          : isDark!
                                              ? colors.tempdarkColor
                                              : colors.bgColor),
                                  child: Text(
                                    comList[i].optionDataList![j].options!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2
                                        ?.copyWith(
                                            color: optId ==
                                                    comList[i]
                                                        .optionDataList![j]
                                                        .id
                                                ? colors.primary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .darkColor,
                                            height: 1.0),
                                    textAlign: TextAlign.center,
                                  )),
                              onTap: () {
                                if (mounted)
                                  setState(() {
                                    // isProcessing = false;
                                    optId = comList[i].optionDataList![j].id;
                                    // isProcessing = true;
                                  });
                              },
                            ),
                            // )//AbsorbPointer
                          );
                        })),
                Padding(
                  padding: EdgeInsets.only(top: 15.0),
                  child: /* AbsorbPointer(
                    absorbing: !isSurvey,
                    child: */
                      InkWell(
                    child: Container(
                      height: 40.0,
                      width: deviceWidth! * 0.35,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: colors.tempboxColor,
                          borderRadius: BorderRadius.circular(7.0)),
                      child: Text(
                        getTranslated(context, 'submit_btn')!,
                        style: Theme.of(this.context)
                            .textTheme
                            .subtitle1
                            ?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.6),
                      ),
                    ),
                    onTap: () async {
                      /* if (mounted)
                          setState(() {
                            isSurvey = false;
                          }); */
                      if (isRedundentClick(DateTime.now(), diff)) {
                        //inBetweenClicks
                        print('hold on, processing');
                        /* showSnackBar(
                              getTranslated(context, 'processing')!, context); */
                        return;
                      }
                      if (optId != null && optId != "") {
                        _setQueResult(comList[i].id!, optId!, i);
                      } else {
                        showSnackBar(
                            getTranslated(context, 'opt_sel')!, context);
                      }
                      diff = resetDiff;
                      /*  if (mounted)
                          setState(() {
                            isSurvey = true;
                          }); */
                    },
                  ),
                  // ),//AbsorbPointer
                )
              ],
            )));
  }

  showSurveyQueResult(int i) {
    return Padding(
        padding: EdgeInsets.only(top: 15.0),
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Theme.of(context).colorScheme.lightColor,
            ),
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: [
                Text(
                  comList[i].question!,
                  style: Theme.of(context).textTheme.headline6?.copyWith(
                      color: Theme.of(context).colorScheme.darkColor,
                      height: 1.0),
                ),
                Padding(
                    padding: EdgeInsetsDirectional.only(
                        top: 15.0, start: 7.0, end: 7.0),
                    child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comList[i].optionDataList!.length,
                        itemBuilder: (context, j) {
                          return Padding(
                            padding: EdgeInsetsDirectional.only(
                                bottom: 10.0, start: 15.0, end: 15.0),
                            child: LinearPercentIndicator(
                              animation: true,
                              animationDuration: 1000,
                              lineHeight: 40.0,
                              percent: double.parse(comList[i]
                                      .optionDataList![j]
                                      .percentage!) /
                                  100,
                              center: Text(
                                comList[i].optionDataList![j].percentage! + "%",
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                              barRadius: const Radius.circular(16),
                              progressColor: colors.primary,
                              isRTL: false,
                              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                            ),
                          );
                        })),
              ],
            )));
  }

  newsItem(int index) {
    List<String> tagList = [];
    DateTime time1 = DateTime.parse(comList[index].date!);

    if (comList[index].tagName! != "") {
      final tagName = comList[index].tagName!;
      tagList = tagName.split(',');
    }

    List<String> tagId = [];

    if (comList[index].tagId! != "") {
      tagId = comList[index].tagId!.split(",");
    }
    return Padding(
        padding: EdgeInsetsDirectional.only(
            top: index == 0 ? 0 : 15.0, start: 15, end: 15),
        child: Column(children: [
          //fbAud
          //check if ads are fb or google & platform is ios or android & load ads accordingly
          if (adv_type != "" &&
              adv_type != "unity" && //as unity doesn't support native ads
              (index != 0 && index % fbAdIndex == 0 && index % goAdIndex == 0))
            Padding(
                padding: EdgeInsets.only(bottom: 15.0),
                child: Container(
                    padding: EdgeInsets.all(7.0),
                    /*  FittedBox(
                    fit: BoxFit.fill,*/
                    height: 320,
                    //120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      //to match it with default ads Bgcolor //Theme.of(context).colorScheme.boxColor,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: (adv_type == "google") //google ads
                        ? (_isBannerAdReady) /* (goBannerId != "" || iosGoBannerId != "") && */
                            ? AdWidget(
                                key: UniqueKey(), ad: createBannerAd()..load())
                            : SizedBox.shrink()
                        : (FbAdHelper.nativeAdUnitId != "")
                            //(fbNativeUnitId != "" || iosFbNativeUnitId != "")
                            ? FacebookNativeAd(
                                /*  backgroundColor:
                                Theme.of(context).colorScheme.boxColor, */
                                placementId: FbAdHelper.nativeAdUnitId,
                                adType: Platform.isAndroid
                                    ? NativeAdType.NATIVE_AD
                                    : NativeAdType.NATIVE_AD_VERTICAL,
                                width: double.infinity,
                                height: 320,
                                //120,
                                keepAlive: true,
                                keepExpandedWhileLoading: false,
                                expandAnimationDuraion: 300,
                                listener: (result, value) {
                                  print("Native Ad: $result --> $value");
                                },
                              )
                            : SizedBox.shrink())),
          // : SizedBox.shrink(),
          //fbAud
          /* AbsorbPointer(
            absorbing: !enabled,
            child: */
          InkWell(
            child: Column(
              children: <Widget>[
                Stack(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: CachedNetworkImage(
                          imageUrl: comList[index].image!,
                          height: ContainerHeight,
                          // deviceHeight! / 4.2,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) {
                            return placeHolder();
                          },
                          errorWidget: (context, error, stackTrace) {
                            return errorWidget(
                                /* deviceHeight! / 4.2 */
                                ContainerHeight,
                                deviceWidth!);
                          },
                        )),
                    Positioned.directional(
                        textDirection: Directionality.of(context),
                        bottom: 7.0,
                        start: 7.0,
                        child: comList[index].tagName! != ""
                            ? SizedBox(
                                height: 16.0,
                                child: ListView.builder(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemCount:
                                        /*  tagList.length >= 2 ? 2 :  */ tagList
                                            .length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: EdgeInsetsDirectional.only(
                                            start: index == 0 ? 0 : 5.5),
                                        child: /* AbsorbPointer(
                                          absorbing: !isTagOpened,
                                          child:  */
                                            InkWell(
                                          child: Container(
                                              /* height: 16.0,
                                            width: 45, */
                                              height: 20.0,
                                              width: 65,
                                              alignment: Alignment.center,
                                              padding:
                                                  EdgeInsetsDirectional.only(
                                                      start: 3.0,
                                                      end: 3.0,
                                                      top: 1.0, //2.5,
                                                      bottom: 1.0),
                                              //2.5,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(10.0),
                                                    topRight:
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
                                                      fontSize: 8.5,
                                                    ),
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: true,
                                              )),
                                          onTap: () async {
                                            /*  if (mounted)
                                                setState(() {
                                                  isTagOpened = false;
                                                }); */

                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => NewsTag(
                                                    tagId: tagId[index],
                                                    tagName: tagList[index],
                                                    updateParent:
                                                        updateHomePage,
                                                  ),
                                                ));
                                            /* if (mounted)
                                                setState(() {
                                                  isTagOpened = true;
                                                }); */
                                          },
                                        ),
                                        // )//AbsorbPointer
                                      );
                                    }))
                            : SizedBox.shrink()),
                  ],
                ),
                Container(
                    alignment: Alignment.bottomLeft,
                    padding: EdgeInsetsDirectional.only(
                        top: 4.0, start: 5.0, end: 5.0),
                    child: Text(
                      comList[index].title!,
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
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .agoLabel
                                        .withOpacity(0.8))),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.only(start: 13.0),
                      child: /* AbsorbPointer(
                        absorbing: !isShared,
                        child:  */
                          InkWell(
                        child: Icon(Icons.share_rounded),
                        onTap: () async {
                          /* if (mounted)
                              setState(() {
                                isShared = false;
                              }); */
                          if (isRedundentClick(DateTime.now(), diff)) {
                            //inBetweenClicks
                            print('hold on, processing');
                            /* showSnackBar(
                              getTranslated(context, 'processing')!, context); */
                            return;
                          }
                          _isNetworkAvail = await isNetworkAvailable();
                          if (_isNetworkAvail) {
                            createDynamicLink(context, comList[index].id!,
                                index, comList[index].title!, false, false);
                          } else {
                            showSnackBar(getTranslated(context, 'internetmsg')!,
                                context);
                          }
                          diff = resetDiff;
                          /* if (mounted)
                              setState(() {
                                isShared = true;
                              }); */
                        },
                      ),
                      // ),//AbsorbPointer
                    ),
                    SizedBox(width: deviceWidth! / 99.0),
                    /* AbsorbPointer(
                      absorbing: !isBookmarked,
                      child:  */
                    InkWell(
                      child: bookMarkValue.contains(comList[index].id)
                          ? Icon(Icons.bookmark_added_rounded)
                          : Icon(Icons.bookmark_add_outlined),
                      onTap: () async {
                        /* if (mounted)
                            setState(() {
                              isBookmarked = false;
                            }); */
                        if (isRedundentClick(DateTime.now(), diff)) {
                          //inBetweenClicks
                          print('hold on, processing');
                          /* showSnackBar(
                              getTranslated(context, 'processing')!, context); */
                          return;
                        }
                        _isNetworkAvail = await isNetworkAvailable();
                        if (CUR_USERID != "") {
                          if (_isNetworkAvail) {
                            setState(() {
                              bookMarkValue.contains(comList[index].id!)
                                  ? _setBookmark("0", comList[index].id!)
                                  : _setBookmark("1", comList[index].id!);
                            });
                          } else {
                            showSnackBar(getTranslated(context, 'internetmsg')!,
                                context);
                          }
                        } else {
                          loginRequired(context);
                          /* Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Login(),
                                  )); */
                        }
                        diff = resetDiff;
                        /* if (mounted)
                            setState(() {
                              isBookmarked = true;
                            }); */
                      },
                    ),
                    // ),//AbsorbPointer
                    SizedBox(width: deviceWidth! / 99.0),
                    /* AbsorbPointer(
                      absorbing: !isLiked,
                      child: */
                    InkWell(
                      //LikeDislike
                      child: comList[index].like == "1"
                          // likeDislikeValue.contains(comList[index])
                          //comList[index].like == "1"
                          ? Icon(Icons.thumb_up_alt)
                          : Icon(Icons.thumb_up_off_alt),
                      onTap: () async {
                        /*  if (mounted)
                          setState(() {
                            isLiked = false;
                          }); */
                        if (isRedundentClick(DateTime.now(), diff)) {
                          //inBetweenClicks
                          print('hold on, processing');
                          /* showSnackBar(
                              getTranslated(context, 'processing')!, context); */
                          return;
                        }
                        _isNetworkAvail = await isNetworkAvailable();
                        if (CUR_USERID != "") {
                          if (_isNetworkAvail) {
                            // if (!isFirst) {
                            //   setState(() {
                            //     isFirst = true;
                            //   });
                            if (comList[index].like == "1") {
                              //(likeDislikeValue.contains(comList[index])) {
                              await _setLikesDisLikes(
                                  "0", comList[index].id!, index);
                              setState(() {});
                            } else {
                              await _setLikesDisLikes(
                                  "1", comList[index].id!, index);
                              setState(() {});
                            }
                            // }
                          } else {
                            showSnackBar(getTranslated(context, 'internetmsg')!,
                                context);
                          }
                        } else {
                          loginRequired(context);
                          /* Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Login(),
                                  )); */
                        }
                        diff = resetDiff;
                        /* if (mounted)
                          setState(() {
                            isLiked = true;
                          }); */
                      },
                    ),
                    //),AbsorbPointer
                  ],
                ),
              ],
            ),
            onTap: () {
              /* if (mounted) if (mounted)
                  setState(() {
                    enabled = false;
                  }); */
              News model = comList[index];
              List<News> recList = [];
              recList.addAll(widget.newsList); //comList
              print("length of list passed - ${recList.length}");
              recList.removeWhere((element) =>
                  element.id == widget.newsList[index].id); //comList
              print("length of list passed after deletion - ${recList.length}");
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => NewsDetails(
                        model: model,
                        index: index,
                        updateParent: updateHomePage,
                        id: model.id,
                        // isFav: false,
                        isDetails: true,
                        news: recList,
                      )));
              /* if (mounted)
                  setState(() {
                    enabled = true;
                  }); */
            },
          ),
          // ), //AbsorbPointer
          //survey
          /* (index % surveyIndex == 0 && questionList.length > 0)
              ? comList[index].from == 2
                  ? showSurveyQueResult(index)
                  : showSurveyQue(index)
              : SizedBox.shrink(), */
          //survey
        ]));
  }
}
