import 'dart:convert';

import 'package:meta/meta.dart';

class CurrencyRate {
  CurrencyRate({
    @required this.currencyProviderName,
    @required this.currency,
    @required this.rate,
    @required this.unit,
  });

  final String currencyProviderName;
  final String currency;
  final double rate;
  final String unit;

  factory CurrencyRate.fromRawJson(String str) => CurrencyRate.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CurrencyRate.fromJson(Map<String, dynamic> json) => CurrencyRate(
        currencyProviderName: json["currency_provider_name"] == null ? null : json["currency_provider_name"],
        currency: json["currency"] == null ? null : json["currency"],
        rate: json["rate"] == null ? null : json["rate"].toDouble(),
        unit: json["unit"] == null ? null : json["unit"],
      );

  Map<String, dynamic> toJson() => {
        "currency_provider_name": currencyProviderName == null ? null : currencyProviderName,
        "currency": currency == null ? null : currency,
        "rate": rate == null ? null : rate,
        "unit": unit == null ? null : unit,
      };
}
