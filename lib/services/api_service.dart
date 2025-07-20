import 'dart:convert';
import 'dart:io';

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
  static const storyUrl = '$base/story';
  static const mailbaseUrl = '$base/mailbox';
  static const userbaseUrl = '$base/user';

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

  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      final url = Uri.parse('$baseUrl/profile');
      final response = await AuthorizedHttpService.sendAuthorizedRequest(
        url,
        method: 'GET',
      );

      if (response!.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      print('❌ Comment failed: $e');
      return {};
    }
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

  static Future<bool> logout() async {
    final tokens = await TokenService.loadTokens();
    try {
      
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': tokens!.refreshToken}),
      );

      await TokenService.clearTokens();

      return true;
    } catch (e) {
      return false;
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

   static Future<List<Map<String, dynamic>>?> getTeacherProfileFeed() async {
    final url = Uri.parse('$feedBaseUrl/teacherprofilefeed');

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
    if (response.statusCode == 200) {      // Assuming the backend returns true/false as JSON
      return response.body == 'true' || response.body == '"true"';
    } else {
      throw Exception('Failed to verifyTeacher email');
    }
  }

  static Future<bool> isAdmin(String email) async {
    final uri = Uri.parse('$baseUrl/isAdmin?email=$email');
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


  static Future<List<dynamic>> getAudiosByEmailForTeacher() async {
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


  static Future<List<dynamic>> getAudiosOfRector() async {
    final uri = Uri.parse('$feedBaseUrl/audio/rector');
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

  static Future<List<dynamic>> getAudiosForStudent() async {
    final uri = Uri.parse('$feedBaseUrl/audio/student');
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


  
  static Future<Map<String, dynamic>> uploadStory({
  required String caption,
  required XFile? photo,
}) async {
  Future<http.Response> sendMultipart(String accessToken) async {
    final url = Uri.parse(storyUrl);
    var request = http.MultipartRequest('POST', url)
      ..fields['caption'] = caption
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
    final refreshed = await ApiService.refreshAccessToken(tokens.refreshToken);
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
    final body = jsonDecode(response.body);
    throw Exception('Failed to upload story: ${body['message']}');
  }

  // Return entire parsed JSON object
  return jsonDecode(response.body) as Map<String, dynamic>;
}



  static Future<List<dynamic>> getStory() async {
    final uri = Uri.parse(storyUrl);
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




  static Future<List<Map<String, dynamic>>> getAllMails() async {
  final url = Uri.parse('$mailbaseUrl/all');

  final response = await AuthorizedHttpService.sendAuthorizedRequest(
    url,
    method: 'GET',
  );

  if (response == null) {
    throw Exception('No response from server');
  }

  if (response.statusCode == 200) {
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.cast<Map<String, dynamic>>();
  }

  if (response.statusCode == 403) {
    try {
      final Map<String, dynamic> errorJson = jsonDecode(response.body);
      throw Exception(errorJson['message'] ?? 'Forbidden access');
    } catch (_) {
      throw Exception('Forbidden access');
    }
  }
    Map<String, dynamic> data = jsonDecode(response.body);

  throw Exception(data['message']);
}



static Future<String?> sendMail({
  required String text,
  required bool anonymous,
  required int recipientId,
}) async {
  final url = Uri.parse(mailbaseUrl);

  final Map<String, dynamic> requestBody = {
    'text': text,
    'anonymous': anonymous,
    'recipientId': recipientId,
  };

  final response = await AuthorizedHttpService.sendAuthorizedRequest(
    url,
    method: 'POST',
    body: requestBody, // ✅ Don't jsonEncode here!
    headers: {
      'Content-Type': 'application/json',
    },
  );

  if (response == null) return 'No response from server';
  if (response.statusCode == 200) return null;

  if (response.statusCode == 403) {
    try {
      final Map<String, dynamic> errorJson = jsonDecode(response.body);
      return errorJson['message'] ?? 'Forbidden access';
    } catch (_) {
      return 'Forbidden access';
    }
  }

  try {
    final body = jsonDecode(response.body);
    return 'Failed: ${body['message'] ?? response.body}';
  } catch (e) {
    return 'Failed: ${response.body}';
  }
}




static Future<List<Map<String, dynamic>>?> getSentMails() async {
  final url = Uri.parse('$mailbaseUrl/sent');

  final response = await AuthorizedHttpService.sendAuthorizedRequest(
    url,
    method: 'GET',
  );

  print('Response status code: ${response?.body}');
  if (response != null && response.statusCode == 200) {
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.cast<Map<String, dynamic>>();
  }

  return null; // Handle token expiry, error, etc.
}


static Future<List<Map<String, dynamic>>> searchUserNames(String query) async {
  final url = Uri.parse('$userbaseUrl/search/usernames?q=$query');

  final response = await AuthorizedHttpService.sendAuthorizedRequest(
    url,
    method: 'GET',
  );

  if (response != null && response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);

    // Convert each item to Map<String, dynamic>
    return data.map((item) => item as Map<String, dynamic>).toList();
  } else {
    throw Exception('Failed to load search results');
  }
  }

  static Future<bool> updateProfile(String nickName,String bio)async {
  final url = Uri.parse(userbaseUrl);
  final Map<String, dynamic> requestBody = {
    'nickName': nickName,
    'bio': bio
  };
   final response = await AuthorizedHttpService.sendAuthorizedRequest(
    url,
    method: 'PUT',
    body: requestBody, // ✅ Don't jsonEncode here!
    headers: {
      'Content-Type': 'application/json',
    },
  );
  if(response != null && response.statusCode==200) {
    return true;
  }
  return false;
}

 static Future<bool> resetPassword(String email) async {
  final url = Uri.parse('$baseUrl/forgot-password?email=$email');

  final response = await http.post(url); // No headers, no body

  if (response.statusCode == 200) {
    print('Success: ${response.body}');
    return true;
  }

  print('Error: ${response.statusCode} - ${response.body}');
  return false;
}



static Future<bool> updateProfilePicture({
  required File? photo, // Use File instead of XFile
}) async {
  Future<http.Response> sendMultipart(String accessToken) async {
    final url = Uri.parse('$userbaseUrl/profile');
    var request = http.MultipartRequest('PUT', url)
      ..headers['Authorization'] = 'Bearer $accessToken';

    if (photo != null) {
      final bytes = await photo.readAsBytes();
      final fileName = photo.path.split('/').last;

      request.files.add(
        http.MultipartFile.fromBytes('photo', bytes, filename: fileName),
      );
    }

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  var tokens = await TokenService.loadTokens();
  if (tokens == null) throw Exception('Not authenticated');

  var response = await sendMultipart(tokens.accessToken);
  print(response.body);
  if (response.statusCode == 401 || response.statusCode == 403) {
    final refreshed = await ApiService.refreshAccessToken(tokens.refreshToken);
    if (refreshed != null &&
        refreshed['accessToken'] != null &&
        refreshed['refreshToken'] != null) {
      await TokenService.saveTokens(
        refreshed['accessToken'],
        refreshed['refreshToken'],
      );
      response = await sendMultipart(refreshed['accessToken']);
      print(response.body);
    } else {
      await TokenService.clearTokens();
      throw Exception('Session expired. Please log in again.');
    }
  }

  return response.statusCode == 200;
}


static Future<bool> deleteProfile()async {
  final url = Uri.parse('$userbaseUrl/profile');
   final response = await AuthorizedHttpService.sendAuthorizedRequest(
    url,
    method: 'DELETE',
  );
  if(response==null){
    return false;
  }
  if(response.statusCode==200) {
    return true;
  }
  return false;
}


static Future<bool> deleteStory(String purl)async {
  final url = Uri.parse('$storyUrl?url=$purl');
   final response = await AuthorizedHttpService.sendAuthorizedRequest(
    url,
    method: 'DELETE',
  );
    if(response==null){
    return false;
  }
  if(response.statusCode==200) {
    return true;
  }
  return false;
}


static Future<bool> deleteAudio(String purl)async {
  final url = Uri.parse('$feedBaseUrl/audio?url=$purl');
   final response = await AuthorizedHttpService.sendAuthorizedRequest(
    url,
    method: 'DELETE',
  );
  if(response?.statusCode==200) {
    return true;
  }
  return false;
}

static Future<bool> deleteFeedbyId(String id)async {
  final url = Uri.parse('$feedBaseUrl/delete?id=$id');
   final response = await AuthorizedHttpService.sendAuthorizedRequest(
    url,
    method: 'DELETE',
  );
  print(response?.body);
  if(response?.statusCode==200) {
    return true;
  }
  return false;
}


}
  

