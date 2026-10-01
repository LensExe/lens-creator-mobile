import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/creator_page_header.dart';
import '../../../core/widgets/creator_section_header.dart';
import '../../../providers/data_providers.dart';
import '../../../domain/models/models.dart';
import 'settings_provider.dart';
import 'widgets/change_password_dialog.dart';
import 'widgets/settings_action_tile.dart';
import 'widgets/settings_group.dart';
import 'widgets/settings_profile_header.dart';
import 'widgets/settings_toggle_tile.dart';

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
  bool saving = false;
  bool twoFactorEnabled = true;
  bool twoFactorInitialized = false;
  bool updatingTwoFactor = false;
  int tab = 0;

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    birthday.dispose();
    address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
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
    final profile = ref.read(myPhotographerProvider);
    setState(() => saving = true);
    try {
      if (profile != null) {
        await ref
            .read(photographersProvider.notifier)
            .update(profile.copyWith(name: updated.name));
      }
      await ref.read(settingsRepositoryProvider).updateProfile(updated);
      if (!mounted) return;
      ref.read(authUserProvider.notifier).setUser(updated);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã lưu thông tin cá nhân')));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể lưu thông tin: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _changePassword(User user) async {
    final messenger = ScaffoldMessenger.of(context);
    await showDialog<void>(
      context: context,
      builder: (context) => ChangePasswordDialog(
        onSubmit: (current, next) async {
          await ref
              .read(settingsRepositoryProvider)
              .changePassword(
                userId: user.id,
                currentPassword: current,
                newPassword: next,
              );
          if (mounted) {
            messenger.showSnackBar(
              const SnackBar(content: Text('Đã đổi mật khẩu')),
            );
          }
        },
      ),
    );
  }

  Future<void> _setTwoFactor(User user, bool enabled) async {
    if (updatingTwoFactor) return;
    setState(() => updatingTwoFactor = true);
    try {
      final result = await ref
          .read(settingsRepositoryProvider)
          .setTwoFactor(user.id, enabled);
      if (!mounted) return;
      setState(() => twoFactorEnabled = result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result ? 'Đã bật xác thực hai bước' : 'Đã tắt xác thực hai bước',
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể cập nhật xác thực hai bước: $error'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => updatingTwoFactor = false);
    }
  }

  Future<void> _signOutOtherDevices(User user) async {
    try {
      await ref.read(settingsRepositoryProvider).signOutOtherDevices(user.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã đăng xuất khỏi các thiết bị khác')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể đăng xuất thiết bị khác: $error')),
        );
      }
    }
  }

  Future<void> _updateNotification(String key, bool enabled) async {
    try {
      await ref.read(notificationSettingsProvider.notifier).set(key, enabled);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã cập nhật thông báo')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể cập nhật, vui lòng thử lại: $error'),
          ),
        );
      }
    }
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
    if (!twoFactorInitialized) {
      twoFactorEnabled =
          ref.read(settingsRepositoryProvider).cachedTwoFactor(user.id) ?? true;
      twoFactorInitialized = true;
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
              CreatorPageHeader(
                title: switch (tab) {
                  0 => 'Hồ sơ cá nhân',
                  1 => 'Tài khoản',
                  _ => 'Thông báo',
                },
                subtitle: switch (tab) {
                  0 => 'Thông tin cá nhân và hồ sơ hiển thị với khách hàng.',
                  1 => 'Quản lý đăng nhập, bảo mật và thiết bị.',
                  _ => 'Chọn những cập nhật bạn muốn nhận.',
                },
              ),
              const SizedBox(height: 18),
              _SettingsTabs(
                selectedIndex: tab,
                onSelected: (index) => setState(() => tab = index),
              ),
              const SizedBox(height: 25),
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
        SettingsProfileHeader(
          name: user.name,
          email: user.email,
          avatarUrl: ref.watch(myPhotographerProvider)?.avatar,
          onChangeAvatar: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tính năng đổi ảnh đại diện sẽ sớm khả dụng'),
            ),
          ),
        ),
        const SizedBox(height: 22),
        SettingsGroup(
          title: 'Hồ sơ năng lực',
          children: [
            SettingsActionTile(
              icon: Icons.photo_library_outlined,
              title: 'Quản lý hồ sơ năng lực',
              subtitle: 'Ảnh, giới thiệu và giá hiển thị cho khách.',
              onTap: () => context.push('/photographer_home/portfolio'),
            ),
          ],
        ),
        const SizedBox(height: 25),
        const CreatorSectionHeader(
          title: 'Thông tin cá nhân',
          subtitle: 'Thông tin liên hệ và địa chỉ dùng cho lịch chụp.',
        ),
        const SizedBox(height: 14),
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
        const SizedBox(height: 18),
        FilledButton(
          onPressed: saving ? null : _save,
          child: Text(saving ? 'Đang lưu...' : 'Lưu thông tin'),
        ),
      ],
    ),
  );

  Widget _account(User user) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SettingsGroup(
        title: 'Thông tin tài khoản',
        children: [
          SettingsActionTile(
            icon: Icons.alternate_email_rounded,
            title: 'Email đăng nhập',
            subtitle: user.email,
            trailing: const Icon(
              Icons.verified_outlined,
              color: AppColors.success,
              size: 20,
            ),
          ),
          SettingsActionTile(
            icon: Icons.lock_outline_rounded,
            title: 'Đổi mật khẩu',
            subtitle: 'Mật khẩu mới cần ít nhất 8 ký tự.',
            onTap: () => _changePassword(user),
          ),
          const SettingsActionTile(
            icon: Icons.badge_outlined,
            title: 'Loại tài khoản',
            subtitle: 'Nhiếp ảnh gia',
          ),
        ],
      ),
      const SizedBox(height: 24),
      SettingsGroup(
        title: 'Bảo mật',
        children: [
          SettingsToggleTile(
            icon: Icons.shield_outlined,
            title: 'Xác thực hai bước',
            subtitle: 'Bảo vệ tài khoản bằng mã xác thực.',
            value: twoFactorEnabled,
            busy: updatingTwoFactor,
            onChanged: updatingTwoFactor
                ? null
                : (value) => _setTwoFactor(user, value),
          ),
        ],
      ),
      const SizedBox(height: 24),
      SettingsGroup(
        title: 'Phiên đăng nhập',
        children: [
          const SettingsActionTile(
            icon: Icons.devices_outlined,
            title: 'Phiên đăng nhập hiện tại',
            subtitle: 'Thiết bị này',
          ),
          SettingsActionTile(
            icon: Icons.devices_other_outlined,
            title: 'Đăng xuất thiết bị khác',
            onTap: () => _signOutOtherDevices(user),
          ),
          SettingsActionTile(
            icon: Icons.logout_rounded,
            title: 'Đăng xuất',
            onTap: () {
              ref.read(authUserProvider.notifier).setUser(null);
              context.go('/login');
            },
            destructive: true,
            trailing: const SizedBox.shrink(),
          ),
        ],
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsGroup(
          title: 'Hoạt động',
          children: [
            for (final option in options.take(2))
              SettingsToggleTile(
                icon: option.$1 == 'bookingUpdates'
                    ? Icons.calendar_month_outlined
                    : Icons.chat_bubble_outline_rounded,
                title: option.$2,
                subtitle: option.$3,
                value: values[option.$1] ?? false,
                onChanged: (value) => _updateNotification(option.$1, value),
              ),
          ],
        ),
        const SizedBox(height: 24),
        SettingsGroup(
          title: 'Ưu đãi & tổng hợp',
          children: [
            for (final option in options.skip(2))
              SettingsToggleTile(
                icon: option.$1 == 'promotions'
                    ? Icons.local_offer_outlined
                    : Icons.mark_email_read_outlined,
                title: option.$2,
                subtitle: option.$3,
                value: values[option.$1] ?? false,
                onChanged: (value) => _updateNotification(option.$1, value),
              ),
          ],
        ),
      ],
    );
  }
}

class _SettingsTabs extends StatelessWidget {
  const _SettingsTabs({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _labels = ['Hồ sơ', 'Tài khoản', 'Thông báo'];

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: AppColors.mist,
      borderRadius: BorderRadius.circular(AppTokens.radiusInput + 2),
    ),
    child: Row(
      children: [
        for (final (index, label) in _labels.indexed)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index == _labels.length - 1 ? 0 : 4,
              ),
              child: Semantics(
                button: true,
                selected: selectedIndex == index,
                label: label,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppTokens.radiusInput),
                    onTap: () => onSelected(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      alignment: Alignment.center,
                      constraints: const BoxConstraints(minHeight: 42),
                      decoration: BoxDecoration(
                        color: selectedIndex == index
                            ? AppColors.snow
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(
                          AppTokens.radiusInput,
                        ),
                        border: selectedIndex == index
                            ? Border.all(color: AppColors.fog)
                            : null,
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: selectedIndex == index
                              ? AppColors.obsidian
                              : AppColors.steel,
                          fontSize: 12,
                          fontWeight: selectedIndex == index
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
