import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shweeshaungdaily/models/user_reg_model.dart';
import 'package:shweeshaungdaily/services/authorized_http_service.dart';
import 'package:shweeshaungdaily/services/token_service.dart';
import '../models/user_model.dart';

class ApiService {
  static const String base = 'https://shweeshaung.mooo.com';
  static const baseUrl = '$base/api/auth';
  static const feedBaseUrl = '$base/feeds';
  static const secbaseUrl = '$base/admin/schedules';
  static const subbaseUrl = '$base/admin/subjects';

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

  static Future<String> getUserName() async {
    try {
      final url = Uri.parse('$baseUrl/getUsername');
      final response = await AuthorizedHttpService.sendAuthorizedRequest(
        url,
        method: 'GET',
      );

      if (response!.statusCode == 200) {
        return response.body;
      }

      return '';
    } catch (e) {
      print('❌ Comment failed: $e');
      return '';
    }
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

  static Future<bool> comment(int feedId, String text) async {
    try {
      final url = Uri.parse('$feedBaseUrl/$feedId/comments?text=$text');
      final response = await AuthorizedHttpService.sendAuthorizedRequest(
        url,
        method: 'POST',
      );

      if (response?.statusCode == 200) {
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Comment failed: $e');
      return false;
    }
  }

  static Future<bool> like(int feedId) async {
    try {
      final url = Uri.parse('$base/api/feeds/$feedId/like');
      final response = await AuthorizedHttpService.sendAuthorizedRequest(
        url,
        method: 'POST',
      );

      if (response?.statusCode == 200) {
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> unlike(int feedId) async {
    try {
      final url = Uri.parse('$base/api/feeds/$feedId/like');
      final response = await AuthorizedHttpService.sendAuthorizedRequest(
        url,
        method: 'DELETE',
      );

      if (response?.statusCode == 200) {
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>?> getComments(int feedId) async {
    final url = Uri.parse('$feedBaseUrl/$feedId/comments');
    final response = await AuthorizedHttpService.sendAuthorizedRequest(
      url,
      method: 'GET',
    );

    if (response != null && response.statusCode == 200) {
      final body = response.body;
      final decoded = jsonDecode(body);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      } else {
        print('Unexpected response format: $decoded');
      }
    } else {
      print('Failed to fetch comments. Status code: ${response?.statusCode}');
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>?> getFeed() async {
    final url = Uri.parse(feedBaseUrl);

    try {
      final response = await AuthorizedHttpService.sendAuthorizedRequest(
        url,
        method: 'GET',
      );

      if (response != null && response.statusCode == 200) {
        final body = response.body;
        final decoded = jsonDecode(body);

        if (decoded is List) {
          return decoded.cast<Map<String, dynamic>>();
        } else {
          print('Unexpected response format: $decoded');
        }
      } else {
        print('Failed to fetch feed. Status code: ${response?.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching feed: $e');
    }

    return null;
  }


  static Future<void> uploadAudio({
    required XFile? voice,
    required String audience,
    required String title
  }) async {
    Future<http.Response> sendMultipart(String accessToken) async {
      final url = Uri.parse("$feedBaseUrl/audio");
      var request =
          http.MultipartRequest('POST', url)
            ..fields['title'] = title
            ..fields['audience'] = audience // Optional field
            ..headers['Authorization'] = 'Bearer $accessToken';

      if (voice != null) {
        final bytes = await voice.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes('voice', bytes, filename: voice.name),
        );
      }

      final streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);
    }

    var tokens = await TokenService.loadTokens();
    if (tokens == null) throw Exception('Not authenticated');

    var response = await sendMultipart(tokens.accessToken);

    if (response.statusCode == 401 || response.statusCode == 403) {
      // Try to refresh token
      final refreshed = await ApiService.refreshAccessToken(
        tokens.refreshToken,
      );
      if (refreshed != null &&
          refreshed['accessToken'] != null &&
          refreshed['refreshToken'] != null) {
        await TokenService.saveTokens(
          refreshed['accessToken'],
          refreshed['refreshToken'],
        );
        response = await sendMultipart(refreshed['accessToken']);
      } else {
        await TokenService.clearTokens();
        throw Exception('Session expired. Please log in again.');
      }
    }

    if (response.statusCode != 200) {
      throw Exception('Failed to upload feed: [${response.body}');
    }
  }


  static Future<void> uploadFeed({
    required String text,
    required String audience,
    XFile? photo,
  }) async {
    Future<http.Response> sendMultipart(String accessToken) async {
      final url = Uri.parse(feedBaseUrl);
      var request =
          http.MultipartRequest('POST', url)
            ..fields['text'] = text
            ..fields['audience'] = audience
            ..headers['Authorization'] = 'Bearer $accessToken';

      if (photo != null) {
        final bytes = await photo.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes('photo', bytes, filename: photo.name),
        );
      }

      final streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);
    }

    var tokens = await TokenService.loadTokens();
    if (tokens == null) throw Exception('Not authenticated');

    var response = await sendMultipart(tokens.accessToken);

    if (response.statusCode == 401 || response.statusCode == 403) {
      // Try to refresh token
      final refreshed = await ApiService.refreshAccessToken(
        tokens.refreshToken,
      );
      if (refreshed != null &&
          refreshed['accessToken'] != null &&
          refreshed['refreshToken'] != null) {
        await TokenService.saveTokens(
          refreshed['accessToken'],
          refreshed['refreshToken'],
        );
        response = await sendMultipart(refreshed['accessToken']);
      } else {
        await TokenService.clearTokens();
        throw Exception('Session expired. Please log in again.');
      }
    }

    if (response.statusCode != 200) {
      throw Exception('Failed to upload feed: [${response.body}');
    }
  }

  //schedule data to fetch
  static Future<Map<String, Map<int, dynamic>>> fetchTimetable() async {
    final uri = Uri.parse('$secbaseUrl/timetableForAll');

    final res = await AuthorizedHttpService.sendAuthorizedRequest(
      uri,
      method: 'GET',
    );

    if (res != null && res.statusCode == 200) {
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

  static Future<List<String>> getSubjectsForNote() async {
    final uri = Uri.parse('$subbaseUrl/list');
    final response = await AuthorizedHttpService.sendAuthorizedRequest(
      uri,
      method: 'GET',
    );

    if (response != null && response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return List<String>.from(data);
    } else {
      throw Exception('Failed to load subjects for note');
    }
  }


  static Future<List<dynamic>> getAudios() async {
    final uri = Uri.parse('$feedBaseUrl/audio');
    try{
    final response = await AuthorizedHttpService.sendAuthorizedRequest(
      uri,
      method: 'GET',
    );

    if (response != null && response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      return [];
    }
  
  } catch (e) {
      throw Exception('Error fetching audio files: $e');
    }
  }
  
}
