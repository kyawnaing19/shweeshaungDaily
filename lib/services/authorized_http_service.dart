import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';
import 'api_service.dart';

class AuthorizedHttpService {
  static Future<http.Response?> sendAuthorizedRequest(
    Uri url, {
    required String method,
    Map<String, String>? headers,
    dynamic body,
  }) async {
    var tokens = await TokenService.loadTokens();
    if (tokens == null) return null;

    headers ??= {};
    headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    headers['Content-Type'] = 'application/json';

    http.Response response = await _sendRequest(method, url, headers, body);
    print(tokens.accessToken);
    if (response.statusCode == 200) return response;

    // Try refresh on 401 or 403
    if (response.statusCode == 401 || response.statusCode == 403) {
      final refreshed = await ApiService.refreshAccessToken(tokens.refreshToken);

      if (refreshed != null &&
          refreshed['accessToken'] != null &&
          refreshed['refreshToken'] != null) {
        await TokenService.saveTokens(
          refreshed['accessToken'],
          refreshed['refreshToken'],
        );

        // Retry original request with new token
        headers['Authorization'] = 'Bearer ${refreshed['accessToken']}';

        response = await _sendRequest(method, url, headers, body);

        if (response.statusCode == 200) return response;

        // Second failure: clear tokens
        await TokenService.clearTokens();
        return null;
      } else {
        await TokenService.clearTokens();
        return null;
      }
    }

    return response;
  }

  static Future<http.Response> _sendRequest(
    String method,
    Uri url,
    Map<String, String> headers,
    dynamic body,
  ) async {
    switch (method.toUpperCase()) {
      case 'GET':
        return await http.get(url, headers: headers);
      case 'POST':
        return await http.post(url, headers: headers, body: jsonEncode(body));
      case 'PUT':
        return await http.put(url, headers: headers, body: jsonEncode(body));
      case 'DELETE':
        return await http.delete(url, headers: headers);
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
  }
}
