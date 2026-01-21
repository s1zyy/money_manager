import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../domain/entities/transaction.dart';
import '/core/error/exceptions.dart';

class TransactionRemoteDataSource {
  final http.Client client;
  final String baseUrl = "https://jsonplaceholder.typicode.com/posts";

  TransactionRemoteDataSource(this.client);





  Future<List<Transaction>> getTransactions() async {

    try{
    final response = await client.get(
      Uri.parse(baseUrl),
    );

    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((json) {
        return Transaction.fromJson(json);
    }).toList();
    }
    if(response.statusCode == 401){
      throw UnauthorizedException();
    }
    throw ServerException(
      'Server error: ${response.statusCode}',
    );
    } on SocketException {
      throw NetworkException();
    }
  }





  Future<void> createTransaction(Transaction tx) async {
    final response = await client.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(tx.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception("Create failed");
    }
  }
}