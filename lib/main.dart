import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:transactions/model/moneyTransaction.dart';
import 'package:transactions/database/database.dart';
import 'package:transactions/MoneyTransactionsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

//const backgroundColorTheme = const Color(0xff32322C);
//const textColor = const Color(0xff13C4A3);

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        hintColor: Color(0xff13C4A3),
        secondaryHeaderColor: Color(0xff13C4A3),
        accentColor: Color(0xff32322C),
        dialogBackgroundColor: Color(0xff32322C),
        cursorColor: Color(0xff13C4A3),
        toggleableActiveColor: Color(0xff13C4A3),
        primarySwatch: Colors.grey,
        textTheme: Theme.of(context).textTheme.apply(
            bodyColor: Color(0xff13C4A3),
            displayColor: Color(0xff13C4A3),
        ),
        scaffoldBackgroundColor: Color(0xff32322C),
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final keyIsFirstLoaded = 'is_first_loaded';
  final balanceKey = 'current_balance';
  List<MoneyTransaction> _transactions = [];
  TextEditingController nameController = new TextEditingController();
  TextEditingController totalController = new TextEditingController();
  TextEditingController balanceController = new TextEditingController();
  TextEditingController searchTransController = new TextEditingController();
  double currentBalance = 0.0;
  SharedPreferences sharedPreferences;
  DateTime selectedDate = DateTime.now();

  Future _selectDate() async {
    DateTime picked = await showDatePicker(
      context: context,
      initialDate: new DateTime.now(),
      firstDate: new DateTime(2019),
      lastDate: new DateTime(2100),

    );
    if(picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentBalance();

    SharedPreferences.getInstance().then((SharedPreferences sp) {
      sharedPreferences = sp;
      currentBalance = sharedPreferences.getDouble(balanceKey);
      if(currentBalance == null) {
        currentBalance = 0.0;
        saveCurrentBalance();
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () => showDialogOnFirstLoad(context));
    Future.delayed(Duration.zero, () => saveCurrentBalance());
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        textTheme: Theme.of(context).textTheme.apply(),
        iconTheme: IconThemeData(
          color: Color(0xff13C4A3),
        ),
        title: Text('Transaction Tracker'),
        actions: <Widget>[
          //ADD TO TOTAL
          new IconButton(
              icon: new Icon(Icons.add),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                          backgroundColor: Color(0xff32322C),
                          title: new Text("Add Transaction", textAlign: TextAlign.center),
                          content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget> [
                                Column(
                                  
                                  children: <Widget>[
                                    TextFormField(
                                      decoration: InputDecoration(
                                          labelText: "Transaction Name",
                                          labelStyle: TextStyle(color : Color(0xff13C4A3),),
                                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color : Color(0xff13C4A3))),
                                      ),
                                      controller: nameController,
                                      style: new TextStyle(color : Color(0xff13C4A3),)
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(10.0),
                                    ),
                                    TextFormField(
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                          labelText: "Total",
                                          labelStyle: TextStyle(color : Color(0xff13C4A3),),
                                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color : Color(0xff13C4A3))),
                                      ),
                                      controller: totalController,
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.all(10.0),
                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      RaisedButton(
                                          onPressed: () {
                                              _selectDate();
                                              setState(() {});
                                          } ,
                                          child: Text("${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
                                          color: Colors.white30,
                                          textColor: Color(0xff13C4A3),
                                      )
                                    ]

                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget> [
                                      FlatButton(
                                          textColor: Color(0xff13C4A3),
                                          child: Text("Cancel"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            nameController.clear();
                                            totalController.clear();
                                          }
                                      ),
                                      FlatButton(
                                          textColor: Color(0xff13C4A3),
                                          child: Text("Add"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            _submit(nameController.text, totalController.text, "${selectedDate.day}/${selectedDate.month}", "+");
                                            setState(() {});
                                            currentBalance += double.parse(totalController.text);
                                            nameController.clear();
                                            totalController.clear();
                                            selectedDate = DateTime.now();
                                            saveCurrentBalance();
                                          }
                                      )
                                    ]
                                )
                              ]
                          )
                      );

                    }
                );
              }
          ),
          //SUBTRACT FROM TOTAL
          new IconButton(
            icon: Icon(Icons.remove),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                          title: new Text("Add Transaction", textAlign: TextAlign.center),
                          content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget> [
                                Column(
                                  children: <Widget>[
                                    TextFormField(
                                      decoration: InputDecoration(
                                          labelText: "Transaction Name",
                                          labelStyle: TextStyle(color : Color(0xff13C4A3),),
                                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color : Color(0xff13C4A3))),
                                      ),
                                      controller: nameController,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(10.0),
                                    ),
                                    TextFormField(
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                          labelText: "Total",
                                          labelStyle: TextStyle(color : Color(0xff13C4A3),),
                                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color : Color(0xff13C4A3))),
                                      ),
                                      controller: totalController,
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.all(10.0),
                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      RaisedButton(
                                        onPressed: () {
                                          _selectDate();
                                          setState(() {});
                                        } ,
                                        child: Text("${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
                                        color: Colors.white30,
                                        textColor: Color(0xff13C4A3),
                                      )
                                    ]

                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget> [
                                      FlatButton(
                                          textColor: Color(0xff13C4A3),
                                          child: Text("Cancel"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            nameController.clear();
                                            totalController.clear();
                                          }
                                      ),
                                      FlatButton(
                                          textColor: Color(0xff13C4A3),
                                          child: Text("Add"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            _submit(nameController.text, totalController.text, "${selectedDate.day}/${selectedDate.month}", "-");
                                            setState(() {});
                                            currentBalance -= double.parse(totalController.text);
                                            nameController.clear();
                                            totalController.clear();
                                            selectedDate = DateTime.now();
                                            saveCurrentBalance();
                                          }
                                      )
                                    ]
                                )
                              ]
                          )
                      );
                    }
                );
              }
          ),
        ],
        elevation: 0.0,
        backgroundColor: Color(0xff32322C),

      ),
      body: Center(
        child: Column(

          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(40.0),
                child: Center (
                  child: new Text('\$$currentBalance',
                      textAlign: TextAlign.center,
                      style: new TextStyle(fontSize: 50.0)
                  ),
                ),
              ), //Current Balance Text
            Padding(
              padding: EdgeInsets.only(bottom: 5.0),
              child: Row(children: <Widget> [
                Expanded(
                  child: new Container(
                      margin: const EdgeInsets.only(left: 10.0, right: 20.0),
                      child: Divider(
                        color: Color(0xff13C4A3),
                        height: 50.0,
                      )
                  ),
                ),
                Text("Transactions"),
                Expanded(
                    child: new Container(
                        margin: const EdgeInsets.only(left: 20.0, right: 10.0),
                        child: Divider(
                          color: Color(0xff13C4A3),
                          height: 50.0,
                        )
                    )
                )
              ]
              ),
            ), //Transactions Line Seperators
            Expanded(
              child: new FutureBuilder<List<MoneyTransaction>>(
                future: fetchTransactionsFromDatabase(),
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
                              ),
                              color: Colors.white30,
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
            ),//Builds Transaction List View
          ],
        )
      )
    );
  }

  void _submit(String name, String total, String date, String type) {
    var transaction = MoneyTransaction(name, total, date, type);
    var dbHelper = DBHelper();
    dbHelper.saveTransaction(transaction);
    _showSnackBar("Transaction Added!");
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text(text)));
  }

  Future<List<MoneyTransaction>> fetchTransactionsFromDatabase() async {
    var dbHelper = DBHelper();
    Future<List<MoneyTransaction>> transactions = dbHelper.getTransaction();
    return transactions;
  }

  showDialogOnFirstLoad(BuildContext context) async {
    //SharedPreferences preferences = await SharedPreferences.getInstance();
    bool isFirstLoaded = sharedPreferences.getBool(keyIsFirstLoaded);
    if(isFirstLoaded == null) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: new Text("Welcome!"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Text('Please enter your current account total'),
                    new TextFormField(
                      keyboardType: TextInputType.number,
                      controller: balanceController,
                    ),
                    new FlatButton(
                      child: Text('Get Started!'),
                      onPressed: () {
                        sharedPreferences.setDouble(balanceKey, double.parse(balanceController.text));
                        Navigator.of(context).pop();
                        sharedPreferences.setBool(keyIsFirstLoaded, true);
                        setState(() {
                          currentBalance = double.parse(balanceController.text);
                        });
                      }
                    )
                  ],
                )
            );
          }
      );

    }
  }

  saveCurrentBalance() async {
    //SharedPreferences preferences = await SharedPreferences.getInstance();
    sharedPreferences.setDouble(balanceKey, currentBalance);
  }

  getCurrentBalance() async {
    //SharedPreferences preferences = await SharedPreferences.getInstance();
    currentBalance = sharedPreferences.getDouble(balanceKey);
  }


}


