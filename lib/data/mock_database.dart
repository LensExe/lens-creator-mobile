import '../domain/models/models.dart';

class MockDatabase {
  static final User customerUser = User(
    id: 'u1',
    name: 'Nguyễn Văn A',
    email: 'customer@lens.com',
    role: 'client',
  );
  static final User photographerUser = User(
    id: 'u2',
    name: 'Studio YC',
    email: 'photo@lens.com',
    role: 'photographer',
  );

  static User? currentUser;

  static final List<Photographer> photographers = [
    Photographer(
      id: 'p1',
      name: 'Alex Photography',
      avatar: 'https://i.pravatar.cc/150?u=p1',
      cover: 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?q=80&w=1000',
      city: 'Hồ Chí Minh',
      styles: ['Cưới', 'Chân dung'],
      pricePerSession: 2000000,
      rating: 4.8,
      reviewCount: 124,
      bio: 'Chuyên gia chụp ảnh cưới với 5 năm kinh nghiệm.',
      experienceYears: 5,
      portfolio: [
        'https://images.unsplash.com/photo-1511285560929-80b456fea0bc',
        'https://images.unsplash.com/photo-1519741497674-611481863552',
      ],
      packages: [
        PhotographerPackage(
          id: 'pkg1',
          name: 'Gói Tiêu chuẩn',
          duration: '2 giờ',
          price: 2000000,
        ),
        PhotographerPackage(
          id: 'pkg2',
          name: 'Gói Cao cấp',
          duration: '4 giờ',
          price: 3500000,
        ),
      ],
    ),
    Photographer(
      id: 'p2',
      name: 'Studio YC',
      avatar: 'https://i.pravatar.cc/150?u=p2',
      cover: 'https://images.unsplash.com/photo-1542038784456-1ea8e935640e?q=80&w=1000',
      city: 'Hà Nội',
      styles: ['Sản phẩm', 'Thương mại'],
      pricePerSession: 3500000,
      rating: 4.9,
      reviewCount: 89,
      bio: 'Studio chuyên chụp ảnh sản phẩm quảng cáo.',
      experienceYears: 7,
      portfolio: [
        'https://images.unsplash.com/photo-1542038784456-1ea8e935640e',
      ],
      packages: [
        PhotographerPackage(
          id: 'pkg3',
          name: 'Chụp Sản phẩm',
          duration: '3 giờ',
          price: 3500000,
        ),
      ],
    ),
  ];

  static List<Booking> bookings = [
    Booking(
      id: 'b1',
      clientId: 'u1',
      clientName: 'Nguyễn Văn A',
      photographerId: 'p2',
      photographerName: 'Studio YC',
      style: 'Sản phẩm',
      date: '2026-10-15',
      location: 'Quận 1, TP.HCM',
      price: 3500000,
      status: BookingStatus.pending,
    ),
    Booking(
      id: 'b2',
      clientId: 'u1',
      clientName: 'Nguyễn Văn A',
      photographerId: 'p1',
      photographerName: 'Alex Photography',
      style: 'Cưới',
      date: '2026-09-20',
      location: 'Đà Lạt',
      price: 2000000,
      status: BookingStatus.confirmed,
    ),
  ];
}
