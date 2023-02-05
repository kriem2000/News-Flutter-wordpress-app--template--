import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:news/Helper/Color.dart';
import 'package:news/Helper/Session.dart';
import 'package:news/Model/LiveStreaming.dart';

// import 'package:news/NewsDetails.dart';
import 'package:news/NewsDetailsVideo.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'Helper/String.dart';
import 'Helper/Widgets.dart';
import 'NewsVideo.dart';

// ignore: must_be_immutable
class Live extends StatefulWidget {
  List<LiveStreamingModel> liveNews;

  Live({Key? key, required this.liveNews}) : super(key: key);

  @override
  State<StatefulWidget> createState() => StateLive();
}

class StateLive extends State<Live> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // YoutubePlayerController? _yc;
  bool _isNetworkAvail = true;
  bool isFullScreen = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  appBarSet() {
    return AppBar(
      // leadingWidth: 35, //25,
      /* elevation: 0.0,
      systemOverlayStyle:
          !isDark! ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light, */
      backgroundColor: Colors.transparent,
      leading: setBackButton(context, Theme.of(context).colorScheme.fontColor),
      //padding: EdgeInsets.only(left: 10.0),

      title: Transform(
        transform: Matrix4.translationValues(-20.0, 0.0, 0.0),
        child: Text(getTranslated(context, 'live_videos_lbl')!,
            style: Theme.of(context).textTheme.headline6?.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.bold,
                )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: appBarSet(),
        body:
            mainListBuilder() /*Stack(children: <Widget>[
          Padding(
            padding: EdgeInsetsDirectional.only(
                start: 15.0, end: 15.0), //, top: 10.0, bottom: 10.0
            child: _isNetworkAvail
                ? widget.liveNews[0][TYPE] == "url_youtube"
                    ? Center(
                        child: YoutubePlayer(
                          controller: _yc!,
                        ),
                      )
                    : NewsDetailsVideo(
                        src: widget.liveNews[0]["url"],
                        type: "3",
                      )
                : Center(child: Text(getTranslated(context, 'internetmsg')!)),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                    padding: EdgeInsetsDirectional.only(
                        top: 30), //start: 20.0,top: 50.0,
                    child: Container(
                        height: 30,
                        width: 30,
                        // padding: EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            print(
                                "value of FullScreen Variable is $isFullScreen");
                            changeResolutionAndClose();
                          },
                          child: Icon(Icons.keyboard_backspace_rounded,
                              color: Theme.of(context).colorScheme.darkColor),
                          splashColor: colors.transparentColor,
                          highlightColor: colors.transparentColor,
                        ))),
                Container(
                  // color: Colors.blue,
                  height: 100,
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: EdgeInsetsDirectional.only(
                      top: MediaQuery.of(context).padding.top + 20),
                  */ /*    padding: EdgeInsetsDirectional.only(
                      top: 50.0, start: 10.0, end: 10.0), */ /*
                  child: Text(
                    widget.liveNews[0][TITLE],
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.darkColor,
                          */ /* fontWeight: FontWeight.w600,
                        letterSpacing: 0.5 */ /*
                        ),
                    maxLines: 5,
                    softWrap: true,
                    // textAlign: TextAlign.justify,
                  ),
                )
              ],
            ),
          ),
        ])*/
        );
  }

  mainListBuilder() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: ListView.separated(
          itemBuilder: ((context, index) {
            return Padding(
              padding: EdgeInsets.only(top: index == 0 ? 0 : 20),
              child: ClipRRect(
                borderRadius: BorderRadius.all(const Radius.circular(10.0)),
                child: /* AbsorbPointer(
                  absorbing: !isVidClicked,
                  child: */
                    InkWell(
                  onTap: () {
                    /* if (mounted)
                      setState(() {
                        isVidClicked = false;
                      }); */
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NewsVideo(
                                  liveModel: widget.liveNews[index],
                                  from: 2,
                                )));
                    /* if (mounted)
                      setState(() {
                        isVidClicked = true;
                      }); */
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (widget.liveNews[index].type == 'url_youtube')
                        CachedNetworkImage(
                          fadeInDuration: Duration(milliseconds: 150),
                          imageUrl: widget.liveNews[index].image!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorWidget: (context, error, stackTrace) =>
                              errorWidget(200, double.infinity),
                          placeholder: (context, url) {
                            return Image.asset(
                              'assets/images/Placeholder_video.jpg',
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.black45,
                          child: Icon(
                            Icons.play_arrow,
                            size: 40,
                            color: Colors.white,
                          )),
                      Positioned.directional(
                        textDirection: Directionality.of(context),
                        bottom: 10,
                        start: 20,
                        end: 20,
                        child: Text(
                          widget.liveNews[index].title!,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(color: colors.tempboxColor),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                ),
                // ),
              ),
            );
          }),
          separatorBuilder: (context, index) {
            return SizedBox(height: 3.0);
          },
          itemCount: widget.liveNews.length),
    );
  }
}
