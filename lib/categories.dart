import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:news/Home.dart';
import 'package:news/Model/Category.dart';
import 'package:news/subCategories.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';

class Categories extends StatefulWidget {
  @override
  CategoriesState createState() => CategoriesState();
}

class CategoriesState extends State<Categories> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  bool _isNetworkAvail = true;

  int offset = 0;
  int total = 0;
  ScrollController _controller = new ScrollController();

  @override
  void initState() {
    super.initState();
    getCat();
    _controller.addListener(_catScrollListener);
  }

  @override
  void dispose() {
    _controller.removeListener(_catScrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: titleCatTxt(),
        body: GridView.count(
          physics: const AlwaysScrollableScrollPhysics(),
          //const BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.only(
              top: 45,
              bottom: deviceHeight! / 10.0,
              left: 10,
              right: 10), //18.0
          crossAxisCount: 3,
          crossAxisSpacing: 5.0,
          mainAxisSpacing: 30.0,
          shrinkWrap: true,
          controller: _controller,
          children: List.generate(
            (offset < total) ? catList.length + 1 : catList.length,
            (index) {
              // print("image value ${catList[0].image}");
              return _isLoading &&
                      catList.isEmpty &&
                      index == (catList.length - 1)
                  ? showCircularProgress(_isLoading, colors.primary)
                  : (index < catList.length)
                      ? GestureDetector(
                          onTap: () {
                            /* print(
                                "tapped on Index $index & ID of Category is ${catList[index].id}");
                            print(
                                "values passed to Subcategory screen --> ${catList[index].id} , ${catList[index].categoryName}, ${catList[index].subData!.length},$index"); */

                            //Navigate to Subcategory tabs+ detailView
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    SubCategories(
                                      //pass Selected CatId to Get details of Subcategory Or containing news details.
                                      catId: catList[index].id,
                                      catName: catList[index].categoryName,
                                      catList: catList,
                                      curTabId: catList[index].id,
                                      isSubCat:
                                          (catList[index].subData!.length > 0)
                                              ? true
                                              : false,
                                      index: index,
                                      subCatId: '0',
                                    )));
                          },
                          child: Column(
                            children: [
                              Expanded(
                                child: CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  /* backgroundImage: Image.network(
                                      catList[index].image!, loadingBuilder:
                                          (context, child, loadingProgress) {
                                    return Center(
                                        child: errorWidget(
                                      deviceHeight! / 10.9,
                                      deviceWidth! / 5.0,
                                    ));
                                  }).image, */
                                  radius: 45, //50,
                                  /* onBackgroundImageError:
                                      (context, stackTrace) => errorWidget(
                                    deviceHeight! / 10.9,
                                    deviceWidth! / 5.0,
                                  ), */
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50.0),
                                    child: CachedNetworkImage(
                                        fadeInDuration:
                                            Duration(milliseconds: 150),
                                        imageUrl:
                                            catList[index].image!,
                                        /*  height: deviceHeight! / 2.9,
                                        width: deviceWidth!, */
                                        height: 90, //deviceHeight! / 5.9,
                                        width: 90, //deviceWidth! / 2.2,
                                        fit: BoxFit.cover,
                                        errorWidget:
                                            (context, error, stackTrace) =>
                                                errorWidget(deviceHeight! / 5.9,
                                                    deviceWidth! / 2.2),
                                      placeholder: (context,url) {return placeHolder();},),
                                  ),
                                ),
                                // alignment: Alignment.center,
                                // ),
                                /* child: ClipOval(
                                  child: CachedNetworkImage(
                                      fadeInDuration:
                                          Duration(milliseconds: 150),
                                      image: CachedNetworkImageProvider(
                                          catList[index].image!),
                                      height: 80, //90,
                                      width: 90,
                                      fit: BoxFit.cover,
                                      imageErrorBuilder:
                                          (context, error, stackTrace) =>
                                              errorWidget(
                                                deviceHeight! / 10.9,
                                                deviceWidth! / 5.0,
                                              ),
                                      placeholder: AssetImage(
                                        placeHolder,
                                      )),
                                ), */
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 3),
                                child: Text(
                                  catList[index].categoryName!,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .darkColor),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink();
            },
          ),
        ));
  }

  _catScrollListener() {
    // print("Listener -- offset - $offset & total count is $total");
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      if (this.mounted) {
        setState(() {
          _isLoading = true;
          //  print("offset - $offset & total count is $total");
          if (offset < total) getCat();
        });
      }
    }
  }

  titleCatTxt() {
    return PreferredSize(
      preferredSize: Size(double.infinity, 70),
      child: Padding(
        padding: EdgeInsetsDirectional.only(
            start: 25, top: MediaQuery.of(context).padding.top + 20.0),
        child: Text(getTranslated(context, 'category_lbl')!,
            style: Theme.of(context).textTheme.headline6?.copyWith(
                  color: Theme.of(context).colorScheme.darkColor,
                  fontWeight: FontWeight.w600,
                )),
      ),
    );
  }

  Future<void> getCat() async {
    // catList.clear();
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (!_isLoading)
        setState(() {
          _isLoading = true;
        });

      var param = {
        ACCESS_KEY: access_key,
        OFFSET: offset.toString(),
        LIMIT: extraLimit.toString(), //perPage.toString(),
      };
      // print("Param value - $param");

      Response response =
          await post(Uri.parse(getCatApi), body: param, headers: headers)
              .timeout(Duration(seconds: timeOut));
      var getdata = json.decode(response.body);

      String error = getdata["error"];

      if (error == "false") {
        total = int.parse(getdata["total"]);
        /*  print(
            "Total value $total & offset value - $offset & list Length is ${catList.length}"); */
        if (catList.length < total) {
          //offset < total
          //&& catList.length < total
          var data = getdata["data"];
          // print("value @ response of CatData - $data");
          List<Category> temp = (data as List)
              .map((data) => new Category.fromJson(data))
              .toList();

          catList.addAll(temp);

          offset = offset + perPage;
          //print("offset value after loading once - $offset & total is $total");
        }
      }
      if (_isLoading)
        setState(() {
          _isLoading = false;
        });
    } else {
      setState(() {
        _isLoading = false;
      });
      showSnackBar(getTranslated(context, 'internetmsg')!, context)!;
    }
  }
}
