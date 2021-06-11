import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recognizing_text2/FirebaseUtils.dart';
import 'package:recognizing_text2/Utils.dart';
import 'package:recognizing_text2/models/category.dart';


final CollectionReference categoryCollectionReference =
    FirebaseFirestore.instance.collection('categories');

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  List<Category> tmp = (await categoryCollectionReference
          .where('asciiName', isGreaterThanOrEqualTo: 'g')
          .where('asciiName', isLessThanOrEqualTo: 'h')
          .get()
          .then((v) => v.docs.map((e) {
                var data = e.data();
                print('dobio sam ove podatke: $data');
                return Category(
                  e.id,
                  data['name'],
                  data['popularity'],
                  int.parse(data['iconCode']),
                );
              })))
      .toList();
  print(tmp);
}
