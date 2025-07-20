import 'package:flutter/material.dart';
import 'package:shweeshaungdaily/models/user_reg_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';

class AuthViewModel extends ChangeNotifier {
  bool isLoading = false;
  bool isTeacher = false;
  String? accessToken;
  String? refreshToken;

  Future<bool> login(
    String email,
    String password, {
    bool stayLoggedIn = true,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.login(
        UserModel(email: email, password: password, stayLoggedIn: stayLoggedIn),
      );
      
      if (result != null) {
        isTeacher = await ApiService.isTeacher(email);
        accessToken = result['accessToken'];
        refreshToken = result['refreshToken'];

        if (accessToken != null && refreshToken != null) {
          await TokenService.saveTokens(accessToken!, refreshToken!);
          await TokenService.setRole(isTeacher ? 'teacher' : 'user');
          if(isTeacher){
            final bool =await ApiService.isAdmin(email);
            if(bool){
              await TokenService.setAsAdmin(true);
            } else {
              await TokenService.setAsAdmin(false);
            }
          }

          await TokenService.setUserName(await ApiService.getUserName());
        //    final startupViewModel = Provider.of<StartupViewModel>(listen: false);
        // startupViewModel.setIsTeacher(isTeacher);
          print('✅ Login successful. Tokens saved.');
          return true;
        } else {
          print('❌ Login response missing tokens');
          return false;
        }
      } else {
        print('❌ Login failed. Null result.');
        return false;
      }
    } catch (e) {
      print('❌ Login exception: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(UserRegistrationData user) async {
    isLoading = true;
    notifyListeners();
    bool success;
    try{
       success = await ApiService.register(user);
    }catch (e){
      throw Exception(e);
    }

    isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> registerEmail(String email, String nickName) async {
    isLoading = true;
    notifyListeners();

    final success = await ApiService.registerEmail(
      UserModel(email: email, nickName: nickName),
    );

    isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> refreshAccessToken() async {
    if (refreshToken == null) return false;

    final tokens = await ApiService.refreshAccessToken(refreshToken!);

    if (tokens != null &&
        tokens['accessToken'] != null &&
        tokens['refreshToken'] != null) {
      accessToken = tokens['accessToken'];
      refreshToken = tokens['refreshToken'];

      await TokenService.saveTokens(accessToken!, refreshToken!);
      print('🔁 Access token refreshed successfully');
      notifyListeners();
      return true;
    } else {
      print('❌ Failed to refresh access token');
      return false;
    }
  }
}
