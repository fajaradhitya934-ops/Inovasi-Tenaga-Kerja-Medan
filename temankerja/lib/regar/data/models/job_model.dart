enum JobType {
  harian('Harian'),
  fullTime('Full Time'),
  freelance('Freelance'),
  proyek('Proyek');

  final String label;
  const JobType(this.label);

  static JobType fromName(String? name) => JobType.values.firstWhere(
        (t) => t.name.toLowerCase() == (name ?? '').toLowerCase(),
        orElse: () => JobType.harian,
      );
}

class JobModel {
  final String id;
  final String title;
  final String company;
  final String location;
  final String category;
  final double salary;
  final String description;
  final JobType type;
  final bool isSkillExchangeable;
  final List<String> requirements;
  final String postedAgo;
  final String phoneNumber;
  final String acceptedPaymentType;
  final String postType;

  const JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.category,
    required this.salary,
    required this.description,
    required this.type,
    this.isSkillExchangeable = false,
    this.requirements = const [],
    this.postedAgo = '',
    this.phoneNumber = '',
    this.acceptedPaymentType = 'cash',
    this.postType = 'worker_profile',
  });

  /// Factory untuk mengonversi data dari Firestore Map ke JobModel
  factory JobModel.fromMap(String id, Map<String, dynamic> map) => JobModel(
        id: id,
        title: map['title'] as String? ?? 'Tanpa Judul',
        company: map['company'] as String? ?? map['workerEmail'] as String? ?? 'Pekerja Profesional',
        location: map['location'] as String? ?? map['district'] as String? ?? 'Medan',
        category: map['category'] as String? ?? 'Umum',
        salary: (map['totalClientPay'] is num)
            ? (map['totalClientPay'] as num).toDouble()
            : (map['cleanSalary'] is num)
                ? (map['cleanSalary'] as num).toDouble()
                : (map['salary'] is num)
                    ? (map['salary'] as num).toDouble()
                    : double.tryParse(map['salary']?.toString() ?? '0') ?? 0.0,
        type: JobType.fromName(map['type'] as String?),
        description: map['description'] as String? ?? '',
        isSkillExchangeable: map['isSkillExchangeable'] as bool? ?? false,
        requirements: List<String>.from(map['requirements'] as List? ?? const []),
        postedAgo: map['postedAgo'] as String? ?? '',
        phoneNumber: map['phoneNumber'] as String? ?? '',
        acceptedPaymentType: map['acceptedPaymentType'] as String? ?? 'cash',
        postType: map['postType'] ?? 'worker_profile',
      );

  /// Mengonversi JobModel ke Map jika ingin dikirim/disimpan ke Firestore
  Map<String, dynamic> toMap() => {
        'title': title,
        'company': company,
        'location': location,
        'category': category,
        'salary': salary,
        'type': type.name,
        'description': description,
        'isSkillExchangeable': isSkillExchangeable,
        'requirements': requirements,
        'postedAgo': postedAgo,
        'phoneNumber': phoneNumber,
        'acceptedPaymentType': acceptedPaymentType,
      };
}