import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_provider.dart';
import 'features/auth/domain/auth_state.dart';
import 'features/recharge/data/recharge_provider.dart';
import 'features/ai_photo/data/photo_provider.dart';
import 'shared/widgets/custom_app_bar.dart';
import 'features/auth/presentation/auth_page.dart';
import 'features/legal/presentation/privacy_policy_page.dart';
import 'features/legal/presentation/user_agreement_page.dart';
import 'features/recharge/presentation/recharge_page.dart';
import 'features/ai_photo/presentation/ai_photo_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RechargeProvider()),
        ChangeNotifierProvider(create: (_) => PhotoProvider()),
      ],
      child: MaterialApp(
        title: 'Mobile App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          '/auth': (context) => const AuthPage(),
          '/privacy': (context) => const PrivacyPolicyPage(),
          '/agreement': (context) => const UserAgreementPage(),
          '/recharge': (context) => const RechargePage(),
          '/ai-photo': (context) => const AIPhotoPage(),
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _HomeTab(),
    const AIPhotoPage(),
    const RechargePage(),
    const _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.state.status != AuthStatus.authenticated) {
          return const AuthPage();
        }

        return Scaffold(
          appBar: const CustomAppBar(
            title: 'Mobile App',
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home),
                selectedIcon: Icon(Icons.home_filled),
                label: '首页',
              ),
              NavigationDestination(
                icon: Icon(Icons.photo_camera),
                selectedIcon: Icon(Icons.photo_camera),
                label: 'AI写真',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_balance_wallet),
                selectedIcon: Icon(Icons.account_balance_wallet),
                label: '充值',
              ),
              NavigationDestination(
                icon: Icon(Icons.person),
                selectedIcon: Icon(Icons.person),
                label: '我的',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(context),
          const SizedBox(height: 24),
          _buildQuickActions(context),
          const SizedBox(height: 24),
          _buildFeaturesSection(context),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.state.user;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '欢迎回来，${user?.username ?? '用户'}！',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '今天也是美好的一天',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快捷操作',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.photo_camera,
                label: 'AI写真',
                onTap: () {
                  Navigator.of(context).pushNamed('/ai-photo');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.account_balance_wallet,
                label: '充值',
                onTap: () {
                  Navigator.of(context).pushNamed('/recharge');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '功能介绍',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _FeatureCard(
          icon: Icons.auto_awesome,
          title: 'AI写真生成',
          description: '使用先进的AI技术，为您生成精美的写真照片',
          onTap: () {
            Navigator.of(context).pushNamed('/ai-photo');
          },
        ),
        const SizedBox(height: 12),
        _FeatureCard(
          icon: Icons.payment,
          title: '便捷充值',
          description: '支持多种支付方式，快速充值，畅享服务',
          onTap: () {
            Navigator.of(context).pushNamed('/recharge');
          },
        ),
        const SizedBox(height: 12),
        _FeatureCard(
          icon: Icons.security,
          title: '安全可靠',
          description: '严格保护用户隐私，数据加密存储',
          onTap: () {
            Navigator.of(context).pushNamed('/privacy');
          },
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
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
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.state.user;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          user?.username?.substring(0, 1).toUpperCase() ?? 'U',
                          style: TextStyle(
                            fontSize: 32,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.username ?? '用户',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? '',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _ProfileMenuItem(
                icon: Icons.person,
                title: '个人资料',
                onTap: () {},
              ),
              _ProfileMenuItem(
                icon: Icons.settings,
                title: '设置',
                onTap: () {},
              ),
              _ProfileMenuItem(
                icon: Icons.privacy_tip,
                title: '隐私协议',
                onTap: () {
                  Navigator.of(context).pushNamed('/privacy');
                },
              ),
              _ProfileMenuItem(
                icon: Icons.description,
                title: '用户协议',
                onTap: () {
                  Navigator.of(context).pushNamed('/agreement');
                },
              ),
              _ProfileMenuItem(
                icon: Icons.info,
                title: '关于我们',
                onTap: () {},
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    authProvider.logout();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('退出登录'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
