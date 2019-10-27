import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:transactions/model/moneyTransaction.dart';

class DBHelper {
  static Database _db;

  Future<Database> get db async {
    if(_db != null) {
      return _db;
    }

    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory docDirectory = await getApplicationDocumentsDirectory();
    String path = join(docDirectory.path, "transactions.db");
    var transactionsDb = await openDatabase(path, version: 4, onCreate: _onCreate);
    return transactionsDb;
  }




  void _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE  MoneyTransactions('
            'id INTEGER PRIMARY KEY, '
            'name TEXT, '
            'total TEXT, '
            'date TEXT,'
            'type TEXT) '
    );
    print("Created table");
  }

  void saveTransaction(MoneyTransaction transaction) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      return await txn.rawInsert(
        'INSERT INTO MoneyTransactions(name, total, date, type) VALUES(' +
          '\'' +
          transaction.name +
          '\'' +
          ',' +
          '\''+
          transaction.total +
            '\'' +
            ',' +
            '\''+
            transaction.date +
            '\'' +
            ',' +
            '\'' +
            transaction.type +
            '\'' +
          ')'
      );
    });
  }

  Future<List<MoneyTransaction>> getTransaction() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM MoneyTransactions');
    List<MoneyTransaction> transactions = new List();
    for(int i = list.length -1; i >= 0; i--) {
      transactions.add(new MoneyTransaction(list[i]["name"], list[i]["total"], list[i]["date"], list[i]["type"]));
    }
    print(transactions.length);
    return transactions;
  }
}