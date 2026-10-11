enum UserRole {
  worker('Pencari Kerja'),
  employer('Penyedia Kerja / UMKM');

  final String label;
  const UserRole(this.label);

  static UserRole fromName(String? name) => UserRole.values.firstWhere(
        (r) => r.name == name,
        orElse: () => UserRole.worker,
      );
}

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String phone;
  final String location; // Contoh: Medan Kota, Medan Helvetia, dll
  final List<String> skills; // Keahlian utama (misal: Pertukangan, Kasir, Desain)
  final UserRole role;
  final String bio;
  final bool isProfileComplete;
  final String createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.location,
    this.skills = const [],
    required this.role,
    this.bio = '',
    this.isProfileComplete = false,
    required this.createdAt,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) => UserModel(
        uid: uid,
        email: map['email'] as String? ?? '',
        fullName: map['fullName'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        location: map['location'] as String? ?? '',
        skills: List<String>.from(map['skills'] as List? ?? const []),
        role: UserRole.fromName(map['role'] as String?),
        bio: map['bio'] as String? ?? '',
        isProfileComplete: map['isProfileComplete'] as bool? ?? false,
        createdAt: map['createdAt'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'email': email,
        'fullName': fullName,
        'phone': phone,
        'location': location,
        'skills': skills,
        'role': role.name,
        'bio': bio,
        'isProfileComplete': isProfileComplete,
        'createdAt': createdAt,
      };
}