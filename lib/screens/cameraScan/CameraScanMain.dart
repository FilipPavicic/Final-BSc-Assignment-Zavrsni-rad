import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter_camera_ml_vision/flutter_camera_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:recognizing_text2/screens/KeyboardInputScreen.dart';

import 'package:recognizing_text2/screens/cameraScan/CameraWidgets.dart';

import '../../ScanLogic.dart';

class CameraScanScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CameraScanScreenState();
}

class CameraScanScreenState extends State<CameraScanScreen> {
  ScanLogic sl;
  ThemeData themeData;

  @override
  void initState() {
    super.initState();
    sl = new ScanLogic(
      observer: () {
        setState(() {});
      },
    );
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (sl.key.currentState != null) {
    //     for (int i = 0; i < sl.priceList.length; i++) {
    //       sl.key.currentState
    //           .insertItem(i, duration: Duration(milliseconds: 250));
    //     }
    //   }
    // });
  }

  CameraWidgets cw;
  @override
  Widget build(BuildContext context) {
    debugPrint('Pozvan je build');
    CameraWidgets cw = new CameraWidgets(context, sl);
    themeData = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
              child: CameraMlVision<VisionText>(
            loadingBuilder: (c) {
              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(themeData.accentColor),
                ),
              );
            },
            detector: sl.detector.processImage,
            onResult: (VisionText text) {
              if (!mounted) {
                return;
              }
              if (sl.dispose != true &&
                  sl.previousFinish != false &&
                  sl.isVisible != false) {
                    sl.previousFinish = false;
                    sl.onScanResult(text).then((value) {
                      if (value == true) {
                        setState(() {});
                      }
                      sl.previousFinish = true;
                    });
              }
            },
            onDispose: () {
              print('[test9] Pozvan onDispose');
              sl.dispose = true;
              sl.detector.close();
            },
          )),
          Container(
            margin: EdgeInsets.only(top: 100, left: 40, right: 40),
            child: Align(
                alignment: Alignment.topCenter,
                child: Text(sl.getHintText(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 36,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w800,
                        color: themeData.accentColor))),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(bottom: 100, left: 10, right: 10),
              child: Card(
                color: themeData.accentColor.withOpacity(0.7),
                shape: RoundedRectangleBorder(
                  //borderSide: BorderSide(themeData.primaryColor, width: 1.0),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Padding(
                  padding:
                      EdgeInsets.only(left: 10, right: 10, top: 25, bottom: 25),
                  child: AnimatedList(
                      shrinkWrap: true,
                      reverse: false,
                      key: sl.keyWidgets,
                      scrollDirection: Axis.vertical,
                      initialItemCount: 1,
                      itemBuilder: (BuildContext context, int index,
                          Animation animation) {
                        debugPrint('[test3] ponovo iscrtavam widgete');
                        return SlideTransition(
                            position: animation.drive(Tween(
                              begin: Offset(0, 0.5),
                              end: Offset(0, 0),
                            ).chain(CurveTween(curve: Curves.ease))),
                            child: cw.myListItem(index));
                      }),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          List<dynamic> succees = await Navigator.of(context).push<List<dynamic>>(
              MaterialPageRoute(
                  builder: (context) => KayboardInputScreenPage()));
          if (succees != null) Navigator.of(context).pop(succees) ;
        },
        child: Icon(
          Icons.keyboard,
          color: themeData.primaryColor,
        ),
      ),
    );
  }
}
