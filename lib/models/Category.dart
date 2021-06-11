import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recognizing_text2/Utils.dart';

class Category {
  static final  Map<String, String> categoryRules = {'0': 'o', '"': ''};
  String id;
  String name;
  String asciiName;
  int popularity;
  IconData iconData;

  Category(id, name, popularity, int iconCode) {
    

    this.id = id;
    this.name = name;
    this.popularity = popularity;
    this.iconData = IconData(iconCode, fontFamily: 'MaterialIcons');
    this.asciiName = adjustOneAndASCII(name,categoryRules);
  }

  @override
  String toString() {
    return 'Category => [id: $id, name: $name, asciiName: $asciiName, popularity: $popularity, IconDataCode: ${iconData.codePoint} ]';
  }
  static Category categoryMapper(DocumentSnapshot e) {
  var data = e.data();
  return Category(
    e.id,
    data['name'],
    data['popularity'],
    int.parse(data['iconCode']),
  );
}
}
