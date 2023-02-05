import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:file_picker/file_picker.dart';
import 'package:news/Helper/Color.dart';
import 'package:news/Helper/String.dart';
import 'package:shimmer/shimmer.dart';

import 'Helper/Session.dart';
import 'Helper/Widgets.dart';

class NewsDescription extends StatefulWidget {
  String? description;
  Function changeDesc;
  Function? validateDesc;
  int? from;

  NewsDescription(
      this.description, this.changeDesc, this.validateDesc, this.from);

  @override
  _NewsDescriptionState createState() => _NewsDescriptionState();
}

class _NewsDescriptionState extends State<NewsDescription> {
  String result = '';
  bool isLoading = true;

  final HtmlEditorController controller = HtmlEditorController();

  @override
  void initState() {
    setValue();

    super.initState();
  }

  setValue() async {
    Future.delayed(
      const Duration(seconds: 4),
      () {
        setState(() {
          isLoading = false;
        });
      },
    );

    Future.delayed(
      const Duration(seconds: 6),
      () {
        setState(() {});
      },
    );
  }

  //set appbar
  getAppBar() {
    return PreferredSize(
        preferredSize: Size(double.infinity, 45),
        child: AppBar(
          centerTitle: false,
          backgroundColor: Colors.transparent,
          title: Transform(
            transform: Matrix4.translationValues(-20.0, 0.0, 0.0),
            child: Text(
              widget.from == 2
                  ? getTranslated(context, 'EDIT_NEWS_LBL')!
                  : getTranslated(context, 'CREATE_NEWS_LBL')!,
              style: Theme.of(context).textTheme.headline6?.copyWith(
                  color: Theme.of(context).colorScheme.darkColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5),
            ),
          ),
          leading: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: InkWell(
              onTap: () {
                controller.getText().then((value) {
                  widget.changeDesc(value, false);
                });
              },
              child: Icon(Icons.arrow_back,
                  color: Theme.of(context).colorScheme.darkColor),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
          ),
          actions: [
            Container(
              padding: EdgeInsetsDirectional.only(end: 20),
              alignment: Alignment.center,
              child: Text(getTranslated(context, 'STEP2TO2_LBL')!,
                  style: Theme.of(context).textTheme.caption!.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .darkColor
                          .withOpacity(0.6))),
            )
          ],
        ));
  }

  Widget nextBtn() {
    return Padding(
      padding: EdgeInsetsDirectional.all(20),
      child: InkWell(
        splashColor: Colors.transparent,
        child: Container(
          height: 55.0,
          //48.0,
          width: deviceWidth! * 0.9,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.darkColor,
              borderRadius: BorderRadius.circular(7.0)),
          child: Text(
            getTranslated(context, 'submit_btn')!, //login_btn
            style: Theme.of(this.context).textTheme.headline6?.copyWith(
                color: Theme.of(context).colorScheme.lightColor,
                fontWeight: FontWeight.w600,
                fontSize: 21,
                letterSpacing: 0.6),
          ),
        ),
        onTap: () async {
          controller.getText().then((value) {
            widget.validateDesc!(value);
          });
        },
      ),
    );
  }

  Widget shimmer() {
    return Container(
      width: double.infinity,
      // padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 13.0),
      child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: deviceHeight! * 0.741,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).cardColor),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    controller.setText(widget.description!);
    print("brighness****${Theme.of(context).brightness == Brightness.light}");
    return Scaffold(
      appBar: getAppBar(),
      // resizeToAvoidBottomInset: false,
      //extendBody: true,
      bottomNavigationBar: nextBtn(),
      body: WillPopScope(
        onWillPop: () {
          controller.getText().then((value) {
            widget.changeDesc(value, false);
          });

          return Future.value(false);
        },
        child: GestureDetector(
            onTap: () {
              if (!kIsWeb) {
                controller.clearFocus(); // for close keybord
              }
            },
            child: Padding(
              padding: EdgeInsetsDirectional.all(20),
              child: isLoading
                  ? shimmer()
                  : Theme(
                      data: Theme.of(context).copyWith(
                          textTheme: TextTheme(
                              subtitle2: Theme.of(context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(color: Colors.orange))),
                      child: HtmlEditor(
                        controller: controller,
                        htmlEditorOptions: HtmlEditorOptions(
                          hint: getTranslated(context, 'DESC_LBL')!,
                          adjustHeightForKeyboard: true,
                          autoAdjustHeight: true,
                          shouldEnsureVisible: true,
                          //darkMode: false

                          /*darkMode:false*/ /*
                              Theme.of(context).brightness == Brightness.light
                                  ? false
                                  : false*/
                        ),
                        htmlToolbarOptions: HtmlToolbarOptions(
                          toolbarPosition: ToolbarPosition.aboveEditor,
                          toolbarType: ToolbarType.nativeGrid,
                          //by default
                          gridViewHorizontalSpacing: 0,
                          gridViewVerticalSpacing: 0,
                          dropdownBackgroundColor:
                              Theme.of(context).colorScheme.lightColor,
                          toolbarItemHeight: 30,
                          buttonColor: Theme.of(context).colorScheme.fontColor,
                          buttonFocusColor: colors.primary,
                          buttonBorderColor: Colors.red,
                          buttonFillColor: colors.secondaryColor,
                          dropdownIconColor: colors.primary,
                          dropdownIconSize: 26,
                          textStyle: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.darkColor),
                          /*TextStyle(
                            fontSize: 16,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Theme.of(context).colorScheme.darkColor
                                    : Colors.white,
                          ),*/
                          onButtonPressed: (ButtonType type, bool? status,
                              Function? updateStatus) {
                            return true;
                          },
                          onDropdownChanged: (DropdownType type,
                              dynamic changed,
                              Function(dynamic)? updateSelectedItem) {
                            return true;
                          },
                          mediaLinkInsertInterceptor:
                              (String url, InsertFileType type) {
                            return true;
                          },
                          mediaUploadInterceptor:
                              (PlatformFile file, InsertFileType type) async {
                            return true;
                          },
                        ),
                        otherOptions: OtherOptions(
                          height: deviceHeight! * 0.725,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).colorScheme.boxColor,
                          ),
                        ),
                        callbacks: Callbacks(
                          onBeforeCommand: (String? currentHtml) {},
                          onChangeContent: (String? changed) {},
                          onChangeCodeview: (String? changed) {
                            result = changed!;
                            // widget.changeDesc(changed);
                          },
                          onChangeSelection: (EditorSettings settings) {},
                          onDialogShown: () {},
                          onEnter: () {},
                          onFocus: () {},
                          onBlur: () {},
                          onBlurCodeview: () {},
                          onInit: () {},
                          onImageUploadError: (
                            FileUpload? file,
                            String? base64Str,
                            UploadError error,
                          ) {},
                          onKeyDown: (int? keyCode) {},
                          onKeyUp: (int? keyCode) {},
                          onMouseDown: () {},
                          onMouseUp: () {},
                          onNavigationRequestMobile: (String url) {
                            return NavigationActionPolicy.ALLOW;
                          },
                          onPaste: () {},
                          onScroll: () {},
                        ),
                      ),
                    ),
            )),
      ),
    );
  }
}
