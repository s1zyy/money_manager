import 'dart:convert';
import 'dart:io';
import '../lib/session1.dart';

void main() {
  // 1. Read JSON string (could be null)
  String? input = stdin.readLineSync();
  
  // 2. Parse with fallback
  Map<String, dynamic> json = jsonDecode(input ?? '{"amount": null}');
  
  // 3. Create transaction
  Transaction t = Transaction()
    ..id = json['id']
    ..amount = json['amount'];
  
  // 4. Print amount or "MISSING"
  print(t.amount ?? 'MISSING');
}