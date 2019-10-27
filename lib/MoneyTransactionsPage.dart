import 'package:flutter/material.dart';
import 'dart:async';
import 'package:transactions/database/database.dart';
import 'package:transactions/model/moneyTransaction.dart';
import 'package:sqflite/sqflite.dart';

Future<List<MoneyTransaction>> fetchMoneyTransaction() async {
  var dbHelper = DBHelper();
  Future<List<MoneyTransaction>> transactions = dbHelper.getTransaction();

  return transactions;
}

class MyMoneyTransactionPage extends StatefulWidget {
  @override
  MyMoneyTransactionPageState createState() => new MyMoneyTransactionPageState();
}

class MyMoneyTransactionPageState extends State<MyMoneyTransactionPage> {
  TextEditingController textSearchController = new TextEditingController();


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Transactions'),
      ),
      body: new Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child: new FutureBuilder<List<MoneyTransaction>>(
                future: fetchMoneyTransaction(),
                builder: (context, snapshot) {
                  if(snapshot.hasData) {
                    if(snapshot.data != null) {
                      return ListView.builder(
                        //reverse: true,
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return new Card(
                              child: ListTile(
                                leading: Text(snapshot.data[index].date),
                                title: Text(snapshot.data[index].name),
                                trailing: Text("\$" + snapshot.data[index].total),
                              )
                          );
                        },
                      );
                    }
                  }
                  else {
                    return new CircularProgressIndicator();
                  }
                },
              ),
            )
          ],
        )
      ),
    );
  }




}