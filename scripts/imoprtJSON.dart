import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:recognizing_text2/Utils.dart';
import 'package:recognizing_text2/models/category.dart';

final CollectionReference categoryCollectionReference =
    FirebaseFirestore.instance.collection('categories');
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  List my_data =
      json.decode(await rootBundle.loadString('assets/category.json'));
  List<Map<String,dynamic>> lista = my_data.map((e) => 
  {
    'name' : e['name'],
    'popularity' : e['popularity'],
    'iconCode' : e['iconCode']
    }
  ).toList();
  lista.forEach((element) {
    element['asciiName'] =
        adjustOneAndASCII(element['name'], Category.categoryRules);
    categoryCollectionReference.add(element);
  });
}
