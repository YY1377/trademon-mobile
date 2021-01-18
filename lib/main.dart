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
        primarySwatch: Colors.lightGreen,
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

class _MyHomePageState extends State<MyHomePage> {
  Summary summary;

  Map<String, List<CurrencyRate>> providerCurrencyRateMap = new Map();

  Future<void> summarize() async {
    var response = await http.get('http://localhost:3333/status/summarize');
    if (response.statusCode == 200) {
      var summary = Summary.fromRawJson(response.body.toString());
      setState(() {
        // ₺
        this.summary = summary;
      });
    }
  }

  Future<void> showCurrentRates() async {
    var response = await http.get('http://localhost:3333/currency/rates');
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.lightGreen,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Spacer(),
            Text(
              'Status',
              style: Theme.of(context).textTheme.headline3,
            ),
            getCurrentStatusRow(summary),
            Spacer(
              flex: 2,
            ),
            Text(
              'Currency Rates',
              style: Theme.of(context).textTheme.headline3,
            ),
            getCurrencyRates(providerCurrencyRateMap),
            Spacer(),
          ],
        ),
      ),
      backgroundColor: Colors.blueGrey,
      floatingActionButton: FloatingActionButton(
        onPressed: refreshAll,
        tooltip: 'Refresh',
        child: Icon(Icons.refresh_outlined),
        backgroundColor: Colors.lightGreen,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Row getCurrentStatusRow(Summary summary) {
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Spacer(),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Total Transaction',
              textScaleFactor: 0.8,
              style: TextStyle(fontWeight: FontWeight.w300),
            ),
            Text(
              '$totalTransaction',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        Spacer(),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Saving Capital',
              textScaleFactor: 0.8,
              style: TextStyle(fontWeight: FontWeight.w300),
            ),
            Text(
              '$savingCapital',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              'Current Capital',
              textScaleFactor: 0.8,
              style: TextStyle(fontWeight: FontWeight.w300),
            ),
            Text(
              '$currentCapital',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        Spacer(),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            'Current Status',
            textScaleFactor: 0.8,
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
          Text(
            '$diffAmount',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          Text(
            '$diffPercentage',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          Text(
            '$diff',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ]),
        Spacer(),
      ],
    );
  }

  getCurrencyRates(Map<String, List<CurrencyRate>> providerCurrencyRateMap) {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: getProviders(providerCurrencyRateMap),
    );
  }

  void refreshAll() async {
    summarize();
    showCurrentRates();
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
