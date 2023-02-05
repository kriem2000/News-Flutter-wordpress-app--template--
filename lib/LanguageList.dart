// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

// import 'package:flutter/services.dart';
import 'package:news/Helper/Color.dart';
import 'package:news/Helper/Constant.dart';
import 'package:news/Helper/Session.dart';
import 'package:news/Helper/String.dart';
import 'package:news/Helper/Widgets.dart';

// import 'package:news/IntroPage.dart';
import 'package:news/Login.dart';
import 'package:news/main.dart';

class LanguageList extends StatefulWidget {
  final int? from;

  const LanguageList({Key? key, this.from}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LanguageListState();
  }
}

class LanguageListState extends State<LanguageList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController _scrlController = new ScrollController();

  List<String> flagList = [
    'assets/images/flag/english.png',
    'assets/images/flag/espanol.png',
    'assets/images/flag/hindi.png',
    'assets/images/flag/turkey.png',
    'assets/images/flag/portuguese.png',
    'assets/images/flag/arabic.svg',
    'assets/images/flag/hebrew.svg',
    /* 'assets/images/flag/bengalibangla.svg',
    'assets/images/flag/german.svg',
    'assets/images/flag/indonesian.svg',
    'assets/images/flag/italian.svg',
    'assets/images/flag/korean.svg',
    'assets/images/flag/russian.svg',
    'assets/images/flag/tamil.svg',
    'assets/images/flag/ukrainian.svg',
    'assets/images/flag/urdu.svg',
    'assets/images/flag/chinese.svg'*/
  ];

  List<String> languageList = [
    eng_lbl,
    span_lbl,
    hin_lbl,
    turk_lbl,
    port_lbl,
    arabic_lbl,
    heb_lbl,
    /*beng_lbl,
    germ_lbl,
    indo_lbl,
    ital_lbl,
    kore_lbl,
    russ_lbl,
    tamil_lbl,
    ukr_lbl,
    urd_lbl,
    chin_lbl*/
  ];

/*  List<String> langCode = [
    "en",
    "es",
    "hi",
    "tr",
    "pt",
    "ar",
    "he",
    "bn",
    "de",
    "id",
    "it",
    "ko",
    "ru",
    "ta",
    "uk",
    "ur",
    "zh"
  ];*/

  List<String> langCode = [
    "en",
    "es",
    "hi",
    "tr",
    "pt",
    "ar",
    "he",
  ];
  int? selectLan;

  @override
  void initState() {
    getLocale().then((locale) {
      print("locale******${locale.languageCode}");

      setState(() {
        selectLan = langCode.indexOf(locale.languageCode);
      });
      print("selectLan****$selectLan");
    });
    super.initState();
  }

  @override
  void dispose() {
    /* if (widget.from == 1)
      SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle.dark);  */ //set to Dark byDefault for IntroScreen
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      //floatingActionButton: saveBtn(),
      appBar: appBarDetails(),
      body: Stack(
        children: <Widget>[setTitle(), setBuilder()],
      ),
    );
  }

  void _changeLan(String language) async {
    Locale _locale = await setLocale(language);
    MyApp.setLocale(context, _locale);
  }

  appBarDetails() {
    return PreferredSize(
      preferredSize: Size(double.infinity, 45),
      child: AppBar(
        // leadingWidth: 35,
        backgroundColor: Colors.transparent,

        /* systemOverlayStyle:
            !isDark! ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light, */
        leading: widget.from == 1
            ? const SizedBox.shrink()
            : setBackButton(
                context,
                Theme.of(context)
                    .colorScheme
                    .skipColor), /* IconButton(
                padding: EdgeInsetsDirectional.only(start: 15),
                icon: Icon(Icons.arrow_back,
                    color: Theme.of(context).colorScheme.skipColor),
                onPressed: () => Navigator.of(context).pop(),
                splashColor: Colors.transparent,
              ), */
      ),
    );
  }

  setTitle() {
    return Container(
      child: Padding(
        padding: EdgeInsetsDirectional.only(top: 25.0, start: 20.0),
        child: Text(
          getTranslated(context, 'choose_lan_lbl')!,
          style: Theme.of(context).textTheme.headline5?.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5),
        ),
      ),
    );
  }

/*  contentView() {
    return SingleChildScrollView(
        padding: EdgeInsetsDirectional.only(
            start: 15.0, end: 15.0, bottom: 20.0), //top: 30.0,
        controller: _scrlController,
        child: getLangList());
  }*/

  setBuilder() {
    return Container(
        margin: EdgeInsetsDirectional.only(top: 80, bottom: 20),
        child: Column(children: [Expanded(child: getLangList()), saveBtn()]));
  }

  getLangList() {
    return ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.only(bottom: 20),
        physics: AlwaysScrollableScrollPhysics(),
        itemBuilder: ((context, index) => Padding(
              padding: EdgeInsets.fromLTRB(
                  20.0, 5.0, 20.0, 5.0), //fromLTRB(10.0, 5.0, 10.0, 5.0),
              child: ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                leading: languageList[index] == arabic_lbl ||
                        languageList[index] == heb_lbl
                    /*languageList[index] == beng_lbl ||
                        languageList[index] == germ_lbl ||
                        languageList[index] == indo_lbl ||
                        languageList[index] == ital_lbl ||
                        languageList[index] == russ_lbl ||
                        languageList[index] == tamil_lbl ||
                        languageList[index] == ukr_lbl ||
                        languageList[index] == urd_lbl ||
                        languageList[index] == chin_lbl ||
                        languageList[index] == kore_lbl*/
                    ? SvgPicture.asset(
                        flagList[index],
                        height: 30.0,
                        width: 54.0,
                      )
                    : Image.asset(
                        flagList[index],
                        width: 30,
                        height: 30,
                      ),
                title: Text(
                  languageList[index],
                  style: Theme.of(this.context).textTheme.titleLarge?.copyWith(
                      color: (selectLan == index)
                          ? Theme.of(context).colorScheme.lightColor
                          : Theme.of(context).colorScheme.fontColor),
                ),
                tileColor: selectLan == index
                    ? Theme.of(context)
                        .colorScheme
                        .darkColor //Theme.of(context).colorScheme.langSel
                    : null,
                onTap: () {
                  setState(() {
                    selectLan = index;
                    //    _changeLan()langCode[index];//change at a time - for demo
                  });
                },
              ),
            )),
        separatorBuilder: (context, index) {
          return SizedBox(height: 1.0);
        },
        itemCount: languageList.length);
  }

  saveBtn() {
    return Container(
      // Padding(
      // padding: EdgeInsets.only(bottom: 15),
      //alignment: Alignment(0, 0.8),
      child: new InkWell(
          child: Container(
            height: 55.0,
            width: MediaQuery.of(context).size.width * 0.9,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(15.0)),
            child: Text(
              getTranslated(context, 'save_lbl')!,
              style: Theme.of(this.context).textTheme.headline6?.copyWith(
                  color: colors.bgColor, fontWeight: FontWeight.bold),
            ),
          ),
          onTap: () {
            if (selectLan == null) {
              showSnackBar(getTranslated(context, 'opt_sel')!, context);
            } else {
              _changeLan(langCode[selectLan!]);
              if (widget.from == 1) {
                //goto loginscreen directly
                setPrefrenceBool(ISFIRSTTIME, true);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
                /* Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => IntroSliderScreen())); */
              } else {
                Navigator.pop(context);
              }
            }
          }),
    );
  }
}
