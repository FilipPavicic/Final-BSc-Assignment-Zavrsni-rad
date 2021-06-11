import 'package:date_util/date_util.dart';
import 'package:flutter/material.dart';
import 'package:diacritic/diacritic.dart';
import 'package:collection/collection.dart';
import 'package:date_utils/date_utils.dart' as dateUtils;

Map<String, String> aciiNamerules = {
  '0': 'o',
  '"': '',
  ' ': '',
  "'": "",
  'ri': 'n',
  'l': 'i'
};

Size getSizeByKey(GlobalKey<State<StatefulWidget>> _key) {
  final RenderBox renderBoxRed = _key.currentContext.findRenderObject();
  return renderBoxRed.size;
}

Size textSize(String text, TextStyle style) {
  final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr)
    ..layout(minWidth: 0, maxWidth: double.infinity);
  return textPainter.size;
}

List<String> adjustElemsAndASCII(List<String> elems) {
  return elems.map((e) => adjustOneAndASCII(e, aciiNamerules)).toList();
}

String adjustOneAndASCII(String s, Map<String, String> rules) {
  s = s.trim();
  s = s.toLowerCase();
  s = removeDiacritics(s);
  rules.forEach((key, value) {
    s = s.replaceAll(key, value);
  });
  return s;
}

String nextString(String value) {
  String v1 = String.fromCharCode(value.codeUnitAt(value.length - 1) + 1);
  return value.substring(0, value.length - 1) + v1;
}

final List<Color> randColors = [
  Colors.cyanAccent,
  Colors.limeAccent[400],
  Colors.pinkAccent[700],
  Colors.orange[400],
  Colors.yellowAccent,
  Colors.lightGreen[700],
  Colors.blueAccent,
  Colors.purpleAccent,
  Colors.brown[100],
  Colors.amber[900],
];

String textOnBillWarning =
    '* Store name is most often present at the top of the bill. Enter the whole line containing the name of the store. Please be precise so that the scanner can recognize it';

List<DateTime> calculateDate(DateTime now, int index, int state) {
  if (state == 0) {
    DateTime first = DateTime(now.year, now.month, now.day + index);
    return [
      first,
      first.add(Duration(days: 1)),
    ];
  }
  if (state == 1) {
    DateTime first = DateTime(now.year, now.month + index, 1);
    return [first, DateTime(first.year, first.month + 1, 1)];
  }
  if (state == 2) {
    DateTime first = DateTime(now.year + index, 1, 1);
    return [first, DateTime(first.year + 1, 1, 1)];
  }
  return null;
}

int calcluateJumpPage(DateTime selected, DateTime now, int state) {
  if (state == 0) {
    return selected.difference(now).inDays;
  }
  if (state == 1) {
    int years = selected.year - now.year;
    return selected.month - now.month + years * 12;
  }
  if (state == 2) {
    return selected.year - now.year;
  }
}

List<List<Color>> gradients = [
  [Color(0xFF6448FE), Color(0xFF5FC6FF)],
  [Color(0xFFFE6197), Color(0xFFFFB463)],
  [Color(0xFF61A3FE), Color(0xFF63FFD5)],
  [Color(0xFFFFA738), Color(0xFFFFE130)],
  [Color(0xFFFF5DCD), Color(0xFFFF8484)],
];

Map<String, double> groupbyAndSum(List<List<dynamic>> list, Function t) {
  return groupBy<List<dynamic>, String>(list, t).map((key, value) =>
      MapEntry(key, value.map((e) => e[4]).fold(0, (prev, cur) => prev + cur)));
}

Map<String, double> mapListForPieChart(
    {@required List<List<dynamic>> list, @required int state, int limit = 6}) {
  int indexState = state == 0 ? 1 : 2;
  Map<String, double> tmpMap =
      groupbyAndSum(list, (e) => e[indexState].toString());
  double limitValue;
  try {
    limitValue =
        tmpMap.values.sorted((a, b) => b.compareTo(a)).elementAt(limit - 1);
  } on RangeError catch (e) {
    return tmpMap;
  }
  double other = 0;
  tmpMap.removeWhere((key, value) {
    if (value >= limitValue) return false;
    other += value;
    return true;
  });
  if (other != 0) tmpMap['other'] = other;
  return tmpMap;
}

List<List<dynamic>> mapListForHistogram(
    {@required List<List<dynamic>> list, @required int dateState}) {
  if (dateState == 0) {
    Map<String, double> tmpMap =
        groupbyAndSum(list, (e) => (DateTime.parse(e[0]).hour ~/ 4).toString());
    for (int i = 0; i < 6; i++) {
      if (!tmpMap.containsKey(i.toString())) tmpMap['$i'] = 0;
    }
    return tmpMap.entries
        .sorted((a, b) => a.key.compareTo(b.key))
        .map((e) =>
            ['${int.parse(e.key) * 4}-${int.parse(e.key) * 4 + 4}', e.value])
        .toList();
  }
  if (dateState == 1) {
    int monthDay =
        dateUtils.DateUtils.lastDayOfMonth(DateTime.parse(list[0][0])).day;
    Map<String, double> tmpMap =
        groupbyAndSum(list, (e) => (DateTime.parse(e[0]).day ~/ 5).toString());
    for (int i = 0; i < monthDay ~/ 5 + 1; i++) {
      if (!tmpMap.containsKey(i.toString())) tmpMap['$i'] = 0;
    }
    return tmpMap.entries
        .sorted((a, b) => a.key.compareTo(b.key))
        .map((e) => [
              '${int.parse(e.key) * 5 + 1}-${int.parse(e.key) * 5 + 5 + 1 > monthDay ? monthDay : int.parse(e.key) * 5 + 5 + 1}',
              e.value
            ])
        .toList();
  }
  if (dateState == 2) {
    Map<String, double> tmpMap =
        groupbyAndSum(list, (e) => (DateTime.parse(e[0]).month).toString());
    for (int i = 1; i < 13; i++) {
      if (!tmpMap.containsKey(i.toString())) tmpMap['$i'] = 0;
    }
    return tmpMap.entries
        .sorted((a, b) => int.parse(a.key).compareTo(int.parse(b.key)))
        .map((e) => ['${int.parse(e.key)}', e.value])
        .toList();
  }
}

String printDate(String str) {
  DateUtil utl = DateUtil();
  DateTime dt = DateTime.parse(str);
  return '${dt.day.toString().padLeft(2, '0')} ${utl.month(dt.month)} ${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

String printDateTimeShort(DateTime dt, String type) {
  switch (type) {
    case 'date':
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    case 'time':
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    default:
      return '';
  }
}

DateTime toDateTimeString(String st, String type) {
  
  try {
  switch (type) {
    case 'date':
      var p = st.split('/').map((e) => int.parse(e)).toList();
      return DateTime(p[2],p[1],p[0]);
    case 'time':
    var p = st.split(':').map((e) => int.parse(e)).toList();
      return DateTime(2000,1,1,p[0],p[1]);
    default:
      return null;
  }
  } catch (e) {
    return null;
  }
}
