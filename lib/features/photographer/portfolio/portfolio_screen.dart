import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_creator_mobile/core/theme/app_colors.dart';
import 'package:lens_creator_mobile/core/widgets/surface_card.dart';
import 'package:lens_creator_mobile/core/widgets/lens_badge.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  bool isEditing = false;

  // Mock data
  String avatar = 'https://i.pravatar.cc/150?img=11';
  String name = 'Studio Ánh Sáng';
  String city = 'Hồ Chí Minh';
  double rating = 4.9;
  int reviewCount = 120;
  int experienceYears = 5;
  int pricePerSession = 1500000;
  List<String> styles = ['Chân dung', 'Sự kiện', 'Tiệc cưới'];
  String bio =
      'Chuyên cung cấp dịch vụ nhiếp ảnh chuyên nghiệp tại TP.HCM. Với 5 năm kinh nghiệm trong lĩnh vực chân dung và tiệc cưới, tôi cam kết mang lại những bức ảnh tự nhiên và cảm xúc nhất.';

  List<String> portfolio = [
    'https://picsum.photos/seed/p1/300/400',
    'https://picsum.photos/seed/p2/400/300',
    'https://picsum.photos/seed/p3/300/300',
    'https://picsum.photos/seed/p4/300/500',
    'https://picsum.photos/seed/p5/400/400',
  ];

  final List<String> allStyles = [
    'Chân dung',
    'Sự kiện',
    'Tiệc cưới',
    'Sản phẩm',
    'Kỷ yếu',
    'Ngoại cảnh',
  ];

  late TextEditingController _bioCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _expCtrl;
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    _bioCtrl = TextEditingController(text: bio);
    _priceCtrl = TextEditingController(text: pricePerSession.toString());
    _expCtrl = TextEditingController(text: experienceYears.toString());
    _selectedCity = city;
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    _priceCtrl.dispose();
    _expCtrl.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      isEditing = !isEditing;
      if (isEditing) {
        // Reset controllers if entering edit mode
        _bioCtrl.text = bio;
        _priceCtrl.text = pricePerSession.toString();
        _expCtrl.text = experienceYears.toString();
        _selectedCity = city;
      }
    });
  }

  void _saveProfile() {
    setState(() {
      bio = _bioCtrl.text;
      pricePerSession = int.tryParse(_priceCtrl.text) ?? pricePerSession;
      experienceYears = int.tryParse(_expCtrl.text) ?? experienceYears;
      if (_selectedCity != null) city = _selectedCity!;
      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mist,
      appBar: AppBar(
        backgroundColor: AppColors.snow,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            isEditing ? Icons.close : Icons.arrow_back,
            color: AppColors.obsidian,
          ),
          onPressed: () {
            if (isEditing) {
              _toggleEdit(); // Cancel edit
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          isEditing ? 'Chỉnh sửa hồ sơ' : 'Hồ sơ năng lực',
          style: const TextStyle(
            color: AppColors.obsidian,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.check, color: AppColors.ember),
              onPressed: _saveProfile,
            )
          else
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.obsidian),
              onPressed: _toggleEdit,
            ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: isEditing ? _buildEditMode() : _buildViewMode(),
      ),
    );
  }

  Widget _buildViewMode() {
    return SingleChildScrollView(
      key: const ValueKey('view'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.pebble,
                      backgroundImage: NetworkImage(avatar),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.obsidian,
                                  ),
                                ),
                              ),
                              Text(
                                '${(pricePerSession / 1000).toStringAsFixed(0)}k+',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ember,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            children: [
                              _buildIconText(Icons.location_on_outlined, city),
                              _buildIconText(
                                Icons.star,
                                '$rating ($reviewCount)',
                                iconColor: Colors.orange,
                              ),
                              _buildIconText(
                                Icons.work_outline,
                                '$experienceYears năm',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: styles
                                .map(
                                  (s) => LensBadge(
                                    text: s,
                                    type: BadgeType.darkOverlay,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: AppColors.fog),
                const SizedBox(height: 16),
                Text(
                  bio,
                  style: const TextStyle(
                    color: AppColors.slate,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ).animate().slideY(begin: 0.1, end: 0).fade(),
          const SizedBox(height: 32),
          Text(
            'Tác phẩm (${portfolio.length} ảnh)',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.obsidian,
            ),
          ).animate().fade(delay: 100.ms),
          const SizedBox(height: 16),
          if (portfolio.isEmpty)
            _buildEmptyGallery()
          else
            _buildGalleryGrid(false).animate().fade(delay: 200.ms),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text, {Color? iconColor}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: iconColor ?? AppColors.steel),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: AppColors.steel, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildEmptyGallery() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.pebble),
      ),
      child: Center(
        child: Column(
          children: const [
            Icon(
              Icons.image_not_supported_outlined,
              size: 48,
              color: AppColors.steel,
            ),
            SizedBox(height: 16),
            Text(
              'Chưa có tác phẩm nào',
              style: TextStyle(
                color: AppColors.steel,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditMode() {
    return SingleChildScrollView(
      key: const ValueKey('edit'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(avatar),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.obsidian,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.snow, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: AppColors.snow,
                            size: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildLabel('Tỉnh / Thành phố'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCity,
                  decoration: _inputDeco(),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.obsidian,
                  ),
                  items: ['Hồ Chí Minh', 'Hà Nội', 'Đà Nẵng'].map((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCity = val;
                    });
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Giá khởi điểm'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _priceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _inputDeco(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Năm kinh nghiệm'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _expCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _inputDeco(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildLabel('Phong cách chụp'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allStyles.map((s) {
                    final isSelected = styles.contains(s);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            styles.remove(s);
                          } else {
                            styles.add(s);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.obsidian
                              : AppColors.snow,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.obsidian
                                : AppColors.pebble,
                          ),
                        ),
                        child: Text(
                          s,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.snow
                                : AppColors.steel,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                _buildLabel('Giới thiệu bản thân'),
                const SizedBox(height: 8),
                TextField(
                  controller: _bioCtrl,
                  maxLines: 4,
                  decoration: _inputDeco(),
                ),
              ],
            ),
          ).animate().slideY(begin: 0.1, end: 0).fade(),
          const SizedBox(height: 32),
          const Text(
            'Chỉnh sửa Tác phẩm',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.obsidian,
            ),
          ),
          const SizedBox(height: 16),
          _buildGalleryGrid(true),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.obsidian,
        fontSize: 14,
      ),
    );
  }

  InputDecoration _inputDeco() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.mist,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.obsidian, width: 1.5),
      ),
    );
  }

  Widget _buildGalleryGrid(bool isEditMode) {
    int itemCount = portfolio.length + (isEditMode ? 1 : 0);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8, // Slightly taller images
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (isEditMode && index == portfolio.length) {
          // Add image button
          return GestureDetector(
            onTap: () {
              // Add image logic
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.mist,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.steel.withOpacity(0.5),
                  style: BorderStyle.solid,
                  width: 1.5,
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 32, color: AppColors.steel),
                    SizedBox(height: 8),
                    Text(
                      'Thêm ảnh',
                      style: TextStyle(
                        color: AppColors.steel,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final imgUrl = portfolio[index];
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(imgUrl, fit: BoxFit.cover),
            ),
            if (isEditMode)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      portfolio.removeAt(index);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 14,
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
