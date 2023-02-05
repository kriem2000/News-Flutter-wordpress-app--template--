import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:news/Helper/Widgets.dart';

import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';
import 'Helper/Session.dart';
import 'Model/News.dart';
import 'NewsDetails.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

bool buildResult =
    false; //used in 2 classes here _SearchState & _SuggestionList

class _SearchState extends State<Search> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int pos = 0;
  List<News> searchList = [];
  List<TextEditingController> _controllerList = [];
  bool _isNetworkAvail = true;

  String query = "";
  int notificationoffset = 0;
  ScrollController? notificationcontroller;
  bool notificationisloadmore = true,
      notificationisgettingdata = false,
      notificationisnodata = false;

  // late AnimationController _animationController;
  Timer? _debounce;
  List<News> history = [];
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;

  String lastStatus = '';
  String lastWords = '';
  late StateSetter setStater;
  List<String> hisList = [];
  List<String> videoURLList = [];

  @override
  void initState() {
    super.initState();
    searchList.clear();

    notificationoffset = 0;

    notificationcontroller = ScrollController(keepScrollOffset: true);
    notificationcontroller!.addListener(_transactionscrollListener);

    _controller.addListener(() {
      if (_controller.text.isEmpty) {
        if (mounted)
          setState(() {
            query = "";
          });
      } else {
        query = _controller.text;
        notificationoffset = 0;
        notificationisnodata = false;
        buildResult = false;
        if (query.trim().length > 0) {
          if (_debounce?.isActive ?? false) _debounce!.cancel();
          _debounce = Timer(const Duration(milliseconds: 500), () {
            if (query.trim().length > 0) {
              notificationisloadmore = true;
              notificationoffset = 0;

              getSearchNews();
            }
          });
        }
      }
    });
  }

  _transactionscrollListener() {
    if (notificationcontroller!.offset >=
            notificationcontroller!.position.maxScrollExtent &&
        !notificationcontroller!.position.outOfRange) {
      if (mounted)
        setState(() {
          getSearchNews();
        });
    }
  }

  Future<List<String>> getHistory() async {
    hisList = (await getPrefrenceList(HISTORY_LIST))!;
    return hisList;
  }

  @override
  void dispose() {
    notificationcontroller!.dispose();
    _controller.dispose();
    for (int i = 0; i < _controllerList.length; i++)
      _controllerList[i].dispose();
    // _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: setBackButton(
            context, isDark! ? colors.lightTextColor : colors.darkModeColor),
        /* IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark! ? colors.lightTextColor : colors.darkModeColor),
          onPressed: () => Navigator.of(context).pop(),
          splashColor: Colors.transparent,
        ), */
        backgroundColor: Theme.of(context).canvasColor,
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
              hintText: getTranslated(context, 'search'),
              hintStyle: TextStyle(
                  color:
                      Theme.of(context).colorScheme.darkColor.withOpacity(0.5)),
              enabledBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.boxColor),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.boxColor),
              ),
              fillColor: colors.bgColor),
        ),
        titleSpacing: 0,
        actions: [
          IconButton(
            onPressed: () {
              _controller.text = '';
            },
            icon: Icon(
              Icons.close,
              color: isDark! ? colors.lightTextColor : colors.darkModeColor,
            ),
          )
        ],
      ),
      body: _showContent(),
    );
  }

  Widget listItem(int index) {
    if (_controllerList.length < index + 1)
      _controllerList.add(new TextEditingController());
    return Padding(
        padding: EdgeInsetsDirectional.only(bottom: 7.0),
        child: ListTile(
            title: Text(
              searchList[index].title!,
              style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            leading: ClipRRect(
                borderRadius: BorderRadius.circular(7.0),
                child: CachedNetworkImage(
                  imageUrl: searchList[index].image!,
                  fadeInDuration: Duration(milliseconds: 10),
                  fit: BoxFit.cover,
                  height: 80,
                  width: 80,
                  placeholder: (context, url) {
                    return placeHolder();
                  },
                  errorWidget: (context, error, stackTrace) {
                    return errorWidget(80, 80);
                  },
                )),
            onTap: () async {
              FocusScope.of(context).requestFocus(new FocusNode());
              News model = searchList[index];
              List<News> seList = [];
              seList.addAll(searchList);
              seList.removeAt(index);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => NewsDetails(
                        model: model,
                        index: index,
                        id: model.id,
                        // isFav: false,
                        isDetails: true,
                        news: seList,
                      )));
            }));
  }

  Future getSearchNews() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (notificationisloadmore) {
          if (mounted)
            setState(() {
              notificationisloadmore = false;
              notificationisgettingdata = true;
              if (notificationoffset == 0) {
                searchList = [];
              }
            });

          var parameter = {
            ACCESS_KEY: access_key,
            SEARCH: query.trim(),
            LIMIT: perPage.toString(),
            OFFSET: notificationoffset.toString(),
            USER_ID: CUR_USERID != "" ? CUR_USERID : "0"
          };
          // print(parameter);
          Response response = await post(Uri.parse(getNewsApi),
                  headers: headers, body: parameter)
              .timeout(Duration(seconds: timeOut));

          var getdata = json.decode(response.body);

          String error = getdata["error"];

          notificationisgettingdata = false;
          if (notificationoffset == 0) if (error == "false") {
            notificationisnodata = false;
          } else {
            notificationisnodata = true;
          }

          if (error == "false") {
            // print("General News Data-  $getdata");
            if (mounted) {
              new Future.delayed(
                  Duration.zero,
                  () => setState(() {
                        List mainlist = getdata['data'];

                        var newsData = getdata['data'];
                        print("content: $newsData");

                        if (mainlist.length != 0) {
                          List<News> items = [];
                          List<News> allItems = [];

                          items.addAll(mainlist
                              .map((data) => new News.fromJson(data))
                              .toList());

                          allItems.addAll(items);

                          if (notificationoffset == 0 && !buildResult) {
                            News element = News(
                                title: 'Search Result for "$query"',
                                image: "",
                                history: false);
                            searchList.insert(0, element);
                            for (int i = 0; i < history.length; i++) {
                              if (history[i].title == query)
                                searchList.insert(0, history[i]);
                            }
                          }

                          for (News item in items) {
                            searchList.where((i) => i.id == item.id).map((obj) {
                              allItems.remove(item);
                              return obj;
                            }).toList();
                          }
                          searchList.addAll(allItems);

                          notificationisloadmore = true;
                          notificationoffset = notificationoffset + perPage;
                        } else {
                          notificationisloadmore = false;
                        }
                      }));
            }
          } else {
            notificationisloadmore = false;
            setState(() {});
          }
        }
      } on TimeoutException catch (_) {
        showSnackBar(getTranslated(context, 'somethingMSg')!, context);
        setState(() {
          notificationisloadmore = false;
        });
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

  clearAll() {
    setState(() {
      query = _controller.text;
      notificationoffset = 0;
      notificationisloadmore = true;
      searchList.clear();
    });
  }

  _showContent() {
    if (_controller.text == "") {
      return FutureBuilder<List<String>>(
          future: getHistory(),
          builder:
              (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              final entities = snapshot.data!;
              List<News> itemList = [];
              for (int i = 0; i < entities.length; i++) {
                News item = News.history(entities[i]);
                itemList.add(item);
              }
              history.clear();
              history.addAll(itemList);

              return SingleChildScrollView(
                padding: EdgeInsetsDirectional.only(top: 15.0),
                child: Column(
                  children: [
                    _SuggestionList(
                      textController: _controller,
                      suggestions: itemList,
                      notificationcontroller: notificationcontroller,
                      getProduct: getSearchNews,
                      clearAll: clearAll,
                    ),
                  ],
                ),
              );
            } else {
              return Column();
            }
          });
    } else if (buildResult) {
      return notificationisnodata
          ? Center(child: Text(getTranslated(context, 'no_news')!))
          : Padding(
              padding: EdgeInsetsDirectional.only(top: 15.0),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                        padding: EdgeInsetsDirectional.only(
                            bottom: 5, start: 10, end: 10, top: 12),
                        controller: notificationcontroller,
                        physics: const AlwaysScrollableScrollPhysics(),
                        //BouncingScrollPhysics(),
                        itemCount: searchList.length,
                        itemBuilder: (context, index) {
                          News? item;
                          try {
                            item =
                                searchList.isEmpty ? null : searchList[index];
                            if (notificationisloadmore &&
                                index == (searchList.length - 1) &&
                                notificationcontroller!.position.pixels <= 0) {
                              getSearchNews();
                            }
                          } on Exception catch (_) {}

                          return item == null
                              ? SizedBox.shrink()
                              : listItem(index);
                        }),
                  ),
                  notificationisgettingdata
                      ? Padding(
                          padding:
                              EdgeInsetsDirectional.only(top: 5, bottom: 5),
                          child: CircularProgressIndicator(),
                        )
                      : SizedBox.shrink(),
                ],
              ));
    }
    return notificationisnodata
        ? Center(child: Text(getTranslated(context, 'no_news')!))
        : Padding(
            padding: EdgeInsetsDirectional.only(top: 15.0),
            child: Column(
              children: <Widget>[
                Expanded(
                    child: _SuggestionList(
                  textController: _controller,
                  suggestions: searchList,
                  notificationcontroller: notificationcontroller,
                  getProduct: getSearchNews,
                  clearAll: clearAll,
                )),
                notificationisgettingdata
                    ? Padding(
                        padding: EdgeInsetsDirectional.only(top: 5, bottom: 5),
                        child: CircularProgressIndicator(),
                      )
                    : SizedBox.shrink(),
              ],
            ));
  }
}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList(
      {this.suggestions,
      this.textController,
      this.notificationcontroller,
      this.getProduct,
      this.clearAll});

  final List<News>? suggestions;
  final TextEditingController? textController;

  final notificationcontroller;
  final Function? getProduct, clearAll;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: suggestions!.length,
      shrinkWrap: true,
      controller: notificationcontroller,
      separatorBuilder: (BuildContext context, int index) => Divider(),
      itemBuilder: (BuildContext context, int i) {
        final News suggestion = suggestions![i];

        return ListTile(
            title: Text(
              suggestion.title!,
              style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            leading: textController!.text.toString().trim().isEmpty ||
                    suggestion.history!
                ? Icon(Icons.history)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(7.0),
                    child: suggestion.image == ''
                        ? Image.asset(
                            'assets/images/placeholder.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          )
                        : CachedNetworkImage(
                            imageUrl: suggestion.image!,
                            fadeInDuration: Duration(milliseconds: 10),
                            fit: BoxFit.cover,
                            height: 80,
                            width: 80,
                            placeholder: (context, url) {
                              return placeHolder();
                            },
                            errorWidget: (context, error, stackTrace) {
                              return errorWidget(80, 80);
                            },
                          )),
            trailing: Image.asset(
              "assets/images/searchbar_arrow.png",
              color: Theme.of(context).colorScheme.fontColor,
            ),
            onTap: () async {
              if (suggestion.title!.startsWith('Search Result for ')) {
                setPrefrenceList(
                    HISTORY_LIST, textController!.text.toString().trim());
                buildResult = true;
                clearAll!();
                getProduct!();
              } else if (suggestion.history!) {
                clearAll!();
                buildResult = true;
                textController!.text = suggestion.title!;
                textController!.selection = TextSelection.fromPosition(
                    TextPosition(offset: textController!.text.length));
              } else {
                setPrefrenceList(
                    HISTORY_LIST, textController!.text.toString().trim());
                buildResult = false;
                News model = suggestion;
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => NewsDetails(
                          model: model,
                          id: model.id,
                          index: 0,
                          //static because of only one news open
                          // isFav: false,
                          isDetails: true,
                          news: [],
                        )));
              }
            });
      },
    );
  }
}
