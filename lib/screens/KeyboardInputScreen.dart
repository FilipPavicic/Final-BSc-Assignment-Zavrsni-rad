import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:recognizing_text2/screens/AddStoreScreen.dart';

import 'StoreTypeAheadWidget.dart';


class KayboardInputScreenPage extends StatefulWidget {
  KayboardInputScreenPage({Key key}) : super(key: key);

  @override
  _KayboardInputScreen createState() => _KayboardInputScreen();
}

class _KayboardInputScreen extends State<KayboardInputScreenPage> {
  AddStoreBottomSheet bottomSheet = AddStoreBottomSheet();
  ThemeData themeData;
  bool isSuggestionPresent = true;
  List<String> storeNameSuggestion = [];
  TextEditingController storeControler = TextEditingController();
  TextEditingController priceControler = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  MySBC sbc = new MySBC();
  var storeFocusNode = FocusNode();
  FocusNode priceFocusNode = new FocusNode();

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => storeFocusNode.requestFocus());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [themeData.primaryColor, Colors.blueAccent[700]])),
        padding: EdgeInsets.only(left: 40, right: 40, top: 150),
        child: Form(
            key: _formKey,
            child: Column(children: [
              Container(
                padding: EdgeInsets.only(bottom: 20),
                child: Align(
                    alignment: Alignment.topCenter,
                    child: Text('Manual insert',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 36,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800,
                            color: themeData.accentColor))),
              ),
              StoreTypeAheadWidget(
                bottomSheet: bottomSheet,
                context: _scaffoldKey.currentContext,
                nextFocusNode: priceFocusNode,
                primaryColor: themeData.primaryColor,
                secundaryColor: themeData.accentColor,
                storeControler: storeControler,
                storeFocusNode: storeFocusNode,
              ),
              Container(
                padding: EdgeInsets.only(top: 30),
                child: TextFormField(
                  controller: priceControler,
                  keyboardType: TextInputType.number,
                  focusNode: priceFocusNode,
                  decoration: MyBorderInputDecoration(
                      suffixIcon: Icon(Icons.monetization_on,
                          color: themeData.accentColor),
                      alignLabelWithHint: true,
                      labelText: "Total price",
                      labelStyle:
                          TextStyle(color: themeData.accentColor, fontSize: 18),
                      //hintText: 'McDonalds',
                      filled: true,
                      hintStyle: TextStyle(color: themeData.accentColor),
                      fillColor: themeData.primaryColor,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: themeData.accentColor, width: 2.0),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      errorStyle: TextStyle(
                          color: themeData.accentColor, fontSize: 14)),
                  style: TextStyle(color: themeData.accentColor),
                  cursorColor: themeData.accentColor,
                  validator: (v) {
                    if (v == '') return 'This field is required';
                    if (double.tryParse(v) == null)
                      return 'Please enter number';
                    return null;
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      margin: EdgeInsets.only(left: 5, right: 5, top: 20),
                      decoration: BoxDecoration(
                          //border: Border.all(color: themeData.primaryColor, width: 1),
                          borderRadius: BorderRadius.circular(25.0),
                          color: themeData.accentColor),
                      child: TextButton(
                        style: ButtonStyle(
                          overlayColor: MaterialStateColor.resolveWith(
                              (states) => Colors.transparent),
                        ),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            FocusScope.of(context).unfocus();
                            Navigator.of(context).pop([
                              storeControler.text,
                              double.parse(priceControler.text)
                            ]);
                          }
                        },
                        child: Text(
                          'Submit',
                          style: TextStyle(
                              color: themeData.primaryColor, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      margin: EdgeInsets.only(left: 5, right: 5, top: 20),
                      decoration: BoxDecoration(
                          //border: Border.all(color: themeData.primaryColor, width: 1),
                          borderRadius: BorderRadius.circular(25.0),
                          color: themeData.accentColor),
                      child: TextButton(
                        style: ButtonStyle(
                          overlayColor: MaterialStateColor.resolveWith(
                              (states) => Colors.transparent),
                        ),
                        onPressed: () async {
                          String text =
                              await bottomSheet.showBottomSheet<String>(
                                  _scaffoldKey.currentContext,
                                  themeData,
                                  storeControler.text);
                          print('[test7] Popan sam: $text');
                          // if (text != null)
                          //   showTopSnackBar(
                          //       _scaffoldKey.currentContext,
                          //       'Thanks for improving this application',
                          //       Colors.green);
                          setState(() {
                            storeControler.text = text;
                          });
                        },
                        child: Text(
                          'Add new Store',
                          style: TextStyle(
                              color: themeData.primaryColor, fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ])),
      ),
    );
  }
}

class MySBC extends SuggestionsBoxController {
  bool isSuggestionPresent = false;

  @override
  void open() {
    super.open();
  }

  @override
  void close() {
    debugPrint('[test4] Pozivam close');
  }
}
