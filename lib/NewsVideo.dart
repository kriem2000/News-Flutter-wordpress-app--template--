// ignore_for_file: must_be_immutable

// import 'dart:ui';

import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:news/Helper/Session.dart';
import 'package:news/Helper/Color.dart';
import 'package:news/Model/LiveStreaming.dart';

// import 'package:news/Helper/String.dart';
import 'package:news/NewsDetailsVideo.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:news/Model/News.dart';

// import 'package:news/NewsDetails.dart';

class NewsVideo extends StatefulWidget {
  int from;
  LiveStreamingModel? liveModel;
  News? model;

  NewsVideo({Key? key, this.model, required this.from, this.liveModel})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => StateVideo();
}

class StateVideo extends State<NewsVideo> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FlickManager? flickManager;
  YoutubePlayerController? _yc;
  bool _isNetworkAvail = true;

  // InAppWebViewController? _webViewController;
  // double webHeight = 300;
  // Color backbtncolor = ColorsRes.black;
  // bool isfullscreen = false, isplayed = false;
  // String videoprogress = "0", totalvideoprogress = "0";
  // bool isupdateprogress;

  // late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    checkInternet();
    if (widget.from == 1) {
      if (widget.model!.contentValue != "" ||
          widget.model!.contentValue != null) {
        if (widget.model!.contentType == "video_upload") {
          flickManager = FlickManager(
              videoPlayerController:
                  VideoPlayerController.network(widget.model!.contentValue!),
              autoPlay: true); //false
        } else if (widget.model!.contentType == "video_youtube") {
          _yc = YoutubePlayerController(
            initialVideoId:
                YoutubePlayer.convertUrlToId(widget.model!.contentValue!)!,
            flags: YoutubePlayerFlags(
              autoPlay: true, //false
            ),
          );
        }
      }
    } else {
      if (widget.liveModel!.type == "url_youtube") {
        _yc = YoutubePlayerController(
          initialVideoId: YoutubePlayer.convertUrlToId(widget.liveModel!.url!)!,
          flags: YoutubePlayerFlags(autoPlay: true, isLive: true //false
              ),
        );
        //false
      }
    }
  }

  checkInternet() async {
    _isNetworkAvail = await isNetworkAvailable();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    if (widget.from == 1) {
      if (widget.model!.contentType == "video_upload") {
        flickManager!.dispose();
        // _controller.dispose();
      } else if (widget.model!.contentType == "video_youtube") {
        _yc!.dispose();
      }
    } else {
      if (widget.liveModel!.type == "url_youtube") {
        _yc!.dispose();
      }
    }
    /* SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor:
            Theme.of(context).colorScheme.lightColor.withOpacity(0.7))); */
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true, //to show Landscape video fullscreen
      appBar: AppBar(
          // centerTitle: false,
          // elevation: 0.0,
          backgroundColor: Colors.transparent,
          // systemOverlayStyle:
          //     !isDark! ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
          leading: InkWell(
            onTap: () {
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
                DeviceOrientation.portraitDown
              ]);
              Navigator.of(context).pop();
            },
            child: Padding(
              padding: EdgeInsetsDirectional.only(start: 20),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(22.0),
                  child: Container(
                      alignment: Alignment.center,
                      // height: 32,
                      // width: 32,
                      decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .likeContainerColor
                              .withOpacity(0.7),
                          shape: BoxShape.circle),
                      child: Icon(
                        Icons.keyboard_backspace_rounded,
                        color: Theme.of(context).colorScheme.skipColor,
                      ))),
            ),
            /* Icon(
              Icons.keyboard_backspace_rounded,
              color: Theme.of(context).colorScheme.skipColor,
            ), */
            splashColor: colors.transparentColor,
            highlightColor: colors.transparentColor,
          )),
      body: Padding(
        padding: EdgeInsetsDirectional.only(
          start: 15.0,
          end: 15.0,
          bottom: 5.0,
        ), // top: MediaQuery.of(context).padding.top
        child: _isNetworkAvail
            ? Container(
                alignment: Alignment.center,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
                child: viewVideo())
            : Center(child: Text(getTranslated(context, 'internetmsg')!)),
      ),
    );
  }

  //news video link set
  viewVideo() {
    return widget.from == 1
        ? widget.model!.contentType == "video_upload"
            ? Container(
                child: FlickVideoPlayer(
                  flickManager: flickManager!,
                ),
              )
            : widget.model!.contentType == "video_youtube"
                ? YoutubePlayer(
                    controller: _yc!,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: colors.primary,
                  )
                : widget.model!.contentType == "video_other"
                    ? Center(
                        child: NewsDetailsVideo(
                          src: widget.model!.contentValue,
                          type: "3",
                        ),
                      )
                    : SizedBox.shrink()
        : widget.liveModel!.type == "url_youtube"
            ? YoutubePlayer(
                controller: _yc!,
                showVideoProgressIndicator: true,
                progressIndicatorColor: colors.primary,
              )
            : Center(
                child: NewsDetailsVideo(
                  src: widget.liveModel!.url,
                  type: "3",
                ),
              );
  }
}
