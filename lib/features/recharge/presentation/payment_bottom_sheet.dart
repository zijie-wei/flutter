import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/recharge_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/network_utils.dart';

class PaymentBottomSheet extends StatelessWidget {
  const PaymentBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RechargeProvider>(
      builder: (context, rechargeProvider, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                '选择支付方式',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _PaymentOption(
                icon: Icons.credit_card,
                title: 'Stripe',
                description: '国际信用卡支付',
                onTap: () {
                  Navigator.of(context).pop();
                  _handlePayment(context, PaymentTypes.stripe);
                },
              ),
              const SizedBox(height: 12),
              _PaymentOption(
                icon: Icons.payment,
                title: 'PayMe',
                description: '便捷移动支付',
                onTap: () {
                  Navigator.of(context).pop();
                  _handlePayment(context, PaymentTypes.payme);
                },
              ),
              const SizedBox(height: 24),
              if (rechargeProvider.state.isPolling)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('支付处理中...'),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handlePayment(BuildContext context, String paymentType) async {
    final rechargeProvider = context.read<RechargeProvider>();

    try {
      await rechargeProvider.createPayment(paymentType);

      if (rechargeProvider.state.status == RechargeStatus.success) {
        if (context.mounted) {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const PaymentResultPage(success: true),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.0, 1.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                var tween = Tween(begin: begin, end: end).chain(
                  CurveTween(curve: curve),
                );

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ),
          );
        }
      } else if (rechargeProvider.state.status == RechargeStatus.failed) {
        if (context.mounted) {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  PaymentResultPage(
                success: false,
                errorMessage: rechargeProvider.state.errorMessage,
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.0, 1.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                var tween = Tween(begin: begin, end: end).chain(
                  CurveTween(curve: curve),
                );

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        NetworkUtils.showError(context, '支付失败，请重试');
      }
    }
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).dividerColor,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentResultPage extends StatelessWidget {
  final bool success;
  final String? errorMessage;

  const PaymentResultPage({
    super.key,
    required this.success,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: success
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  success ? Icons.check_circle : Icons.error,
                  size: 80,
                  color: success ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                success ? '支付成功' : '支付失败',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: success ? Colors.green : Colors.red,
                    ),
              ),
              const SizedBox(height: 16),
              if (!success && errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    errorMessage!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              if (!success)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        '可能的原因：',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• 网络连接问题\n• 账户余额不足\n• 支付信息错误\n• 银行拒绝交易',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('完成'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('返回'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
