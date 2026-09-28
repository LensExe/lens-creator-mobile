import 'package:flutter/material.dart';
import 'package:lens_creator_mobile/core/theme/app_colors.dart';
import 'package:lens_creator_mobile/core/widgets/primary_button.dart';
import 'package:go_router/go_router.dart';

class EditPackageScreen extends StatefulWidget {
  final String id;
  const EditPackageScreen({super.key, required this.id});

  @override
  State<EditPackageScreen> createState() => _EditPackageScreenState();
}

class _EditPackageScreenState extends State<EditPackageScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _descCtrl;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    // In a real app, you would fetch package details by ID
    _nameCtrl = TextEditingController(text: 'Chụp ảnh thẻ chuyên nghiệp');
    _priceCtrl = TextEditingController(text: '150000');
    _descCtrl = TextEditingController(
      text: 'Bao gồm makeup nhẹ, chụp không giới hạn, PTS và in 4 tấm 3x4, 4 tấm 4x6.',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mist,
      appBar: AppBar(
        backgroundColor: AppColors.mist,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.obsidian),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Chỉnh sửa gói',
          style: TextStyle(
            color: AppColors.obsidian,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Switch(
            value: _isActive,
            activeColor: AppColors.snow,
            activeTrackColor: AppColors.obsidian,
            inactiveThumbColor: AppColors.steel,
            inactiveTrackColor: AppColors.pebble,
            onChanged: (val) {
              setState(() {
                _isActive = val;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.snow,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    offset: Offset(0, 4),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tên gói chụp',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.obsidian,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameCtrl,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.obsidian,
                    ),
                    decoration: _inputDeco(hint: 'VD: Chụp ngoại cảnh cá nhân'),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(color: AppColors.fog),
                  ),

                  const Text(
                    'Giá (VNĐ)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.obsidian,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ember,
                    ),
                    decoration: _inputDeco(hint: 'VD: 1500000'),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(color: AppColors.fog),
                  ),

                  const Text(
                    'Mô tả dịch vụ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.obsidian,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descCtrl,
                    maxLines: 5,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.obsidian,
                      height: 1.5,
                    ),
                    decoration: _inputDeco(
                      hint: 'Nhập thông tin chi tiết gói chụp, thời gian, số lượng ảnh...',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.snow,
          border: Border(top: BorderSide(color: AppColors.pebble)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.mist,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  padding: const EdgeInsets.all(12),
                  onPressed: () {
                    // Trigger delete logic here
                    context.pop();
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PrimaryButton(
                  text: 'Lưu thay đổi',
                  onPressed: () {
                    // Trigger save logic here
                    context.pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppColors.steel,
        fontWeight: FontWeight.normal,
      ),
      filled: true,
      fillColor: AppColors.mist,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none, // Seamless look inside the white card
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.obsidian, width: 1.5),
      ),
    );
  }
}
