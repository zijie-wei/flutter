import '../../../shared/models/user_model.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

enum AuthMode {
  login,
  register,
  resetPassword,
}

class AuthState {
  final AuthStatus status;
  final AuthMode mode;
  final UserModel? user;
  final String? errorMessage;
  final bool isLoading;
  final bool isCodeSent;
  final int countdown;

  AuthState({
    this.status = AuthStatus.initial,
    this.mode = AuthMode.login,
    this.user,
    this.errorMessage,
    this.isLoading = false,
    this.isCodeSent = false,
    this.countdown = 0,
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthMode? mode,
    UserModel? user,
    String? errorMessage,
    bool? isLoading,
    bool? isCodeSent,
    int? countdown,
  }) {
    return AuthState(
      status: status ?? this.status,
      mode: mode ?? this.mode,
      user: user ?? this.user,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
      isCodeSent: isCodeSent ?? this.isCodeSent,
      countdown: countdown ?? this.countdown,
    );
  }
}
