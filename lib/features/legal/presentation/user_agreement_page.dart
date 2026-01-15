import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class UserAgreementPage extends StatefulWidget {
  const UserAgreementPage({super.key});

  @override
  State<UserAgreementPage> createState() => _UserAgreementPageState();
}

class _UserAgreementPageState extends State<UserAgreementPage> {
  bool _isAgreed = false;
  bool _hasScrolledToBottom = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      if (!_hasScrolledToBottom) {
        setState(() {
          _hasScrolledToBottom = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户协议'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '用户服务协议',
                    style: AppTheme.titleTextStyle.copyWith(
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '最后更新日期：2024年1月1日',
                    style: AppTheme.bodyTextStyle.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildArticle(
                    '1. 协议的接受',
                    '''
1.1 欢迎使用我们的服务！在使用我们的服务之前，请仔细阅读本协议的所有条款。

1.2 点击"同意"或使用我们的服务，即表示您已阅读、理解并同意受本协议的约束。

1.3 如果您不同意本协议的任何条款，请不要使用我们的服务。
''',
                  ),
                  _buildArticle(
                    '2. 服务说明',
                    '''
2.1 我们提供的服务包括但不限于：
- AI写真生成服务
- 充值服务
- 用户账户管理服务
- 其他相关服务

2.2 我们保留随时修改、暂停或终止服务的权利，无需事先通知。

2.3 服务可能包含第三方提供的内容或服务，第三方内容受其自己的条款约束。
''',
                  ),
                  _buildArticle(
                    '3. 用户账户',
                    '''
3.1 您需要创建账户才能使用某些服务。

3.2 您有责任：
- 保管好您的账户信息
- 对账户下的所有活动负责
- 及时通知我们任何未经授权的使用

3.3 您不得：
- 创建多个账户
- 转让或出售账户
- 使用他人账户
''',
                  ),
                  _buildArticle(
                    '4. 用户行为',
                    '''
4.1 您同意不会：
- 上传违法或有害内容
- 侵犯他人知识产权
- 干扰服务正常运行
- 试图绕过安全措施

4.2 您对您上传的内容承担全部责任。

4.3 我们保留删除违规内容的权利。
''',
                  ),
                  _buildArticle(
                    '5. 知识产权',
                    '''
5.1 服务及其内容受知识产权法保护。

5.2 您获得的是使用服务的许可，而非所有权。

5.3 您上传的内容仍归您所有，但您授予我们使用、修改、展示的许可。

5.4 AI生成的内容归您所有，但您同意我们可以在营销中使用。
''',
                  ),
                  _buildArticle(
                    '6. 付费服务',
                    '''
6.1 某些服务需要付费，价格可能随时调整。

6.2 支付完成后，服务通常不可退款，除非法律另有规定。

6.3 我们使用第三方支付服务，您需遵守其条款。

6.4 虚拟货币和积分不兑换现金。
''',
                  ),
                  _buildArticle(
                    '7. 免责声明',
                    '''
7.1 服务按"现状"提供，不提供任何明示或暗示的保证。

7.2 我们不对以下情况负责：
- 服务的暂时中断
- 数据丢失或损坏
- 第三方行为
- 不可抗力事件

7.3 在法律允许的最大范围内，我们排除所有责任。
''',
                  ),
                  _buildArticle(
                    '8. 赔偿',
                    '''
8.1 您同意赔偿并使我们免受因以下原因产生的任何索赔：
- 您违反本协议
- 您侵犯他人权利
- 您使用服务不当

8.2 我们保留抗辩和控制的权利。
''',
                  ),
                  _buildArticle(
                    '9. 协议变更',
                    '''
9.1 我们可以随时修改本协议。

9.2 修改后的协议将在发布后生效。

9.3 继续使用服务即表示您接受修改后的协议。

9.4 重大变更将通过邮件或应用内通知告知。
''',
                  ),
                  _buildArticle(
                    '10. 终止',
                    '''
10.1 您可以随时终止使用服务并删除账户。

10.2 我们可以在以下情况下终止您的账户：
- 您违反本协议
- 您长期不使用账户
- 法律要求我们这样做

10.3 终止后，您可能无法访问账户或内容。
''',
                  ),
                  _buildArticle(
                    '11. 争议解决',
                    '''
11.1 本协议受中华人民共和国法律管辖。

11.2 任何争议应首先通过友好协商解决。

11.3 协商不成的，应提交至有管辖权的人民法院诉讼解决。
''',
                  ),
                  _buildArticle(
                    '12. 其他条款',
                    '''
12.1 本协议构成您与我们之间的完整协议。

12.2 如果本协议的任何条款被认定为无效，其余条款仍然有效。

12.3 我们未执行任何条款不构成放弃该权利。

12.4 您不得转让本协议。
''',
                  ),
                  const SizedBox(height: 32),
                  Text(
                    '联系我们',
                    style: AppTheme.headingTextStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '如有任何关于用户协议的问题，请通过以下方式联系我们：\n\n'
                    '邮箱：support@example.com\n'
                    '电话：400-123-4567\n'
                    '地址：中国某省某市某区某路123号',
                    style: AppTheme.bodyTextStyle,
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          _buildAgreementSection(),
        ],
      ),
    );
  }

  Widget _buildArticle(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.headingTextStyle.copyWith(
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content.trim(),
            style: AppTheme.bodyTextStyle.copyWith(
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgreementSection() {
    return Container(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Checkbox(
                  value: _isAgreed,
                  onChanged: (value) {
                    setState(() {
                      _isAgreed = value ?? false;
                    });
                  },
                ),
                const Expanded(
                  child: Text('我已阅读并同意以上用户协议'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isAgreed && _hasScrolledToBottom
                    ? () {
                        Navigator.of(context).pop(true);
                      }
                    : null,
                child: const Text('同意并继续'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
