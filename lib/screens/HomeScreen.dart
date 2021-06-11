import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:recognizing_text2/FirebaseUtils.dart';
import 'package:recognizing_text2/models/Records.dart';
import 'package:recognizing_text2/screens/AddStoreScreen.dart';
import 'package:recognizing_text2/screens/TopSnackBar.dart';
import 'package:recognizing_text2/screens/billScreen.dart';
import 'package:recognizing_text2/screens/cameraScan/CameraScanMain.dart';
import 'package:recognizing_text2/Utils.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:share/share.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AddStoreBottomSheet bottomSheet = AddStoreBottomSheet();
  static final int bigInt = 1e12.toInt();
  PageController pageController = PageController(
    initialPage: bigInt,
  );
  int periodState = 0;
  final DateTime now = DateTime.now();
  List<DateTime> dates;
  List<DateTime> tmpdates;
  Records records;
  int pieState = 0;

  var currentPageValue = 0.0;

  double maxHeigthMyContainerChild = 265;
  double verticalMarginMyContainer = 20;
  double heightOfCard = 70;

  inicializeRecords() {
    Records.inicialize().then((value) => setState(() => records = value));
  }

  @override
  void initState() {
    super.initState();
    tmpdates = dates = calculateDate(now, 0, periodState);
    print('[test12] Inicjalni datum: $dates');
    inicializeRecords();
    // pageController.addListener(() {
    //   setState(() {
    //     currentPageValue = pageController.page;
    //     dates = calculateDate(
    //         now, (pageController.page - bigInt).floor(), periodState);
    //     print('[test12]pozvan setStae,dates: $dates');
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    print('[test12]pozvan bulider');
    themeData = Theme.of(context);
    return Scaffold(
      body: Stack(children: [
        Container(
          color: themeData.primaryColor,
          child: createBody(context),
        ),
        SafeArea(
          child: Container(
            height: 30,
            //width: 30,
            margin: EdgeInsets.all(5),
            color: Colors.transparent,
            alignment: Alignment.topRight,
            child: PopupMenuButton<String>(
              iconSize: 30,
              icon: Icon(
                Icons.more_vert,
                color: themeData.accentColor,
              ),
              color: themeData.accentColor,
              onSelected: (value) => onPopupSelect(context, value),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'AddStore',
                  child: Text('Add Store'),
                ),
                PopupMenuItem(
                  value: 'Export',
                  child: Text('Export to Excel'),
                )
              ],
            ),
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          List<dynamic> succes = await Navigator.of(context)
              .push<List<dynamic>>(
                  MaterialPageRoute(builder: (context) => CameraScanScreen()));
          if (succes != null) {
            showTopSnackBar(context, 'New record added', Colors.green);
            print('Dobio sam podatke: $succes');
            records.addRecord(succes).then((value) => setState(() {}));
          }
        },
      ),
    );
  }

  onPopupSelect(BuildContext context, String value) async {
    if (value == 'AddStore') {
      bottomSheet.showBottomSheet<String>(context, themeData, null);
    }
    if (value == 'Export') {
      String path = await records.createExcelAndSave();
      Share.shareFiles([path], text: 'This is my bills in Excel');
    }
  }

  Widget createBody(BuildContext context) {
    return Column(
      children: [
        Container(
          //color: Colors.green,
          height: 250,
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 50, left: 30, right: 30),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            createTabBar(context),
            SizedBox(
              height: 30,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    '${tmpdates[0].year.toString().padLeft(2, '0')}-${tmpdates[0].month.toString().padLeft(2, '0')}-${tmpdates[0].day.toString().padLeft(2, '0')}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: themeData.accentColor,
                      fontSize: 24,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '${tmpdates[1].year.toString().padLeft(2, '0')}-${tmpdates[1].month.toString().padLeft(2, '0')}-${tmpdates[1].day.toString().padLeft(2, '0')}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: themeData.accentColor,
                      fontSize: 24,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            )
          ]),
        ),
        Expanded(
          child: Container(
            child: createPageView(context),
          ),
        ),
      ],
    );
  }

  Widget createTabBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 50),
      height: 40,
      child: DefaultTabController(
        length: 3,
        child: Container(
          margin: EdgeInsets.only(
            left: 20,
            right: 20,
          ),
          decoration: BoxDecoration(
              color: themeData.accentColor,
              borderRadius: BorderRadius.circular(20)),
          child: TabBar(
              indicator: BubbleTabIndicator(
                tabBarIndicatorSize: TabBarIndicatorSize.tab,
                indicatorHeight: 30.0,
                indicatorColor: themeData.primaryColor,
              ),
              labelColor: themeData.accentColor,
              unselectedLabelColor: themeData.primaryColor,
              tabs: <Widget>[
                Container(alignment: Alignment.center, child: Text('Day')),
                Container(alignment: Alignment.center, child: Text('Month')),
                Container(alignment: Alignment.center, child: Text('Year')),
              ],
              onTap: (i) {
                print('[test12] Stisnuti ');
                if (periodState == i) {
                  //setState(() {});
                  return;
                }
                int previous = periodState;
                setState(() {
                  periodState = i;
                  dates = calculateDate(
                      now, pageController.page.toInt() - bigInt, periodState);

                  if (previous < i) {
                    pageController.jumpToPage(pageController.page.toInt() +
                        calcluateJumpPage(now, dates[0], i));
                  } else {
                    DateTime jump = previous == 2
                        ? DateTime(dates[0].year, now.month, now.day)
                        : DateTime(dates[0].year, dates[0].month, now.day);

                    pageController.jumpToPage(pageController.page.toInt() +
                        calcluateJumpPage(now, jump, i));
                  }
                  tmpdates = dates;
                });
              }),
        ),
      ),
    );
  }

  Widget createPageView(BuildContext context) {
    return PageView.builder(
      itemBuilder: (context1, index) {
        int position = index - bigInt;
        // if (position == currentPageValue.floor()) {
        //   print('[test12] usao u  if');
        // } else if (position == currentPageValue.floor() + 1) {

        //   print('[test12] usao u prvi else');
        // } else {
        //   print('[test12] usao u drugi else');
        // }

        dates = calculateDate(now, position, periodState);
        return summaryView(context, position);
      },
      controller: pageController,
      onPageChanged: (i) => setState(
          () => tmpdates = calculateDate(now, i - bigInt, periodState)),
    );
  }

  Widget summaryView(BuildContext context, int position) {
    if (records == null)
      return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [themeData.primaryColor, Colors.blueAccent[400]])),
      );
    List<List<dynamic>> dateRecords = records.filterDate(dates[0], dates[1]);
    if (dateRecords.isEmpty)
      return Container(
          height: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [themeData.primaryColor, Colors.blueAccent[400]])),
          child: Align(
            alignment: Alignment.center,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                height: 170,
                child: Image.asset('images/notFound.png'),
              ),
              Container(
                height: 80,
                width: 240,
                child: Text(
                  'There are no found bills for this period',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: themeData.accentColor,
                    fontSize: 26,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(
                height: 100,
              )
            ]),
          ));
    return Container(
      //color: Colors.green,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [themeData.primaryColor, Colors.blueAccent[400]])),
      alignment: Alignment.topCenter,
      child: ListView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 50),
        children: [
          myContainer(
              name: 'Recent Bills',
              child: recentBillsView(context, dateRecords),
              flexiable: true),
          myContainer(name: 'Cost share', child: pieChart(dateRecords)),
          myContainer(name: 'Expenses', child: histogram(dateRecords)),
        ],
      ),
    );
  }

  Widget recentBillsView(BuildContext context, List<List<dynamic>> listItems) {
    return Container(
      height: listItems.length * heightOfCard > maxHeigthMyContainerChild
          ? maxHeigthMyContainerChild
          : null,
      child: ListView.builder(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(0),
          itemCount: listItems.length,
          itemBuilder: (context1, index) {
            var row = listItems[index];
            print('Dobiveni podaci ${listItems[index]}');
            return Container(
              height: heightOfCard,
              margin: EdgeInsets.only(bottom: 5),
              child: Card(
                elevation: 0,
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0)),
                child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: gradients[(index + 1) % 5]),
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    onTap: () async {
                      bool changed = await Navigator.of(context)
                          .push<bool>(MaterialPageRoute(
                              builder: (context) => BillScreen(
                                    records: records,
                                    index: index,
                                    gradientIndex: (index + 1) % 5,
                                  )));
                      print('Dobio sam change: $changed');
                      if (changed != null && changed == true) setState(() {});
                    },
                    leading: Container(
                        height: double.infinity,
                        child: Icon(IconData((row[3] as int),
                            fontFamily: 'MaterialIcons'))),
                    trailing: Text(
                      '${row[4]} kn',
                      style: TextStyle(fontSize: 16),
                    ),
                    title: Text(row[1], style: TextStyle(fontSize: 16)),
                    subtitle:
                        Text(printDate(row[0]), style: TextStyle(fontSize: 12)),
                    dense: true,
                  ),
                ),
              ),
            );
          }),
    );
  }

  Widget histogram(List<List<dynamic>> listItems) {
    print(
        'Histogram data ${mapListForHistogram(list: listItems, dateState: periodState)}');
    charts.OrdinalAxisSpec primaryaxis = charts.OrdinalAxisSpec(
      renderSpec: charts.SmallTickRendererSpec(
        labelStyle: charts.TextStyleSpec(
            fontSize: 12,
            color: charts.MaterialPalette
                .white), //chnage white color as per your requirement.
      ),
    );

    charts.NumericAxisSpec axisNum = charts.NumericAxisSpec(
        renderSpec: charts.GridlineRendererSpec(
      labelStyle: charts.TextStyleSpec(
          fontSize: 14,
          color: charts.MaterialPalette
              .white), //chnage white color as per your requirement.
    ));
    return new charts.BarChart(
      [
        charts.Series(
          id: 'Bills',
          data: mapListForHistogram(list: listItems, dateState: periodState),
          domainFn: (d, _) => d[0],
          measureFn: (d, _) => d[1],
          colorFn: (_, i) => charts.MaterialPalette.white,
        )
      ],
      primaryMeasureAxis: axisNum,
      domainAxis: primaryaxis,
    );
  }

  Widget pieChart(List<List<dynamic>> listItems) {
    return InkWell(
        onTap: () {
          setState(() {
            pieState = 1 - pieState;
          });
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: PieChart(
          key: ValueKey(dates),
          dataMap:
              mapListForPieChart(list: listItems, state: pieState, limit: 5),
          legendOptions: LegendOptions(
              legendPosition: LegendPosition.bottom,
              showLegendsInRow: true,
              legendTextStyle: TextStyle(
                color: themeData.accentColor,
                fontSize: 14,
              )),
          initialAngleInDegree: -90,
          chartLegendSpacing: 30,
          chartRadius: 200,
          animationDuration: Duration(milliseconds: 1000),
          chartValuesOptions: ChartValuesOptions(
              showChartValuesOutside: true,
              showChartValueBackground: false,
              showChartValuesInPercentage: true,
              chartValueStyle: TextStyle(fontSize: 16)),
          chartType: ChartType.disc,
        ));
  }

  Widget myContainer({String name, Widget child, bool flexiable = false}) {
    return Container(
      //color: Colors.red,
      margin: EdgeInsets.symmetric(
          horizontal: 30, vertical: 20),
      width: double.infinity,
      constraints: BoxConstraints(
          maxHeight: 310),
      //height: 310,
      child: Column(
        //crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            height: 30,
            child: Text(
              name,
              style: TextStyle(
                color: themeData.accentColor,
                fontSize: 26,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Material(
            color: Colors.transparent,
            //elevation: 20,
            child: Container(
              width: double.infinity,
              constraints: flexiable ? null : BoxConstraints(maxHeight: maxHeigthMyContainerChild),
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(15),
              //   gradient: LinearGradient(
              //       begin: Alignment.bottomLeft,
              //       end: Alignment.topRight,
              //       colors: [Colors.blue[100].withOpacity(0.5), Colors.indigoAccent[700].withOpacity(0.4)]),
              // ),
              alignment: Alignment.center,
              child: child,
            ),
          )
        ],
      ),
    );
  }
}
