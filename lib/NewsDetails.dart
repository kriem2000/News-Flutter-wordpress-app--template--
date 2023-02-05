// ignore_for_file: must_be_immutable, unused_field, unnecessary_null_comparison, unnecessary_statements, non_constant_identifier_names

// import 'dart:async';
// import 'dart:convert';
// import 'dart:io'; //fbAud
// import 'dart:ui';
// import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

import 'package:facebook_audience_network/facebook_audience_network.dart'; //fbAud
// import 'package:device_info_plus/device_info_plus.dart';
import 'package:news/Helper/FbAdHelper.dart'; //fbAud
import 'package:news/Helper/AdHelper.dart';
import 'package:news/Helper/unityAdHelper.dart';
import 'package:flutter/material.dart';

// import 'package:flutter/services.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:news/Home.dart';

// import 'package:html/parser.dart' show parse;
// import 'package:http/http.dart';
import 'package:news/Model/BreakingNews.dart';

// import 'package:news/Model/Comment.dart';
import 'package:news/Model/News.dart';
import 'package:news/NewsSubDetails.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

// import 'package:news/NewsVideo.dart';
// import 'package:news/ShowMoreNewsList.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'Helper/AdHelper.dart';

// import 'Helper/Color.dart';
// import 'Helper/Constant.dart';

import 'Helper/Session.dart';
import 'Helper/String.dart';

// import 'Image_Preview.dart';
// import 'Login.dart';
// import 'NewsTag.dart';

class NewsDetails extends StatefulWidget {
  News? model; //final
  int? index; //final
  Function? updateParent; //final
  String? id; //final
  // bool? isFav; //final
  bool? isbookmarked; //final
  bool? isDetails; //final //if false > breaking News , else all other news.
  List<News>? news; //final
  BreakingNewsModel? model1; //final
  List<BreakingNewsModel>? news1; //final
  bool? fromShowMoreList;

  NewsDetails(
      {Key? key,
      this.model,
      this.index,
      this.updateParent,
      this.id,
      // this.isFav,
      this.isbookmarked,
      this.isDetails,
      this.news,
      this.model1,
      this.news1,
      this.fromShowMoreList})
      : super(key: key);

  @override
  NewsDetailsState createState() => NewsDetailsState();
}

class NewsDetailsState extends State<NewsDetails> {
  /* static final AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  ); */
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _isNetworkAvail = true;
  List<News> tempList = [];
  bool _isLoading = true;
  bool isLoadingmore = true;
  int offset = 0;
  int total = 0;
  int _curSlider = 0;
  final PageController pageController = PageController();
  bool isScroll = false;
  bool _isInterstitialAdLoaded = false;
  bool _isRewardedAdLoaded = false;
  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  int maxFailedLoadAttempts = 3;
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  /* Map<String, bool> placements = {
    AdManager.interstitialVideoAdPlacementId: false,
    AdManager.rewardedVideoAdPlacementId: false,
  };*/

  @override
  void initState() {
    super.initState();
    // SystemChrome.setSystemUIOverlayStyle(
    //     SystemUiOverlayStyle.light); //byDefault light - because of SafeArea
    //fbAud
    if (adv_type == "google") {
      AdHelper.createRewardedAd();
      _createInterstitialAd();
    }
    if (adv_type == "fb") {
      FbAdHelper.fbInit();
      _loadInterstitialAd();
      _loadRewardedAd();
    }
    if (adv_type == "unity") {


      UnityAds.init(
        gameId: Platform.isAndroid ? unityGameID : iosUnityGameID,
        testMode: true,
        onComplete: () {
          print('Initialization Complete');
          _loadAd(unityAdHelper.interstitialAdUnitId);
          _loadAd(unityAdHelper.rewardAdUnitId);
        },
        onFailed: (error, message) =>
            print('Initialization Failed: $error $message'),
      );
    }
    //fbAud
    getUserDetails();
  }

  /*void _loadAds() {
    for (var placementId in placements.keys) {
      _loadAd(placementId);
    }
  }*/

  void _loadAd(String placementId) {
    UnityAds.load(
        placementId: placementId,
        onComplete: (placementId) {
          print('Load Complete $placementId');
          setState(() {
            _isInterstitialAdLoaded = true;
            _isRewardedAdLoaded = true;
          });
        },
        onFailed: (placementId, error, message) {
          setState(() {
            _isInterstitialAdLoaded = false;
            _isRewardedAdLoaded = false;
          });
          print('Load Failed $placementId: $error $message');
        });
  }

  void _showAd(String placementId) {
    /* setState(() {
      placements[placementId] = false;
    });*/
    UnityAds.showVideoAd(
      placementId: placementId,
      onComplete: (placementId) {
        print('Video Ad $placementId completed');
        _loadAd(placementId);
      },
      onFailed: (placementId, error, message) {
        print('Video Ad $placementId failed: $error $message');
        _loadAd(placementId);
      },
      onStart: (placementId) => print('Video Ad $placementId started'),
      onClick: (placementId) => print('Video Ad $placementId click'),
      onSkipped: (placementId) {
        print('Video Ad $placementId skipped');
        _loadAd(placementId);
      },
    );
  }

  @override
  void dispose() {
    /* !isDark! //set it back to as it was
        ? SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark)
        : SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light); */
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(
    //     SystemUiOverlayStyle.light); //byDefault light - because of SafeArea
    /*  !isDark!
        ? SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light)
        : SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark); */
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    return Scaffold(
        key: _scaffoldKey,
        body: !widget.isDetails! ? _showBreakingNews() : _showNews());
    /*  SafeArea(
      child: Scaffold(
          key: _scaffoldKey,
          body: !widget.isDetails! ? _showBreakingNews() : _showNews()),
    ); */ //check for breakingNews or Others
  }

  void _showGoogleRewardedAd() {
    if (_rewardedAd == null) {
      print('Warning: attempt to show rewarded before loaded.');
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        AdHelper.createRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        AdHelper.createRewardedAd();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
    });
    _rewardedAd = null;
  }

  getUserDetails() async {
    CUR_USERID = await getPrefrence(ID) ?? "";
    setState(() {});
  }

  void _createInterstitialAd() {
    if (goInterstitialId != null || iosGoInterstitialId != null) {
      InterstitialAd.load(
          adUnitId: AdHelper.interstitialAdUnitId,
          request: request,
          adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (InterstitialAd ad) {
              print('$ad loaded now****');
              _interstitialAd = ad;
              _numInterstitialLoadAttempts = 0;
              _interstitialAd!.setImmersiveMode(true);
            },
            onAdFailedToLoad: (LoadAdError error) {
              print('InterstitialAd failed to load: $error.');
              _numInterstitialLoadAttempts += 1;
              _interstitialAd = null;
              if (_numInterstitialLoadAttempts <= maxFailedLoadAttempts) {
                _createInterstitialAd();
              }
            },
          ));
    }
  }

  void _showGoogleInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  void _loadInterstitialAd() {
    if (iosFbInterstitialId != "" || fbInterstitialId != "") {
      FacebookInterstitialAd.loadInterstitialAd(
        placementId: FbAdHelper.interstitialAdUnitId,
        listener: (result, value) {
          print(">> FAN > Interstitial Ad: $result --> $value");
          if (result == InterstitialAdResult.LOADED)
            _isInterstitialAdLoaded = true;

          if (result == InterstitialAdResult.DISMISSED &&
              value["invalidated"] == true) {
            print("invalidated fb");
            _isInterstitialAdLoaded = false;
            _loadInterstitialAd();
            setState(() {}); //to set all setting back
          }
        },
      );
    }
  }

  void _loadRewardedAd() {
    if (iosFbRewardedVideoId != "" || fbRewardedVideoId != "") {
      FacebookRewardedVideoAd.loadRewardedVideoAd(
        placementId: FbAdHelper.rewardAdUnitId,
        listener: (result, value) {
          print(">> FAN > RewardedVideo Ad: $result --> $value");
          if (result == RewardedVideoAdResult.LOADED)
            _isRewardedAdLoaded = true;

          if (result == RewardedVideoAdResult.VIDEO_CLOSED &&
              value["invalidated"] == true) {
            _isRewardedAdLoaded = false;
            _loadRewardedAd();
            setState(() {}); //to set all setting back
          }
        },
      );
    }
  }

//fbAud
  //page slider for Breaking news list data
  Widget _showBreakingNews() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
        height: height,
        width: width,
        child: PageView.builder(
            controller: pageController,
            onPageChanged: (index) async {
              setState(() {
                _curSlider = index;
              });
              _isNetworkAvail = await isNetworkAvailable();

              if (_isNetworkAvail) {
                if (index % 2 == 0) {
                  if (adv_type == "google") showAdmobRewardAd();
                  if (adv_type == "fb") _showRewardedAd();
                  if (adv_type == "unity")
                    _showAd(unityAdHelper.rewardAdUnitId);
                }
                //fbAud
                if ((index % 3 == 0) || (index % 5 == 0)) {
                  if (adv_type == "google") showAdmobInterstitialAd();
                  if (adv_type == "fb") showFBInterstitialAd();
                  if (adv_type == "unity")
                    _showAd(unityAdHelper.interstitialAdUnitId);
                }
                //fbAud
              }
            },
            itemCount: widget.news1!.length == 0 ? 1 : widget.news1!.length + 1,
            itemBuilder: (context, index) {
              return index == 0
                  ? NewsSubDetails(
                      model1: widget.model1,
                      index: widget.index != null ? widget.index : 0,
                      updateParent: widget.updateParent,
                      id: widget.id,
                      isDetails: widget.isDetails,
                    )
                  : NewsSubDetails(
                      model1: widget.news1![index - 1],
                      index: widget.index != null ? index - 1 : 0,
                      updateParent: widget.updateParent,
                      id: widget.news1![index - 1].id,
                      isDetails: widget.isDetails,
                    );
            }));
  }

  //page slider news list data
  Widget _showNews() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
        height: height,
        width: width,
        child: PageView.builder(
            controller: pageController,
            onPageChanged: (index) async {
              setState(() {
                _curSlider = index;
              });
              _isNetworkAvail = await isNetworkAvailable();
              if (_isNetworkAvail) {
                if (index % 2 == 0) {
                  if (adv_type == "google") showAdmobRewardAd();
                  if (adv_type == "fb") _showRewardedAd();
                  if (adv_type == "unity")
                    _showAd(unityAdHelper.rewardAdUnitId);
                }
                //fbAud
                if ((index % 3 == 0) || (index % 5 == 0)) {
                  if (adv_type == "google") showAdmobInterstitialAd();
                  if (adv_type == "fb") showFBInterstitialAd();
                  if (adv_type == "unity")
                    _showAd(unityAdHelper.interstitialAdUnitId);
                }
                //fbAud
              }
            },
            itemCount: widget.news!.length == 0 ? 1 : widget.news!.length + 1,
            itemBuilder: (context, index) {
              return index == 0
                  ? NewsSubDetails(
                      model: widget.model,
                      index: widget.index,
                      updateParent: widget.updateParent,
                      id: widget.id,
                      isBookmarked: widget.isbookmarked,
                      isDetails: widget.isDetails,
                      fromShowMoreList: widget.fromShowMoreList,
                    )
                  : NewsSubDetails(
                      model: widget.news![index - 1],
                      index: index - 1,
                      updateParent: widget.updateParent,
                      id: widget.news![index - 1].id,
                      isBookmarked: widget.isbookmarked,
                      isDetails: widget.isDetails,
                      fromShowMoreList: widget.fromShowMoreList,
                    );
            }));
  }

  showAdmobInterstitialAd() {
    if (unityInterstitialId != null || iosUnityInterstitialId != null) {
      _showGoogleInterstitialAd();
    }
  }

  showAdmobRewardAd() {
    if (goRewardedVideoId != null || iosGoRewardedVideoId != null) {
      _showGoogleRewardedAd();
    }
  }

  showFBInterstitialAd() {
    if (iosFbInterstitialId != "" || fbInterstitialId != "") {
      if (iosFbInterstitialId != "" || fbInterstitialId != "") {
        if (_isInterstitialAdLoaded == true)
          FacebookInterstitialAd.showInterstitialAd();
        else
          print("Interstial Ad not yet loaded!");
      }
    }
  }

  _showRewardedAd() {
    if (_isRewardedAdLoaded == true)
      FacebookRewardedVideoAd.showRewardedVideoAd();
    else
      print("Rewarded Ad not yet loaded!");
  }

/*showUnityInterstitialAd() {
    if (unityInterstitialId != null || iosUnityInterstitialId != null) {
      if (_isInterstitialAdLoaded == true)
        unityAdHelper.showInterstitialAd();
      else
        print("Unity Interstitial Ad not yet loaded!");
    }
  }*/

/*showUnityRewardAd() {
    if (unityRewardedVideoId != null || iosUnityRewardedVideoId != null) {
      if (_isRewardedAdLoaded == true)
        unityAdHelper.createUnityRewardedAd();
      else
        print("Unity Reward Ad not yet loaded!");
    }
  }*/
}
