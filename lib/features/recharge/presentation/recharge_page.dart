import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/recharge_provider.dart';
import '../domain/recharge_models.dart';
import 'payment_bottom_sheet.dart';

class RechargePage extends StatefulWidget {
  const RechargePage({super.key});

  @override
  State<RechargePage> createState() => _RechargePageState();
}

class _RechargePageState extends State<RechargePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RechargeProvider>().loadPackages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('充值中心'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '套餐选择'),
              Tab(text: '充值记录'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PackagesTab(),
            _HistoryTab(),
          ],
        ),
      ),
    );
  }
}

class _PackagesTab extends StatelessWidget {
  const _PackagesTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<RechargeProvider>(
      builder: (context, rechargeProvider, child) {
        if (rechargeProvider.state.status == RechargeStatus.loading &&
            rechargeProvider.state.packages.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (rechargeProvider.state.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(rechargeProvider.state.errorMessage!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    rechargeProvider.loadPackages();
                    rechargeProvider.clearError();
                  },
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: rechargeProvider.state.packages.length,
                itemBuilder: (context, index) {
                  final package = rechargeProvider.state.packages[index];
                  return _PackageCard(package: package);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: rechargeProvider.state.selectedPackage != null
                        ? () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) =>
                                  const PaymentBottomSheet(),
                            );
                          }
                        : null,
                    child: const Text('立即充值'),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PackageCard extends StatelessWidget {
  final RechargePackage package;

  const _PackageCard({required this.package});

  @override
  Widget build(BuildContext context) {
    final isSelected = context.select<RechargeProvider, bool>(
      (provider) => provider.state.selectedPackage?.id == package.id,
    );

    return GestureDetector(
      onTap: () {
        context.read<RechargeProvider>().selectPackage(package);
      },
      child: Card(
        elevation: isSelected ? 8 : 2,
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
        child: Stack(
          children: [
            if (package.isPopular)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '热门',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${package.credits} 积分',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (package.description != null)
                    Text(
                      package.description!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '¥${package.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<RechargeProvider>(
      builder: (context, rechargeProvider, child) {
        if (rechargeProvider.state.status == RechargeStatus.loading &&
            rechargeProvider.state.records.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (rechargeProvider.state.records.isEmpty) {
          return const Center(
            child: Text('暂无充值记录'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rechargeProvider.state.records.length,
          itemBuilder: (context, index) {
            final record = rechargeProvider.state.records[index];
            return _RecordTile(record: record);
          },
        );
      },
    );
  }
}

class _RecordTile extends StatelessWidget {
  final RechargeRecord record;

  const _RecordTile({required this.record});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(record.status),
          child: Icon(
            _getStatusIcon(record.status),
            color: Colors.white,
          ),
        ),
        title: Text(record.packageName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${record.credits} 积分'),
            Text(
              _formatDate(record.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '¥${record.amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              _getStatusText(record.status),
              style: TextStyle(
                color: _getStatusColor(record.status),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'processing':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check;
      case 'failed':
        return Icons.close;
      case 'processing':
        return Icons.hourglass_empty;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return '成功';
      case 'failed':
        return '失败';
      case 'processing':
        return '处理中';
      default:
        return '未知';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
