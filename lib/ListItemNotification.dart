import 'package:flutter/material.dart';
import 'package:news/Helper/Color.dart';
import 'package:news/Model/Notification.dart';

import 'Helper/Session.dart';

class ListItemNoti extends StatefulWidget {
  final Key? key;
  final NotificationModel? userNoti;
  final ValueChanged<bool>? isSelected;

  ListItemNoti({this.userNoti, this.isSelected, this.key});

  @override
  _ListItemNotiState createState() => _ListItemNotiState();
}

class _ListItemNotiState extends State<ListItemNoti> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
          widget.isSelected!(isSelected);
        });
      },
      child: listItem1(),
    );
  }

  //list of notification shown
  Widget listItem1() {
    DateTime time1 = DateTime.parse(widget.userNoti!.date!);
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: 5.0,
        bottom: 10.0,
      ),
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.controlSettings, //.boxColor,
            /*  boxShadow: <BoxShadow>[
              BoxShadow(
                  blurRadius: 10.0,
                  offset: const Offset(5.0, 5.0),
                  color:
                      Theme.of(context).colorScheme.fontColor.withOpacity(0.1),
                  spreadRadius: 1.0),
            ], */
            borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: colors.primary,
                  size: 22,
                ),
              // : SizedBox.shrink(),
              Padding(
                padding: EdgeInsetsDirectional.only(start: 10.0),
                child: widget.userNoti!.type == "comment"
                    ? Icon(Icons.message,
                        color: Theme.of(context).colorScheme.darkColor)
                    : Icon(Icons.thumb_up_alt),
              ),
              Expanded(
                  child: Padding(
                padding:
                    EdgeInsetsDirectional.only(start: 13.0, end: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(widget.userNoti!.message!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.subtitle1?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .fontColor
                                .withOpacity(0.9),
                            fontSize: 15.0,
                            letterSpacing: 0.1)),
                    Padding(
                        padding: EdgeInsetsDirectional.only(top: 8.0),
                        child: Text(convertToAgo(context, time1, 2)!,
                            style: Theme.of(context)
                                .textTheme
                                .caption
                                ?.copyWith(
                                    fontWeight: FontWeight.normal,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .fontColor
                                        .withOpacity(0.7),
                                    fontSize: 11)))
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
