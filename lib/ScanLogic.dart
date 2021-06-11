import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:developer' as log;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:recognizing_text2/FirebaseUtils.dart';
import 'package:recognizing_text2/Utils.dart';
import 'package:recognizing_text2/screens/AddStoreScreen.dart';

class ScanLogic {
  final GlobalKey<AnimatedListState> key = GlobalKey();
  final GlobalKey<AnimatedListState> keyWidgets = GlobalKey();
  final GlobalKey keyRed = GlobalKey();

  int state = 0; //0 -- text, 1-- price, 2-- submit

  bool dispose = false;
  bool previousFinish = true;
  String store;
  TextRecognizer detector = FirebaseVision.instance.textRecognizer();
  int selected_index = -1;
  final List<double> priceList = [];
  List<Widget> widgetlist;
  bool isPriceVisible = false;
  double textPricePading = 3;
  bool callBulder = false;
  final List<String> hintTexts = [
    'Scan the name of store',
    'Scan the total price',
    'Press submit'
  ];

  AddStoreBottomSheet bottomSheet = AddStoreBottomSheet();

  RegExp priceRegex = RegExp(r"^[0-9]+[,.][0-9]{2}$");

  final Function observer;

  bool isVisible = true;

  ScanLogic({@required this.observer}) {
    Firebase.initializeApp();
    store = defaultStore();
  }
  String defaultStore() {
    return 'Searching ...';
  }

  addPrice(double br) {
    debugPrint('[test3] Pocinjem posao u addPrice za broj: $br');
    log.log('Dobio sam broj: $br');
    log.log('SelectedIndex je: $selected_index');
    bool inserted = false;
    for (int i = 0; i < priceList.length; i++) {
      if (br == priceList.elementAt(i)) {
        log.log('Broj je jednak broju na mjestu: $i');
        inserted = true;
        debugPrint('[test3] Zavrsio posao u addPrice za broj: $br');
        return;
      }
      if (br > priceList.elementAt(i)) {
        inserted = true;
        priceList.insert(i, br);
        log.log('Unosim broj na mjesto: $i');
        log.log(
            'Element na sljedecem mjestu je: ${priceList.elementAt(i + 1)}');
        if (selected_index >= i && selected_index != -1) {
          log.log('Trenutni selectedIndex: $selected_index');
          selected_index++;
          log.log('postavljam selectedIndex na: $selected_index');
        }

        log.log('Šaljem ga na poziciju : $i');
        try {
          key.currentState.insertItem(i);
        } catch (e) {
          debugPrint('[test3] nesto je poslo po zlu: $e');
        }
        break;
      }
    }
    debugPrint('[test3] Iza FoR u addPrice');
    if (inserted == false) {
      log.log('Unosim broj na kraj');
      priceList.add(br);
      log.log('Šaljem ga na poziciju : ${priceList.length - 1}');
      try {
        key.currentState.insertItem(priceList.length - 1);
      } catch (e) {
        debugPrint('[test3] nesto je poslo po zlu: $e');
      }
    }
    debugPrint('[test3] Zavrsio posao u addPrice za broj: $br');
  }

  Future<bool> onScanResult(VisionText text) async {
    if (dispose == true) return Future.value(false);
    var elems = text.text.split('\n');
    debugPrint('[Imena]Dobio sam elemente $elems');
    //debugPrint('Dobio sam elemente: $elems');
    switch (state) {
      case 0:
        {
          debugPrint('Obrađujem state 0');
          String findStore;
          await getStore(elems).then((value) {
            findStore = value;
            debugPrint('[test2] zavrsio then');
          });
          debugPrint('[test2] varijabla findStore: $findStore');
          debugPrint('[test2] idem dalje');
          if (findStore == null) return Future.value(false);
          store = findStore;
          debugPrint('[test2] miejnjam state u 1');
          selected_index == -1 ? setState(1) : setState(2);
          return Future.value(true);
        }
      case 1:
        {
          debugPrint('[test3] Dobio sam zadatak u state 1');
          debugPrint('[test]Trenutno u listi imam: $priceList');
          debugPrint('Obrađujem state 1');
          await getPrices(elems);
          debugPrint('[test3] Izlazim iz zadatka state 1');
          return Future.value(true);
        }
      default:
        debugPrint('Obrađujem state ostalo');
        return Future.value(false);
    }
  }

  getPrices(List<String> elems) {
    debugPrint('[test3] Dobio sam zadatak u getPrice');
    elems.forEach((element) {
      element = adjustOneAndASCII(element, {'kn':'',' ': ''});
      debugPrint('[test3] Dobio sam zadatak u getPrice ForEach');
      if (priceRegex.hasMatch(element)) {
        element = element.replaceAll(',', '.');
        debugPrint(
            '[test3]Evo me prije addPrice u getPrice ForEach, element je $element');
        double broj = double.parse(element);
        debugPrint(
            '[test3]Evo me prije addPrice u getPrice ForEach, Parsirani element je $broj');
        if (isPriceVisible == false) {
          keyWidgets.currentState.insertItem(1);
          isPriceVisible = true;
        }
        addPrice(double.parse(element));
        debugPrint('[test3] Odradio sam addPrice za broj $element');
      }
    });
  }

  List<String> findStoresTmp = [];
  List<String> blokingStores = [];

  Future<String> getStore(List<String> elems) async {
    List<String> asciiElems = adjustElemsAndASCII(elems);
    if (findStoresTmp.isNotEmpty) {
      String store = findStoresTmp.removeAt(0);
      return store;
    }
    await fireBaseContains(
            storeCollectionReference, 'billName', 'name', asciiElems)
        .then((value) => findStoresTmp = value);
    debugPrint('dobio sam u getStore listu: $findStoresTmp');
    String returnedValue;
    findStoresTmp = findStoresTmp
        .where((element) => !blokingStores.contains(element))
        .toList();
    if (findStoresTmp.isNotEmpty) returnedValue = findStoresTmp.removeAt(0);
    return returnedValue;
  }

  void setState(int state) {
    if(this.state != 2 && state == 2) insertItemInWidgetList(2);
    if(this.state == 2 && state != 2) removeItemFromWidgetList(2);
    debugPrint('Postavljam state: $state');
    this.state = state;
  }

  double widthOfMaxNumber() {
    double width =
        textSize('${priceList.elementAt(0).toStringAsFixed(2)} kn', TextStyle())
            .width;
    //width += 2 * textPricePading;
    debugPrint('izracunao min Width $width elementa ${priceList.elementAt(0)}');
    return width;
  }

  void onPriceButton(int index) {
    if (selected_index == index) {
      selected_index = -1;
      setState(1);
      observer();
      return;
    }
    setState(2);
    selected_index = index;
    debugPrint('Selected index : $selected_index');
    observer();
  }

  void onRetryButton(Function removeWidgetFunction) {
    blokingStores.add(store);
    store = defaultStore();
    setState(0);
    observer();
  }

  String getHintText() {
    return hintTexts.elementAt(state);
  }
  void removeItemFromWidgetList(int position){
    keyWidgets.currentState.removeItem(
        position,
        (context, animation) =>
            SlideTransition(
                position: animation.drive(
                    Tween(
                  begin: Offset(0, 0.5),
                  end: Offset(0, 0),
                ).chain(CurveTween(
                        curve: Curves.ease))),
                child: widgetlist.elementAt(position)),
        duration:
            Duration(milliseconds: 250));
  } 
  void insertItemInWidgetList(int position){
    keyWidgets.currentState.insertItem(position,
    duration: const Duration(milliseconds: 500));
  }
}
