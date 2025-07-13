import 'dart:convert';
import 'package:http/http.dart' as http;

class MiniAppConfig {
  final bool show;
  final String url;
  final String version;

  MiniAppConfig({
    required this.show,
    required this.url,
    required this.version,
  });

  factory MiniAppConfig.fromJson(Map<String, dynamic> json) {
    return MiniAppConfig(
      show: json['showMiniApp'] ?? false,
      url: json['miniAppUrl'] ?? '',
      version: json['version'] ?? '0.0.0',
    );
  }
}

Future<MiniAppConfig> fetchMiniAppConfig() async {
  const configUrl = 'https://raw.githubusercontent.com/amk-35/apiUrl/refs/heads/main/miniAppConfig';

  final response = await http.get(Uri.parse(configUrl));

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    return MiniAppConfig.fromJson(jsonData);
  } else {
    throw Exception("Failed to fetch config: ${response.statusCode}");
  }
}
