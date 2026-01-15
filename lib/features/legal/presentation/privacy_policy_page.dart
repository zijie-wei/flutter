import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {
    '1. 信息收集': GlobalKey(),
    '2. 信息使用': GlobalKey(),
    '3. 信息共享': GlobalKey(),
    '4. 信息存储': GlobalKey(),
    '5. 用户权利': GlobalKey(),
    '6. Cookie使用': GlobalKey(),
    '7. 儿童隐私': GlobalKey(),
    '8. 隐私政策更新': GlobalKey(),
  };
  String? _highlightedSection;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(String sectionTitle) {
    final key = _sectionKeys[sectionTitle];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      setState(() {
        _highlightedSection = sectionTitle;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _highlightedSection = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('隐私协议'),
      ),
      body: Row(
        children: [
          Container(
            width: 200,
            color: Theme.of(context).colorScheme.surface,
            child: ListView(
              children: _sectionKeys.keys.map((title) {
                return ListTile(
                  title: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: _highlightedSection == title
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      fontWeight: _highlightedSection == title
                          ? FontWeight.bold
                          : null,
                    ),
                  ),
                  onTap: () => _scrollToSection(title),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '隐私协议',
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
                  _buildSection(
                    '1. 信息收集',
                    _sectionKeys['1. 信息收集']!,
                    '''
我们收集以下类型的信息：

1.1 您提供的信息
- 注册账号时提供的个人信息（如姓名、邮箱、手机号）
- 使用服务时提供的内容（如照片、视频）
- 与我们沟通时提供的信息

1.2 自动收集的信息
- 设备信息（如设备型号、操作系统版本）
- 使用数据（如使用时间、功能使用情况）
- 位置信息（仅在您授权的情况下）

1.3 第三方来源
- 来自社交媒体的信息（如您选择关联账号）
- 来自支付平台的信息（如您使用支付服务）
''',
                  ),
                  _buildSection(
                    '2. 信息使用',
                    _sectionKeys['2. 信息使用']!,
                    '''
我们使用收集的信息用于：

2.1 提供服务
- 处理您的请求和交易
- 提供个性化服务
- 改进服务质量

2.2 安全保障
- 验证用户身份
- 防止欺诈和滥用
- 保护账户安全

2.3 沟通联系
- 发送服务通知
- 回应用户咨询
- 推送相关更新

2.4 分析改进
- 分析使用趋势
- 优化产品功能
- 开发新服务
''',
                  ),
                  _buildSection(
                    '3. 信息共享',
                    _sectionKeys['3. 信息共享']!,
                    '''
我们不会出售您的个人信息。在以下情况下，我们可能共享信息：

3.1 服务提供商
- 支付处理服务商
- 云存储服务商
- 数据分析服务商

3.2 法律要求
- 遵守法律法规
- 响应政府要求
- 保护我们的权利

3.3 业务转让
- 合并或收购
- 资产转让
- 业务重组

3.4 用户同意
- 在获得您明确同意的情况下
''',
                  ),
                  _buildSection(
                    '4. 信息存储',
                    _sectionKeys['4. 信息存储']!,
                    '''
4.1 存储位置
您的信息存储在安全的服务器上，位于中国境内。

4.2 存储期限
- 账号信息：账号存续期间
- 交易记录：法律要求的期限
- 使用日志：不超过12个月

4.3 数据删除
您可以通过以下方式删除信息：
- 删除账号
- 删除特定内容
- 联系客服请求删除
''',
                  ),
                  _buildSection(
                    '5. 用户权利',
                    _sectionKeys['5. 用户权利']!,
                    '''
您拥有以下权利：

5.1 访问权
- 查看我们收集的个人信息
- 了解信息的使用情况

5.2 更正权
- 更新不准确的个人信息
- 补充不完整的信息

5.3 删除权
- 删除不再需要的个人信息
- 撤回已给予的同意

5.4 携带权
- 以结构化格式导出个人信息
- 将信息转移到其他服务

5.5 反对权
- 反对特定信息的处理
- 退出营销通讯
''',
                  ),
                  _buildSection(
                    '6. Cookie使用',
                    _sectionKeys['6. Cookie使用']!,
                    '''
6.1 Cookie类型
- 必要Cookie：确保基本功能
- 性能Cookie：收集使用数据
- 功能Cookie：记住您的偏好
- 营销Cookie：提供相关内容

6.2 Cookie管理
您可以通过浏览器设置管理Cookie：
- 接受所有Cookie
- 拒绝所有Cookie
- 删除已存储的Cookie

6.3 Cookie影响
禁用Cookie可能影响部分功能的使用。
''',
                  ),
                  _buildSection(
                    '7. 儿童隐私',
                    _sectionKeys['7. 儿童隐私']!,
                    '''
7.1 年龄限制
我们的服务面向18岁及以上用户。

7.2 儿童保护
我们不会故意收集13岁以下儿童的个人信息。

7.3 家长控制
如发现我们收集了儿童信息，请联系我们删除。
''',
                  ),
                  _buildSection(
                    '8. 隐私政策更新',
                    _sectionKeys['8. 隐私政策更新']!,
                    '''
8.1 更新通知
- 通过应用内通知
- 通过邮件通知
- 在应用内公示

8.2 更新生效
更新后的政策将在发布后立即生效。

8.3 继续使用
继续使用我们的服务即表示您接受更新后的政策。
''',
                  ),
                  const SizedBox(height: 32),
                  Text(
                    '联系我们',
                    style: AppTheme.headingTextStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '如有任何关于隐私政策的问题，请通过以下方式联系我们：\n\n'
                    '邮箱：privacy@example.com\n'
                    '电话：400-123-4567\n'
                    '地址：中国某省某市某区某路123号',
                    style: AppTheme.bodyTextStyle,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, GlobalKey key, String content) {
    final isHighlighted = _highlightedSection == title;

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
            : null,
        borderRadius: BorderRadius.circular(8),
        border: isHighlighted
            ? Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.headingTextStyle.copyWith(
              fontSize: 18,
              color: isHighlighted
                  ? Theme.of(context).colorScheme.primary
                  : null,
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
}
