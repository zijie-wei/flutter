import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/recharge_models.dart';

enum RechargeStatus {
  initial,
  loading,
  success,
  failed,
  processing,
}

class RechargeState {
  final RechargeStatus status;
  final List<RechargePackage> packages;
  final List<RechargeRecord> records;
  final String? errorMessage;
  final RechargePackage? selectedPackage;
  final String? paymentId;
  final bool isPolling;

  RechargeState({
    this.status = RechargeStatus.initial,
    this.packages = const [],
    this.records = const [],
    this.errorMessage,
    this.selectedPackage,
    this.paymentId,
    this.isPolling = false,
  });

  RechargeState copyWith({
    RechargeStatus? status,
    List<RechargePackage>? packages,
    List<RechargeRecord>? records,
    String? errorMessage,
    RechargePackage? selectedPackage,
    String? paymentId,
    bool? isPolling,
  }) {
    return RechargeState(
      status: status ?? this.status,
      packages: packages ?? this.packages,
      records: records ?? this.records,
      errorMessage: errorMessage,
      selectedPackage: selectedPackage ?? this.selectedPackage,
      paymentId: paymentId ?? this.paymentId,
      isPolling: isPolling ?? this.isPolling,
    );
  }
}

class RechargeProvider extends ChangeNotifier {
  Timer? _pollingTimer;

  RechargeState _state = RechargeState();
  RechargeState get state => _state;

  Future<void> loadPackages() async {
    _state = _state.copyWith(
      status: RechargeStatus.loading,
      errorMessage: null,
    );
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final packages = [
      RechargePackage(
        id: '1',
        name: '基础套餐',
        description: '适合个人使用',
        price: 9.9,
        credits: 10,
      ),
      RechargePackage(
        id: '2',
        name: '标准套餐',
        description: '适合小团队',
        price: 29.9,
        credits: 50,
      ),
      RechargePackage(
        id: '3',
        name: '专业套餐',
        description: '适合专业用户',
        price: 99.9,
        credits: 200,
      ),
      RechargePackage(
        id: '4',
        name: '企业套餐',
        description: '适合企业使用',
        price: 299.9,
        credits: 1000,
      ),
    ];

    _state = _state.copyWith(
      status: RechargeStatus.success,
      packages: packages,
    );
    notifyListeners();
  }

  Future<void> loadHistory() async {
    _state = _state.copyWith(
      status: RechargeStatus.loading,
      errorMessage: null,
    );
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final records = [
      RechargeRecord(
        id: '1',
        packageId: '1',
        packageName: '基础套餐',
        amount: 9.9,
        credits: 10,
        paymentMethod: 'stripe',
        status: 'completed',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      RechargeRecord(
        id: '2',
        packageId: '2',
        packageName: '标准套餐',
        amount: 29.9,
        credits: 50,
        paymentMethod: 'stripe',
        status: 'completed',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ];

    _state = _state.copyWith(
      status: RechargeStatus.success,
      records: records,
    );
    notifyListeners();
  }

  void selectPackage(RechargePackage package) {
    _state = _state.copyWith(selectedPackage: package);
    notifyListeners();
  }

  Future<void> createPayment(String paymentType) async {
    if (_state.selectedPackage == null) {
      _state = _state.copyWith(
        errorMessage: '请选择充值套餐',
      );
      notifyListeners();
      return;
    }

    _state = _state.copyWith(
      status: RechargeStatus.loading,
      errorMessage: null,
    );
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final paymentId = 'payment_${DateTime.now().millisecondsSinceEpoch}';

    _state = _state.copyWith(
      status: RechargeStatus.processing,
      paymentId: paymentId,
    );
    notifyListeners();

    await _startPaymentPolling(paymentId);
  }

  Future<void> _startPaymentPolling(String paymentId) async {
    _state = _state.copyWith(isPolling: true);
    notifyListeners();

    int elapsed = 0;
    _pollingTimer = Timer.periodic(
      const Duration(milliseconds: AppConstants.pollingInterval),
      (timer) async {
        elapsed += AppConstants.pollingInterval;

        if (elapsed >= 3000) {
          timer.cancel();
          _state = _state.copyWith(
            status: RechargeStatus.success,
            isPolling: false,
          );
          notifyListeners();
          return;
        }
      },
    );
  }

  void clearError() {
    _state = _state.copyWith(errorMessage: null);
    notifyListeners();
  }

  void reset() {
    _pollingTimer?.cancel();
    _state = RechargeState();
    notifyListeners();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
