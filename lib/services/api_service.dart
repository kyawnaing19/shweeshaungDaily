import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shweeshaungdaily/models/user_reg_model.dart';
import 'package:shweeshaungdaily/services/authorized_http_service.dart';
import 'package:shweeshaungdaily/services/token_service.dart';
import '../models/user_model.dart';

class ApiService {
  static const baseUrl = 'http://192.168.3.109:8080/api/auth';
  static const secbaseUrl = 'http://192.168.3.109:8080/admin/schedules';

  static Future<Map<String, dynamic>?> login(UserModel user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  static Future<bool> register(UserRegistrationData user) async {
    print(jsonEncode(user.toJson()));
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );
    if (response.statusCode == 201) {
      return true;
    } else {
      print('Registration failed with status code: ${response.statusCode}');
      return false;
    }
  }

  static Future<bool> registerEmail(UserModel user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/registerEmail'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );
    return response.statusCode == 201;
  }

  static Future<void> logout() async {
    final tokens = await TokenService.loadTokens();
    try {
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': tokens!.refreshToken}),
      );
    } catch (e) {
      print('Logout failed: $e');
    }
  }

  static Future<Map<String, dynamic>?> refreshAccessToken(
    String refreshToken,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      print('Refresh token status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('Refresh token response: ${response.body}');
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getProtectedMessage() async {
    final url = Uri.parse('$baseUrl/protected-message');

    final response = await AuthorizedHttpService.sendAuthorizedRequest(
      url,
      method: 'GET',
    );

    if (response != null && response.statusCode == 200) {
      return response.body;
    }

    return null; // Token expired or user logged out
  }

  //schedule data to fetch
  static Future<Map<String, Map<int, dynamic>>> fetchTimetable({
    required String userClass,
    required String semester,
    required String major,
  }) async {
    final uri = Uri.parse(
      '$secbaseUrl/timetable?userClass=$userClass&semester=$semester&major=$major',
    );

    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      Map<String, Map<int, dynamic>> timetable = {};

      for (var item in data) {
        String day = item['dayOfWeek'];
        int period = item['periodNumber'];
        timetable.putIfAbsent(day, () => {});
        timetable[day]![period] = item;
      }

      return timetable;
    } else {
      throw Exception('Failed to load timetable');
    }
  }

  static Future<bool> verifyMail(String email) async {
    final uri = Uri.parse('$baseUrl/verify?email=$email');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      // Assuming the backend returns true/false as JSON
      return response.body == 'true' || response.body == '"true"';
    } else {
      throw Exception('Failed to verify email');
    }
  }

  static Future<bool> isTeacher(String email) async {
    final uri = Uri.parse('$baseUrl/isTeacher?email=$email');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      // Assuming the backend returns true/false as JSON
      return response.body == 'true' || response.body == '"true"';
    } else {
      throw Exception('Failed to verifyTeacher email');
    }
  }
}
