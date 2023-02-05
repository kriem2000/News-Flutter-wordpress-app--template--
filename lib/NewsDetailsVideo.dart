// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:news/Helper/Session.dart';

class NewsDetailsVideo extends StatefulWidget {
  String? src;
  String type;

  NewsDetailsVideo({Key? key, this.src, required this.type}) : super(key: key);

  @override
  State<StatefulWidget> createState() => StateNewsDetailsVideo();
}

class StateNewsDetailsVideo extends State<NewsDetailsVideo> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _isNetworkAvail = true;
  var iframe;

  @override
  void initState() {
    super.initState();
    checkInternet();
    /* if (widget.type == "2") {
      // ${widget.src}
      //<iframe src="https://www.youtube.com/embed/7BOi0H59tXY" width="100%" height="100%" allowfullscreen="allowfullscreen"></iframe>
      iframe = '''
        <html>
        ${widget.src}
        </html>
        ''';
    } else */
    if ((widget.type == "1") || (widget.type == "3")) {
      //(widget.type == "1") {
      //((widget.type == "1") || (widget.type == "2"))
      // <iframe src="${widget.src!}" frameborder="0" allow="autoplay" allowfullscreen="allowfullscreen" width:"100%"; height:"100%"; margin: 0; padding: 0;></iframe>
      iframe = '''
        <html>
          <iframe src="${widget.src!}" width="100%" height="100%" allowfullscreen="allowfullscreen"></iframe>
        </html>
        ''';
    } else {
      iframe = '''
        <html>
        <video controls="controls" width="100%" height="100%">
        <source src="${widget.src!}"></video>
        </html>
        ''';
    }
  }

  checkInternet() async {
    _isNetworkAvail = await isNetworkAvailable();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: _isNetworkAvail ? viewVideo() : SizedBox.shrink(),
      ),
    );
  }

  //news video link set
  viewVideo() {
    var frm;
    frm = Uri.dataFromString(
      iframe,
      mimeType: 'text/html',
    );
    return Center(
      child: InAppWebView(
        initialUrlRequest: URLRequest(url: frm),
      ),
    );
  }
}
