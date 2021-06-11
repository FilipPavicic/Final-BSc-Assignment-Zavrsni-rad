import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recognizing_text2/FirebaseUtils.dart';
import 'package:recognizing_text2/Utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  firebaseUtilsInitalizations();
  test('Firebase fetch data', () async {
    List<String> elems;
    await fireBaseContains(storeCollectionReference, 'ascii_name', 'name',
        ['dm-drogerie markt d.o.o.']).then((value) => elems = value);
    expect(['Dm-drogerie markt d.o.o.'], elems);
  });
}
