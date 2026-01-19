import 'package:http/http.dart' as http;
import '../lib/features/transactions/data/datasources/transaction_remote_datasource.dart';
import '../lib/features/transactions/domain/entities/transaction.dart';


Future<void> main() async {
  final datasource = TransactionRemoteDataSource(http.Client());

  print("Get");
  final list = await datasource.getTransactions();
  list.forEach(print);

  print("/nPost");

  await datasource.createTransaction(Transaction(
    id: "123",
    amount: 250.0,
    category: "Test",
  ));
  print("Done");
  

}