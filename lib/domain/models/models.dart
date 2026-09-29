class Photographer {
  final String id;
  final String name;
  final String avatar;
  final String cover;
  final String city;
  final List<String> styles;
  final int pricePerSession;
  final double rating;
  final int reviewCount;
  final String bio;
  final int experienceYears;
  final List<String> portfolio;
  final List<PhotographerPackage> packages;
  final bool featured;
  final String rank;

  Photographer({
    required this.id,
    required this.name,
    required this.avatar,
    required this.cover,
    required this.city,
    required this.styles,
    required this.pricePerSession,
    required this.rating,
    required this.reviewCount,
    required this.bio,
    required this.experienceYears,
    required this.portfolio,
    this.packages = const [],
    this.featured = false,
    this.rank = 'Pro',
  });

  Photographer copyWith({
    String? name,
    String? city,
    String? bio,
    int? pricePerSession,
    int? experienceYears,
    List<String>? styles,
    List<String>? portfolio,
    List<PhotographerPackage>? packages,
  }) => Photographer(
    id: id,
    name: name ?? this.name,
    avatar: avatar,
    cover: cover,
    city: city ?? this.city,
    styles: styles ?? this.styles,
    pricePerSession: pricePerSession ?? this.pricePerSession,
    rating: rating,
    reviewCount: reviewCount,
    bio: bio ?? this.bio,
    experienceYears: experienceYears ?? this.experienceYears,
    portfolio: portfolio ?? this.portfolio,
    packages: packages ?? this.packages,
    featured: featured,
    rank: rank,
  );
}

class PhotographerPackage {
  final String id;
  final String name;
  final String duration;
  final int price;
  final String description;
  final int photoCount;
  final double durationHours;
  final int deliveryDays;

  PhotographerPackage({
    required this.id,
    required this.name,
    required this.duration,
    required this.price,
    this.description = '',
    this.photoCount = 20,
    this.durationHours = 2,
    this.deliveryDays = 7,
  });
}

enum BookingStatus {
  awaitingDeposit,
  pending,
  confirmed,
  held,
  released,
  cancelled,
}

enum CollaborationStatus { invited, accepted, declined }

class BookingCollaborator {
  const BookingCollaborator({required this.photographerId,
    required this.photographerName, required this.sharePct,
    this.status = CollaborationStatus.invited});
  final String photographerId;
  final String photographerName;
  final int sharePct;
  final CollaborationStatus status;

  BookingCollaborator copyWith({CollaborationStatus? status}) =>
      BookingCollaborator(photographerId: photographerId,
          photographerName: photographerName, sharePct: sharePct,
          status: status ?? this.status);
}

class Booking {
  final String id;
  final String clientId;
  final String clientName;
  final String photographerId;
  final String photographerName;
  final String style;
  final String date;
  final String location;
  final int price;
  final String? packageId;
  final String? packageName;
  final int? promisedPhotos;
  final double? durationHours;
  final int? deliveryDays;
  final String? timeSlot;
  final String? contactPhone;
  final String? note;
  final int depositAmount;
  final int deliveredPhotos;
  final List<String> deliveredPhotoUrls;
  final List<BookingCollaborator> collaborators;
  final BookingStatus status;

  Booking({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.photographerId,
    required this.photographerName,
    required this.style,
    required this.date,
    required this.location,
    required this.price,
    this.packageId,
    this.packageName,
    this.promisedPhotos,
    this.durationHours,
    this.deliveryDays,
    this.timeSlot,
    this.contactPhone,
    this.note,
    this.depositAmount = 0,
    this.deliveredPhotos = 0,
    this.deliveredPhotoUrls = const [],
    this.collaborators = const [],
    this.status = BookingStatus.pending,
  });

  Booking copyWith({
    BookingStatus? status,
    int? deliveredPhotos,
    List<String>? deliveredPhotoUrls,
    List<BookingCollaborator>? collaborators,
  }) => Booking(
    id: id,
    clientId: clientId,
    clientName: clientName,
    photographerId: photographerId,
    photographerName: photographerName,
    style: style,
    date: date,
    location: location,
    price: price,
    packageId: packageId,
    packageName: packageName,
    promisedPhotos: promisedPhotos,
    durationHours: durationHours,
    deliveryDays: deliveryDays,
    timeSlot: timeSlot,
    contactPhone: contactPhone,
    note: note,
    depositAmount: depositAmount,
    deliveredPhotos: deliveredPhotos ?? this.deliveredPhotos,
    deliveredPhotoUrls: deliveredPhotoUrls ?? this.deliveredPhotoUrls,
    collaborators: collaborators ?? this.collaborators,
    status: status ?? this.status,
  );
}

class User {
  final String id;
  final String name;
  final String email;
  final String role; // 'client' or 'photographer'
  final String phone;
  final String birthday;
  final String gender;
  final String city;
  final String addressDetail;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone = '',
    this.birthday = '',
    this.gender = '',
    this.city = '',
    this.addressDetail = '',
  });

  User copyWith({
    String? name,
    String? phone,
    String? birthday,
    String? gender,
    String? city,
    String? addressDetail,
  }) => User(
    id: id,
    name: name ?? this.name,
    email: email,
    role: role,
    phone: phone ?? this.phone,
    birthday: birthday ?? this.birthday,
    gender: gender ?? this.gender,
    city: city ?? this.city,
    addressDetail: addressDetail ?? this.addressDetail,
  );
}
