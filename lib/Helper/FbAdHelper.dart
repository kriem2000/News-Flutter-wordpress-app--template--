import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:news/Helper/String.dart';

class FbAdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return fbBannerId;
    } else if (Platform.isIOS) {
      return iosFbBannerId;
    }
    throw new UnsupportedError("Unsupported platform");
  }

  static String get nativeAdUnitId {
    if (Platform.isAndroid) {
      return fbNativeUnitId;
    } else if (Platform.isIOS) {
      return iosFbNativeUnitId;
    }
    throw new UnsupportedError("Unsupported platform");
  }

  static String get interstitialAdUnitId {
    if (Platform.isIOS) {
      return iosFbInterstitialId;
    } else if (Platform.isAndroid) {
      return fbInterstitialId;
    }
    throw new UnsupportedError("Unsupported platform");
  }

  static String get rewardAdUnitId {
    if (Platform.isIOS) {
      return iosFbRewardedVideoId;
    } else if (Platform.isAndroid) {
      return fbRewardedVideoId;
    }
    throw new UnsupportedError("Unsupported platform");
  }

  static fbInit() async {
    String? deviceId = await getId();
    print("device id*****$deviceId");
    FacebookAudienceNetwork.init(
        iOSAdvertiserTrackingEnabled: true, testingId: deviceId);
  }

  static Future<String?> getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // Unique ID on iOS
    }
  }
}
