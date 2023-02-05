import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:news/Helper/String.dart';

final AdRequest request = AdRequest(
  //static
  keywords: <String>['foo', 'bar'],
  contentUrl: 'http://foo.com/bar.html',
  nonPersonalizedAds: true,
);
RewardedAd? rewardedAd;
int _numRewardedLoadAttempts = 0;
int maxFailedLoadAttempts = 3;

late BannerAd bannerAd;

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return goBannerId;
    } else if (Platform.isIOS) {
      return iosGoBannerId;
    }
    throw new UnsupportedError("Unsupported platform");
  }

  static String get nativeAdUnitId {
    if (Platform.isAndroid) {
      return goNativeUnitId;
    } else if (Platform.isIOS) {
      return iosGoNativeUnitId;
    }
    throw new UnsupportedError("Unsupported platform");
  }

  static String get interstitialAdUnitId {
    if (Platform.isIOS) {
      return iosGoInterstitialId;
    } else if (Platform.isAndroid) {
      return goInterstitialId;
    }
    throw new UnsupportedError("Unsupported platform");
  }

  static String get rewardAdUnitId {
    if (Platform.isIOS) {
      return iosGoRewardedVideoId;
    } else if (Platform.isAndroid) {
      return goRewardedVideoId;
    }
    throw new UnsupportedError("Unsupported platform");
  }

  static void createRewardedAd() {
    if (goRewardedVideoId != " " || iosGoRewardedVideoId != " ") {
      RewardedAd.load(
          adUnitId: rewardAdUnitId,
          request: request,
          rewardedAdLoadCallback: RewardedAdLoadCallback(
            onAdLoaded: (RewardedAd ad) {
              print('$ad loaded.');
              rewardedAd = ad;
              _numRewardedLoadAttempts = 0;
            },
            onAdFailedToLoad: (LoadAdError error) {
              print('RewardedAd failed to load: $error');
              rewardedAd = null;
              _numRewardedLoadAttempts += 1;
              if (_numRewardedLoadAttempts <= maxFailedLoadAttempts) {
                createRewardedAd();
              }
            },
          ));
    }
  }

  BannerAd createAllInOneBannerAd(BuildContext context) {
    // if (AdHelper.bannerAdUnitId != "") {
    bannerAd = BannerAd(
      adUnitId:
          AdHelper.bannerAdUnitId, //'ca-app-pub-3940256099942544/6300978111',
      request: AdRequest(),
      size: AdSize.mediumRectangle, //mediumRectangle, //fullBanner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          // setState(() {
          //   _isBannerAdReady = true;
          print("Native/Banner ad is Loaded !!!");
          // });
        },
        onAdFailedToLoad: (ad, err) {
          /*  setState(() {
            _isBannerAdReady = false;
          }); */
          print("error in loading Native/Banner ad $err");
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print(
            'Native/Banner ad opened.'), // Called when an ad opens an overlay that covers the screen.
        onAdClosed: (Ad ad) => print(
            'Native/Banner ad closed.'), // Called when an ad removes an overlay that covers the screen.
        onAdImpression: (Ad ad) => print('Native/Banner ad impression.'),
      ),
    );
    return bannerAd;
  }
}
