import 'dart:math';

import 'package:flushbar/flushbar_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recognizing_text2/FirebaseUtils.dart';
import 'package:recognizing_text2/Utils.dart';
import 'package:recognizing_text2/models/category.dart';
import 'package:recognizing_text2/screens/TopSnackBar.dart';


class AddStoreBottomSheet {
  final int colorStart = Random().nextInt(10);
  final _formInfoKey = GlobalKey<FormState>();

  BuildContext context;
  ThemeData themeData;

  int _currentStep = 0;
  TextEditingController storeNamecontoler = TextEditingController();
  TextEditingController billNamecontoler = TextEditingController();
  TextEditingController searchcontoler = TextEditingController();
  int _currentCategory = -1;
  List<Category> categoryList = [];
  List<Category> categoryListTop10 = [];
  Future categoryListFuture;
  String tmpArg;
  bool isFutureDone = true;
  FocusNode billNamefocus;
  FocusNode storeNamefocus;
  var stepperKey = GlobalKey();

  void inicialization() {
    _currentStep = 0;
    storeNamecontoler = TextEditingController();
    billNamecontoler = TextEditingController();
    searchcontoler = TextEditingController();
    _currentCategory = -1;
    categoryList = [];
    categoryListTop10 = [];
    categoryListFuture = null;
    tmpArg = null;
    isFutureDone = true;
    storeNamefocus = new FocusNode();
    billNamefocus = new FocusNode();
  }

  AddStoreBottomSheet() {
    inicialization();
    // storeNamecontoler.addListener(() {
    //   debugPrint('[test5] nova vrijendnost u textu: ${storecontoler.text}');
    // });
  }

  Future<T> showBottomSheet<T>(
      BuildContext context, ThemeData themeData, String initialName) {
    this.context = context;
    this.themeData = themeData;
    if (categoryList.isEmpty && categoryListFuture == null) {
      isFutureDone = false;
      categoryListFuture =
          getFirst10(categoryCollectionReference, Category.categoryMapper)
              .then((value) => categoryList = categoryListTop10 = value)
              .whenComplete(() => isFutureDone = true);
    }
    if (initialName != null && storeNamecontoler.text == '')
      storeNamecontoler.text = initialName;
    return showModalBottomSheet<T>(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) => createBottomSheetWidget(),
    ).then((value) {
      if (value != null)
        showTopSnackBar(
            context, 'Thanks for improving this application', Colors.green);
      return value;
    });
  }

  applayCategorySearch(String arg, Function setState) async {
    print('[test6] usao u applayCategorySearch s: $arg');
    tmpArg = arg;
    if (isFutureDone == false) {
      print('[test6] Future zauzet');
      return;
    }
    isFutureDone = false;
    String argBefore = tmpArg;
    print('[test6] Šaljem zadatak');
    if (tmpArg != '') {
      categoryListFuture = get10BySearch<Category>(
              categoryCollectionReference,
              'asciiName',
              adjustOneAndASCII(tmpArg, Category.categoryRules),
              (c1, c2) => c2.popularity.compareTo(c1.popularity),
              Category.categoryMapper)
          .then((value) => setState(() => categoryList = value))
          .whenComplete(() {
        isFutureDone = true;
        if (tmpArg == null) return;
        if (argBefore != tmpArg) applayCategorySearch(tmpArg, setState);
      });
    } else {
      setState(() => categoryList = categoryListTop10);
      isFutureDone = true;
    }
    //tmpArg = null;
  }

  void addStore() {
    String retText = storeNamecontoler.text;
    addStoreToFireBase(storeNamecontoler.text, billNamecontoler.text,
        categoryList.elementAt(_currentCategory).id);
    inicialization();
    Navigator.pop(context, retText);
  }

  Widget createBottomSheetWidget() {
    return StatefulBuilder(
      builder: (BuildContext context1, setState) => SingleChildScrollView(
        child: Container(
          height: 550,
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.only(top: 20, left: 10, right: 30),
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
                color: themeData.accentColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                )),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Add New Store',
                      style: TextStyle(
                          fontSize: 28,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w800,
                          color: themeData.primaryColor)),
                  SizedBox(height: 10),
                  Container(
                    height: 480,
                    child: Stepper(
                      key: stepperKey,
                      type: StepperType.vertical,
                      physics: ScrollPhysics(),
                      currentStep: _currentStep,
                      onStepTapped: (value) =>
                          setState(() => _currentStep = value),
                      onStepContinue: () {
                        FocusScope.of(context1).unfocus();
                        _currentStep < 1
                            ? setState(() => _currentStep += 1)
                            : addStore();
                      },
                      onStepCancel: () {
                        FocusScope.of(context1).unfocus();
                        _currentStep > 0
                            ? setState(() => _currentStep -= 1)
                            : null;
                      },
                      controlsBuilder: (context,
                              {onStepCancel, onStepContinue}) =>
                          buttons(context, onStepCancel, onStepContinue),
                      steps: <Step>[
                        Step(
                          title: Text('Store info'),
                          content: storeInfoSection(),
                          isActive: _currentStep >= 0,
                          state: _currentStep >= 0
                              ? StepState.complete
                              : StepState.disabled,
                        ),
                        Step(
                          title: Text('Store category'),
                          content: storeCategorySection(setState, context1),
                          isActive: _currentStep >= 0,
                          state: _currentStep >= 1
                              ? StepState.complete
                              : StepState.disabled,
                        ),
                      ],
                    ),
                  )
                ]),
          ),
        ),
      ),
    );
  }

  Widget storeInfoSection() {
    return Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(top: 5),
        height: 250,
        child: Form(
            key: _formInfoKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    controller: storeNamecontoler,
                    focusNode: storeNamefocus,
                    onEditingComplete: () => billNamefocus.requestFocus(),
                    decoration: MyBorderInputDecoration(
                        isDense: true, // Added this
                        contentPadding: EdgeInsets.all(12),
                        labelText: 'Store name',
                        labelStyle: TextStyle(
                            color: themeData.primaryColor, fontSize: 18),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: themeData.primaryColor, width: 2.0),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        errorStyle: TextStyle(
                            color: themeData.primaryColor, fontSize: 14)),
                    validator: (v) {
                      if (v == '') return 'This field is required';
                      return null;
                    }),
                // SizedBox(
                //   height: 20,
                // ),
                TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  focusNode: billNamefocus,
                  controller: billNamecontoler,
                  decoration: MyBorderInputDecoration(
                      counterStyle: TextStyle(color: themeData.primaryColor),
                      isDense: true, // Added this
                      contentPadding: EdgeInsets.all(12),
                      border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: themeData.primaryColor, width: 2.0),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      labelText: 'Text on bill',
                      labelStyle:
                          TextStyle(color: themeData.primaryColor, fontSize: 18),
                      errorStyle:
                          TextStyle(color: themeData.primaryColor, fontSize: 14)),
                  validator: (v) {
                    if (v == '') return 'This field is required';
                    return null;
                  },
                ),
                //SizedBox(height: 10),
                Text(
                  textOnBillWarning,
                  style: TextStyle(color: themeData.primaryColor,fontSize: 12),
                ),
              ],
            ),
          ),
        );
  }

  Widget storeCategorySection(Function setState, BuildContext context1) {
    return Container(
      padding: EdgeInsets.only(bottom: 20),
      height: 220,
      //color: Colors.green,

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Category',
                    //textAlign: TextAlign.center,
                    style: TextStyle(
                        color: themeData.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    height: 40,
                    alignment: Alignment.centerRight,
                    child: TextField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: searchcontoler,
                      onChanged: (value) =>
                          applayCategorySearch(value, setState),
                      textAlignVertical: TextAlignVertical.bottom,
                      style: TextStyle(fontSize: 14),
                      decoration: MyBorderInputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(fontSize: 14),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: themeData.primaryColor, width: 2.0),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        suffixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 130,
            //color: Colors.green,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categoryList.length,
                itemBuilder: (BuildContext context, int position) {
                  return InkWell(
                    onTap: () => setState(() {
                      FocusScope.of(context1).unfocus();
                      _currentCategory =
                          _currentCategory == position ? -1 : position;
                    }),
                    child: widgetCategory(position),
                  );
                }),
          )
        ],
      ),
    );
  }

  Widget widgetCategory(int position) {
    Category c = categoryList.elementAt(position);
    return Container(
      margin: EdgeInsets.only(
          top: 5,
          bottom: 5,
          right: position == categoryList.length - 1 ? 0 : 5,
          left: position == 0 ? 0 : 5),
      height: 130,
      width: 90,
      alignment: Alignment.center,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        height: position == _currentCategory ? 110 : 95,
        width: position == _currentCategory ? 90 : 75,
        decoration: BoxDecoration(
          color: randColors[(colorStart + position) % 10],
          borderRadius: BorderRadius.all(Radius.circular(15)),
          // border: position == _currentCategory
          //     ? Border.all(width: 2, color: themeData.primaryColor)
          //     : null,
          boxShadow: [
            BoxShadow(
              color: randColors[(colorStart + position) % 10].withOpacity(0.5),
              blurRadius: 4,
              offset: Offset(4, 8), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.center,
                child: Icon(c.iconData, size: 27),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                  width: 80,
                  alignment: Alignment.topCenter,
                  padding: EdgeInsets.all(3),
                  child: Text(
                    c.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        //color: themeData.accentColor,
                        fontSize: 14),
                  )),
            )
          ],
        ),
      ),
    );
  }

  Widget buttons(context, onStepCancel, onStepContinue) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            height: 40,
            width: double.infinity,
            margin: EdgeInsets.only(left: 5, right: 5),
            decoration: BoxDecoration(
                //border: Border.all(color: themeData.primaryColor, width: 1),
                borderRadius: BorderRadius.circular(20.0),
                color: themeData.primaryColor),
            child: TextButton(
              style: ButtonStyle(
                overlayColor: MaterialStateColor.resolveWith(
                    (states) => Colors.transparent),
              ),
              onPressed: () {
                onStepCancel();
              },
              child: Text(
                'Previous',
                style: TextStyle(color: themeData.accentColor, fontSize: 18),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 40,
            width: double.infinity,
            margin: EdgeInsets.only(left: 5, right: 5),
            decoration: BoxDecoration(
                //border: Border.all(color: themeData.primaryColor, width: 1),
                borderRadius: BorderRadius.circular(25.0),
                color: themeData.primaryColor),
            child: TextButton(
              style: ButtonStyle(
                overlayColor: MaterialStateColor.resolveWith(
                    (states) => Colors.transparent),
              ),
              onPressed: () {
                if (_currentStep == 0) {
                  if (!_formInfoKey.currentState.validate()) {
                    return;
                  }
                }
                if (_currentStep == 1) {
                  if (_currentCategory == -1) {
                    showTopSnackBar(
                        context, "Choose store category", Colors.yellow);
                    return;
                  }
                }
                onStepContinue();
              },
              child: Text(
                _currentStep == 0 ? 'Next' : 'Add Store',
                style: TextStyle(color: themeData.accentColor, fontSize: 18),
              ),
            ),
          ),
        ),
      ].skip(_currentStep == 0 ? 1 : 0).toList(),
    );
  }
}

class MyBorderInputDecoration extends InputDecoration {
  final OutlineInputBorder border;
  const MyBorderInputDecoration({
    this.border,
    icon,
    labelText,
    labelStyle,
    helperText,
    helperStyle,
    helperMaxLines,
    hintText,
    hintStyle,
    hintTextDirection,
    hintMaxLines,
    errorText,
    errorStyle,
    errorMaxLines,
    @Deprecated('Use floatingLabelBehavior instead. '
        'This feature was deprecated after v1.13.2.')
        hasFloatingPlaceholder = true,
    floatingLabelBehavior,
    isCollapsed = false,
    isDense,
    contentPadding,
    prefixIcon,
    prefixIconConstraints,
    prefix,
    prefixText,
    prefixStyle,
    suffixIcon,
    suffix,
    suffixText,
    suffixStyle,
    suffixIconConstraints,
    counter,
    counterText,
    counterStyle,
    filled,
    fillColor,
    focusColor,
    hoverColor,
    enabled = true,
    semanticCounterText,
    alignLabelWithHint,
  }) : super(
            alignLabelWithHint: alignLabelWithHint,
            border: border,
            contentPadding: contentPadding,
            counter: counter,
            counterStyle: counterStyle,
            counterText: counterText,
            disabledBorder: border,
            enabled: enabled,
            enabledBorder: border,
            errorBorder: border,
            errorMaxLines: errorMaxLines,
            errorStyle: errorStyle,
            errorText: errorText,
            fillColor: fillColor,
            filled: filled,
            floatingLabelBehavior: floatingLabelBehavior,
            focusColor: focusColor,
            focusedBorder: border,
            focusedErrorBorder: border,
            hasFloatingPlaceholder: hasFloatingPlaceholder,
            helperMaxLines: helperMaxLines,
            helperStyle: helperStyle,
            helperText: helperText,
            hintMaxLines: hintMaxLines,
            hintStyle: hintStyle,
            hintText: hintText,
            hintTextDirection: hintTextDirection,
            hoverColor: hoverColor,
            icon: icon,
            isCollapsed: isCollapsed,
            isDense: isDense,
            labelStyle: labelStyle,
            labelText: labelText,
            prefix: prefix,
            prefixIcon: prefixIcon,
            prefixIconConstraints: prefixIconConstraints,
            prefixStyle: prefixStyle,
            prefixText: prefixText,
            semanticCounterText: semanticCounterText,
            suffix: suffix,
            suffixIcon: suffixIcon,
            suffixIconConstraints: suffixIconConstraints,
            suffixStyle: suffixStyle,
            suffixText: suffixText);
}
