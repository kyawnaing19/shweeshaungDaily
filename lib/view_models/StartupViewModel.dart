import 'package:flutter/material.dart';
import 'package:shweeshaungdaily/services/api_service.dart';
import 'package:shweeshaungdaily/services/token_service.dart';

class StartupViewModel extends ChangeNotifier {
  bool? _isLoggedIn;

  bool? get isLoggedIn => _isLoggedIn;

  Future<void> initializeApp() async {
    final tokens = await TokenService.loadTokens();
    print("🔄 Loaded tokens: ${tokens?.accessToken}, ${tokens?.refreshToken}");

    if (tokens != null) {
      try {
        print("🔄 Attempting to refresh access token...");
        final response = await ApiService.refreshAccessToken(
          tokens.refreshToken,
        );

        if (response != null &&
            response['accessToken'] != null &&
            response['refreshToken'] != null) {
          await TokenService.saveTokens(
            response['accessToken'],
            response['refreshToken'],
          );
        } else {
          print("❌ Token refresh failed or response invalid");
          // Optionally handle refresh failure, but still allow access if tokens exist
        }
        _isLoggedIn = true; // Allow access if tokens exist, even if refresh fails
      } catch (e) {
        print("❌ Exception in refresh logic: $e");
        _isLoggedIn = true; // Allow access if tokens exist, even if offline/exception
      }
    } else {
      print("❌ No tokens found in SharedPreferences");
      _isLoggedIn = false;
    }

    notifyListeners();
  }
}
