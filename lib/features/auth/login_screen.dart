import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/surface_card.dart';
import '../../core/widgets/lens_text_field.dart';
import '../../providers/data_providers.dart';
import '../../data/mock_database.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _login() {
    // Mock login action
    ref.read(authUserProvider.notifier).setUser(MockDatabase.photographerUser);
    context.go('/photographer_home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mist,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 40.0,
            ),
            child:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo & Title
                    const Center(
                      child: Column(
                        children: [
                          Icon(
                            LucideIcons.camera,
                            size: 64,
                            color: AppColors.obsidian,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Lens Creator',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.obsidian,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Manage your photography business',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.slate,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Auth Card
                    SurfaceCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          // Custom Tab Bar
                          Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: AppColors.fog),
                              ),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              indicatorColor: AppColors.obsidian,
                              indicatorWeight: 3,
                              labelColor: AppColors.obsidian,
                              unselectedLabelColor: AppColors.ash,
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                              tabs: const [
                                Tab(text: 'Sign In'),
                                Tab(text: 'Sign Up'),
                              ],
                            ),
                          ),

                          // Tab Content
                          SizedBox(
                            height: 380, // Fixed height for content to avoid infinite constraints
                            child: TabBarView(
                              controller: _tabController,
                              children: [_buildLoginTab(), _buildSignUpTab()],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Social Auth
                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppColors.pebble)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR CONTINUE WITH',
                            style: TextStyle(
                              color: AppColors.ash,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: AppColors.pebble)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialBtn(Icons.apple, 'Apple'),
                        const SizedBox(width: 16),
                        _buildSocialBtn(Icons.g_mobiledata, 'Google'),
                      ],
                    ),
                  ],
                ).animate().fade().slideY(
                  begin: 0.1,
                  end: 0,
                  duration: 400.ms,
                  curve: Curves.easeOut,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Email Address',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.obsidian,
            ),
          ),
          const SizedBox(height: 8),
          const LensTextField(
            hintText: 'creator@lens.com',
            prefixIcon: LucideIcons.mail,
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Password',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.obsidian,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Forgot?',
                  style: TextStyle(
                    color: AppColors.ember,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LensTextField(
            hintText: '••••••••',
            prefixIcon: LucideIcons.lock,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                color: AppColors.ash,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),

          const Spacer(),
          PrimaryButton(text: 'Sign In', onPressed: _login),
        ],
      ),
    );
  }

  Widget _buildSignUpTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Full Name',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.obsidian,
            ),
          ),
          const SizedBox(height: 8),
          const LensTextField(
            hintText: 'Studio Name or Your Name',
            prefixIcon: LucideIcons.user,
          ),
          const SizedBox(height: 16),

          const Text(
            'Email Address',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.obsidian,
            ),
          ),
          const SizedBox(height: 8),
          const LensTextField(
            hintText: 'creator@lens.com',
            prefixIcon: LucideIcons.mail,
          ),
          const SizedBox(height: 16),

          const Text(
            'Password',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.obsidian,
            ),
          ),
          const SizedBox(height: 8),
          LensTextField(
            hintText: 'Create a strong password',
            prefixIcon: LucideIcons.lock,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                color: AppColors.ash,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),

          const Spacer(),
          PrimaryButton(text: 'Create Account', onPressed: _login),
        ],
      ),
    );
  }

  Widget _buildSocialBtn(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.pebble),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.obsidian),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.obsidian,
            ),
          ),
        ],
      ),
    );
  }
}
