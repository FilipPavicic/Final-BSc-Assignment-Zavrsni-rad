import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

ThemeData themeData;
final List<Flushbar> flushbars = [];

void showTopSnackBar(BuildContext context, String mess, Color typecolor) {
  themeData = Theme.of(context);
  show(
      context,
      Flushbar(
        messageText: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.circle,
              color: typecolor,
              size: 12,
            ),
            SizedBox(width: 5),
            Flexible(
                child: Text(
              mess,
              style: TextStyle(color: themeData.accentColor),
              textAlign: TextAlign.center,
            ))
          ],
        ),
        duration: Duration(seconds: 2),
        flushbarPosition: FlushbarPosition.TOP,
        borderRadius: 30,
        shouldIconPulse: false,
        margin: EdgeInsets.only(top: 20, left: 70, right: 70),
        barBlur: 30,
        backgroundGradient: LinearGradient(
            colors: [themeData.primaryColor, themeData.primaryColorLight]),
      ));
}

Future show(BuildContext context, Flushbar newFlushbar) async {
  await Future.wait(flushbars.map((f) => f.dismiss()).toList());
  flushbars.clear();
  newFlushbar.show(context);
  flushbars.add(newFlushbar);
}
