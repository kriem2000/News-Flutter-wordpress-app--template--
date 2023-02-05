import 'dart:io';
import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'package:news/Helper/String.dart';

late UnityBannerAd bannerAd;

class unityAdHelper {
  static String get gameId {
    if (Platform.isIOS) {
      return iosUnityGameID;
    } else if (Platform.isAndroid) {
      return unityGameID;
    }
    throw new UnsupportedError("Unsupported platform");
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return unityBannerId;
    } else if (Platform.isIOS) {
      return iosUnityBannerId;
    }
    throw new UnsupportedError("Unsupported platform");
  }

  static String get interstitialAdUnitId {
    if (Platform.isIOS) {
      return iosUnityInterstitialId;
    } else if (Platform.isAndroid) {
      return unityInterstitialId;
    }
    throw new UnsupportedError("Unsupported platform");
  }

  static String get rewardAdUnitId {
    if (Platform.isIOS) {
      return iosUnityRewardedVideoId;
    } else if (Platform.isAndroid) {
      return unityRewardedVideoId;
    }
    throw new UnsupportedError("Unsupported platform");
  }

  static void unityAdsInit() {
    UnityAds.init(
      gameId: Platform.isAndroid ? unityGameID : iosUnityGameID, //'4877963', //android ID
      testMode: true,
      onComplete: () => print('Unity ad Initialization Complete'),
      onFailed: (error, message) =>
          print('Unity ad Initialization Failed: $error $message'),
    );
  }

  static bool? loadAd(String unitId) {
    UnityAds.load(
      placementId: unitId,
      onComplete: (placementId) {
        print('Unity Ad $placementId completed');
        return true;
      },
      onFailed: (placementId, error, message) {
        print('Unity Ad $placementId failed: $error $message');
        return false;
      },
    );
    return false;
  }

  static void createUnityRewardedAd() {
    if (unityRewardedVideoId != " " || iosUnityRewardedVideoId != " ") {
      if (loadAd(rewardAdUnitId)!)
        UnityAds.showVideoAd(
          placementId: rewardAdUnitId,
          onComplete: (placementId) =>
              print('Reward Video Ad $placementId completed'),
          onFailed: (placementId, error, message) =>
              print('Reward Video Ad $placementId failed: $error $message'),
          onStart: (placementId) =>
              print('Reward Video Ad $placementId started'),
          onClick: (placementId) => print('Reward Video Ad $placementId click'),
          onSkipped: (placementId) =>
              print('Reward Video Ad $placementId skipped'),
        );

      /* UnityAds.load(
        placementId: rewardAdUnitId,
        onComplete: (placementId) =>
            print('Reward Video Ad $placementId completed'),
        onFailed: (placementId, error, message) =>
            print('Reward Video Ad $placementId failed: $error $message'),
      ); */
    }
  }

  static void showInterstitialAd() {
    if (loadAd(interstitialAdUnitId)!)
      UnityAds.showVideoAd(
        placementId: interstitialAdUnitId,
        onComplete: (placementId) =>
            print('Interstitial Ad $placementId completed'),
        onFailed: (placementId, error, message) =>
            print('Interstitial Ad $placementId failed: $error $message'),
        onStart: (placementId) => print('Interstitial Ad $placementId started'),
        onClick: (placementId) => print('Interstitial Ad $placementId click'),
        onSkipped: (placementId) =>
            print('Interstitial Ad $placementId skipped'),
      );
  }

  UnityBannerAd createAllInOneBannerAd(BuildContext context) {
    if (loadAd(bannerAdUnitId)!)
      bannerAd = UnityBannerAd(
        placementId: bannerAdUnitId,
        onFailed: (placementId, error, message) =>
            print('Video Ad $placementId failed: $error $message'),
        onClick: (placementId) => print('Video Ad $placementId click'),
      );
    return bannerAd;
  }
}
