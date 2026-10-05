enum JobType {
  harian('Harian'),
  fullTime('Full Time'),
  freelance('Freelance'),
  proyek('Proyek');

  final String label;
  const JobType(this.label);

  static JobType fromName(String? name) => JobType.values.firstWhere(
        (t) => t.name == name,
        orElse: () => JobType.harian,
      );
}

class JobModel {
  final String id;
  final String title;
  final String company;
  final String location;
  final String salary;
  final JobType type;
  final String category;
  final String description;
  final List<String> requirements;
  final String postedAgo;

  const JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.type,
    required this.category,
    this.description = '',
    this.requirements = const [],
    this.postedAgo = '',
  });

  /// Dipakai nanti saat data diambil dari Firestore.
  factory JobModel.fromMap(String id, Map<String, dynamic> map) => JobModel(
        id: id,
        title: map['title'] as String? ?? '',
        company: map['company'] as String? ?? '',
        location: map['location'] as String? ?? '',
        salary: map['salary'] as String? ?? '',
        type: JobType.fromName(map['type'] as String?),
        category: map['category'] as String? ?? '',
        description: map['description'] as String? ?? '',
        requirements:
            List<String>.from(map['requirements'] as List? ?? const []),
        postedAgo: map['postedAgo'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'company': company,
        'location': location,
        'salary': salary,
        'type': type.name,
        'category': category,
        'description': description,
        'requirements': requirements,
        'postedAgo': postedAgo,
      };
}
