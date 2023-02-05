// ignore_for_file: must_be_immutable, invalid_return_type_for_catch_error
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:news/Helper/Color.dart';
import 'package:news/Helper/Constant.dart';
import 'package:news/Helper/Session.dart';
import 'package:news/Helper/String.dart';
import 'package:news/Helper/Widgets.dart';
import 'package:news/Model/News.dart';
import 'package:news/NewsVideo.dart';
import 'package:path_provider/path_provider.dart';

import 'package:video_thumbnail/video_thumbnail.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:http/http.dart' as http;

import 'Home.dart';

class Videos extends StatefulWidget {
  bool isBackRequired = false;

  Videos({
    Key? key,
    required this.isBackRequired,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => VideosState();
}

class VideosState extends State<Videos> {
  String url = "";
  List<News> items = [];

  bool _isNetworkAvail = true;
  int offsetVal = 0;

  bool _isLoading = false;
  bool isBookmarkLoading = false;
  List bookMarkValue = [];
  List<News> bookmarkList = [];

  bool isVidClicked = false;
  bool isSaved = true;
  bool isShared = true;

  // int inBetweenClicks = 0; //10;

  @override
  void initState() {
    super.initState();
    // offsetVal = 0;
    getNewsVideoURL();
    _getBookmark();
  }

  @override
  void dispose() {
    //bookmarkList.clear(); //as it is using setState
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Videos are loading? --$_isLoading');
    return Scaffold(
      appBar: appBar(),
      body: _isLoading
          ? Padding(
              padding: EdgeInsets.only(
                  bottom: 10.0,
                  left: 30.0,
                  right: 30.0), //start: 13.0, end: 13.0
              child: contentShimmer(context))
          : mainListBuilder(),
    );
  }

  _setBookmark(String status, String id) async {
    if (bookMarkValue.contains(id)) {
      //  setState(() {
      bookMarkValue = List.from(bookMarkValue)..remove(id);
      //  });
    } else {
      //  setState(() {
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
      print(msg);
      if (error == "false") {
        /* if (status == "0") {
          showSnackBar(msg, context);
        } else {
          showSnackBar(msg, context);
        } */
      }
    } else {
      showSnackBar(getTranslated(context, 'internetmsg')!, context);
    }
  }

// ignore: non_constant_identifier_names
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

  appBar() {
    return PreferredSize(
        preferredSize: Size(double.infinity, 45),
        child: AppBar(
          /*    systemOverlayStyle:
              !isDark! ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light, */
          iconTheme:
              IconThemeData(color: Theme.of(context).colorScheme.darkColor),
          leading: (widget.isBackRequired)
              ? setBackButton(
                  context,
                  isDark!
                      ? colors.bgColor
                      : colors
                          .secondaryColor) /* IconButton(
                  icon: Icon(Icons.arrow_back,
                      color: isDark! ? colors.bgColor : colors.secondaryColor),
                  onPressed: () => Navigator.of(context).pop(),
                  splashColor: Colors.transparent,
                ) */
              : SizedBox.shrink(),
          // leadingWidth: 0, //25
          titleSpacing: 0.0,
          centerTitle: false,
          // elevation: 0.0,
          backgroundColor: Colors.transparent,
          title: Transform(
            transform: Matrix4.translationValues(
                (widget.isBackRequired) ? -10.0 : -28.0, //-35.0
                0.0,
                0.0),
            //used to set title to Left Forecefully instead of using LeadingWidth[it affects click of BackButton]
            child: Text(
              getTranslated(context, 'videos_lbl')!,
              style: Theme.of(context).textTheme.headline6?.copyWith(
                  color: Theme.of(context).colorScheme.darkColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5),
            ),
          ),
        ));
  }

  mainListBuilder() {
    return ListView.separated(
        itemBuilder: ((context, index) {
          return Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(const Radius.circular(10.0)),
                  child: /* AbsorbPointer(
                    absorbing: !isVidClicked,
                    child: */
                      InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NewsVideo(
                                    model: videoItems[index],
                                    from: 1,
                                  )));
                      /* if (mounted)
                        setState(() {
                          isVidClicked = true;
                        }); */
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        (videoItems[index].contentType == 'video_youtube')
                            ? CachedNetworkImage(
                                fadeInDuration: Duration(milliseconds: 150),
                                imageUrl: videoItems[index].img!,
                                width: 356,
                                height: 200,
                                fit: BoxFit.cover,
                                errorWidget: (context, error, stackTrace) =>
                                    errorWidget(200, double.infinity),
                                placeholder: (context, url) {
                                  return Image.asset(
                                    'assets/images/Placeholder_video.jpg',
                                    width: 356,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            : ((videoItems[index].contentType == 'video_upload')
                                ? Image.file(
                                    File(videoItems[index].img!),
                                    width: 356,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorBuilder: (BuildContext context,
                                        Object exception,
                                        StackTrace? stackTrace) {
                                      return Image.asset(
                                        'assets/images/Placeholder_video.jpg',
                                        width: 356,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  )
                                : Image.asset(
                                    'assets/images/Placeholder_video.jpg',
                                    width: 356,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  )),
                        CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.black45,
                            child: Icon(
                              Icons.play_arrow,
                              size: 40,
                              color: Colors.white,
                            ))
                      ],
                    ),
                  ),
                  // ),
                ),
              ),
              Padding(
                  padding:
                      EdgeInsets.only(left: 30, right: 30), //start: 15, end: 15
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        videoItems[index].title!,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ))),
              Padding(
                padding: EdgeInsets.only(left: 30, right: 30),
                //left: 15, right: 15
                child: Row(
                  children: [
                    Text(
                        convertToAgo(context,
                            DateTime.parse(videoItems[index].date!), 0)!,
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .agoLabel
                                .withOpacity(0.8))),
                    Spacer(),
                    /* AbsorbPointer(
                      absorbing: !isSaved,
                      child:  */
                    InkWell(
                      onTap: () {
                        /*  if (mounted)
                          setState(() {
                            isSaved = false;
                          }); */
                        //if (isSaved) {
                        /* if (mounted)
                          setState(() {
                            isSaved = false;
                          }); */
                        if (isRedundentClick(DateTime.now(), diff)) {
                          //inBetweenClicks
                          print('hold on, processing');
                          /* showSnackBar(
                              getTranslated(context, 'processing')!, context); */
                          return;
                        }
                        if (CUR_USERID != "") {
                          setState(() {
                            bookMarkValue.contains(videoItems[index].id!)
                                ? _setBookmark("0", videoItems[index].id!)
                                : _setBookmark("1", videoItems[index].id!);

                            // isSaved = true;
                            //inBetweenClicks = 2; //0
                            diff = resetDiff;
                          });
                        } else {
                          loginRequired(context);
                          if (mounted)
                            setState(() {
                              diff = resetDiff;
                              // inBetweenClicks = 2; //0
                            });
                          /*  if (mounted)
                              setState(() {
                                isSaved = true;
                              }); */
                        }
                        //  }
                      },
                      child: bookMarkValue.contains(videoItems[index].id)
                          ? Icon(Icons.bookmark_added_rounded)
                          : Icon(Icons.bookmark_add_outlined),
                      splashColor: Colors.transparent,
                    ),
                    // ),
                    SizedBox(width: deviceWidth! / 99.0),
                    /* AbsorbPointer(
                      absorbing: !isShared,
                      child: */
                    InkWell(
                      onTap: () async {
                        if (isRedundentClick(DateTime.now(), diff)) {
                          //inBetweenClicks
                          print('hold on, processing');
                          /* showSnackBar(
                              getTranslated(context, 'processing')!, context); */
                          return;
                        }
                        // print('run process');
                        // },

                        /* if (mounted)
                          setState(() {
                            isShared = false;
                          }); */
                        _isNetworkAvail = await isNetworkAvailable();
                        if (_isNetworkAvail) {
                          createDynamicLink(context, videoItems[index].id!,
                              index, videoItems[index].title!, true, false);
                        } else {
                          showSnackBar(
                              getTranslated(context, 'internetmsg')!, context);
                        }
                        if (mounted)
                          setState(() {
                            diff = resetDiff;
                            //inBetweenClicks = 2; //0
                          });
                        /* if (mounted)
                          setState(() {
                            isShared = true;
                          }); */
                      },
                      child: Icon(Icons.share_rounded),
                      splashColor: Colors.transparent,
                    ),
                    // )
                  ],
                ),
              ),
            ],
          );
        }),
        separatorBuilder: (context, index) {
          return SizedBox(height: 3.0);
        },
        itemCount: videoItems.length);
  }

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

          var getdata = json.decode(response.body);

          String error = getdata["error"];
          if (error == "false") {
            bookmarkList.clear();
            var data = getdata["data"];

            bookmarkList =
                (data as List).map((data) => new News.fromJson(data)).toList();
            bookMarkValue.clear();

            for (int i = 0; i < bookmarkList.length; i++) {
              if (mounted)
                setState(() {
                  bookMarkValue.add(bookmarkList[i].newsId);
                });
            }
            if (mounted)
              setState(() {
                isBookmarkLoading = false;
              });
          } else {
            setState(() {
              isBookmarkLoading = false;
            });
          }
        } on TimeoutException catch (_) {
          showSnackBar(getTranslated(context, 'somethingMSg')!, context);
          setState(() {
            isBookmarkLoading = false;
          });
        }
      } else {
        showSnackBar(getTranslated(context, 'internetmsg')!, context);
      }
    }
  }

  Future getNewsVideoURL() async {
    print("video URl get = ${videoItems.length}");
    if (videoItems.isNotEmpty) return;
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        setState(() {
          _isLoading = true;
        });
        var parameter = {
          ACCESS_KEY: access_key,
          LIMIT: vidCount.toString(),
          OFFSET: offsetVal.toString(),
          USER_ID: CUR_USERID != "" ? CUR_USERID : "0"
        };
        print(" Parameters - Videos API - $parameter");
        Response response =
            await post(Uri.parse(getNewsApi), headers: headers, body: parameter)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        print("getdata*****$getdata");

        String error = getdata["error"];

        if (error == "false") {
          videoItems.clear();
          // print("General News Data-  $getdata");
          if (mounted) {
            new Future.delayed(Duration.zero, () async {
              List mainlist = getdata['data'];
              if (mainlist.length != 0) {
                items.addAll(
                    mainlist.map((data) => new News.fromJson(data)).toList());

                // print("length of list of items: ${items.length}");
                int ii = 0;
                for (int i = 0; i < items.length; i++) {
                  // print("item ${items[i].contentType}");
                  if ((items[i].contentType == 'video_other') ||
                      (items[i].contentType == 'video_upload') ||
                      (items[i].contentType == 'video_youtube')) {
                    print(
                        "URLs - ${items[i].contentValue} - ${items[i].contentType}- ${items[i].id}");
                    // videoItems.add(items[i]);
                    if (videoItems.contains(items[i])) {
                      videoItems.removeAt(i);
                    } else {
                      videoItems.add(items[i]);
                    }
                    // print("-----${videoItems.length} & $ii");
                    if (videoItems.length > 0 && ii < videoItems.length) {
                      if (items[i].contentType != 'video_youtube') {
                        if (items[i].contentType == 'video_upload') {
                          String? image = await getThumbnailImage(
                              videoItems[ii].contentValue!);
                          videoItems[ii].img = image;
                          ii++;
                          // print("Length of VideoItems - ${videoItems.length}");//--${videoItems[i].img}
                        } else {
                          //type = 'video_other'
                          //pass placeholder image there
                          videoItems[ii].img =
                              'assets/images/Placeholder_video.jpg';
                          ii++;
                          // print("Length of VideoItems after type - Others - ${videoItems.length} ");
                        }
                      } else if (items[i].contentType == 'video_youtube') {
                        String? videoId =
                            convertUrlToId(videoItems[ii].contentValue!);
                        print("Video id- $videoId");
                        String thumbnailUrl =
                            getThumbnail(videoId: videoId ?? "");
                        print("Youtube thumbnail located @ $thumbnailUrl");
                        videoItems[ii].img = thumbnailUrl;
                        ii++;
                      }
                    }
                  }
                }
                offsetVal = offsetVal + vidCount;
                print(
                    "Length of Videos in Next screen -----${videoItems.length}");
                // print("Check value of img url - ${videoItems[0].img.toString()} - len of List - ${videoItems.length}");
              }
            }).then((value) {
              if (mounted)
                setState(() {
                  _isLoading = false;
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

//YouTubeThumbnail
String getThumbnail({
  required String videoId,
}) =>
    'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';

String? convertUrlToId(String url, {bool trimWhitespaces = true}) {
  if (!url.contains("http") && (url.length == 11)) return url;
  if (trimWhitespaces) url = url.trim();

  for (var exp in [
    RegExp(
        r"^https:\/\/(?:www\.|m\.)?youtube\.com\/watch\?v=([_\-a-zA-Z0-9]{11}).*$"),
    RegExp(
        r"^https:\/\/(?:www\.|m\.)?youtube(?:-nocookie)?\.com\/embed\/([_\-a-zA-Z0-9]{11}).*$"),
    RegExp(r"^https:\/\/youtu\.be\/([_\-a-zA-Z0-9]{11}).*$")
  ]) {
    Match? match = exp.firstMatch(url);
    if (match != null && match.groupCount >= 1) return match.group(1);
  }
  return null;
}
//YouTubeThumbnail
