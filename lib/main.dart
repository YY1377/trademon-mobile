import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trademon_mobile/app/models/currency_rate.dart';

import 'app/models/summary.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trademon',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Trademon Dashboard'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  Summary summary;

  Map<String, List<CurrencyRate>> providerCurrencyRateMap = new Map();

  AnimationController _refreshButtonAnimationController;
  bool isRefreshing = false;

  MaterialColor currencyRatesStatusColor;
  MaterialColor summarizeStatusColor;

  @override
  void initState() {
    super.initState();
    this.summarizeStatusColor = Colors.amber;
    this.currencyRatesStatusColor = Colors.amber;
    this._refreshButtonAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 450));
  }

  Future<bool> summarize() async {
    var response = await http.get('http://localhost:3333/status/summarize').timeout(Duration(seconds: 5));
    if (response.statusCode == 200) {
      var summary = Summary.fromRawJson(response.body.toString());
      setState(() {
        this.summary = summary;
      });
      return true;
    }
    return false;
  }

  Future<bool> showCurrentRates() async {
    var response = await http.get('http://localhost:3333/currency/rates').timeout(Duration(seconds: 5));
    if (response.statusCode == 200) {
      List<CurrencyRate> listOfCurrencyRate = new List();
      List.from(jsonDecode(response.body)).forEach((element) => listOfCurrencyRate.add(CurrencyRate.fromJson(element)));
      Map<String, List<CurrencyRate>> providerCurrencyRateMap = new Map();
      listOfCurrencyRate.forEach((currencyRate) => {
            if (providerCurrencyRateMap.containsKey(currencyRate.currencyProviderName))
              {providerCurrencyRateMap[currencyRate.currencyProviderName].add(currencyRate)}
            else
              {
                providerCurrencyRateMap.putIfAbsent(currencyRate.currencyProviderName, () => [currencyRate])
              }
          });

      setState(() {
        this.providerCurrencyRateMap = providerCurrencyRateMap;
      });

      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.amber,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    color: Colors.black45,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Status',
                                style:
                                    Theme.of(context).textTheme.headline3.merge(TextStyle(color: summarizeStatusColor)),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [getStatusRow(summary)],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.black54,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Container(
                            height: 75,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Currency Rates',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline3
                                      .merge(TextStyle(color: summarizeStatusColor)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: getCurrencyRatesRow(providerCurrencyRateMap),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ))
          ],
        ),
      ),
      backgroundColor: Colors.blueGrey,
      floatingActionButton: FloatingActionButton(
        onPressed: refreshAll,
        tooltip: 'Refresh',
        child: AnimatedIcon(
          icon: AnimatedIcons.play_pause,
          progress: _refreshButtonAnimationController,
        ),
        backgroundColor: Colors.amber,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void refreshAll() async {
    setState(() {
      this.isRefreshing = !this.isRefreshing;
      this.isRefreshing
          ? this._refreshButtonAnimationController.forward()
          : this._refreshButtonAnimationController.reverse();
    });
    try {
      await summarize();
      summarizeStatusColor = Colors.amber;
    } on TimeoutException catch (e) {
      summarizeStatusColor = Colors.red;
    }
    try {
      await showCurrentRates();
      currencyRatesStatusColor = Colors.amber;
    } on TimeoutException catch (e) {
      currencyRatesStatusColor = Colors.red;
    }

    setState(() {
      this._refreshButtonAnimationController.reverse();
    });
  }

  Row getStatusRow(Summary summary) {
    if (summary == null) {
      return Row(
        children: [Text('-')],
      );
    }

    var totalTransaction = summary.totalTransaction ?? '-';
    var savingCapital = summary.savingCapital + ' ₺' ?? '-';
    var currentCapital = summary.currentCapital + ' ₺' ?? '-';
    var currentStatus = summary.currentStatus;
    var diffAmount = '-';
    var diffPercentage = '-';
    var diff = '-';
    if (currentStatus != null) {
      diffAmount = currentStatus.diffAmount + ' ₺' ?? '-';
      diffPercentage = ' %' + (currentStatus.diffPercentage ?? '-').toString();
      diff = currentStatus.diff ?? '-';
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Total Transaction',
                textScaleFactor: 0.8,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
              ),
              Text(
                '$totalTransaction',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Saving Capital',
                textScaleFactor: 0.8,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300, ),
              ),
              Text(
                '$savingCapital',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              Text(
                'Current Capital',
                textScaleFactor: 0.8,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
              ),
              Text(
                '$currentCapital',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              'Current Status',
              textScaleFactor: 0.8,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
            ),
            Text(
              '$diffAmount',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              '$diffPercentage',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              '$diff',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ]),
        ),
      ],
    );
  }

  getCurrencyRatesRow(Map<String, List<CurrencyRate>> providerCurrencyRateMap) {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: getProviders(providerCurrencyRateMap),
    );
  }

  getProviders(Map<String, List<CurrencyRate>> providerCurrencyRateMap) {
    List<Widget> list = new List();
    for (var key in providerCurrencyRateMap.keys) {
      list.add(Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            key,
            style: TextStyle(decoration: TextDecoration.underline),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: getCurrs(providerCurrencyRateMap[key]),
          ),
        ],
      ));
    }
    return list;
  }

  getCurrs(List<CurrencyRate> rates) {
    List<Widget> list = new List();
    for (var cr in rates) {
      list.add(Spacer());
      list.add(
        Column(children: [
          Text(
            cr.currency,
            textScaleFactor: 0.8,
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
          Text(
            cr.rate.toString() + ' ₺',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ]),
      );
      list.add(Spacer());
    }

    return list;
  }
}
