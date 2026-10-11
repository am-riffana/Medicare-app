class DoctorModel {
  final String id;
  final String? userId;
  final String? specializationId;
  final String name;
  final String? qualification;
  final int experienceYears;
  final double consultationFee;
  final String? about;
  final String? profileImage;
  final String? clinicName;
  final String? clinicAddress;
  final String? phone;
  final double rating;
  final int totalReviews;
  final bool isAvailable;
  final bool isVerified;

  const DoctorModel({
    required this.id,
    this.userId,
    this.specializationId,
    required this.name,
    this.qualification,
    required this.experienceYears,
    required this.consultationFee,
    this.about,
    this.profileImage,
    this.clinicName,
    this.clinicAddress,
    this.phone,
    required this.rating,
    required this.totalReviews,
    required this.isAvailable,
    required this.isVerified,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      specializationId: json['specialization_id'] as String?,
      name: json['name'] as String? ?? 'Doctor',
      qualification: json['qualification'] as String?,
      experienceYears:
          (json['experience_years'] as num?)?.toInt() ?? 0,
      consultationFee:
          (json['consultation_fee'] as num?)?.toDouble() ?? 0.0,
      about: json['about'] as String?,
      profileImage: json['profile_image'] as String?,
      clinicName: json['clinic_name'] as String?,
      clinicAddress: json['clinic_address'] as String?,
      phone: json['phone'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      isAvailable: json['is_available'] as bool? ?? true,
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'specialization_id': specializationId,
      'name': name,
      'qualification': qualification,
      'experience_years': experienceYears,
      'consultation_fee': consultationFee,
      'about': about,
      'profile_image': profileImage,
      'clinic_name': clinicName,
      'clinic_address': clinicAddress,
      'phone': phone,
      'rating': rating,
      'total_reviews': totalReviews,
      'is_available': isAvailable,
      'is_verified': isVerified,
    };
  }
}