import 'package:flutter/material.dart';
import 'package:recognizing_text2/Utils.dart';

import '../../ScanLogic.dart';

class CameraWidgets {
  BuildContext context;
  ThemeData themeData;
  ScanLogic sl;

  CameraWidgets(BuildContext context, ScanLogic sl) {
    this.context = context;
    this.themeData = Theme.of(context);
    this.sl = sl;
    sl.widgetlist = createWidgets();
  }

  createWidgets() {
    double borderSelectWidth = 3;
    List<Widget> WIDGETS_CAMERA = [
      Card(

          // filled: true,
          // fillColor: CameraScthemeDataanScreen.accentColor,
          // // labelText: 'Store',
          // // labelStyle: TextStyle(
          // //   fontSize: 18,
          // //   color: Colors.white
          // // ),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: themeData.primaryColor, width: 1.0),
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: InputDecorator(
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(left: 20),
              prefixIcon: sl.store != sl.defaultStore()
                  ? IconButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      color: themeData.primaryColor,
                      onPressed: () {
                        sl.onRetryButton(() => removeItemFromWidgetList(2));
                      },
                      icon: Icon(Icons.replay, size: 25),
                    )
                  : null,
              suffixIcon: IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                color: themeData.primaryColor,
                onPressed: () async {
                  sl.isVisible = false;
                  String text = await sl.bottomSheet
                      .showBottomSheet<String>(context, themeData, null);
                  print('[test3] Nastavljam dalje');
                  sl.isVisible = true;
                },
                icon: Container(
                    padding: EdgeInsets.only(right: 5),
                    child: Icon(Icons.add_circle, size: 27)),
              ),
            ),
            child: Text(sl.store,
                style: TextStyle(color: themeData.primaryColor, fontSize: 18)),
          )),
      Container(
        margin: EdgeInsets.only(top: 10),
        key: sl.keyRed,
        height: 65,
        child: AnimatedList(
          key: sl.key,
          scrollDirection: Axis.horizontal,
          initialItemCount: sl.priceList.length,
          itemBuilder: (BuildContext context, int index, Animation animation) {
            debugPrint('[test3]Pozvan je graditelj cijena s indexom: $index');
            return Padding(
              padding: sl.selected_index != index
                  ? EdgeInsets.only(
                      top: borderSelectWidth, bottom: borderSelectWidth)
                  : EdgeInsets.only(),
              child: ScaleTransition(
                scale:
                    CurvedAnimation(parent: animation, curve: Curves.bounceOut)
                        .drive(Tween<double>(begin: 0, end: 1)),
                child: Container(
                  width: getSizeByKey(sl.keyWidgets).width /
                              sl.priceList.length >
                          sl.widthOfMaxNumber() + 25
                      ? getSizeByKey(sl.keyWidgets).width / sl.priceList.length
                      : null,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      side: sl.selected_index == index
                          ? BorderSide(
                              color: themeData.primaryColor,
                              width: borderSelectWidth)
                          : BorderSide.none,
                      borderRadius: sl.selected_index == index
                          ? BorderRadius.circular(30.0)
                          : BorderRadius.circular(25.0),
                    ),
                    child: IntrinsicWidth(
                      child: InputDecorator(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                                left: sl.textPricePading,
                                right: sl.textPricePading),
                            labelStyle:
                                TextStyle(color: themeData.primaryColor),
                          ),
                          child: Container(
                            margin: sl.selected_index == index
                                ? EdgeInsets.only(
                                    left: borderSelectWidth,
                                    right: borderSelectWidth)
                                : EdgeInsets.only(),
                            child: TextButton(
                              style: ButtonStyle(
                                overlayColor: MaterialStateProperty.all(
                                    Colors.transparent),
                              ),
                              onPressed: () {
                                sl.onPriceButton(index);
                              },
                              child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${sl.priceList.elementAt(index).toStringAsFixed(2)} kn',
                                    style: TextStyle(
                                        color: themeData.primaryColor),
                                  )),
                            ),
                          )),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      Container(
        height: 45,
        width: double.infinity,
        margin: EdgeInsets.only(left: 40, right: 40, top: 10),
        decoration: BoxDecoration(
          //border: Border.all(color: themeData.primaryColor, width: 1),
          borderRadius: BorderRadius.circular(25.0),
          gradient: LinearGradient(
            colors: [themeData.primaryColor, themeData.primaryColorLight],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: TextButton(
          style: ButtonStyle(
            overlayColor:
                MaterialStateColor.resolveWith((states) => Colors.transparent),
          ),
          onPressed: () {
            Navigator.of(context).pop([
              sl.store,
              sl.priceList[sl.selected_index]
            ]);
          },
          child: Text(
            'Submit',
            style: TextStyle(color: themeData.accentColor, fontSize: 24),
          ),
        ),
      )
    ];
    return WIDGETS_CAMERA;
  }

  Widget myListItem(int index) {
    return sl.widgetlist.elementAt(index);
  }
  void removeItemFromWidgetList(int position){
    sl.keyWidgets.currentState.removeItem(
        position,
        (context, animation) =>
            SlideTransition(
                position: animation.drive(
                    Tween(
                  begin: Offset(0, 0.5),
                  end: Offset(0, 0),
                ).chain(CurveTween(
                        curve: Curves.ease))),
                child: myListItem(position)),
        duration:
            Duration(milliseconds: 250));
  } 
  void insertItemInWidgetList(int position){
    sl.keyWidgets.currentState.insertItem(position,
    duration: const Duration(milliseconds: 500));
  }
}
