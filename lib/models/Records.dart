import 'dart:async';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert' show utf8;
import 'package:csv/csv.dart';
import 'package:recognizing_text2/FirebaseUtils.dart';
import 'package:recognizing_text2/models/category.dart';


class Records {
  static final List<String> headers = [
    'date',
    'store',
    'category',
    'categroyIcon',
    'price',
    'image'
  ];
  List<List<dynamic>> data;
  Records({@required this.data});

  static Future<Records> inicialize() async {
    List<List<dynamic>> data;
    File file = await _localFile;
    bool exits = await file.exists();
    if (exits == false) {
      data = [];
      return Records(data: data);
    }
    final input = file.openRead();
    data = await input
        .transform(utf8.decoder)
        .transform(CsvCodec().decoder)
        .map((e) {
      if (e[5] == 'null') e[5] = null;
      return e;
    }) // image if 'null' to null
        .toList();
    data.removeAt(0);
    data = data.reversed.toList();
    return Records(data: data);
  }

  writeToFile() async {
    List<List<dynamic>> tmpData = [headers];
    tmpData.addAll(this.data);
    String csv = const ListToCsvConverter().convert(tmpData);
    File file = await _localFile;
    await file.create(recursive: true);
    file.writeAsString(csv);
  }

  static Future<File> get _localFile async {
    Directory path = await getApplicationDocumentsDirectory();
    return File('${path.path}/records.txt');
  }

  Future<List<dynamic>> createRecord({
    @required String store,
    @required double price,
    Category category,
    DateTime date,
  }) async {
    if (category == null) category = await getCategoryByName(store);
    if (date == null) date = DateTime.now();
    List<dynamic> record = [
      date.toString(),
      store,
      category.name,
      category.iconData.codePoint,
      price,
      null
    ];
    return record;
  }

  Future addRecord(List<dynamic> data) async {
    List<dynamic> record = await createRecord(store: data[0],price: data[1]);
    this.data.insert(0,record);
    writeToFile();
  }

  Future updateRecord(int index,{
    @required String store,
    @required double price,
    Category category,
    DateTime date,
  }) async {
    List<dynamic> record = await createRecord(date: date,price: price,category: category,store: store);
    this.data[index] = record;
    writeToFile();
  }

  Future removeRecord(int index) async {
    this.data.removeAt(index);
    writeToFile();
  }

  List<List<dynamic>> filterDate(DateTime start, DateTime end) {
    return data
        .where((el) =>
            (DateTime.parse(el[0])).isAfter(start) &&
            (DateTime.parse(el[0])).isBefore(end))
        .toList();
  }

  Future<String> createExcelAndSave() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];
    for (int i = 0; i < data.length; i++) {
      sheetObject.insertRowIterables(data[i], i);
    }
    Directory path = await getApplicationDocumentsDirectory();
    await excel.encode().then((onValue) {
      File("${path.path}/excel.xlsx")
        ..createSync(recursive: true)
        ..writeAsBytesSync(onValue);
    });
    return Future.value("${path.path}/excel.xlsx");
  }

  Future changeRecordsAndSave(int row, int index, dynamic newValue) async {
    this.data[row][index] = newValue; // row + 1 zbog header
    writeToFile();
  }
}
