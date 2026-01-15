import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/data/auth_provider.dart';
import '../../features/auth/domain/auth_state.dart';
import '../models/user_model.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return AppBar(
          title: title != null ? Text(title!) : null,
          automaticallyImplyLeading: automaticallyImplyLeading,
          leading: leading,
          actions: [
            ..._buildActions(context, authProvider),
            if (actions != null) ...actions!,
          ],
        );
      },
    );
  }

  List<Widget> _buildActions(BuildContext context, AuthProvider authProvider) {
    final List<Widget> widgets = [];

    if (authProvider.state.status == AuthStatus.authenticated) {
      final user = authProvider.state.user;
      widgets.add(
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            _showNotifications(context);
          },
        ),
      );
      widgets.add(
        PopupMenuButton<String>(
          icon: _buildUserAvatar(context, user),
          onSelected: (value) {
            _handleMenuSelection(context, value, authProvider);
          },
          itemBuilder: (menuContext) => [
            if (user?.username != null)
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person),
                    const SizedBox(width: 8),
                    Text(user?.username ?? '用户'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 8),
                  Text('设置'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 8),
                  Text('退出登录'),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      widgets.add(
        TextButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/auth');
          },
          child: const Text('登录'),
        ),
      );
    }

    return widgets;
  }

  Widget _buildUserAvatar(BuildContext context, UserModel? user) {
    if (user?.avatar != null && user!.avatar!.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage(user.avatar!),
        radius: 16,
      );
    }

    return CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      radius: 16,
      child: Text(
        user?.username?.substring(0, 1).toUpperCase() ?? 'U',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '通知中心',
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text('暂无新通知'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuSelection(
    BuildContext context,
    String value,
    AuthProvider authProvider,
  ) {
    switch (value) {
      case 'profile':
        Navigator.of(context).pushNamed('/profile');
        break;
      case 'settings':
        Navigator.of(context).pushNamed('/settings');
        break;
      case 'logout':
        _showLogoutDialog(context, authProvider);
        break;
    }
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              authProvider.logout();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
