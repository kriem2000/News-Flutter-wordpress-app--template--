import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:news/Helper/Color.dart';
import 'package:news/Helper/Widgets.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'package:news/Login.dart';
import 'Model/News.dart';
import 'NewsDetails.dart';

class Bookmark extends StatefulWidget {
  @override
  BookmarkState createState() => BookmarkState();
}

class BookmarkState extends State<Bookmark> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _isNetworkAvail = true;
  List<News> tempList = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  ScrollController _controller = new ScrollController();
  // bool enabled = true;

  List bookMarkValue = [];
  List likeDisLikeValue = [];
  List<News> bookmarkList = [];
  int offset = 0;
  int total = 0;
  bool isLoadingmore = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_scrollListener);
    getUserDetails();
    _getBookmark();
  }

  @override
  void dispose() {
    _controller.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: appBar(),
        body: Padding(
          padding:
              EdgeInsetsDirectional.only(bottom: 10.0, start: 20.0, end: 20.0),
          child: _isLoading
              ? contentShimmer(context)
              : CUR_USERID != ""
                  ? bookmarkList.length == 0 && !_isLoading
                      ? getNoItem()
                      : getBookmarkList()
                  : loginMsg(),
        ));
  }

  appBar() {
    return PreferredSize(
        preferredSize: Size(double.infinity, 45),
        child: AppBar(
            // systemOverlayStyle: !isDark!
            //     ? SystemUiOverlayStyle.dark
            //     : SystemUiOverlayStyle.light,
            // leadingWidth: 25,
            // elevation: 0.0,
            backgroundColor: Colors.transparent,
            title: Transform(
              transform: Matrix4.translationValues(-25.0, 0.0, 0.0),
              child: Text(
                getTranslated(context, 'bookmark_lbl')!,
                style: Theme.of(context).textTheme.headline6?.copyWith(
                    color: isDark! ? colors.bgColor : colors.secondaryColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5),
              ),
            ),
            leading: setBackButton(
                context,
                isDark!
                    ? colors.bgColor
                    : colors
                        .secondaryColor) /* IconButton(
            icon: Icon(Icons.arrow_back,
                color: isDark! ? colors.bgColor : colors.secondaryColor),
            onPressed: () => Navigator.of(context).pop(),
            splashColor: Colors.transparent,
          ), */
            ));
  }

//news bookmark list have no news then call this function
  Widget getNoItem() {
    return Center(child: Text(getTranslated(context, 'bookmark_nt_avail')!));
  }

//show bookmarklist
  getBookmarkList() {
    return RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        child: ListView.builder(
            controller: _controller,
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: bookmarkList.length,
            itemBuilder: (context, index) {
              DateTime time1 = DateTime.parse(bookmarkList[index].date!);
              return (index == bookmarkList.length && isLoadingmore)
                  ? Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: EdgeInsetsDirectional.only(top: 15.0),
                      child: /* AbsorbPointer(
                        absorbing: !enabled,
                        child: */
                          InkWell(
                        child: Stack(
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: CachedNetworkImage(
                                  //image
                                  imageUrl: bookmarkList[index].image!,
                                  height: 215.0, //320.0,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (context,url) {return placeHolder();},

                                  errorWidget:
                                      (context, error, stackTrace) {
                                    return errorWidget(215, double.infinity);
                                  },
                                )),
                            Positioned.directional(
                                textDirection: Directionality.of(context),
                                bottom: 0,
                                start: 0,
                                end: 0,
                                height: 95,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(10.0),
                                      bottomRight: Radius.circular(10.0)),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) {
                                      return LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            colors.darkColor1.withOpacity(0.01),
                                            colors.darkColor1.withOpacity(0.75)
                                          ]).createShader(bounds);
                                    },
                                    blendMode: BlendMode.overlay,
                                    child: Container(
                                      height: 60,
                                      width: double.infinity,
                                      color: Colors.transparent,
                                      child: Padding(
                                          padding: EdgeInsetsDirectional.only(
                                              start: 10, end: 10),
                                          child: Container(
                                            alignment: Alignment.center,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  convertToAgo(
                                                      context, time1, 0)!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .caption
                                                      ?.copyWith(
                                                          color: Colors.white,
                                                          fontSize: 13.0,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                ),
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 8.0),
                                                    child: Text(
                                                      bookmarkList[index]
                                                          .title!,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle1
                                                          ?.copyWith(
                                                              color: colors
                                                                  .bgColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 15,
                                                              height: 1.0,
                                                              letterSpacing:
                                                                  0.5),
                                                      maxLines: 3,
                                                      softWrap: true,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )),
                                              ],
                                            ),
                                          )),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                        onTap: () async {
                          /*  setState(() {
                              enabled = false;
                            }); */
                          if (isRedundentClick(DateTime.now(), diff)) {
                            //duration
                            print('hold on, processing');
                            return;
                          }
                          News model = bookmarkList[index];
                          List<News> bookList = [];
                          bookList.addAll(bookmarkList);
                          bookList.removeAt(index);
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) => NewsDetails(
                                    model: model,
                                    index: index,
                                    updateParent: updateFav,
                                    id: model.newsId,
                                    // isFav: true,
                                    isDetails: true,
                                    isbookmarked: true,
                                    news: bookList,
                                  )));
                          /* setState(() {
                              enabled = true;
                            }); */
                          diff = resetDiff;
                        },
                      ),
                      // )//AbsorbPointer
                    );
            }));
  }

//user not login then show this function used to navigate login screen
  Widget loginMsg() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
        height: height,
        width: width,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              getTranslated(context, 'bookmark_login')!,
              style: Theme.of(context).textTheme.subtitle2,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            InkWell(
                child: Text(
                  getTranslated(context, 'loginnow_lbl')!,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Login(),
                      ));
                }),
          ],
        ));
  }

  Future<void> getUserDetails() async {
    CUR_USERID = (await getPrefrence(ID)) ?? "";
    setState(() {});
  }

  //get bookmark api here
  _getBookmark() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_USERID != "") {
        try {
          var param = {
            ACCESS_KEY: access_key,
            USER_ID: CUR_USERID,
            LIMIT: perPage.toString(),
            OFFSET: offset.toString(),
          };
          Response response = await post(Uri.parse(getBookmarkApi),
                  body: param, headers: headers)
              .timeout(Duration(seconds: timeOut));

          var getdata = json.decode(response.body);

          String error = getdata["error"];
          if (error == "false") {
            total = int.parse(getdata["total"]);

            if ((offset) < total) {
              var data = getdata["data"];
              // print("bookmark data -- $data");
              tempList.clear();
              tempList = (data as List)
                  .map((data) => new News.fromJson(data))
                  .toList();
              if (offset == 0) bookmarkList.clear();
              bookmarkList.addAll(tempList);
              bookMarkValue.clear();
              for (int i = 0; i < bookmarkList.length; i++) {
                bookMarkValue.add(bookmarkList[i].newsId);
              }
              offset = offset + perPage;
            }

            if (this.mounted)
              setState(() {
                _isLoading = false;
              });
          } else {
            setState(() {
              isLoadingmore = false;
              _isLoading = false;
            });
          }
        } on TimeoutException catch (_) {
          showSnackBar(getTranslated(context, 'somethingMSg')!, context);
        }
      } else {
        setState(() {
          isLoadingmore = false;
          _isLoading = false;
        });
      }
    } else {
      showSnackBar(getTranslated(context, 'internetmsg')!, context);
    }
  }

  callApi() {
    offset = 0;
    total = 0;
    _getBookmark();
  }

  //refresh function to refresh page
  Future<String> _refresh() async {
    setState(() {
      _isLoading = true;
    });
    return callApi();
  }

  _scrollListener() {
    if (_controller.positions.last.pixels >=
            _controller.positions.last.maxScrollExtent &&
        !_controller.positions.last.outOfRange) {
      if (this.mounted) {
        setState(() {
          isLoadingmore = true;
          if (offset < total) _getBookmark();
        });
      }
    }
  }

  updateFav() {
    setState(() {
      offset = 0;
      total = 0;
      bookmarkList.clear();
      bookMarkValue.clear();
      _getBookmark();
    });
  }
}
