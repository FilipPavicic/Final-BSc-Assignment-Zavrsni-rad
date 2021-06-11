import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recognizing_text2/Utils.dart';
import 'package:recognizing_text2/models/category.dart';

CollectionReference storeCollectionReference;
CollectionReference categoryCollectionReference;

void firebaseUtilsInitalizations() {
  storeCollectionReference = FirebaseFirestore.instance.collection('stores');
  categoryCollectionReference =
      FirebaseFirestore.instance.collection('categories');
}

Future<List<String>> fireBaseContains(CollectionReference ref, String arg,
    String returnArg, List<String> elems) async {
  List<Future> tasks = [];
  List<String> returnedElems = [];
  for (var i = 0; i < elems.length; i += 10) {
    var chunk = elems
        .sublist(i, i + 10 > elems.length ? elems.length : i + 10)
        .toList();
    tasks.add(ref.where(arg, whereIn: chunk).get().then((value) {
      if (value.docs.isEmpty == true) {
        return;
      }
      returnedElems.addAll(value.docs.map((e) => e.data()[returnArg]));
    }));
  }
  await Future.wait(tasks);
  return Future.value(returnedElems);
}

Future<List<T>> get10BySearch<T>(
    CollectionReference ref,
    String arg,
    String text,
    int Function(T, T) compare,
    T Function(QueryDocumentSnapshot) mapper) {
  return ref
      .where(arg, isGreaterThanOrEqualTo: text)
      .where(arg, isLessThanOrEqualTo: nextString(text))
      .get()
      .then((value) {
    List<T> lista = value.docs.map((e) => mapper(e)).toList();
    if (compare != null) lista.sort(compare);
    return lista.take(10).toList();
  });
}

Future<List<T>> getFirst10<T>(
    CollectionReference ref, T Function(QueryDocumentSnapshot) mapper) {
  return ref
      .orderBy('popularity', descending: true)
      .get()
      .then((value) => value.docs.map((e) => mapper(e)).toList());
}

Future addStoreToFireBase(String name, String billName, String category) async {
  billName = adjustOneAndASCII(billName, aciiNamerules);
  String asciiName = adjustOneAndASCII(name, {});

  var data = {
    'name': name,
    'ascii_name': asciiName,
    'category': category,
    'billName': billName
  };
  await storeCollectionReference.add(data);
  final DocumentReference docRef = categoryCollectionReference.doc(category);
  await docRef.update({'popularity': FieldValue.increment(1)});
}

Future<Category> getCategoryByName(String name) async {
  String idCategory = await storeCollectionReference
      .where('name', isEqualTo: name)
      .get()
      .then((value) => value.docs[0]['category']);
  return await categoryCollectionReference
      .doc(idCategory)
      .get()
      .then((value) => Category.categoryMapper(value));
}
