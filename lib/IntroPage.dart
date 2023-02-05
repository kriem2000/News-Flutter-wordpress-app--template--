import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:news/languageList.dart';
import 'Helper/Color.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
// import 'Login.dart';

//slide class
class Slide {
  final String? imageUrl;
  final String? title;
  final String? description;

  Slide({
    @required this.imageUrl,
    @required this.title,
    @required this.description,
  });
}

class IntroSliderScreen extends StatefulWidget {
  @override
  _GettingStartedScreenState createState() => _GettingStartedScreenState();
}

class _GettingStartedScreenState extends State<IntroSliderScreen>
    with TickerProviderStateMixin {
  PageController pageController = PageController();

  double count = 0.00;

  late List<Slide> slideList = [
    Slide(
      imageUrl: 'assets/images/uptodate_intro.png',
      title: getTranslated(context, 'wel_title1')!,
      description: getTranslated(context, 'wel_des1')!,
    ),
    Slide(
      imageUrl: 'assets/images/bookmark_share.png',
      title: getTranslated(context, 'wel_title2')!,
      description: getTranslated(context, 'wel_des2')!,
    ),
    Slide(
      imageUrl: 'assets/images/new_categories.png',
      title: getTranslated(context, 'wel_title3')!,
      description: getTranslated(context, 'wel_des3')!,
    ),
  ];

  @override
  void initState() {
    super.initState();
    onPageChanged(0);
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: (isDark != null && isDark == true)
            ? Brightness.dark
            : Brightness.light,
        statusBarIconBrightness: (isDark != null && isDark == true)
            ? Brightness.light
            : Brightness.dark,
        statusBarColor: colors.transparentColor));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.dark); //despite or dark / light theme
    return Scaffold(
      backgroundColor: colors.bgColor, //despite or dark / light theme
      appBar: appbar(),
      body: Padding(
        padding: EdgeInsets.only(top: 5.0),
        child: _buildIntroSlider(),
      ),
    );
  }

  void onPageChanged(int index) {
    setState(() {
      switch (index) {
        case 0:
          count = 0.35;
          break;
        case 1:
          count = 0.65;
          break;
        case 2:
          count = 1.0;
          break;
        default:
          count = 0.0;
          break;
      }
      /*  if (index == 0) {
        count = 0.35;
      } else if (index == 1) {
        count = 0.65;
      } else if (index == 2) {
        count = 1.0;
      } else {
        count = 0.0;
      } */
    });
  }

  Widget _buildIntroSlider() {
    Color gradientStart = colors.clearColor;
    Color gradientEnd = colors.secondaryColor;
    return PageView.builder(
      onPageChanged: onPageChanged,
      controller: pageController,
      itemBuilder: (context, index) {
        return Container(
          child: Stack(children: [
            Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: ShaderMask(
                shaderCallback: (rect) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [gradientStart, gradientEnd],
                  ).createShader(
                      Rect.fromLTRB(0, -140, rect.width, rect.height - 20));
                },
                blendMode: BlendMode.darken,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    image: DecorationImage(
                      image: AssetImage(slideList[index].imageUrl!),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
              elevation: 5,
              margin: EdgeInsets.all(15),
            ),
            Column(
              children: [
                Expanded(
                  //blank container
                  child: Container(
                      // blank container along with flex:1 to make space from top / before content
                      ),
                  flex: 1,
                ),
                Expanded(
                  //title text
                  child: titleText(index),
                  flex: 0,
                ),
                Expanded(
                  //description text
                  child: subtitleText(index),
                  flex: 0,
                ),
                Expanded(
                  //Linear Progressbar
                  child: progressIndicator(),
                  flex: 0,
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Container(
                    //Next / Login/Start button
                    margin: EdgeInsets.only(bottom: 40.0),
                    child: ButtonTheme(child: NxtButton(index)),
                  ),
                  flex: 0,
                ),
              ],
            ),
          ]),
        );
      },
      itemCount: slideList.length,
    );
  }

  appbar() {
    return PreferredSize(
      preferredSize: Size(double.infinity, 80),
      child: Padding(
        padding: EdgeInsetsDirectional.only(
            top: MediaQuery.of(context).padding.top + 10.0,
            start: 20,
            end: 16),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 43,
                child: Image.asset(
                  "assets/images/splash_Icon.png",
                  fit: BoxFit.fill,
                ),
              ),
              TextButton(
                style: ButtonStyle(
                  overlayColor:
                      MaterialStateProperty.all(colors.transparentColor),
                  foregroundColor: MaterialStateProperty.all(
                      colors.darkColor1.withOpacity(0.4)),
                ),
                onPressed: () async {
                  bool isFirstTime = await getPrefrenceBool(ISFIRSTTIME);
                  if (!isFirstTime) {
                    setPrefrenceBool(ISFIRSTTIME, true);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LanguageList(from: 1)),
                    );
                  }
                },
                child: Text(
                  getTranslated(context, 'skip')!,
                  style: const TextStyle(fontWeight: FontWeight.normal),
                ),
              ),
            ]),
      ),
    );
  }

  titleText(int index) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 10),
      margin: EdgeInsets.only(bottom: 20.0, left: 10, right: 10),
      child: Text(
        slideList[index].title!,
        style: Theme.of(context).textTheme.headline4?.copyWith(
            color: colors.bgColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5),
      ),
      alignment: Alignment.centerLeft,
    );
  }

  subtitleText(int index) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 10),
      margin: EdgeInsets.only(bottom: 55.0, left: 10, right: 10),
      child: Text(
        slideList[index].description!,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  progressIndicator() {
    return Container(
      height: 3,
      width: 118,
      child: LinearProgressIndicator(
        backgroundColor: colors.bgColor,
        value: count,
        valueColor: new AlwaysStoppedAnimation<Color>(colors.primary),
      ),
    );
  }

  NxtButton(int index) {
    return ElevatedButton(
      onPressed: () {
        if (index == slideList.length - 1) {
          //GoTo Login Screen
          setPrefrenceBool(ISFIRSTTIME, true);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => LanguageList(from: 1)), // Login()
          );
        } else {
          //GoTo Next Slide
          index += 1;
          pageController.animateToPage(index,
              duration: Duration(seconds: 1),
              curve: Curves.fastLinearToSlowEaseIn);
        }
      },
      style: ElevatedButton.styleFrom(
        primary: colors.primary,
        onPrimary: colors.bgColor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        minimumSize: Size(162, 50),
      ),
      child: Text(
        getTranslated(
            context, (index == (slideList.length - 1)) ? 'login_btn' : 'nxt')!,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}
