import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  print('Send request');
  final response = await http.get(
    Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
  );

  print("Response received");
  final json = jsonDecode(response.body);
  print(json['title']);
}