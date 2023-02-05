// ignore_for_file: must_be_immutable, unused_field, unnecessary_null_comparison, unnecessary_statements, non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';

// import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart';
import 'package:news/Helper/FbAdHelper.dart';
import 'package:news/Helper/unityAdHelper.dart';
import 'package:news/Home.dart';
import 'package:news/Model/BreakingNews.dart';
import 'package:news/Model/Comment.dart';
import 'package:news/Model/News.dart';
import 'package:news/NewsDetails.dart';
import 'package:news/NewsDetailsVideo.dart';
import 'package:news/NewsVideo.dart';
import 'package:news/ShowMoreNewsList.dart';
import 'package:shimmer/shimmer.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart' as unity;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'Helper/AdHelper.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Image_Preview.dart';

// import 'Login.dart';
import 'NewsTag.dart';

class NewsSubDetails extends StatefulWidget {
  final News? model;
  final int? index;
  final Function? updateParent;
  final String? id;
  final bool? isDetails;
  final bool? isBookmarked;
  final BreakingNewsModel? model1;
  final bool? fromShowMoreList;

  const NewsSubDetails(
      {Key? key,
      this.model,
      this.index,
      this.updateParent,
      this.id,
      this.isBookmarked,
      this.isDetails,
      this.model1,
      this.fromShowMoreList})
      : super(key: key);

  @override
  NewsSubDetailsState createState() => NewsSubDetailsState();
}

class NewsSubDetailsState extends State<NewsSubDetails> {
  /*static final AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );*/
  List<String> allImage = [];
  String? profile;
  bool _isNetworkAvail = true;
  int _fontValue = 15;
  int offset = 0;
  int total = 0;
  String comTotal = "";
  bool _isLoadNews = true;
  bool _isLoadMoreNews = true;
  List<News> tempList = [];
  List<News> newsList = [];
  List<News> bookmarkList = [];
  List<Comment> commentList = [];
  bool _isLoading = true;
  bool isLoadingmore = true;
  bool _isBookmark = false;
  bool comBtnEnabled = false;
  bool replyComEnabled = false;
  TextEditingController _commentC = new TextEditingController();
  TextEditingController _replyComC = new TextEditingController();
  TextEditingController reportC = new TextEditingController();
  final _pageController = PageController();
  int _curSlider = 0;
  bool comEnabled = false;
  bool isReply = false;
  int? replyComIndex;
  FlutterTts? _flutterTts;
  bool isPlaying = false;

  // bool isLikeBtnEnabled = true;
  bool isFirst = false;

  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  String? lanCode;
  int offsetNews = 0;
  int totalNews = 0;
  ScrollController controller = new ScrollController();
  ScrollController controller1 = new ScrollController();
  late BannerAd _bannerAd;

  bool _isBannerAdReady = false;

  final _controller = PageController();
  int sliderIndex = 0;

  @override
  void initState() {
    super.initState();
    /*  SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.light);  */ //byDefault light - because of SafeArea
    // setOverlayStyle();
    getUserDetails();
    initializeTts();
    callApi();
    allImage.clear();
    if (widget.isDetails!) {
      allImage.add(widget.model!.image!);
      if (widget.model!.imageDataList!.length != 0) {
        for (int i = 0; i < widget.model!.imageDataList!.length; i++) {
          allImage.add(widget.model!.imageDataList![i].otherImage!);
        }
      }
    } else {
      allImage.add(widget.model1!.image!);
    }

    if (adv_type == "unity") {
      unity.UnityAds.init(
          gameId: Platform.isAndroid ? unityGameID : iosUnityGameID,
          testMode: true,
          onComplete: () {
            print('Initialization Complete');
            setState(() {
              _isBannerAdReady = true;
            });
          },
          onFailed: (error, message) {
            setState(() {
              _isBannerAdReady = false;
            });
            print('Initialization Failed: $error $message');
          });
    }

    if (adv_type == "fb") {
      FbAdHelper.fbInit();
    }
    if (adv_type == "google") {
      _createBottomBannerAd();
    } //banner load

    controller.addListener(_scrollListener);
    controller1.addListener(_scrollListener1);

    _isBookmark = (widget.isBookmarked != null) ? widget.isBookmarked! : false;
  }

  @override
  void dispose() {
    if (widget.isDetails!) {
      isPlaying = false;
      _flutterTts!.stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPress, //onBackPress(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Container(
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                // color: Colors.white,
                width: deviceWidth,
                child: SingleChildScrollView(
                    child: Stack(children: <Widget>[
                  imageView(),
                  imageSliderDot(),
                  backBtn(),
                  videoBtn(),
                  allDetails(),
                  likeBtn(),
                ]))),
          ),
          //add banner ads here - outside scrollbar
          Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: setBannerAd()) //fbAud
          /* widget.index! % 2 == 0 ? setBannerAd() : SizedBox.shrink()) */
        ],
      ),
    );
  }

  setBannerAd() {
    print("check*****$adv_type*****${AdHelper.bannerAdUnitId}");
    if (adv_type == "google") {
      //google ads
      if (goBannerId != "" || iosGoBannerId != "") {
        if (_isBannerAdReady) {
          print("loaded****");
          return Padding(
            padding: EdgeInsetsDirectional.only(start: 5.0, end: 5.0),
            child: Container(
                width: double.maxFinite,
                height: _bannerAd.size.height.toDouble(),
                color: Colors.red,
                child: AdWidget(ad: _bannerAd)),
          );
        } else {
          print("ad not loaded yet");
        }
      }
    }
    if (adv_type == "fb") {
      //fb ads
      if (fbBannerId != null || iosFbBannerId != null) {
        return Container(
            child: FacebookBannerAd(
          placementId: FbAdHelper.bannerAdUnitId,
          bannerSize: BannerSize.STANDARD,
          listener: (result, value) {
            switch (result) {
              case BannerAdResult.ERROR:
                print("Error: $value");
                break;
              case BannerAdResult.LOADED:
                print("Loaded: $value");
                break;
              case BannerAdResult.CLICKED:
                print("Clicked: $value");
                break;
              case BannerAdResult.LOGGING_IMPRESSION:
                print("Logging Impression: $value");
                break;
            }
          },
        ));
      }
    }
    if (adv_type == "unity") {
      //unity ads
      return Container(
        width: double.maxFinite,
        height: 50,
        child: unity.UnityBannerAd(
          placementId: unityAdHelper.bannerAdUnitId,
          onLoad: (placementId) => print('Banner loaded: $placementId'),
          onClick: (placementId) => print('Banner clicked: $placementId'),
          onFailed: (placementId, error, message) =>
              print('Banner Ad $placementId failed: $error $message'),
        ),
      );
    }
  }

  callApi() async {
    _getBookmark();
    await getRelatedNews();
    await _getComment();
  }

  /* void _animateSlider() {
    Future.delayed(const Duration(seconds: 10)).then((_) {
      if (mounted) {
        int nextPage = _controller.hasClients
            ? _controller.page!.round() + 1
            : _controller.initialPage;

        if (nextPage == newsList.length) {
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
  } */

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  Widget showCoverageNews() {
    return Column(
      children: [
        Stack(
          children: [
            SizedBox(
              height: deviceHeight! / 2.9,
              width: double.infinity,
              child: PageView.builder(
                itemCount: newsList.length,
                scrollDirection: Axis.horizontal,
                controller: _controller,
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
                                imageUrl: newsList[index].image!,
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
                                News model = newsList[index];
                                List<News> tempList = [];
                                tempList.addAll(newsList);
                                tempList.removeAt(index);

                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        NewsDetails(
                                          model: model,
                                          index: index,
                                          updateParent: updateHomePage,
                                          id: model.id,
                                          // isFav: false,
                                          isDetails: true,
                                          news: tempList,
                                        )));
                              },
                            ),
                          )),
                      Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                              padding: EdgeInsetsDirectional.only(
                                  bottom: deviceHeight! / 18.9,
                                  start: deviceWidth! / 20.0,
                                  end: 5.0),
                              width: deviceWidth,
                              //TITLE
                              child: Text(
                                newsList[index].title!,
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
                      newsList,
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
                                  ? Theme.of(context).colorScheme.primary
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
                //resetOverlayStyle();
                //goto ShowMoreNewsList
                News model = newsList[0];
                List<News> tempList = [];
                tempList.addAll(newsList);
                String str1 = getTranslated(context, 'all_lbl')!;
                String str2 = getTranslated(context, 'news_lbl')!;
                String concatStr = str1 + " " + str2;
                Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => ShowMoreNewsList(
                              model: model,
                              index: 0,
                              updateParent: updateHomePage,
                              id: model.id,
                              // isFav: false,
                              isDetails: true,
                              news: tempList,
                              newsType: concatStr,
                              fromNewsDetails: true,
                            )))
                    /* .then((value) => setState(() {
                          /*  SystemChrome.setSystemUIOverlayStyle(
                              SystemUiOverlayStyle.light); */
                        })
                        ) */
                    ;
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.transparent,
                onPrimary: colors.primary,
                shadowColor: Colors.transparent,
              ),
            )

            /* Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.image,
                    color: Theme.of(context)
                        .colorScheme
                        .fontColor
                        .withOpacity(0.9)),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      //goto ShowMoreNewsList
                      News model = newsList[0];
                      List<News> tempList = [];
                      tempList.addAll(newsList);
                      String str1 = getTranslated(context, 'all_lbl')!;
                      String str2 = getTranslated(context, 'news_lbl')!;
                      String concatStr = str1 + " " + str2;
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => ShowMoreNewsList(
                                model: model,
                                index: 0,
                                updateParent: updateHomePage,
                                id: model.id,
                                // isFav: false,
                                isDetails: true,
                                news: tempList,
                                newsType: concatStr,
                              )));
                    },
                    child: Text(
                      getTranslated(context, 'view_full_coverage')!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.subtitle1?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .fontColor
                              .withOpacity(0.9),
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ) */
            ),
      ],
    );
  }

  void _createBottomBannerAd() {
    if (goBannerId != "" || iosGoBannerId != "") {
      print("inner*****$goBannerId");
      _bannerAd = BannerAd(
        adUnitId: AdHelper.bannerAdUnitId,
        request: AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (_) {
            setState(() {
              print("readyyyyy****");
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
  }

  //get prefrences
  getUserDetails() async {
    profile = await getPrefrence(PROFILE) ?? "";
    lanCode = await getPrefrence(LANGUAGE_CODE);

    getLocale().then((locale) {
      lanCode = locale.languageCode;
    });

    setState(() {});
  }

  initializeTts() {
    // if (widget.isDetails!) {// no need - as it is used in both type of news from now on
    _flutterTts = FlutterTts();

    _flutterTts!.setStartHandler(() async {
      if (this.mounted)
        setState(() {
          isPlaying = true;
        });
    });

    _flutterTts!.setCompletionHandler(() {
      if (this.mounted) {
        setState(() {
          isPlaying = false;
        });
      }
    });

    _flutterTts!.setErrorHandler((err) {
      if (this.mounted) {
        setState(() {
          print("error occurred: " + err);
          isPlaying = false;
        });
      }
    });
    // }
  }

  _speak(String Description) async {
    if (Description != null && Description.isNotEmpty) {
      await _flutterTts!.setVolume(volume);
      await _flutterTts!.setSpeechRate(rate);
      await _flutterTts!.setPitch(pitch);
      await _flutterTts!.getLanguages;
      List<dynamic> languages = await _flutterTts!.getLanguages;
      print(languages);
      await _flutterTts!.setLanguage(() {
        switch (lanCode) {
          case "en":
            print("en-US");
            return "en-US";
          case "es":
            print("es-ES");
            return "es-ES";
          case "hi":
            print("hi-IN");
            return "hi-IN";
          case "tr":
            print("tr-TR");
            return "tr-TR";
          case "pt":
            print("pt-PT");
            return "pt-PT";
          default:
            print("en-US");
            return "en-US";
        }
        /*   if (lanCode == "en") {
          print("en-US");
          return "es-US";
        } else if (lanCode == "es") {
          print("en-ES");
          return "es-ES";
        } else if (lanCode == "hi") {
          print("hi-IN");
          return "hi-IN";
        } else if (lanCode == "tr") {
          print("tr-TR");
          return "tr-TR";
        } else if (lanCode == "pt") {
          print("pt-PT");
          return "pt-PT";
        } else {
          print("en-US");
          return "en-US";
        } */
      }());
      int length = Description.length;
      if (length < 4000) {
        setState(() {
          isPlaying = true;
        });
        await _flutterTts!.speak(Description);
        _flutterTts!.setCompletionHandler(() {
          setState(() {
            _flutterTts!.stop();
            isPlaying = false;
          });
        });
      } else if (length < 8000) {
        String temp1 = Description.substring(0, length ~/ 2);
        // print(temp1.length);
        await _flutterTts!.speak(temp1);
        _flutterTts!.setCompletionHandler(() {
          setState(() {
            isPlaying = true;
          });
        });

        String temp2 = Description.substring(temp1.length, Description.length);
        await _flutterTts!.speak(temp2);
        _flutterTts!.setCompletionHandler(() {
          setState(() {
            isPlaying = false;
          });
        });
      } else if (length < 12000) {
        String temp1 = Description.substring(0, 3999);
        await _flutterTts!.speak(temp1);
        _flutterTts!.setCompletionHandler(() {
          setState(() {
            isPlaying = true;
          });
        });
        String temp2 = Description.substring(temp1.length, 7999);
        await _flutterTts!.speak(temp2);
        _flutterTts!.setCompletionHandler(() {
          setState(() {});
        });
        String temp3 = Description.substring(temp2.length, Description.length);
        await _flutterTts!.speak(temp3);
        _flutterTts!.setCompletionHandler(() {
          setState(() {
            isPlaying = false;
            print("execution complete");
          });
        });
      }
    }
  }

  Future _stop() async {
    var result = await _flutterTts!.stop();
    if (result == 1)
      setState(() {
        isPlaying = false;
      });
  }

  //get comment list using api
  Future<void> _getComment() async {
    if (widget.isDetails!) {
      if (comments_mode == "1") {
        _isNetworkAvail = await isNetworkAvailable();
        if (_isNetworkAvail) {
          try {
            var param = {
              ACCESS_KEY: access_key,
              NEWS_ID: widget.model!.id,
              LIMIT: perPage.toString(),
              OFFSET: offset.toString(),
              USER_ID: CUR_USERID != null && CUR_USERID != "" ? CUR_USERID : "0"
            };
            Response response = await post(Uri.parse(getCommnetByNewsApi),
                    body: param, headers: headers)
                .timeout(Duration(seconds: timeOut));

            var getdata = json.decode(response.body);

            String error = getdata["error"];
            if (error == "false") {
              comTotal = getdata["total"];
              total = int.parse(getdata["total"]);

              if ((offset) < total) {
                var data = getdata["data"];
                commentList = (data as List)
                    .map((data) => new Comment.fromJson(data))
                    .toList();
                // print(commentList.toList());
                offset = offset + perPage;
              }

              if (mounted)
                setState(() {
                  _isLoading = false;
                });
            }
          } on TimeoutException catch (_) {
            if (mounted)
              showSnackBar(getTranslated(context, 'somethingMSg')!, context);
            setState(() {
              _isLoading = false;
            });
          }
        } else {
          showSnackBar(getTranslated(context, 'internetmsg')!, context);
        }
      }
    }
  }

  //set bookmark of news using api
  _setBookmark(String status) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      var param = {
        ACCESS_KEY: access_key,
        USER_ID: CUR_USERID,
        NEWS_ID: widget.id,
        STATUS: status,
      };
      Response response =
          await post(Uri.parse(setBookmarkApi), body: param, headers: headers)
              .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      String error = getdata["error"];

      String msg = getdata["message"];
      print(msg);
      if (error == "false") {
        if (status == "0") {
          // showSnackBar(msg, context);
          setState(() {
            _isBookmark = false;
          });
          widget.updateParent!();
        } else {
          // showSnackBar(msg, context);
          setState(() {
            _isBookmark = true;
          });
          widget.updateParent!();
        }
      }
    } else {
      showSnackBar(getTranslated(context, 'internetmsg')!, context);
    }
  }

  _setComLikeDislike(String status, String comId) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      var param = {
        ACCESS_KEY: access_key,
        USER_ID: CUR_USERID,
        COMMENT_ID: comId,
        STATUS: status,
      };

      Response response = await post(Uri.parse(setLikeDislikeComApi),
              body: param, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getData = json.decode(response.body);

      String error = getData["error"];

      if (error == "false") {
        /* if (status == "1") {
          //   showSnackBar(getTranslated(context, 'com_like_msg')!, context);
        } else if (status == "2") {
          //   showSnackBar(getTranslated(context, 'com_dislike_msg')!, context);
        } else {
          // showSnackBar(getTranslated(context, 'com_update_msg')!, context);
        } */
      }
    } else {
      showSnackBar(getTranslated(context, 'internetmsg')!, context);
    }
  }

  //get bookmark news list using api
  _getBookmark() async {
    if (widget.isDetails!) {
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        if (CUR_USERID != null && CUR_USERID != "") {
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
              var data = getdata["data"];
              bookmarkList.clear();
              bookmarkList = (data as List)
                  .map((data) => new News.fromJson(data))
                  .toList();

              for (int i = 0; i < bookmarkList.length; i++) {
                if (bookmarkList[i].newsId == (widget.id)) {
                  _isBookmark = true;
                }
              }
              if (mounted)
                setState(() {
                  _isLoading = false;
                });
            }
          } on TimeoutException catch (_) {
            showSnackBar(getTranslated(context, 'somethingMSg')!, context);
          }
        }
      } else {
        showSnackBar(getTranslated(context, 'internetmsg')!, context);
      }
    }
  }

  /*  setDeleteComment(String id, int index, int from) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      var param = {
        ACCESS_KEY: access_key,
        USER_ID: CUR_USERID,
        COMMENT_ID: id,
      };
      Response response = await post(Uri.parse(setCommentDeleteApi),
              body: param, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);
      String error = getdata["error"];

      String msg = getdata["message"];
      if (error == "false") {
        if (from == 1) {
          setState(() {
            commentList = List.from(commentList)..removeAt(index);
          });
        } else {
          setState(() {
            commentList[replyComIndex!].replyComList =
                List.from(commentList[replyComIndex!].replyComList!)
                  ..removeAt(index);
          });
        }
        //  showSnackBar(getTranslated(context, 'com_del_succ')!, context);
      } else {
        showSnackBar(msg, context); //error = true
      }
    } else {
      showSnackBar(getTranslated(context, 'internetmsg')!, context);
    }
  } */
  setDeleteComment(String id, int index, int from) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      var param = {
        ACCESS_KEY: access_key,
        USER_ID: CUR_USERID,
        COMMENT_ID: id,
      };
      Response response = await post(Uri.parse(setCommentDeleteApi),
              body: param, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);
      String error = getdata["error"];

      String msg = getdata["message"];
      if (error == "false") {
        if (from == 1) {
          setState(() {
            commentList = List.from(commentList)..removeAt(index);
            if (commentList.isEmpty) {
              isReply = false;
            }
          });
        } else {
          setState(() {
            commentList[replyComIndex!].replyComList =
                List.from(commentList[replyComIndex!].replyComList!)
                  ..removeAt(index);
          });
        }
        //  showSnackBar(getTranslated(context, 'com_del_succ')!, context);
      } else {
        showSnackBar(msg, context); //error = true
      }
    } else {
      showSnackBar(getTranslated(context, 'internetmsg')!, context);
    }
  }

  //set comment by user using api
  Future<void> _setComment(String message, String parent_id) async {
    if (comments_mode == "1") {
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        var param = {
          ACCESS_KEY: access_key,
          USER_ID: CUR_USERID,
          PARENT_ID: parent_id,
          NEWS_ID: widget.id,
          MESSAGE: message,
        };
        Response response =
            await post(Uri.parse(setCommentApi), body: param, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        String error = getdata["error"];

        String msg = getdata["message"];

        comTotal = getdata["total"];

        if (error == "false") {
          //  showSnackBar(msg, context);
          var data = getdata["data"];
          commentList =
              (data as List).map((data) => new Comment.fromJson(data)).toList();
          setState(() {});

          if (parent_id == "0") {
            comBtnEnabled = false;
            _commentC.text = "";
          } else {
            replyComEnabled = false;
            _replyComC.text = "";
            setState(() {});
          }
        } else {
          showSnackBar(msg, context); //error = true
        }
      } else {
        showSnackBar(getTranslated(context, 'internetmsg')!, context);
      }
    }
  }

  Future<void> _setFlag(String message, String com_id) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      var param = {
        ACCESS_KEY: access_key,
        USER_ID: CUR_USERID,
        NEWS_ID: widget.id,
        MESSAGE: message,
        COMMENT_ID: com_id
      };
      Response response =
          await post(Uri.parse(setFlagApi), body: param, headers: headers)
              .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      String error = getdata["error"];

      String msg = getdata["message"];
      if (error == "false") {
        //  showSnackBar(getTranslated(context, 'report_success')!, context);
        reportC.text = "";
        setState(() {});
      } else {
        showSnackBar(msg, context); //error = true
      }
    } else {
      showSnackBar(getTranslated(context, 'internetmsg')!, context);
    }
  }

  //set likes/Dislikes of news using api
  _setLikesDisLikes(String status, String id) async {
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

      // String msg = getdata["message"];

      if (error == "false") {
        if (status == "1") {
          widget.model!.like = "1";
          widget.model!.totalLikes =
              (int.parse(widget.model!.totalLikes!) + 1).toString();
          //  showSnackBar(getTranslated(context, 'like_succ')!, context);
        } else if (status == "0") {
          widget.model!.like = "0";
          widget.model!.totalLikes =
              (int.parse(widget.model!.totalLikes!) - 1).toString();
          //  showSnackBar(getTranslated(context, 'dislike_succ')!, context);
        }
        setState(() {
          isFirst = false;
        });
        if (this.mounted)
          setState(() {
            _isLoading = false;
          });
      }
    } else {
      showSnackBar(getTranslated(context, 'internetmsg')!, context);
    }
  }

  //set not comment of news text
  Widget getNoItem() {
    return Text(
      getTranslated(context, 'com_nt_avail')!,
      textAlign: TextAlign.center,
    );
  }

  imageView() {
    return Container(
        height: deviceHeight! * 0.42,
        width: double.maxFinite, //double.infinity,
        child: widget.isDetails!
            ? PageView.builder(
                itemCount: allImage.length,
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _curSlider = index;
                  });
                },
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    child: CachedNetworkImage(
                      fadeInDuration: Duration(milliseconds: 150),
                      imageUrl: allImage[index],
                      fit: BoxFit.cover,
                      //fill,
                      height: deviceHeight! * 0.42,
                      width: double.infinity,
                      errorWidget: (context, error, stackTrace) =>
                          errorWidget(deviceHeight! * 0.42, double.infinity),
                      placeholder: (context, url) {
                        return placeHolder();
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => ImagePreview(
                                    index: index,
                                    imgList: allImage,
                                    isNetworkAvail: _isNetworkAvail),
                              ))
                          /* .then((value) => setState(
                              () {})) */
                          ; //to reload data on back focus to screen
                    },
                  );
                })
            : CachedNetworkImage(
                fadeInDuration: Duration(milliseconds: 150),
                imageUrl: widget.isDetails!
                    ? widget.model!.image!
                    : widget.model1!.image!,
                fit: BoxFit.cover,
                //fill,
                height: deviceHeight! * 0.42,
                width: double.infinity,
                errorWidget: (context, error, stackTrace) =>
                    errorWidget(deviceHeight! * 0.42, double.infinity),
                placeholder: (context, url) {
                  return placeHolder();
                },
              ));
  }

  imageSliderDot() {
    return widget.isDetails!
        ? allImage.length <= 1
            ? SizedBox.shrink()
            : Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    margin: EdgeInsets.only(top: deviceHeight! / 2.6 - 23),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: map<Widget>(
                        allImage,
                        (index, url) {
                          return Container(
                              width: _curSlider == index ? 10.0 : 8.0,
                              height: _curSlider == index ? 10.0 : 8.0,
                              margin: EdgeInsets.symmetric(horizontal: 1.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _curSlider == index
                                    ? colors.bgColor
                                    : colors.bgColor.withOpacity((0.5)),
                              ));
                        },
                      ),
                    )))
        : SizedBox.shrink();
  }

  backBtn() {
    return Container(
        padding: EdgeInsetsDirectional.only(top: 20.0, start: 20.0), //top: 50.0
        child: InkWell(
          child: ClipRRect(
              borderRadius: BorderRadius.circular(52.0),
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                      alignment: Alignment.center,
                      height: 39,
                      width: 39,
                      decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .likeContainerColor
                              .withOpacity(0.7),
                          shape: BoxShape.circle),
                      child: Icon(Icons.keyboard_backspace_rounded)))),
          onTap: () {
            //resetOverlayStyle();
            if (widget.fromShowMoreList == true) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            } else {
              Navigator.pop(context);
            }
            //Navigator.pop(context);
          },
        ));
  }

  Future<bool> onBackPress() {
    //resetOverlayStyle();
    // Navigator.of(context).popUntil((route) => route.isFirst);
    //Navigator.pop(context);

    if (widget.fromShowMoreList == true) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  /*  setOverlayStyle() {
    // setState(() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Theme.of(context).colorScheme.lightColor,
      //.withOpacity(0.7), //Colors.white24, //.transparent,
      statusBarIconBrightness: !isDark! ? Brightness.dark : Brightness.light,
      statusBarBrightness: !isDark! ? Brightness.dark : Brightness.light,
      //for iOS
    ));
    // });
  } */

  /* resetOverlayStyle() {
    // setState(() {
     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: !isDark! ? Brightness.dark : Brightness.light,
      statusBarBrightness: !isDark! ? Brightness.dark : Brightness.light,
      //for iOS
    ));
    // });
  } */

  videoBtn() {
    return widget.isDetails!
        ? widget.model!.contentType == "video_upload" ||
                widget.model!.contentType == "video_youtube" ||
                widget.model!.contentType == "video_other"
            ? Positioned.directional(
                textDirection: Directionality.of(context),
                top: 20.0,
                end: 20.0,
                child: InkWell(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            height: 39,
                            width: 39,
                            // padding: EdgeInsets.all(8),
                            child: Center(
                                child: Icon(
                              Icons.play_circle_fill_rounded,
                              color: Theme.of(context)
                                  .colorScheme
                                  .likeContainerColor,
                            )),
                          ))),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewsVideo(
                            model: widget.model,
                            from: 1,
                          ),
                        )) /* .then((value) => setState(() {})) */;
                  },
                ))
            : SizedBox.shrink()
        : SizedBox.shrink();
  }

  changeFontSizeSheet() {
    showModalBottomSheet<dynamic>(
        context: context,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50), topRight: Radius.circular(50))),
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (BuildContext context, setStater) {
            return Container(
                padding: EdgeInsetsDirectional.only(
                    bottom: 20.0, top: 5.0, start: 20.0, end: 20.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(top: 30.0, bottom: 30.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.text_fields_rounded),
                            Padding(
                                padding:
                                    EdgeInsetsDirectional.only(start: 15.0),
                                child: Text(
                                  getTranslated(context, 'txtSize_lbl')!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .fontColor),
                                )),
                          ],
                        )),
                    SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.red[700],
                          inactiveTrackColor: Colors.red[100],
                          trackShape: RoundedRectSliderTrackShape(),
                          trackHeight: 4.0,
                          thumbShape:
                              RoundSliderThumbShape(enabledThumbRadius: 12.0),
                          thumbColor: Colors.redAccent,
                          overlayColor: Colors.red.withAlpha(32),
                          overlayShape:
                              RoundSliderOverlayShape(overlayRadius: 28.0),
                          tickMarkShape: RoundSliderTickMarkShape(),
                          activeTickMarkColor: Colors.red[700],
                          inactiveTickMarkColor: Colors.red[100],
                          valueIndicatorShape:
                              PaddleSliderValueIndicatorShape(),
                          valueIndicatorColor: Colors.redAccent,
                          valueIndicatorTextStyle: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        child: Slider(
                          label: '$_fontValue',
                          value: _fontValue.toDouble(),
                          activeColor: colors.primary,
                          min: 15,
                          max: 40,
                          divisions: 10,
                          onChanged: (value) {
                            setStater(() {
                              setState(() {
                                _fontValue = value.round();
                                setPrefrence(font_value, _fontValue.toString());
                              });
                            });
                          },
                        )),
                  ],
                ));
          });
        });
  }

  allRowBtn() {
    //all options bydefault & only 2 options in Breaking News
    return widget.isDetails!
        ? Padding(
            padding: EdgeInsetsDirectional.only(end: 110),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  child: Column(
                    children: [
                      Icon(Icons.insert_comment_rounded),
                      Padding(
                          padding: EdgeInsetsDirectional.only(top: 4.0),
                          child: Text(
                            getTranslated(context, 'com_lbl')!,
                            style: Theme.of(this.context)
                                .textTheme
                                .caption
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .fontColor
                                        .withOpacity(0.8),
                                    fontSize: 9.0),
                          ))
                    ],
                  ),
                  onTap: () {
                    if (isRedundentClick(DateTime.now(), diff)) {
                      //inBetweenClicks
                      print('hold on, processing');
                      /* showSnackBar(
                              getTranslated(context, 'processing')!, context); */
                      return;
                    }
                    setState(() {
                      if (CUR_USERID != "") {
                        //allow comment only when User is loggedIn
                        comEnabled = true;
                      } else {
                        //resetOverlayStyle();
                        loginRequired(context);
                      }
                      diff = resetDiff;
                    });
                  },
                ),
                Padding(
                  padding: EdgeInsetsDirectional.zero,
                  child: InkWell(
                    child: setShareBtn(),
                    /* Column(
                      children: [
                        Icon(Icons.share_rounded),
                        Padding(
                            padding: EdgeInsetsDirectional.only(top: 4.0),
                            child: Text(
                              getTranslated(context, 'share_lbl')!,
                              style: Theme.of(this.context)
                                  .textTheme
                                  .caption
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .fontColor
                                          .withOpacity(0.8),
                                      fontSize: 9.0),
                            ))
                      ],
                    ), */
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
                        createDynamicLink(context, widget.model!.id!,
                            widget.index!, widget.model!.title!, false, false);
                      } else {
                        showSnackBar(
                            getTranslated(context, 'internetmsg')!, context);
                      }
                      diff = resetDiff;
                    },
                  ),
                ),
                Padding(
                  // SAVE
                  padding: EdgeInsetsDirectional.zero,
                  child: InkWell(
                    child: Column(
                      children: [
                        Icon(
                          _isBookmark
                              ? Icons.bookmark_added_rounded
                              : Icons.bookmark_add_outlined,
                        ),
                        Padding(
                            padding: EdgeInsetsDirectional.only(top: 4.0),
                            child: Text(
                              getTranslated(context, 'save_lbl')!,
                              style: Theme.of(this.context)
                                  .textTheme
                                  .caption
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .fontColor
                                          .withOpacity(0.8),
                                      fontSize: 9.0),
                            ))
                      ],
                    ),
                    onTap: () async {
                      if (isRedundentClick(DateTime.now(), diff)) {
                        //inBetweenClicks
                        print('hold on, processing');
                        /* showSnackBar(
                              getTranslated(context, 'processing')!, context); */
                        return;
                      }
                      if (CUR_USERID != "") {
                        _isNetworkAvail = await isNetworkAvailable();
                        if (_isNetworkAvail) {
                          _isBookmark ? _setBookmark("0") : _setBookmark("1");
                        } else {
                          showSnackBar(
                              getTranslated(context, 'internetmsg')!, context);
                        }
                      } else {
                        //resetOverlayStyle();
                        loginRequired(context);
                      }
                      diff = resetDiff;
                    },
                  ),
                ),
                Padding(
                    //TEXTSIZE
                    padding: EdgeInsetsDirectional.zero,
                    child: InkWell(
                      child: Column(
                        children: [
                          Icon(Icons.text_fields_rounded),
                          Padding(
                              padding: EdgeInsetsDirectional.only(top: 4.0),
                              child: Text(
                                getTranslated(context, 'txtSize_lbl')!,
                                style: Theme.of(this.context)
                                    .textTheme
                                    .caption
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor
                                            .withOpacity(0.8),
                                        fontSize: 9.0),
                              ))
                        ],
                      ),
                      onTap: () {
                        changeFontSizeSheet();
                      },
                    )),
                Padding(
                    padding: EdgeInsetsDirectional.zero,
                    child: InkWell(
                      child: setSpeakBtn(),
                      /* Column(
                        children: [
                          Icon(Icons.speaker_phone_rounded),
                          Padding(
                              padding: EdgeInsetsDirectional.only(top: 4.0),
                              child: Text(
                                getTranslated(context, 'speakLoud_lbl')!,
                                style: Theme.of(this.context)
                                    .textTheme
                                    .caption
                                    ?.copyWith(
                                        color: isPlaying
                                            ? colors.primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .fontColor
                                                .withOpacity(0.8),
                                        fontSize: 9.0),
                              ))
                        ],
                      ), */
                      onTap: () {
                        if (isPlaying) {
                          _stop();
                        } else {
                          final document = parse(widget.model!.desc);
                          String parsedString =
                              parse(document.body!.text).documentElement!.text;
                          _speak(parsedString);
                        }
                      },
                    )),
              ],
            ),
          )
        : Row(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                  //TEXTSIZE
                  padding: EdgeInsetsDirectional.zero,
                  child: InkWell(
                    child: setTextSize(),
                    onTap: () {
                      changeFontSizeSheet();
                    },
                  )),
              Padding(
                padding: EdgeInsetsDirectional.only(start: 8.0),
                child: InkWell(
                  child: setSpeakBtn(),
                  onTap: () {
                    if (isPlaying) {
                      _stop();
                    } else {
                      final document = parse(widget.model1!.desc);
                      String parsedString =
                          parse(document.body!.text).documentElement!.text;
                      _speak(parsedString);
                    }
                  },
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(start: 8.0),
                child: InkWell(
                  child: setShareBtn(),
                  onTap: () async {
                    if (isRedundentClick(DateTime.now(), diff)) {
                      //inBetweenClicks
                      print('hold on, processing');
                      /* showSnackBar(
                              getTranslated(context, 'processing')!, context); */
                      return;
                    }
                    print(
                        "values to share - ${widget.model1!.id!} - ${widget.index!} - ${widget.model1!.title!}");
                    _isNetworkAvail = await isNetworkAvailable();
                    if (_isNetworkAvail) {
                      createDynamicLink(context, widget.model1!.id!,
                          widget.index!, widget.model1!.title!, false, true);
                    } else {
                      showSnackBar(
                          getTranslated(context, 'internetmsg')!, context);
                    }
                    diff = resetDiff;
                  },
                ),
              ),
            ],
          ); //SizedBox.shrink();
  }

  setShareBtn() {
    return Column(
      children: [
        Icon(Icons.share_rounded),
        Padding(
            padding: EdgeInsetsDirectional.only(top: 4.0),
            child: Text(
              getTranslated(context, 'share_lbl')!,
              style: Theme.of(this.context).textTheme.caption?.copyWith(
                  color:
                      Theme.of(context).colorScheme.fontColor.withOpacity(0.8),
                  fontSize: 9.0),
            ))
      ],
    );
  }

  setSpeakBtn() {
    return Column(
      children: [
        Icon(Icons.speaker_phone_rounded),
        Padding(
            padding: EdgeInsetsDirectional.only(top: 4.0),
            child: Text(
              getTranslated(context, 'speakLoud_lbl')!,
              style: Theme.of(this.context).textTheme.caption?.copyWith(
                  color: isPlaying
                      ? colors.primary
                      : Theme.of(context)
                          .colorScheme
                          .fontColor
                          .withOpacity(0.8),
                  fontSize: 9.0),
            ))
      ],
    );
  }

  setTextSize() {
    return Column(
      children: [
        Icon(Icons.text_fields_rounded),
        Padding(
            padding: EdgeInsetsDirectional.only(top: 4.0),
            child: Text(
              getTranslated(context, 'txtSize_lbl')!,
              style: Theme.of(this.context).textTheme.caption?.copyWith(
                  color:
                      Theme.of(context).colorScheme.fontColor.withOpacity(0.8),
                  fontSize: 9.0),
            ))
      ],
    );
  }

  dateView() {
    DateTime? time1;
    if (widget.isDetails!) {
      time1 = DateTime.parse(widget.model!.date!);
    }
    return widget.isDetails!
        ? !isReply
            ? !comEnabled
                ? Padding(
                    padding: EdgeInsetsDirectional.only(top: 8.0),
                    child: Text(
                      convertToAgo(context, time1!, 0)!,
                      style: Theme.of(this.context).textTheme.caption?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .fontColor
                              .withOpacity(0.8),
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600),
                    ),
                  )
                : SizedBox.shrink()
            : SizedBox.shrink()
        : SizedBox.shrink();
  }

  tagView() {
    // print("tags in NewsDetails - ${widget.model!.tagId} -- ${widget.model!.tagName}");
    List<String> tagList = [];
    if (widget.isDetails!) {
      if (widget.model!.tagName! != "") {
        final tagName = widget.model!.tagName!;
        tagList = tagName.split(',');
      }
    }
    List<String> tagId = [];
    if (widget.isDetails!) {
      if (widget.model!.tagId! != "") {
        tagId = widget.model!.tagId!.split(",");
      }
    }
    return widget.isDetails!
        ? !isReply && !comEnabled && widget.model!.tagName! != ""
            ? Padding(
                padding: EdgeInsetsDirectional.only(top: 15.0), //8.0
                child: SizedBox(
                    height: 20.0,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(tagList.length, (index) {
                          return Padding(
                              padding: EdgeInsetsDirectional.only(
                                  start: index == 0 ? 0 : 7),
                              child: InkWell(
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(3.0),
                                    child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 30, sigmaY: 30),
                                        child: Container(
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
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .skipColor,
                                            ),
                                            child: Text(
                                              tagList[index],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2
                                                  ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .likeContainerColor,
                                                    fontSize: 11,
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: true,
                                            )))),
                                onTap: () {
                                  //resetOverlayStyle();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => NewsTag(
                                          tagId: tagId[index],
                                          tagName: tagList[index],
                                          updateParent: updateHomePage,
                                        ),
                                      )) /* .then((value) => setState(() {})) */;
                                },
                              ));
                        }),
                      ),
                    )))
            : SizedBox.shrink()
        // : SizedBox.shrink()
        // : SizedBox.shrink()
        : SizedBox.shrink();
  }

  titleView() {
    return !isReply
        ? !comEnabled
            ? Padding(
                padding: EdgeInsetsDirectional.only(top: 6.0),
                child: Text(
                  widget.isDetails!
                      ? widget.model!.title!
                      : widget.model1!.title!,
                  style: Theme.of(this.context).textTheme.subtitle1?.copyWith(
                      color: Theme.of(context).colorScheme.fontColor,
                      fontWeight: FontWeight.w600),
                ),
              )
            : SizedBox.shrink()
        : SizedBox.shrink();
  }

  descView() {
    return !isReply
        ? !comEnabled
            ? Padding(
                padding: EdgeInsets.only(top: 5.0),
                child: HtmlWidget(
                  // the first parameter (`html`) is required
                  widget.isDetails!
                      ? widget.model!.desc!
                      : widget.model1!.desc!,

                  onTapUrl: (String? url) async {
                    if (await canLaunchUrl(Uri.parse(url!))) {
                      await launchUrl(Uri.parse(url));
                      return true;
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  onErrorBuilder: (context, element, error) =>
                      Text('$element error: $error'),
                  onLoadingBuilder: (context, element, loadingProgress) =>
                      Center(child: CircularProgressIndicator()),

                  renderMode: RenderMode.column,

                  // set the default styling for text
                  textStyle: TextStyle(fontSize: _fontValue.toDouble()),
                  customWidgetBuilder: (element) {
                    /*  if (element.toString() == "<html iframe>") {
                      print("inner");
                      return NewsDetailsVideo(
                        src: element.attributes["src"],
                        type: "1",
                      );
                    } */
                    /* if (element.toString() == "<html iframe>") {
                      print("inner");
                      return Container(
                        height: 180, //250,
                        width: deviceWidth,
                        padding: EdgeInsets.zero,
                        color: Colors.red,
                        child: NewsDetailsVideo(
                          src: element.attributes["src"],
                          type: "1",
                        ),
                      );
                    }
                    if (element.toString() == "<html video>") {
                      return Container(
                          height: 250,
                          width: deviceWidth,
                          color: Colors.green,
                          padding: EdgeInsets.zero,
                          child: NewsDetailsVideo(
                            type: "2",
                            src: element.outerHtml,
                          ));
                    } */
                    if ((element.toString() == "<html iframe>") ||
                        (element.toString() == "<html video>")) {
                      return FittedBox(
                        fit: BoxFit.fill,
                        child: Container(
                            height: 220, //250,
                            width: deviceWidth,
                            color: colors.transparentColor,
                            child: (element.toString() == "<html iframe>")
                                ? NewsDetailsVideo(
                                    src: element.attributes["src"],
                                    type: "1",
                                  )
                                : NewsDetailsVideo(
                                    //"<html video>"
                                    type: "2",
                                    src: element.outerHtml,
                                  )),
                      );
                    }
                    /* if (element.toString() == "<html video>") {
                      return FittedBox(
                        fit: BoxFit.fill,
                        child: Container(
                          color: colors.transparentColor,
                          height: 220, // 250,
                          width: deviceWidth,
                          child: NewsDetailsVideo(
                            type: "2",
                            src: element.outerHtml,
                          ),
                        ),
                      );
                    } */
                    return null;
                  },
                  // turn on selectable if required (it's disabled by default)
                  isSelectable: true,
                ))
            : SizedBox.shrink()
        : SizedBox.shrink();
  }

  allDetails() {
    return Padding(
        padding: EdgeInsets.only(top: deviceHeight! / 2.7),
        // 2.6
        child: Container(
          padding:
              EdgeInsetsDirectional.only(top: 20.0, start: 20.0, end: 20.0),
          width: double.maxFinite, //deviceWidth,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              color: isDark! ? colors.darkModeColor : colors.bgColor),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                allRowBtn(),
                tagView(),
                dateView(),
                titleView(),
                descView(),
                widget.isDetails!
                    ? !isReply
                        ? comEnabled
                            ? commentView()
                            : SizedBox.shrink()
                        : SizedBox.shrink()
                    : SizedBox.shrink(),
                widget.isDetails!
                    ? isReply
                        ? replyCommentView()
                        : SizedBox.shrink()
                    : SizedBox.shrink(),
                viewRelatedContent()
              ]),
        ));
  }

  likeBtn() {
    return widget.isDetails!
        ? Positioned.directional(
            textDirection: Directionality.of(context),
            top: deviceHeight! / 2.90, //2.80,
            end: deviceWidth! / 8.5,
            child: Column(children: [
              InkWell(
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(52.0),
                    child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          alignment: Alignment.center,
                          height: 39,
                          width: 39,
                          decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .likeContainerColor
                                  .withOpacity(0.7),
                              shape: BoxShape.circle),
                          child: widget.model!.like == "1"
                              ? Icon(Icons.thumb_up_alt)
                              : Icon(Icons.thumb_up_off_alt),
                        ))),
                onTap: () async {
                  if (isRedundentClick(DateTime.now(), diff)) {
                    //inBetweenClicks
                    print('hold on, processing');
                    /* showSnackBar(
                              getTranslated(context, 'processing')!, context); */
                    return;
                  }
                  if (CUR_USERID != "") {
                    if (_isNetworkAvail) {
                      if (!isFirst) {
                        setState(() {
                          isFirst = true;
                        });
                        if (widget.model!.like == "1") {
                          await _setLikesDisLikes("0", widget.id!);
                          setState(() {});
                        } else {
                          await _setLikesDisLikes("1", widget.id!);
                          setState(() {});
                        }
                      }
                    } else {
                      showSnackBar(
                          getTranslated(context, 'internetmsg')!, context);
                    }
                  } else {
                    //resetOverlayStyle();
                    loginRequired(context);
                    /* Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    ); */
                  }
                  diff = resetDiff;
                },
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(
                  top: 5.0,
                ),
                child: Text(
                  widget.model!.totalLikes != "0"
                      ? widget.model!.totalLikes! +
                          " " +
                          getTranslated(context, 'like_lbl')!
                      : "",
                  style: Theme.of(this.context).textTheme.caption?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .fontColor
                            .withOpacity(0.7),
                      ),
                ),
              )
            ]))
        : SizedBox.shrink();
  }

  _scrollListener() {
    if (controller.positions.last.pixels >=
            controller.positions.last.maxScrollExtent &&
        !controller.positions.last.outOfRange) {
      if (this.mounted) {
        setState(() {
          _isLoadMoreNews = true;

          if (offsetNews < totalNews) getRelatedNews();
        });
      }
    }
  }

  _scrollListener1() {
    if (controller1.offset >= controller1.position.maxScrollExtent &&
        !controller1.position.outOfRange) {
      if (this.mounted) {
        setState(() {
          isLoadingmore = true;

          if (offset < total) _getComment();
        });
      }
    }
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
                          top: 15.0, start: i == 0 ? 0 : 6.0),
                      child: Stack(children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.grey.withOpacity(0.6)),
                          height: 240.0,
                          width: 195.0,
                        ),
                        Positioned.directional(
                            textDirection: Directionality.of(context),
                            bottom: 7.0,
                            start: 7,
                            end: 7,
                            height: 99,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.grey,
                              ),
                            )),
                      ])))
                  .toList()),
        ));
  }

  viewRelatedContent() {
    return widget.isDetails!
        ? !isReply && !comEnabled && !_isLoadNews && newsList.length != 0
            ? Padding(
                padding: EdgeInsetsDirectional.only(
                  top: 15.0,
                  bottom: 15.0,
                ),
                child: Column(children: [
                  Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(bottom: 15.0),
                        child: Text(getTranslated(context, 'related_news')!,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.fontColor,
                                    fontWeight: FontWeight.w600)),
                      )),
                  showCoverageNews()
                ]))
            : SizedBox.shrink()
        : SizedBox.shrink();
  }

  newsItem(int index) {
    DateTime time1 = DateTime.parse(newsList[index].date!);

    return Padding(
      padding: EdgeInsetsDirectional.only(
          top: 15.0, start: index == 0 ? 0 : 6.0, bottom: 15.0),
      child: InkWell(
        child: Stack(
          children: <Widget>[
            ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: CachedNetworkImage(
                  fadeInDuration: Duration(milliseconds: 150),
                  imageUrl: newsList[index].image!,
                  height: 250.0,
                  width: 193.0,
                  fit: BoxFit.cover,
                  errorWidget: (context, error, stackTrace) =>
                      errorWidget(250, 193),
                  placeholder: (context, url) {
                    return placeHolder();
                  },
                )),
            Positioned.directional(
                textDirection: Directionality.of(context),
                bottom: 7.0,
                start: 7,
                end: 7,
                height: 99,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: colors.tempboxColor.withOpacity(0.85),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                convertToAgo(context, time1, 0)!,
                                style: Theme.of(context)
                                    .textTheme
                                    .caption
                                    ?.copyWith(
                                        color: colors.tempdarkColor,
                                        fontSize: 10.0),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    newsList[index].title!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2
                                        ?.copyWith(
                                            color: colors.tempdarkColor
                                                .withOpacity(0.9),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12.5,
                                            height: 1.0),
                                    maxLines: 3,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                            ],
                          ),
                        )))),
          ],
        ),
        onTap: () {
          News model = newsList[index];
          List<News> recList = [];
          recList.addAll(newsList);
          recList.removeAt(index);

          /* model = model;
          index = index;
          updateParent = updateHomePage();
          this.widget.id = model.id;
          this.widget.isFav = false;
          this.widget.isDetails = true;
          this.widget.news = recList; */

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
        },
      ),
    );
  }

  updateHomePage() {
    setState(() {
      bookmarkList.clear();
      _getBookmark();
    });
  }

  Future<void> getRelatedNews() async {
    if (widget.isDetails!) {
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        try {
          var param = {
            ACCESS_KEY: access_key,
            LIMIT: perPage.toString(),
            OFFSET: offsetNews.toString(),
            USER_ID: CUR_USERID != "" ? CUR_USERID : "0",
          };

          if (widget.model!.subCatId != "0" && widget.model!.subCatId != null) {
            param[SUBCAT_ID] = widget.model!.subCatId!;
          } else {
            param[CATEGORY_ID] =
                widget.model!.categoryId!; //widget.model!.subCatId!;
          }

          Response response = await post(Uri.parse(getNewsByCatApi),
                  body: param, headers: headers)
              .timeout(Duration(seconds: timeOut));
          if (response.statusCode == 200) {
            var getData = json.decode(response.body);

            String error = getData["error"];
            if (error == "false") {
              totalNews = int.parse(getData["total"]);
              if ((offsetNews) < totalNews) {
                tempList.clear();
                var data = getData["data"];
                tempList = (data as List)
                    .map((data) => new News.fromJson(data))
                    .toList();
                newsList.addAll(tempList);
                newsList.removeWhere((element) => element.id == widget.id);

                offsetNews = offsetNews + perPage;
              }
            } else {
              if (this.mounted)
                setState(() {
                  _isLoadMoreNews = false;
                });
            }
            if (this.mounted)
              setState(() {
                _isLoadNews = false;
              });
          }
        } on TimeoutException catch (_) {
          showSnackBar(getTranslated(context, 'somethingMSg')!, context);
          setState(() {
            _isLoadNews = false;
            _isLoadMoreNews = false;
          });
        }
      } else {
        showSnackBar(getTranslated(context, 'internetmsg')!, context);
        setState(() {
          _isLoadNews = false;
          _isLoadMoreNews = false;
        });
      }
    }
  }

  allCommentView() {
    return Row(
      children: [
        if (commentList.length != 0)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              getTranslated(context, 'all_lbl')! +
                  " " +
                  commentList.length.toString() +
                  " " +
                  getTranslated(context, 'coms_lbl')!,
              style: Theme.of(this.context).textTheme.caption?.copyWith(
                  color:
                      Theme.of(context).colorScheme.fontColor.withOpacity(0.6),
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600),
            ),
          ),
        // : SizedBox.shrink(),
        Spacer(),
        Align(
            alignment: Alignment.topRight,
            child: InkWell(
              child: Icon(Icons.close_rounded),
              onTap: () {
                setState(() {
                  comEnabled = false;
                });
              },
            ))
      ],
    );
  }

  profileWithSendCom() {
    return Padding(
        padding: EdgeInsetsDirectional.only(top: 5.0),
        child: Row(
          children: [
            Expanded(
                flex: 1,
                child: profile != null && profile != ""
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(profile!),
                        /* child: ClipRRect(
                          borderRadius: BorderRadius.circular(50.0),
                          child: FadeInImage(
                              fadeInDuration: Duration(milliseconds: 150),
                              image: CachedNetworkImageProvider(profile!),
                              height: 32,
                              width: 32,
                              fit: BoxFit.cover,
                              imageErrorBuilder: (context, error, stackTrace) =>
                                  errorWidget(32, 32),
                              placeholder: AssetImage(
                                placeHolder,
                              )),
                        ),
                        backgroundColor: colors.transparentColor, */
                      )
                    : Container(
                        height: 35,
                        width: 35,
                        child: Icon(
                          Icons.account_circle,
                          // color: colors.primary,
                          size: 35,
                        ),
                      )),
            Expanded(
                flex: 7,
                child: Padding(
                    padding: EdgeInsetsDirectional.only(start: 18.0),
                    child: TextField(
                      controller: _commentC,
                      style: Theme.of(context).textTheme.subtitle2?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .fontColor
                              .withOpacity(0.7)),
                      onChanged: (String val) {
                        if (_commentC.text.trim().isNotEmpty) {
                          setState(() {
                            comBtnEnabled = true;
                          });
                        } else {
                          setState(() {
                            comBtnEnabled = false;
                          });
                        }
                      },
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.only(top: 10.0, bottom: 2.0),
                          isDense: true,
                          suffixIconConstraints: BoxConstraints(
                            maxHeight: 35,
                            maxWidth: 30,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .fontColor
                                    .withOpacity(0.5),
                                width: 1.5),
                          ),
                          hintText: getTranslated(context, 'share_thoght_lbl')!,
                          hintStyle: Theme.of(context)
                              .textTheme
                              .subtitle2
                              ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .fontColor
                                      .withOpacity(0.7)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.send,
                              color: comBtnEnabled
                                  ? Theme.of(context)
                                      .colorScheme
                                      .fontColor
                                      .withOpacity(0.8)
                                  : Colors.transparent,
                              size: 20.0,
                            ),
                            onPressed: () async {
                              if (isRedundentClick(DateTime.now(), diff)) {
                                //duration
                                print('hold on, processing');
                                /* showSnackBar(
                          getTranslated(context, 'processing')!, context); */
                                return;
                              }
                              if (CUR_USERID != "") {
                                setState(() {
                                  _setComment(_commentC.text, "0");
                                  FocusScopeNode currentFocus =
                                      FocusScope.of(context);

                                  if (!currentFocus.hasPrimaryFocus) {
                                    currentFocus.unfocus();
                                  }
                                  _commentC.clear();
                                });
                              } else {
                                //resetOverlayStyle();
                                loginRequired(context);
                              }
                              diff = resetDiff;
                            },
                          )),
                    )))
          ],
        ));
  }

  allComListView() {
    return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: SingleChildScrollView(
            child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) => Divider(
                      color: Theme.of(context)
                          .colorScheme
                          .fontColor
                          .withOpacity(0.5),
                    ),
                shrinkWrap: true,
                padding: EdgeInsets.only(top: 20.0),
                controller: controller1,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: commentList.length,
                itemBuilder: (context, index) {
                  DateTime time1 = DateTime.parse(commentList[index].date!);
                  return (index == commentList.length && isLoadingmore)
                      ? Center(child: CircularProgressIndicator())
                      : InkWell(
                          child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                commentList[index].profile != null ||
                                        commentList[index].profile != ""
                                    ? Container(
                                        height: 40,
                                        width: 40,
                                        child: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              commentList[index].profile!),
                                          /* child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(50.0),
                                            child: FadeInImage(
                                                fadeInDuration:
                                                    Duration(milliseconds: 150),
                                                image:
                                                    CachedNetworkImageProvider(
                                                        commentList[index]
                                                            .profile!),
                                                height: 32,
                                                width: 32,
                                                fit: BoxFit.cover,
                                                imageErrorBuilder: (context,
                                                        error, stackTrace) =>
                                                    errorWidget(32, 32),
                                                placeholder: AssetImage(
                                                  placeHolder,
                                                )),
                                          ),
                                          backgroundColor:
                                              colors.transparentColor, */
                                          radius: 32,
                                        ))
                                    : Container(
                                        height: 35,
                                        width: 35,
                                        child: Icon(
                                          Icons.account_circle,
                                          // color: colors.primary,
                                          size: 35,
                                        ),
                                      ),
                                Expanded(
                                    child: Padding(
                                        padding: EdgeInsetsDirectional.only(
                                            start: 15.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(commentList[index].name!,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2
                                                        ?.copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .fontColor
                                                                .withOpacity(
                                                                    0.7),
                                                            fontSize: 13)),
                                                Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .only(start: 10.0),
                                                    child: Icon(
                                                      Icons.circle,
                                                      size: 4.0,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .fontColor
                                                          .withOpacity(0.7),
                                                    )),
                                                Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .only(start: 10.0),
                                                    child: Text(
                                                      convertToAgo(
                                                          context, time1, 1)!,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .caption
                                                          ?.copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .fontColor
                                                                  .withOpacity(
                                                                      0.7),
                                                              fontSize: 10),
                                                    )),
                                              ],
                                            ),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(top: 8.0),
                                              child: Text(
                                                commentList[index].message!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle2
                                                    ?.copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .darkColor,
                                                        fontWeight:
                                                            FontWeight.normal),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(top: 15.0),
                                              child: Row(
                                                children: [
                                                  InkWell(
                                                      child: Icon(Icons
                                                          .thumb_up_off_alt_rounded),
                                                      onTap: () {
                                                        if (isRedundentClick(
                                                            DateTime.now(),
                                                            diff)) {
                                                          //inBetweenClicks
                                                          print(
                                                              'hold on, processing');
                                                          /* showSnackBar(
                              getTranslated(context, 'processing')!, context); */
                                                          return;
                                                        }
                                                        if (CUR_USERID != "") {
                                                          if (_isNetworkAvail) {
                                                            if (commentList[
                                                                        index]
                                                                    .like ==
                                                                "1") {
                                                              _setComLikeDislike(
                                                                "0",
                                                                commentList[
                                                                        index]
                                                                    .id!,
                                                              );
                                                              commentList[index]
                                                                  .like = "0";

                                                              commentList[index]
                                                                      .totalLikes =
                                                                  (int.parse(commentList[index]
                                                                              .totalLikes!) -
                                                                          1)
                                                                      .toString();

                                                              setState(() {});
                                                            } else if (commentList[
                                                                        index]
                                                                    .dislike ==
                                                                "1") {
                                                              _setComLikeDislike(
                                                                "1",
                                                                commentList[
                                                                        index]
                                                                    .id!,
                                                              );
                                                              commentList[index]
                                                                      .dislike =
                                                                  "0";

                                                              commentList[index]
                                                                      .totalDislikes =
                                                                  (int.parse(commentList[index]
                                                                              .totalDislikes!) -
                                                                          1)
                                                                      .toString();

                                                              commentList[index]
                                                                  .like = "1";
                                                              commentList[index]
                                                                      .totalLikes =
                                                                  (int.parse(commentList[index]
                                                                              .totalLikes!) +
                                                                          1)
                                                                      .toString();
                                                              setState(() {});
                                                            } else {
                                                              _setComLikeDislike(
                                                                "1",
                                                                commentList[
                                                                        index]
                                                                    .id!,
                                                              );
                                                              commentList[index]
                                                                  .like = "1";
                                                              commentList[index]
                                                                      .totalLikes =
                                                                  (int.parse(commentList[index]
                                                                              .totalLikes!) +
                                                                          1)
                                                                      .toString();
                                                              setState(() {});
                                                            }
                                                          } else {
                                                            showSnackBar(
                                                                getTranslated(
                                                                    context,
                                                                    'internetmsg')!,
                                                                context);
                                                          }
                                                        } else {
                                                          //resetOverlayStyle();
                                                          loginRequired(
                                                              context);
                                                          /* Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        Login()),
                                                          ); */
                                                        }
                                                        diff = resetDiff;
                                                      }),
                                                  commentList[index]
                                                              .totalLikes! !=
                                                          "0"
                                                      ? Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .only(
                                                                      start:
                                                                          4.0),
                                                          child: Text(
                                                            commentList[index]
                                                                .totalLikes!,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .subtitle2
                                                                ?.copyWith(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .darkColor),
                                                          ),
                                                        )
                                                      : Container(
                                                          width: 12,
                                                        ),
                                                  Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .only(start: 35),
                                                      child: InkWell(
                                                        child: Icon(Icons
                                                            .thumb_down_alt_rounded),
                                                        onTap: () {
                                                          if (isRedundentClick(
                                                              DateTime.now(),
                                                              diff)) {
                                                            //inBetweenClicks
                                                            print(
                                                                'hold on, processing');
                                                            /* showSnackBar(
                              getTranslated(context, 'processing')!, context); */
                                                            return;
                                                          }
                                                          if (CUR_USERID !=
                                                              "") {
                                                            if (_isNetworkAvail) {
                                                              if (commentList[
                                                                          index]
                                                                      .dislike ==
                                                                  "1") {
                                                                _setComLikeDislike(
                                                                  "0",
                                                                  commentList[
                                                                          index]
                                                                      .id!,
                                                                );
                                                                commentList[
                                                                        index]
                                                                    .dislike = "0";

                                                                commentList[
                                                                        index]
                                                                    .totalDislikes = (int.parse(
                                                                            commentList[index].totalDislikes!) -
                                                                        1)
                                                                    .toString();

                                                                setState(() {});
                                                              } else if (commentList[
                                                                          index]
                                                                      .like ==
                                                                  "1") {
                                                                _setComLikeDislike(
                                                                  "2",
                                                                  commentList[
                                                                          index]
                                                                      .id!,
                                                                );
                                                                commentList[
                                                                        index]
                                                                    .like = "0";

                                                                commentList[
                                                                        index]
                                                                    .totalLikes = (int.parse(
                                                                            commentList[index].totalLikes!) -
                                                                        1)
                                                                    .toString();

                                                                commentList[
                                                                        index]
                                                                    .dislike = "1";
                                                                commentList[
                                                                        index]
                                                                    .totalDislikes = (int.parse(
                                                                            commentList[index].totalDislikes!) +
                                                                        1)
                                                                    .toString();
                                                                setState(() {});
                                                              } else {
                                                                _setComLikeDislike(
                                                                  "2",
                                                                  commentList[
                                                                          index]
                                                                      .id!,
                                                                );
                                                                commentList[
                                                                        index]
                                                                    .dislike = "1";
                                                                commentList[
                                                                        index]
                                                                    .totalDislikes = (int.parse(
                                                                            commentList[index].totalDislikes!) +
                                                                        1)
                                                                    .toString();
                                                                setState(() {});
                                                              }
                                                            } else {
                                                              showSnackBar(
                                                                  getTranslated(
                                                                      context,
                                                                      'internetmsg')!,
                                                                  context);
                                                            }
                                                          } else {
                                                            //resetOverlayStyle();
                                                            loginRequired(
                                                                context);
                                                            /* Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          Login()),
                                                            ); */
                                                          }
                                                          diff = resetDiff;
                                                        },
                                                      )),
                                                  commentList[index]
                                                              .totalDislikes! !=
                                                          "0"
                                                      ? Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .only(
                                                                      start:
                                                                          4.0),
                                                          child: Text(
                                                            commentList[index]
                                                                .totalDislikes!,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .subtitle2
                                                                ?.copyWith(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .darkColor),
                                                          ),
                                                        )
                                                      : Container(
                                                          width: 12,
                                                        ),
                                                  Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .only(start: 35),
                                                      child: InkWell(
                                                        child: Icon(Icons
                                                            .quickreply_rounded),
                                                      )),
                                                  commentList[index]
                                                              .replyComList!
                                                              .length !=
                                                          0
                                                      ? Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .only(
                                                                      start:
                                                                          5.0),
                                                          child: Text(
                                                            commentList[index]
                                                                .replyComList!
                                                                .length
                                                                .toString(),
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .subtitle2
                                                                ?.copyWith(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .darkColor),
                                                          ),
                                                        )
                                                      : SizedBox.shrink(),
                                                  Spacer(),
                                                  if (CUR_USERID != "")
                                                    InkWell(
                                                      child: Icon(
                                                        Icons
                                                            .more_vert_outlined,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .darkColor,
                                                        size: 17,
                                                      ),
                                                      onTap: () {
                                                        if (isRedundentClick(
                                                            DateTime.now(),
                                                            diff)) {
                                                          //duration
                                                          print(
                                                              'hold on, processing');
                                                          /* showSnackBar(
                          getTranslated(context, 'processing')!, context); */
                                                          return;
                                                        }
                                                        delAndReportCom(
                                                          commentList[index]
                                                              .id!,
                                                          index,
                                                        );
                                                        diff = resetDiff;
                                                      },
                                                    )
                                                  // : SizedBox.shrink()
                                                ],
                                              ),
                                            ),
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(top: 10.0),
                                                child: InkWell(
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 4),
                                                    child: Text(
                                                      commentList[index]
                                                                  .replyComList!
                                                                  .length !=
                                                              0
                                                          ? commentList[index]
                                                                  .replyComList!
                                                                  .length
                                                                  .toString() +
                                                              " " +
                                                              getTranslated(
                                                                  context,
                                                                  'reply_lbl')!
                                                          : "",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .caption
                                                          ?.copyWith(
                                                              color: colors
                                                                  .primary,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    setState(() {
                                                      isReply = true;
                                                      replyComIndex = index;
                                                    });
                                                  },
                                                )),
                                          ],
                                        ))),
                              ]),
                          onTap: () {
                            setState(() {
                              isReply = true;
                              replyComIndex = index;
                            });
                          },
                        );
                })));
  }

  commentView() {
    return comments_mode == "1"
        ? Padding(
            padding: EdgeInsetsDirectional.only(top: 10.0, bottom: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                allCommentView(),
                profileWithSendCom(),
                allComListView()
              ],
            ))
        : Column(children: [
            Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  child: Icon(Icons.close_rounded),
                  onTap: () {
                    setState(() {
                      comEnabled = false;
                    });
                  },
                )),
            Container(
                padding: EdgeInsetsDirectional.only(top: kToolbarHeight),
                child: Text(getTranslated(context, 'com_disable')!))
          ]);
  }

  delAndReportCom(String comId, int index) {
    showDialog(
        context: context,
        barrierDismissible: true, //false,
        builder: (BuildContext context) {
          return AlertDialog(
              contentPadding: EdgeInsets.all(20),
              elevation: 2.0,
              backgroundColor: Theme.of(context).colorScheme.fontColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
              content: SingleChildScrollView(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (CUR_USERID == commentList[index].userId!)
                    Row(
                      children: <Widget>[
                        Text(
                          getTranslated(context, 'delete_txt')!,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .controlBGColor
                                      .withOpacity(0.9),
                                  fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        InkWell(
                          splashColor: colors.transparentColor,
                          highlightColor: colors.transparentColor,
                          child: Image.asset(
                            "assets/images/delete_icon.png",
                            color: Theme.of(context).colorScheme.controlBGColor,
                            height: 20,
                            width: 20,
                          ),
                          onTap: () async {
                            if (isRedundentClick(DateTime.now(), diff)) {
                              //duration
                              print('hold on, processing');
                              return;
                            }
                            if (CUR_USERID != "") {
                              setDeleteComment(comId, index, 1);
                              Navigator.pop(context);
                            }
                            /* else {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Login()),
                                  );
                                } */
                            diff = resetDiff;
                          },
                        ),
                      ],
                    ),
                  // : SizedBox.shrink(),
                  if (CUR_USERID != commentList[index].userId!)
                    Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Row(
                          children: <Widget>[
                            Text(
                              getTranslated(context, 'report_txt')!,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .controlBGColor
                                          .withOpacity(0.9),
                                      fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            Image.asset(
                              "assets/images/flag_icon.png",
                              color:
                                  Theme.of(context).colorScheme.controlBGColor,
                              height: 20,
                              width: 20,
                            ),
                          ],
                        )),
                  //: SizedBox.shrink(),
                  if (CUR_USERID != commentList[index].userId!)
                    Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: TextField(
                          controller: reportC,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          style: Theme.of(context).textTheme.caption?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .controlBGColor
                                    .withOpacity(0.7),
                              ),
                          decoration: new InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .controlBGColor,
                                  width: 0.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .controlBGColor,
                                  width: 0.5),
                            ),
                          ),
                        )),
                  // : SizedBox.shrink(),
                  if (CUR_USERID != commentList[index].userId!)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              getTranslated(context, 'cancel_btn')!,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .controlBGColor
                                          .withOpacity(0.9),
                                      fontWeight: FontWeight.bold),
                            )),
                        TextButton(
                            onPressed: () {
                              if (isRedundentClick(DateTime.now(), diff)) {
                                //duration
                                print('hold on, processing');
                                /* showSnackBar(
                          getTranslated(context, 'processing')!, context); */
                                return;
                              }
                              if (CUR_USERID != "") {
                                if (reportC.text.trim().isNotEmpty) {
                                  _setFlag(reportC.text, comId);
                                  Navigator.pop(context);
                                } else {
                                  showSnackBar(
                                      getTranslated(
                                          context, 'first_fill_data')!,
                                      context);
                                }
                              } else {
                                //resetOverlayStyle();
                                loginRequired(context);
                                /* Navigator.pop(context);
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Login()),
                                    ); */
                              }
                              diff = resetDiff;
                            },
                            child: Text(
                              getTranslated(context, 'submit_btn')!,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .controlBGColor
                                          .withOpacity(0.9),
                                      fontWeight: FontWeight.bold),
                            )),
                      ],
                    ),
                  // : SizedBox.shrink(),
                ],
              )));
        });
  }

  delAndReportCom1(String comId, int index) {
    showDialog(
        context: context,
        barrierDismissible: true, //false,
        builder: (BuildContext context) {
          return AlertDialog(
              contentPadding: EdgeInsets.all(20),
              elevation: 2.0,
              backgroundColor: Theme.of(context).colorScheme.fontColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
              content: SingleChildScrollView(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CUR_USERID ==
                          commentList[replyComIndex!]
                              .replyComList![index]
                              .userId
                      ? Row(
                          children: <Widget>[
                            Text(
                              getTranslated(context, 'delete_txt')!,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .controlBGColor
                                          .withOpacity(0.9),
                                      fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            InkWell(
                              splashColor: colors.transparentColor,
                              highlightColor: colors.transparentColor,
                              child: Image.asset(
                                "assets/images/delete_icon.png",
                                color: Theme.of(context)
                                    .colorScheme
                                    .controlBGColor,
                                height: 20,
                                width: 20,
                              ),
                              onTap: () async {
                                if (isRedundentClick(DateTime.now(), diff)) {
                                  //duration
                                  print('hold on, processing');
                                  return;
                                }
                                if (CUR_USERID != "") {
                                  setDeleteComment(comId, index, 2);
                                  Navigator.pop(context);
                                }
                                /* else {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Login()),
                                  );
                                } */
                                diff = resetDiff;
                              },
                            ),
                          ],
                        )
                      : SizedBox.shrink(),
                  CUR_USERID !=
                          commentList[replyComIndex!]
                              .replyComList![index]
                              .userId
                      ? Padding(
                          padding: EdgeInsets.only(top: 15),
                          child: Row(
                            children: <Widget>[
                              Text(
                                getTranslated(context, 'report_txt')!,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .controlBGColor
                                            .withOpacity(0.9),
                                        fontWeight: FontWeight.bold),
                              ),
                              Spacer(),
                              Image.asset(
                                "assets/images/flag_icon.png",
                                color: Theme.of(context)
                                    .colorScheme
                                    .controlBGColor,
                                height: 20,
                                width: 20,
                              ),
                            ],
                          ))
                      : SizedBox.shrink(),
                  CUR_USERID !=
                          commentList[replyComIndex!]
                              .replyComList![index]
                              .userId
                      ? Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: TextField(
                            controller: reportC,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            style:
                                Theme.of(context).textTheme.caption?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .controlBGColor
                                          .withOpacity(0.7),
                                    ),
                            decoration: new InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .controlBGColor,
                                    width: 0.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .controlBGColor,
                                    width: 0.5),
                              ),
                            ),
                          ))
                      : SizedBox.shrink(),
                  CUR_USERID !=
                          commentList[replyComIndex!]
                              .replyComList![index]
                              .userId
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  getTranslated(context, 'cancel_btn')!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .controlBGColor
                                              .withOpacity(0.9),
                                          fontWeight: FontWeight.bold),
                                )),
                            TextButton(
                                onPressed: () {
                                  if (isRedundentClick(DateTime.now(), diff)) {
                                    //duration
                                    print('hold on, processing');
                                    /* showSnackBar(
                          getTranslated(context, 'processing')!, context); */
                                    return;
                                  }
                                  if (CUR_USERID != "") {
                                    if (reportC.text.trim().isNotEmpty) {
                                      _setFlag(reportC.text, comId);
                                      Navigator.pop(context);
                                    } else {
                                      showSnackBar(
                                          getTranslated(
                                              context, 'first_fill_data')!,
                                          context);
                                    }
                                  } else {
                                    //resetOverlayStyle();
                                    loginRequired(context);
                                    /*  Navigator.pop(context);
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Login()),
                                    ); */
                                  }
                                  diff = resetDiff;
                                },
                                child: Text(
                                  getTranslated(context, 'submit_btn')!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .controlBGColor
                                              .withOpacity(0.9),
                                          fontWeight: FontWeight.bold),
                                )),
                          ],
                        )
                      : SizedBox.shrink()
                ],
              )));
        });
  }

  allReplyComView() {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            getTranslated(context, 'all_lbl')! +
                " " +
                commentList[replyComIndex!].replyComList!.length.toString() +
                " " +
                getTranslated(context, 'reply_lbl')!,
            style: Theme.of(this.context).textTheme.caption?.copyWith(
                color: Theme.of(context).colorScheme.fontColor.withOpacity(0.6),
                fontSize: 12.0,
                fontWeight: FontWeight.w600),
          ),
        ),
        Spacer(),
        Align(
            alignment: Alignment.topRight,
            child: InkWell(
              child: Icon(Icons.arrow_back), //Icons.close_rounded),
              onTap: () {
                setState(() {
                  isReply = false;
                });
              },
            ))
      ],
    );
  }

  replyComProfileWithCom() {
    DateTime time1 = DateTime.parse(commentList[replyComIndex!].date!);
    return Padding(
        padding: EdgeInsets.only(top: 10),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              commentList[replyComIndex!].profile != null ||
                      commentList[replyComIndex!].profile != ""
                  ? Container(
                      height: 40,
                      width: 40,
                      child: CircleAvatar(
                        backgroundImage:
                            NetworkImage(commentList[replyComIndex!].profile!),
                        /* child: ClipRRect(
                          borderRadius: BorderRadius.circular(50.0),
                          child: FadeInImage(
                              fadeInDuration: Duration(milliseconds: 150),
                              image: CachedNetworkImageProvider(
                                  commentList[replyComIndex!].profile!),
                              height: 32,
                              width: 32,
                              fit: BoxFit.cover,
                              imageErrorBuilder: (context, error, stackTrace) =>
                                  errorWidget(32, 32),
                              placeholder: AssetImage(
                                placeHolder,
                              )),
                        ),
                        backgroundColor: colors.transparentColor, */
                        radius: 32,
                      ))
                  : Container(
                      height: 35,
                      width: 35,
                      child: Icon(
                        Icons.account_circle,
                        // color: colors.bgColor, //colors.primary,
                        size: 35,
                      ),
                    ),
              Expanded(
                  child: Padding(
                      padding: EdgeInsetsDirectional.only(start: 15.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(commentList[replyComIndex!].name!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .fontColor
                                              .withOpacity(0.7),
                                          fontSize: 13)),
                              Padding(
                                  padding:
                                      EdgeInsetsDirectional.only(start: 10.0),
                                  child: Icon(
                                    Icons.circle,
                                    size: 4.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .fontColor
                                        .withOpacity(0.7),
                                  )),
                              Padding(
                                  padding:
                                      EdgeInsetsDirectional.only(start: 10.0),
                                  child: Text(
                                    convertToAgo(context, time1, 1)!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption
                                        ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .fontColor
                                                .withOpacity(0.7),
                                            fontSize: 10),
                                  )),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              commentList[replyComIndex!].message!,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .fontColor,
                                      fontWeight: FontWeight.normal),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 15.0),
                            child: Row(
                              children: [
                                InkWell(
                                  child: Icon(Icons.thumb_up_off_alt_rounded),
                                  onTap: () {
                                    if (isRedundentClick(
                                        DateTime.now(), diff)) {
                                      //inBetweenClicks
                                      print('hold on, processing');
                                      /* showSnackBar(
                              getTranslated(context, 'processing')!, context); */
                                      return;
                                    }
                                    if (CUR_USERID != "") {
                                      if (_isNetworkAvail) {
                                        if (commentList[replyComIndex!].like ==
                                            "1") {
                                          _setComLikeDislike(
                                            "0",
                                            commentList[replyComIndex!].id!,
                                          );
                                          commentList[replyComIndex!].like =
                                              "0";

                                          commentList[replyComIndex!]
                                              .totalLikes = (int.parse(
                                                      commentList[
                                                              replyComIndex!]
                                                          .totalLikes!) -
                                                  1)
                                              .toString();

                                          setState(() {});
                                        } else if (commentList[replyComIndex!]
                                                .dislike ==
                                            "1") {
                                          _setComLikeDislike(
                                            "1",
                                            commentList[replyComIndex!].id!,
                                          );
                                          commentList[replyComIndex!].dislike =
                                              "0";

                                          commentList[replyComIndex!]
                                              .totalDislikes = (int.parse(
                                                      commentList[
                                                              replyComIndex!]
                                                          .totalDislikes!) -
                                                  1)
                                              .toString();

                                          commentList[replyComIndex!].like =
                                              "1";
                                          commentList[replyComIndex!]
                                              .totalLikes = (int.parse(
                                                      commentList[
                                                              replyComIndex!]
                                                          .totalLikes!) +
                                                  1)
                                              .toString();
                                          setState(() {});
                                        } else {
                                          _setComLikeDislike(
                                            "1",
                                            commentList[replyComIndex!].id!,
                                          );
                                          commentList[replyComIndex!].like =
                                              "1";
                                          commentList[replyComIndex!]
                                              .totalLikes = (int.parse(
                                                      commentList[
                                                              replyComIndex!]
                                                          .totalLikes!) +
                                                  1)
                                              .toString();
                                          setState(() {});
                                        }
                                      } else {
                                        showSnackBar(
                                            getTranslated(
                                                context, 'internetmsg')!,
                                            context);
                                      }
                                    } else {
                                      //resetOverlayStyle();
                                      loginRequired(context);
                                      /*  Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Login()),
                                      ); */
                                    }
                                    diff = resetDiff;
                                  },
                                ),
                                commentList[replyComIndex!].totalLikes! != "0"
                                    ? Padding(
                                        padding: EdgeInsetsDirectional.only(
                                            start: 4.0),
                                        child: Text(
                                          commentList[replyComIndex!]
                                              .totalLikes!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .darkColor,
                                              ),
                                        ),
                                      )
                                    : Container(
                                        width: 12,
                                      ),
                                Padding(
                                    padding:
                                        EdgeInsetsDirectional.only(start: 35),
                                    child: InkWell(
                                      child: Icon(Icons.thumb_down_alt_rounded),
                                      onTap: () {
                                        if (isRedundentClick(
                                            DateTime.now(), diff)) {
                                          //inBetweenClicks
                                          print('hold on, processing');
                                          /* showSnackBar(
                              getTranslated(context, 'processing')!, context); */
                                          return;
                                        }
                                        if (CUR_USERID != "") {
                                          if (_isNetworkAvail) {
                                            if (commentList[replyComIndex!]
                                                    .dislike ==
                                                "1") {
                                              _setComLikeDislike(
                                                "0",
                                                commentList[replyComIndex!].id!,
                                              );
                                              commentList[replyComIndex!]
                                                  .dislike = "0";

                                              commentList[replyComIndex!]
                                                  .totalDislikes = (int.parse(
                                                          commentList[
                                                                  replyComIndex!]
                                                              .totalDislikes!) -
                                                      1)
                                                  .toString();

                                              setState(() {});
                                            } else if (commentList[
                                                        replyComIndex!]
                                                    .like ==
                                                "1") {
                                              _setComLikeDislike(
                                                "2",
                                                commentList[replyComIndex!].id!,
                                              );
                                              commentList[replyComIndex!].like =
                                                  "0";

                                              commentList[replyComIndex!]
                                                  .totalLikes = (int.parse(
                                                          commentList[
                                                                  replyComIndex!]
                                                              .totalLikes!) -
                                                      1)
                                                  .toString();

                                              commentList[replyComIndex!]
                                                  .dislike = "1";
                                              commentList[replyComIndex!]
                                                  .totalDislikes = (int.parse(
                                                          commentList[
                                                                  replyComIndex!]
                                                              .totalDislikes!) +
                                                      1)
                                                  .toString();
                                              setState(() {});
                                            } else {
                                              _setComLikeDislike(
                                                "2",
                                                commentList[replyComIndex!].id!,
                                              );
                                              commentList[replyComIndex!]
                                                  .dislike = "1";
                                              commentList[replyComIndex!]
                                                  .totalDislikes = (int.parse(
                                                          commentList[
                                                                  replyComIndex!]
                                                              .totalDislikes!) +
                                                      1)
                                                  .toString();
                                              setState(() {});
                                            }
                                          } else {
                                            showSnackBar(
                                                getTranslated(
                                                    context, 'internetmsg')!,
                                                context);
                                          }
                                        } else {
                                          //resetOverlayStyle();
                                          loginRequired(context);
                                          /*  Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Login()),
                                          ); */
                                        }
                                        diff = resetDiff;
                                      },
                                    )),
                                commentList[replyComIndex!].totalDislikes! !=
                                        "0"
                                    ? Padding(
                                        padding: EdgeInsetsDirectional.only(
                                            start: 4.0),
                                        child: Text(
                                          commentList[replyComIndex!]
                                              .totalDislikes!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .darkColor,
                                              ),
                                        ),
                                      )
                                    : Container(
                                        width: 12,
                                      ),
                                Padding(
                                    padding:
                                        EdgeInsetsDirectional.only(start: 35),
                                    child: InkWell(
                                      child: Icon(Icons.quickreply_rounded),
                                    )),
                                if (commentList[replyComIndex!]
                                        .replyComList!
                                        .length !=
                                    0)
                                  Padding(
                                    padding:
                                        EdgeInsetsDirectional.only(start: 5.0),
                                    child: Text(
                                      commentList[replyComIndex!]
                                          .replyComList!
                                          .length
                                          .toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .darkColor,
                                          ),
                                    ),
                                  ),
                                //: SizedBox.shrink(),
                                Spacer(),
                                if (CUR_USERID != "")
                                  InkWell(
                                    child: Icon(
                                      Icons.more_vert_outlined,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .darkColor,
                                      size: 17,
                                    ),
                                    onTap: () {
                                      if (isRedundentClick(
                                          DateTime.now(), diff)) {
                                        //inBetweenClicks
                                        print('hold on, processing');
                                        /* showSnackBar(
                              getTranslated(context, 'processing')!, context); */
                                        return;
                                      }
                                      delAndReportCom(
                                        commentList[replyComIndex!].id!,
                                        replyComIndex!,
                                      );
                                      diff = resetDiff;
                                    },
                                  )
                                // : SizedBox.shrink()
                              ],
                            ),
                          ),
                        ],
                      ))),
            ]));
  }

  replyComSendReplyView() {
    return CUR_USERID != ""
        ? Padding(
            padding: EdgeInsetsDirectional.only(top: 10.0),
            child: Row(
              children: [
                Expanded(
                    flex: 1,
                    child: (profile != null && profile != "")
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(profile!),
                            /* child: ClipRRect(
                              borderRadius: BorderRadius.circular(50.0),
                              child: FadeInImage(
                                fadeInDuration: Duration(milliseconds: 150),
                                image: CachedNetworkImageProvider(profile!),
                                height: 32,
                                width: 32,
                                fit: BoxFit.cover,
                                imageErrorBuilder:
                                    (context, error, stackTrace) =>
                                        errorWidget(32, 32),
                                placeholder: const Icon(Icons.account_circle)
                                    as ImageProvider,
                              ),
                            ),
                            backgroundColor: colors.bgColor, */
                          )
                        : Container(
                            height: 35,
                            width: 35,
                            child: Icon(
                              Icons.account_circle,
                              // color: colors.primary,
                              size: 35,
                            ),
                          )),
                Expanded(
                    flex: 7,
                    child: Padding(
                        padding: EdgeInsetsDirectional.only(start: 18.0),
                        child: TextField(
                          controller: _replyComC,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2
                              ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .fontColor
                                      .withOpacity(0.7)),
                          onChanged: (String val) {
                            if (_replyComC.text.trim().isNotEmpty) {
                              setState(() {
                                replyComEnabled = true;
                              });
                            } else {
                              setState(() {
                                replyComEnabled = false;
                              });
                            }
                          },
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.only(top: 10.0, bottom: 2.0),
                              isDense: true,
                              suffixIconConstraints: BoxConstraints(
                                maxHeight: 35,
                                maxWidth: 30,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .fontColor
                                        .withOpacity(0.5),
                                    width: 1.5),
                              ),
                              hintText: getTranslated(context, 'public_reply')!,
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .fontColor
                                          .withOpacity(0.7)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  Icons.send,
                                  color: replyComEnabled
                                      ? Theme.of(context)
                                          .colorScheme
                                          .fontColor
                                          .withOpacity(0.8)
                                      : Colors.transparent,
                                  size: 20.0,
                                ),
                                onPressed: () async {
                                  if (isRedundentClick(DateTime.now(), diff)) {
                                    //duration
                                    print('hold on, processing');
                                    /* showSnackBar(
                          getTranslated(context, 'processing')!, context); */
                                    return;
                                  }
                                  if (CUR_USERID != "") {
                                    setState(() {
                                      _setComment(_replyComC.text,
                                          commentList[replyComIndex!].id!);
                                      FocusScopeNode currentFocus =
                                          FocusScope.of(context);

                                      if (!currentFocus.hasPrimaryFocus) {
                                        currentFocus.unfocus();
                                      }
                                      _replyComC.clear();
                                    });
                                  } else {
                                    //resetOverlayStyle();
                                    loginRequired(context);
                                  }
                                  diff = resetDiff;
                                },
                              )),
                        )))
              ],
            ))
        : SizedBox.shrink();
  }

  replyAllComListView() {
    return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: SingleChildScrollView(
            child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) => Divider(
                      color: Theme.of(context)
                          .colorScheme
                          .fontColor
                          .withOpacity(0.5),
                    ),
                shrinkWrap: true,
                reverse: true,
                padding: EdgeInsets.only(top: 20.0),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: commentList[replyComIndex!].replyComList!.length,
                itemBuilder: (context, index) {
                  DateTime time1 = DateTime.parse(
                      commentList[replyComIndex!].replyComList![index].date!);
                  return Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        commentList[replyComIndex!]
                                        .replyComList![index]
                                        .profile !=
                                    null ||
                                commentList[replyComIndex!]
                                        .replyComList![index]
                                        .profile !=
                                    ""
                            ? Container(
                                height: 40,
                                width: 40,
                                color: colors.transparentColor,
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      commentList[replyComIndex!]
                                          .replyComList![index]
                                          .profile!),
                                  radius: 32,
                                ))
                            : Container(
                                height: 35,
                                width: 35,
                                child: Icon(
                                  Icons.account_circle,
                                  // color: colors.primary,
                                  size: 35,
                                ),
                              ),
                        Expanded(
                            child: Padding(
                                padding:
                                    EdgeInsetsDirectional.only(start: 15.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                            commentList[replyComIndex!]
                                                .replyComList![index]
                                                .name!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .fontColor
                                                        .withOpacity(0.7),
                                                    fontSize: 13)),
                                        Padding(
                                            padding: EdgeInsetsDirectional.only(
                                                start: 10.0),
                                            child: Icon(
                                              Icons.circle,
                                              size: 4.0,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .fontColor
                                                  .withOpacity(0.7),
                                            )),
                                        Padding(
                                            padding: EdgeInsetsDirectional.only(
                                                start: 10.0),
                                            child: Text(
                                              convertToAgo(context, time1, 1)!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  ?.copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .fontColor
                                                          .withOpacity(0.7),
                                                      fontSize: 10),
                                            )),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        commentList[replyComIndex!]
                                            .replyComList![index]
                                            .message!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2
                                            ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .fontColor,
                                                fontWeight: FontWeight.normal),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 15.0),
                                      child: Row(
                                        children: [
                                          InkWell(
                                            child: Icon(
                                                Icons.thumb_up_off_alt_rounded),
                                            onTap: () {
                                              if (isRedundentClick(
                                                  DateTime.now(), diff)) {
                                                //inBetweenClicks
                                                print('hold on, processing');
                                                /* showSnackBar(
                              getTranslated(context, 'processing')!, context); */
                                                return;
                                              }
                                              if (CUR_USERID != "") {
                                                if (_isNetworkAvail) {
                                                  if (commentList[
                                                              replyComIndex!]
                                                          .replyComList![index]
                                                          .like ==
                                                      "1") {
                                                    _setComLikeDislike(
                                                      "0",
                                                      commentList[
                                                              replyComIndex!]
                                                          .replyComList![index]
                                                          .id!,
                                                    );
                                                    commentList[replyComIndex!]
                                                        .replyComList![index]
                                                        .like = "0";

                                                    commentList[replyComIndex!]
                                                        .replyComList![index]
                                                        .totalLikes = (int.parse(
                                                                commentList[
                                                                        replyComIndex!]
                                                                    .replyComList![
                                                                        index]
                                                                    .totalLikes!) -
                                                            1)
                                                        .toString();

                                                    setState(() {});
                                                  } else if (commentList[
                                                              replyComIndex!]
                                                          .replyComList![index]
                                                          .dislike ==
                                                      "1") {
                                                    _setComLikeDislike(
                                                      "1",
                                                      commentList[
                                                              replyComIndex!]
                                                          .replyComList![index]
                                                          .id!,
                                                    );
                                                    commentList[replyComIndex!]
                                                        .replyComList![index]
                                                        .dislike = "0";

                                                    commentList[replyComIndex!]
                                                            .replyComList![index]
                                                            .totalDislikes =
                                                        (int.parse(commentList[
                                                                        replyComIndex!]
                                                                    .replyComList![
                                                                        index]
                                                                    .totalDislikes!) -
                                                                1)
                                                            .toString();

                                                    commentList[replyComIndex!]
                                                        .replyComList![index]
                                                        .like = "1";
                                                    commentList[replyComIndex!]
                                                        .replyComList![index]
                                                        .totalLikes = (int.parse(
                                                                commentList[
                                                                        replyComIndex!]
                                                                    .replyComList![
                                                                        index]
                                                                    .totalLikes!) +
                                                            1)
                                                        .toString();
                                                    setState(() {});
                                                  } else {
                                                    _setComLikeDislike(
                                                      "1",
                                                      commentList[
                                                              replyComIndex!]
                                                          .replyComList![index]
                                                          .id!,
                                                    );
                                                    commentList[replyComIndex!]
                                                        .replyComList![index]
                                                        .like = "1";
                                                    commentList[replyComIndex!]
                                                        .replyComList![index]
                                                        .totalLikes = (int.parse(
                                                                commentList[
                                                                        replyComIndex!]
                                                                    .replyComList![
                                                                        index]
                                                                    .totalLikes!) +
                                                            1)
                                                        .toString();
                                                    setState(() {});
                                                  }
                                                } else {
                                                  showSnackBar(
                                                      getTranslated(context,
                                                          'internetmsg')!,
                                                      context);
                                                }
                                              } else {
                                                //resetOverlayStyle();
                                                loginRequired(context);
                                                /* Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          Login()),
                                                ); */
                                              }
                                              diff = resetDiff;
                                            },
                                          ),
                                          commentList[replyComIndex!]
                                                      .replyComList![index]
                                                      .totalLikes! !=
                                                  "0"
                                              ? Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .only(start: 4.0),
                                                  child: Text(
                                                    commentList[replyComIndex!]
                                                        .replyComList![index]
                                                        .totalLikes!,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subtitle2
                                                        ?.copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .darkColor,
                                                        ),
                                                  ),
                                                )
                                              : Container(
                                                  width: 12,
                                                ),
                                          Padding(
                                              padding:
                                                  EdgeInsetsDirectional.only(
                                                      start: 35),
                                              child: InkWell(
                                                child: Icon(Icons
                                                    .thumb_down_alt_rounded),
                                                onTap: () {
                                                  if (isRedundentClick(
                                                      DateTime.now(), diff)) {
                                                    //inBetweenClicks
                                                    print(
                                                        'hold on, processing');
                                                    /* showSnackBar(
                              getTranslated(context, 'processing')!, context); */
                                                    return;
                                                  }
                                                  if (CUR_USERID != "") {
                                                    if (_isNetworkAvail) {
                                                      if (commentList[
                                                                  replyComIndex!]
                                                              .replyComList![
                                                                  index]
                                                              .dislike ==
                                                          "1") {
                                                        _setComLikeDislike(
                                                          "0",
                                                          commentList[
                                                                  replyComIndex!]
                                                              .replyComList![
                                                                  index]
                                                              .id!,
                                                        );
                                                        commentList[
                                                                replyComIndex!]
                                                            .replyComList![
                                                                index]
                                                            .dislike = "0";

                                                        commentList[replyComIndex!]
                                                                .replyComList![
                                                                    index]
                                                                .totalDislikes =
                                                            (int.parse(commentList[
                                                                            replyComIndex!]
                                                                        .replyComList![
                                                                            index]
                                                                        .totalDislikes!) -
                                                                    1)
                                                                .toString();

                                                        setState(() {});
                                                      } else if (commentList[
                                                                  replyComIndex!]
                                                              .replyComList![
                                                                  index]
                                                              .like ==
                                                          "1") {
                                                        _setComLikeDislike(
                                                          "2",
                                                          commentList[
                                                                  replyComIndex!]
                                                              .replyComList![
                                                                  index]
                                                              .id!,
                                                        );
                                                        commentList[
                                                                replyComIndex!]
                                                            .replyComList![
                                                                index]
                                                            .like = "0";

                                                        commentList[
                                                                replyComIndex!]
                                                            .replyComList![
                                                                index]
                                                            .totalLikes = (int.parse(commentList[
                                                                        replyComIndex!]
                                                                    .replyComList![
                                                                        index]
                                                                    .totalLikes!) -
                                                                1)
                                                            .toString();

                                                        commentList[
                                                                replyComIndex!]
                                                            .replyComList![
                                                                index]
                                                            .dislike = "1";
                                                        commentList[replyComIndex!]
                                                                .replyComList![
                                                                    index]
                                                                .totalDislikes =
                                                            (int.parse(commentList[
                                                                            replyComIndex!]
                                                                        .replyComList![
                                                                            index]
                                                                        .totalDislikes!) +
                                                                    1)
                                                                .toString();
                                                        setState(() {});
                                                      } else {
                                                        _setComLikeDislike(
                                                          "2",
                                                          commentList[
                                                                  replyComIndex!]
                                                              .replyComList![
                                                                  index]
                                                              .id!,
                                                        );
                                                        commentList[
                                                                replyComIndex!]
                                                            .replyComList![
                                                                index]
                                                            .dislike = "1";
                                                        commentList[replyComIndex!]
                                                                .replyComList![
                                                                    index]
                                                                .totalDislikes =
                                                            (int.parse(commentList[
                                                                            replyComIndex!]
                                                                        .replyComList![
                                                                            index]
                                                                        .totalDislikes!) +
                                                                    1)
                                                                .toString();
                                                        setState(() {});
                                                      }
                                                    } else {
                                                      showSnackBar(
                                                          getTranslated(context,
                                                              'internetmsg')!,
                                                          context);
                                                    }
                                                  } else {
                                                    //resetOverlayStyle();
                                                    loginRequired(context);
                                                    /* Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Login()),
                                                    ); */
                                                  }
                                                  diff = resetDiff;
                                                },
                                              )),
                                          commentList[replyComIndex!]
                                                      .replyComList![index]
                                                      .totalDislikes! !=
                                                  "0"
                                              ? Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .only(start: 4.0),
                                                  child: Text(
                                                    commentList[replyComIndex!]
                                                        .replyComList![index]
                                                        .totalDislikes!,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subtitle2
                                                        ?.copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .darkColor,
                                                        ),
                                                  ),
                                                )
                                              : SizedBox.shrink(),
                                          Spacer(),
                                          if (CUR_USERID != "")
                                            InkWell(
                                              child: Icon(
                                                Icons.more_vert_outlined,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .darkColor,
                                                size: 17,
                                              ),
                                              onTap: () {
                                                if (isRedundentClick(
                                                    DateTime.now(), diff)) {
                                                  //inBetweenClicks
                                                  print('hold on, processing');
                                                  /* showSnackBar(
                              getTranslated(context, 'processing')!, context); */
                                                  return;
                                                }
                                                delAndReportCom1(
                                                  commentList[replyComIndex!]
                                                      .replyComList![index]
                                                      .id!,
                                                  index,
                                                );
                                                diff = resetDiff;
                                              },
                                            )
                                          // : SizedBox.shrink()
                                        ],
                                      ),
                                    ),
                                  ],
                                ))),
                      ]);
                })));
  }

  replyCommentView() {
    return Padding(
        padding: EdgeInsetsDirectional.only(top: 10.0, bottom: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            allReplyComView(),
            replyComProfileWithCom(),
            replyComSendReplyView(),
            replyAllComListView(),
          ],
        ));
  }
}
