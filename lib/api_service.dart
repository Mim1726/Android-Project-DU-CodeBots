import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<dynamic>> fetchRecipes(String cuisine, String search) async {
  final response = await http.get(Uri.parse(
    'http://<192.168.226.80>:8004/recipes?cuisine=$cuisine&search=$search',
  ));

  if (response.statusCode == 200) {
    return json.decode(response.body)['recipes'];
  } else {
    throw Exception('Failed to load recipes');
  }
}
