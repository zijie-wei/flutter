import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/auth_provider.dart';
import '../domain/auth_state.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../core/utils/network_utils.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _verificationCodeController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    switch (authProvider.state.mode) {
      case AuthMode.login:
        await authProvider.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        break;
      case AuthMode.register:
        await authProvider.register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
          verificationCode: _verificationCodeController.text,
        );
        break;
      case AuthMode.resetPassword:
        await authProvider.resetPassword(
          email: _emailController.text.trim(),
          newPassword: _passwordController.text,
          verificationCode: _verificationCodeController.text,
        );
        break;
    }

    if (mounted && authProvider.state.errorMessage != null) {
      NetworkUtils.showError(context, authProvider.state.errorMessage!);
      authProvider.clearError();
    }
  }

  Future<void> _handleSendCode() async {
    if (_emailController.text.isEmpty) {
      NetworkUtils.showError(context, '请输入邮箱地址');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    await authProvider.sendVerificationCode(_emailController.text.trim());

    if (mounted && authProvider.state.errorMessage != null) {
      NetworkUtils.showError(context, authProvider.state.errorMessage!);
      authProvider.clearError();
    } else if (mounted) {
      NetworkUtils.showSuccess(context, '验证码已发送');
    }
  }

  void _switchMode(AuthMode mode) {
    context.read<AuthProvider>().setMode(mode);
    _formKey.currentState?.reset();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _verificationCodeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    _buildLogo(),
                    const SizedBox(height: 40),
                    _buildTitle(authProvider.state.mode),
                    const SizedBox(height: 32),
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    if (authProvider.state.mode == AuthMode.register) ...[
                      const SizedBox(height: 16),
                      _buildConfirmPasswordField(),
                    ],
                    if (authProvider.state.mode != AuthMode.login) ...[
                      const SizedBox(height: 16),
                      _buildVerificationCodeField(authProvider),
                    ],
                    const SizedBox(height: 24),
                    _buildSubmitButton(authProvider),
                    const SizedBox(height: 16),
                    _buildModeSwitcher(authProvider.state.mode),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          Icons.photo_camera,
          size: 48,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildTitle(AuthMode mode) {
    String title;
    switch (mode) {
      case AuthMode.login:
        title = '登录';
        break;
      case AuthMode.register:
        title = '注册';
        break;
      case AuthMode.resetPassword:
        title = '重置密码';
        break;
    }

    return Text(
      title,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: '邮箱',
        prefixIcon: Icon(Icons.email),
        hintText: '请输入邮箱地址',
      ),
      validator: ValidationUtils.validateEmail,
    );
  }

  Widget _buildPasswordField() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return TextFormField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: authProvider.state.mode == AuthMode.resetPassword
                ? '新密码'
                : '密码',
            prefixIcon: const Icon(Icons.lock),
            hintText: '请输入密码',
          ),
          validator: ValidationUtils.validatePassword,
        );
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: true,
      decoration: const InputDecoration(
        labelText: '确认密码',
        prefixIcon: Icon(Icons.lock_outline),
        hintText: '请再次输入密码',
      ),
      validator: (value) => ValidationUtils.validateConfirmPassword(
        value,
        _passwordController.text,
      ),
    );
  }

  Widget _buildVerificationCodeField(AuthProvider authProvider) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _verificationCodeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(
              labelText: '验证码',
              prefixIcon: Icon(Icons.verified_user),
              hintText: '请输入验证码',
              counterText: '',
            ),
            validator: ValidationUtils.validateVerificationCode,
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 120,
          height: 56,
          child: ElevatedButton(
            onPressed: authProvider.state.countdown > 0
                ? null
                : _handleSendCode,
            child: Text(
              authProvider.state.countdown > 0
                  ? '${authProvider.state.countdown}秒'
                  : '发送验证码',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(AuthProvider authProvider) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: authProvider.state.isLoading ? null : _handleSubmit,
        child: authProvider.state.isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                authProvider.state.mode == AuthMode.login
                    ? '登录'
                    : authProvider.state.mode == AuthMode.register
                        ? '注册'
                        : '重置密码',
              ),
      ),
    );
  }

  Widget _buildModeSwitcher(AuthMode mode) {
    if (mode == AuthMode.resetPassword) {
      return TextButton(
        onPressed: () => _switchMode(AuthMode.login),
        child: const Text('返回登录'),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          mode == AuthMode.login ? '还没有账号？' : '已有账号？',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () => _switchMode(
            mode == AuthMode.login ? AuthMode.register : AuthMode.login,
          ),
          child: Text(
            mode == AuthMode.login ? '立即注册' : '立即登录',
          ),
        ),
      ],
    );
  }
}
