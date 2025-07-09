import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';

class AuthHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final tokens = await TokenService.loadTokens();
    if (tokens == null) return _inner.send(request);

    request.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    var response = await _inner.send(request);

    if (response.statusCode == 403) {
      final newAccessToken = await _refreshAccessToken(tokens.refreshToken);
      if (newAccessToken != null) {
        await TokenService.updateAccessToken(newAccessToken);
        request.headers['Authorization'] = 'Bearer $newAccessToken';
        response = await _inner.send(request);
      }
    }

    return response;
  }

  Future<String?> _refreshAccessToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse('http://52.77.118.48:8080/auth/refresh-token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['accessToken'];
    }

    return null;
  }
}
