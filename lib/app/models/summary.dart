import 'dart:convert';

import 'package:meta/meta.dart';

class Summary {
  Summary({
    @required this.totalTransaction,
    @required this.savingCapital,
    @required this.currentCapital,
    @required this.currentStatus,
  });

  final int totalTransaction;
  final String savingCapital;
  final String currentCapital;
  final CurrentStatus currentStatus;

  factory Summary.fromRawJson(String str) => Summary.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
        totalTransaction: json["total_transaction"] == null ? null : json["total_transaction"],
        savingCapital: json["saving_capital"] == null ? null : json["saving_capital"],
        currentCapital: json["current_capital"] == null ? null : json["current_capital"],
        currentStatus: json["current_status"] == null ? null : CurrentStatus.fromJson(json["current_status"]),
      );

  Map<String, dynamic> toJson() => {
        "total_transaction": totalTransaction == null ? null : totalTransaction,
        "saving_capital": savingCapital == null ? null : savingCapital,
        "current_capital": currentCapital == null ? null : currentCapital,
        "current_status": currentStatus == null ? null : currentStatus.toJson(),
      };
}

class CurrentStatus {
  CurrentStatus({
    @required this.diffAmount,
    @required this.diffPercentage,
    @required this.diff,
  });

  final String diffAmount;
  final double diffPercentage;
  final String diff;

  factory CurrentStatus.fromRawJson(String str) => CurrentStatus.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CurrentStatus.fromJson(Map<String, dynamic> json) => CurrentStatus(
        diffAmount: json["diff_amount"] == null ? null : json["diff_amount"],
        diffPercentage: json["diff_percentage"] == null ? null : json["diff_percentage"].toDouble(),
        diff: json["diff"] == null ? null : json["diff"],
      );

  Map<String, dynamic> toJson() => {
        "diff_amount": diffAmount == null ? null : diffAmount,
        "diff_percentage": diffPercentage == null ? null : diffPercentage,
        "diff": diff == null ? null : diff,
      };
}
