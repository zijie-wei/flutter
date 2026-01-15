import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/validation_utils.dart';
import '../domain/auth_state.dart';
import '../../../shared/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  Timer? _countdownTimer;

  AuthState _state = AuthState();
  AuthState get state => _state;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(StorageKeys.isLoggedIn) ?? false;

    if (isLoggedIn) {
      final token = await _secureStorage.read(key: StorageKeys.accessToken);
      if (token != null) {
        final userInfo = prefs.getString(StorageKeys.userInfo);
        if (userInfo != null) {
          final user = UserModel.fromJson(
            Map<String, dynamic>.from(
              await compute(_parseUserInfo, userInfo),
            ),
          );
          _state = _state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
          );
          notifyListeners();
        }
      }
    }
  }

  static Map<String, dynamic> _parseUserInfo(String userInfo) {
    return Map<String, dynamic>.from(
      userInfo.split(',').fold<Map<String, dynamic>>(
        {},
        (map, item) {
          final parts = item.split(':');
          if (parts.length == 2) {
            map[parts[0].trim()] = parts[1].trim();
          }
          return map;
        },
      ),
    );
  }

  void setMode(AuthMode mode) {
    _state = _state.copyWith(mode: mode);
    notifyListeners();
  }

  Future<void> sendVerificationCode(String email) async {
    if (!ValidationUtils.isValidEmail(email)) {
      _state = _state.copyWith(
        errorMessage: '请输入有效的邮箱地址',
      );
      notifyListeners();
      return;
    }

    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _state = _state.copyWith(
      isLoading: false,
      isCodeSent: true,
      countdown: AppConstants.verificationCodeCountdown,
    );
    notifyListeners();

    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_state.countdown > 0) {
        _state = _state.copyWith(countdown: _state.countdown - 1);
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final emailError = ValidationUtils.validateEmail(email);
    final passwordError = ValidationUtils.validatePassword(password);

    if (emailError != null || passwordError != null) {
      _state = _state.copyWith(
        errorMessage: emailError ?? passwordError,
      );
      notifyListeners();
      return;
    }

    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    final mockToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
    final mockUser = UserModel(
      id: '1',
      email: email,
      username: email.split('@')[0],
      avatar: null,
      createdAt: DateTime.now(),
    );

    await _secureStorage.write(key: StorageKeys.accessToken, value: mockToken);
    await _secureStorage.write(
      key: StorageKeys.refreshToken,
      value: 'mock_refresh_token',
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.isLoggedIn, true);
    await prefs.setString(StorageKeys.userInfo, mockUser.toString());

    _state = _state.copyWith(
      status: AuthStatus.authenticated,
      user: mockUser,
      isLoading: false,
    );
    notifyListeners();
  }

  Future<void> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String verificationCode,
  }) async {
    final emailError = ValidationUtils.validateEmail(email);
    final passwordError = ValidationUtils.validatePassword(password);
    final confirmError = ValidationUtils.validateConfirmPassword(
      confirmPassword,
      password,
    );
    final codeError = ValidationUtils.validateVerificationCode(verificationCode);

    if (emailError != null ||
        passwordError != null ||
        confirmError != null ||
        codeError != null) {
      _state = _state.copyWith(
        errorMessage: emailError ?? passwordError ?? confirmError ?? codeError,
      );
      notifyListeners();
      return;
    }

    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    final mockToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
    final mockUser = UserModel(
      id: '1',
      email: email,
      username: email.split('@')[0],
      avatar: null,
      createdAt: DateTime.now(),
    );

    await _secureStorage.write(key: StorageKeys.accessToken, value: mockToken);
    await _secureStorage.write(
      key: StorageKeys.refreshToken,
      value: 'mock_refresh_token',
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.isLoggedIn, true);
    await prefs.setString(StorageKeys.userInfo, mockUser.toString());

    _state = _state.copyWith(
      status: AuthStatus.authenticated,
      user: mockUser,
      isLoading: false,
    );
    notifyListeners();
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
    required String verificationCode,
  }) async {
    final emailError = ValidationUtils.validateEmail(email);
    final passwordError = ValidationUtils.validatePassword(newPassword);
    final codeError = ValidationUtils.validateVerificationCode(verificationCode);

    if (emailError != null || passwordError != null || codeError != null) {
      _state = _state.copyWith(
        errorMessage: emailError ?? passwordError ?? codeError,
      );
      notifyListeners();
      return;
    }

    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      await _dioClient.post(
        ApiEndpoints.resetPassword,
        data: {
          'email': email,
          'new_password': ValidationUtils.hashPassword(newPassword),
          'verification_code': verificationCode,
        },
      );

      _state = _state.copyWith(
        isLoading: false,
        mode: AuthMode.login,
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: '重置密码失败，请重试',
      );
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      await _dioClient.post(ApiEndpoints.logout);

      await _secureStorage.delete(key: StorageKeys.accessToken);
      await _secureStorage.delete(key: StorageKeys.refreshToken);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(StorageKeys.isLoggedIn, false);
      await prefs.remove(StorageKeys.userInfo);

      _state = AuthState();
      notifyListeners();
    } catch (e) {
      await _secureStorage.delete(key: StorageKeys.accessToken);
      await _secureStorage.delete(key: StorageKeys.refreshToken);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(StorageKeys.isLoggedIn, false);
      await prefs.remove(StorageKeys.userInfo);

      _state = AuthState();
      notifyListeners();
    }
  }

  void clearError() {
    _state = _state.copyWith(errorMessage: null);
    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
