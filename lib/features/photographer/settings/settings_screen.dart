import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/creator_avatar.dart';
import '../../../core/widgets/creator_list_row.dart';
import '../../../providers/data_providers.dart';
import '../../../domain/models/models.dart';

class NotificationSettingsNotifier extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() => {
    'bookingUpdates': true,
    'messages': true,
    'promotions': true,
    'emailDigest': false,
  };

  void set(String key, bool value) => state = {...state, key: value};
}

final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsNotifier, Map<String, bool>>(
      NotificationSettingsNotifier.new,
    );

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final phone = TextEditingController();
  final birthday = TextEditingController();
  final address = TextEditingController();
  String? city;
  String? gender;
  bool initialized = false;
  int tab = 0;

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    birthday.dispose();
    address.dispose();
    super.dispose();
  }

  void _save() {
    if (!formKey.currentState!.validate()) return;
    final user = ref.read(authUserProvider);
    if (user == null) return;
    final updated = user.copyWith(
      name: name.text.trim(),
      phone: phone.text.trim(),
      birthday: birthday.text.trim(),
      city: city ?? '',
      gender: gender ?? '',
      addressDetail: address.text.trim(),
    );
    ref.read(authUserProvider.notifier).setUser(updated);
    final profile = ref.read(myPhotographerProvider);
    if (profile != null) {
      ref
          .read(photographersProvider.notifier)
          .update(profile.copyWith(name: updated.name));
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã lưu thông tin cá nhân')));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authUserProvider);
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Vui lòng đăng nhập')));
    }
    if (!initialized) {
      name.text = user.name;
      phone.text = user.phone;
      birthday.text = user.birthday;
      address.text = user.addressDetail;
      city = user.city.isEmpty ? null : user.city;
      gender = user.gender.isEmpty ? null : user.gender;
      initialized = true;
    }
    return Scaffold(
      backgroundColor: AppColors.snow,
      appBar: AppBar(title: const Text('Cài đặt')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppTokens.contentMaxWidth,
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final (index, label) in const [
                      'Hồ sơ',
                      'Tài khoản',
                      'Thông báo',
                    ].indexed) ...[
                      ChoiceChip(
                        label: Text(label),
                        selected: tab == index,
                        onSelected: (_) => setState(() => tab = index),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (tab == 0)
                _profile(user)
              else if (tab == 1)
                _account(user)
              else
                _notifications(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profile(User user) => Form(
    key: formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            CreatorAvatar(name: user.name, size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    user.email,
                    style: const TextStyle(color: AppColors.steel),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => context.push('/photographer_home/portfolio'),
          child: const Text(
            'Quản lý ảnh, giới thiệu và giá trên hồ sơ năng lực',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: name,
          decoration: const InputDecoration(labelText: 'Họ và tên'),
          validator: (value) => (value ?? '').trim().length < 2
              ? 'Vui lòng nhập họ và tên'
              : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: phone,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Số điện thoại'),
          validator: (value) =>
              (value ?? '').trim().isEmpty ||
                  RegExp(r'^(0|\+84)\d{8,10}$').hasMatch(value!.trim())
              ? null
              : 'Số điện thoại không hợp lệ',
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: birthday,
          decoration: const InputDecoration(
            labelText: 'Ngày sinh (YYYY-MM-DD)',
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: gender,
          decoration: const InputDecoration(labelText: 'Giới tính'),
          items: const [
            DropdownMenuItem(value: 'male', child: Text('Nam')),
            DropdownMenuItem(value: 'female', child: Text('Nữ')),
            DropdownMenuItem(value: 'other', child: Text('Khác')),
          ],
          onChanged: (value) => gender = value,
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: city,
          decoration: const InputDecoration(labelText: 'Tỉnh / Thành phố'),
          onChanged: (value) => city = value,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: address,
          maxLength: 120,
          decoration: const InputDecoration(labelText: 'Địa chỉ chi tiết'),
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: _save, child: const Text('Lưu thông tin')),
      ],
    ),
  );

  Widget _account(User user) => Column(
    children: [
      CreatorListRow(
        icon: Icons.alternate_email_rounded,
        title: 'Email đăng nhập',
        subtitle: user.email,
        trailing: const Icon(Icons.verified_outlined, color: AppColors.success),
      ),
      const Divider(),
      const CreatorListRow(
        icon: Icons.badge_outlined,
        title: 'Loại tài khoản',
        subtitle: 'Nhiếp ảnh gia',
        trailing: SizedBox.shrink(),
      ),
      const Divider(),
      CreatorListRow(
        icon: Icons.logout_rounded,
        title: 'Đăng xuất',
        onTap: () {
          ref.read(authUserProvider.notifier).setUser(null);
          context.go('/login');
        },
      ),
    ],
  );

  Widget _notifications() {
    final values = ref.watch(notificationSettingsProvider);
    const options = [
      (
        'bookingUpdates',
        'Cập nhật lịch đặt',
        'Khi lịch chụp được xác nhận, thay đổi hoặc cần thanh toán.',
      ),
      ('messages', 'Tin nhắn mới', 'Khi có người nhắn tin cho bạn.'),
      (
        'promotions',
        'Ưu đãi & khuyến mãi',
        'Mã giảm giá và chương trình Lens.',
      ),
      (
        'emailDigest',
        'Email tổng hợp hằng tuần',
        'Tóm tắt hoạt động trong tuần.',
      ),
    ];
    return Column(
      children: [
        for (final (key, label, hint) in options) ...[
          SwitchListTile(
            title: Text(label),
            subtitle: Text(hint),
            value: values[key] ?? false,
            onChanged: (value) =>
                ref.read(notificationSettingsProvider.notifier).set(key, value),
          ),
          const Divider(),
        ],
      ],
    );
  }
}
