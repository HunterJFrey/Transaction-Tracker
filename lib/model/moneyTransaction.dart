import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class MoneyTransaction  {
  List<MoneyTransaction> transactions = [];
  String name;
  String total;
  String date;
  String type;

  MoneyTransaction(String name, String total, String date, String type) {
    this.name = name;
    this.total = total;
    this.date = date;
    this.type = type;
  }

  MoneyTransaction.fromTransaction(this.transactions);

}
