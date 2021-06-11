import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recognizing_text2/Utils.dart';
import 'package:recognizing_text2/models/Records.dart';
import 'package:recognizing_text2/screens/AddStoreScreen.dart';
import 'package:recognizing_text2/screens/DateTimeTextFiled.dart';
import 'package:recognizing_text2/screens/PriceTextField.dart';
import 'package:recognizing_text2/screens/StoreTypeAheadWidget.dart';



class BillScreen extends StatefulWidget {
  final Records records;
  final int index;
  final int gradientIndex;
  BillScreen(
      {@required this.records, @required this.index, this.gradientIndex = 0}) {}
  @override
  _BillScreenState createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  final double topPartSize = 250;
  final ImagePicker imagePicker = ImagePicker();
  List<dynamic> data;
  ThemeData themeData;
  Image _image;
  bool isEdited = false;
  AddStoreBottomSheet bottomSheet = AddStoreBottomSheet();
  TextEditingController storeController = TextEditingController();
  FocusNode priceFocusNode = new FocusNode();
  FocusNode storeFocusNode = new FocusNode();
  TextEditingController priceControler = TextEditingController();
  TextEditingController dateControler = TextEditingController();
  TextEditingController timeControler = TextEditingController();
  double dateKeyboardHeigth = 60;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    this.data = widget.records.data[widget.index];
    print('BillScreen data $data');
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future save(int index, dynamic newValue) async {
    widget.records.changeRecordsAndSave(widget.index, index, newValue);
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: WillPopScope(
          onWillPop: () async {
            Navigator.of(context).pop(isEdited);
            return isEdited;
          },
          child: SafeArea(
              child: Stack(
            children: [
              Container(
                height: 300,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end:  Alignment.bottomCenter,
                    colors: [themeData.primaryColor, Colors.indigoAccent[700]]
                  )
                ),
                alignment: Alignment.center,
                child: imageWidget(data[5]),
              ),
              Container(
                margin: EdgeInsets.only(top: topPartSize),
                child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: gradients[widget.gradientIndex]),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50),
                        )),
                    alignment: Alignment.topCenter,
                    padding: EdgeInsets.only(top: 40),
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                              color: themeData.accentColor,
                              borderRadius: BorderRadius.circular(50)),
                          alignment: Alignment.center,
                          child: Icon(
                            IconData(
                              (data[3] as int),
                              fontFamily: 'MaterialIcons',
                            ),
                            size: 50.0,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          data[1],
                          style: TextStyle(
                            color: themeData.accentColor,
                            fontSize: 40,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          data[2],
                          style: TextStyle(
                            color: themeData.accentColor,
                            fontSize: 22,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          printDate(data[0]),
                          style: TextStyle(
                            color: themeData.accentColor,
                            fontSize: 20,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          '${data[4]} kn',
                          style: TextStyle(
                            color: themeData.accentColor,
                            fontSize: 20,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    )),
              ),
              Positioned(
                right: 15,
                bottom: 15,
                child: FloatingActionButton(
                  heroTag: 'edit',
                  onPressed: () => editDialog(context),
                  child: Icon(Icons.edit),
                ),
              ),
              Positioned(
                left: 15,
                bottom: 15,
                child: FloatingActionButton(
                  heroTag: 'delete',
                  onPressed: () => deleteDialog(context),
                  child: Icon(Icons.delete),
                ),
              ),
              //     Positioned(
              //       height: dateKeyboardHeigth,

              // bottom: dateKeyboardHeigth,
              // child: ListView(
              //   physics: NeverScrollableScrollPhysics(),
              //   children: [
              //     Container(
              //       margin: EdgeInsets.only(top: 0),
              //       height: dateKeyboardHeigth,
              //       child: DatePickerWidget(

              //       ),
              //     )
              //     ],
              //   ),
              // )
            ],
          )),
        ));
  }

  Widget imageWidget(String image) {
    if (image == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'No image',
            style: TextStyle(
              color: themeData.accentColor,
              fontSize: 30,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          FloatingActionButton(
              heroTag: null,
              backgroundColor: themeData.accentColor,
              onPressed: () async {
                PickedFile image =
                    await imagePicker.getImage(source: ImageSource.camera);
                if (image == null) {
                  print('Nisam dobio sliku');
                  return;
                }
                Uint8List imageBytes = await image.readAsBytes();
                File(image.path).delete();
                save(5, base64Encode(imageBytes));
                setState(() {});
              },
              child: Icon(
                Icons.photo_camera,
                color: themeData.primaryColor,
              ))
        ],
      );
    } else {
      return GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return FullScreenWidget(
              child: Hero(
                tag: "HeroTag",
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(
                    base64Decode(image),
                  ),
                ),
              ),
            );
          }));
        },
        child: Stack(children: [
          Hero(
            child: Container(
                width: double.infinity,
                child: Image.memory(base64Decode(image), fit: BoxFit.fitWidth)),
            tag: "HeroTag",
          ),
          Positioned(
              top: 15,
              right: 15,
              width: 40,
              height: 40,
              child: FloatingActionButton(
                onPressed: () async {
                  bool removeImage = await showDialog<bool>(
                      barrierColor: Colors.transparent,
                      context: context,
                      builder: (context) => removeImageAlert(context));
                  if (removeImage != null && removeImage == true) {
                    save(5, null);
                    setState(() {});
                  }
                },
                heroTag: 'removeImage',
                child: Icon(
                  Icons.clear,
                  color: Colors.red[900],
                ),
              ))
        ]),
      );
    }
  }

  removeImageAlert(BuildContext context) {
    return Column(children: [
      Container(
        height: topPartSize,
        alignment: Alignment.center,
        child: Container(
          width: 220,
          height: 120,
          child: Material(
            color: Colors.transparent,
            elevation: 20,
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30)),
                alignment: Alignment.topCenter,
                padding: EdgeInsets.all(17),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Remove image ?', style: TextStyle(fontSize: 20)),
                    Container(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        height: 50,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            FloatingActionButton(
                              elevation: 20,
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: Icon(Icons.clear, color: Colors.red[900]),
                            ),
                            FloatingActionButton(
                              elevation: 20,
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                              child:
                                  Icon(Icons.check, color: Colors.green[900]),
                            )
                          ],
                        ))
                  ],
                )),
          ),
        ),
      ),
    ]);
  }

  editDialog(BuildContext context) async {
    storeController.text = data[1];
    priceControler.text = data[4].toString();
    dateControler.text = printDateTimeShort(DateTime.parse(data[0]), 'date');
    timeControler.text = printDateTimeShort(DateTime.parse(data[0]), 'time');
    bool isNew = await showDialog<bool>(
        context: context,
        builder: (context) => Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 30),
                        height: 420,
                        child: Material(
                          color: Colors.transparent,
                          elevation: 20,
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(35)),
                              alignment: Alignment.topCenter,
                              padding: EdgeInsets.all(17),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text('Edit Bill',
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontFamily: 'Nunito',
                                          fontWeight: FontWeight.w800,
                                        )),
                                    StoreTypeAheadWidget(
                                      context: context,
                                      storeControler: storeController,
                                      bottomSheet: bottomSheet,
                                      primaryColor: themeData.accentColor,
                                      secundaryColor: themeData.primaryColor,
                                      //nextFocusNode: priceFocusNode,
                                      storeFocusNode: storeFocusNode,
                                      initList: [data[1]],
                                    ),
                                    PriceTextField(
                                      priceController: priceControler,
                                      priceFocusNode: priceFocusNode,
                                      primaryColor: themeData.accentColor,
                                      secundaryColor: themeData.primaryColor,
                                      topPadding: 0,
                                    ),
                                    Row(children: [
                                      Expanded(
                                        flex: 6,
                                        child: DateTimeTextField(
                                          controller: dateControler,
                                          label: 'Date',
                                          primaryColor: themeData.accentColor,
                                          secundaryColor:
                                              themeData.primaryColor,
                                          sufficIconData: Icons.date_range,
                                          topPadding: 0,
                                          focusNode: FocusNode(),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: DateTimeTextField(
                                          controller: timeControler,
                                          label: 'Time',
                                          primaryColor: themeData.accentColor,
                                          secundaryColor:
                                              themeData.primaryColor,
                                          sufficIconData: Icons.access_time,
                                          topPadding: 0,
                                          focusNode: FocusNode(),
                                        ),
                                      )
                                    ]),
                                    Container(
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 8),
                                        height: 60,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            FloatingActionButton(
                                              elevation: 20,
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(false);
                                              },
                                              child: Icon(Icons.clear,
                                                  color: Colors.red[900]),
                                            ),
                                            FloatingActionButton(
                                              elevation: 20,
                                              onPressed: () {
                                                if (_formKey.currentState
                                                    .validate()) {
                                                  Navigator.of(context)
                                                      .pop(true);
                                                }
                                              },
                                              child: Icon(Icons.check,
                                                  color: Colors.green[900]),
                                            )
                                          ],
                                        ))
                                  ],
                                ),
                              )),
                        ),
                      ),
                    ),
                  ]),
            ));
    if (isNew != null && isNew == true) {
      DateTime newTime = toDateTimeString(timeControler.text, 'time');
      DateTime newDT = DateTime.fromMillisecondsSinceEpoch(
          toDateTimeString(dateControler.text, 'date').millisecondsSinceEpoch +
              newTime.hour * 1000 * 60 * 60 +
              newTime.minute * 1000 * 60);
      await widget.records.updateRecord(widget.index,
          price: double.parse(priceControler.text),
          store: storeController.text,
          date: newDT);
      isEdited = true;
      setState(() {
        data = widget.records.data[widget.index];
      });
    }
  }

  deleteDialog(BuildContext context) async {
    bool delete = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                'Delete bill',
                style: TextStyle(
                  color: themeData.primaryColor,
                  fontFamily: 'Nunito',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  ),
                textAlign: TextAlign.center),
              content: Container(
                height: 90,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Do you want to delete the bill?',
                      style: TextStyle(color: themeData.primaryColor),
                    ),
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.center,
                      mainAxisAlignment:
                          MainAxisAlignment.spaceAround,
                      children: [
                        FloatingActionButton(
                          elevation: 20,
                          onPressed: () {
                            Navigator.of(context)
                                .pop(false);
                          },
                          child: Icon(Icons.clear,
                              color: Colors.red[900]),
                        ),
                        FloatingActionButton(
                          elevation: 20,
                          onPressed: () {
                              Navigator.of(context)
                                  .pop(true);
                            
                          },
                          child: Icon(Icons.check,
                              color: Colors.green[900]),
                        )
                      ],
                    )
                  ]),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ));
    if (delete != null && delete == true) {
      widget.records.removeRecord(widget.index);
      Navigator.of(context).pop(true);
    }
  }
}
