enum TaskStatus { berjalan, menungguVerifikasi, selesai }

class WorkerProfile {
  final String name;
  final String skill;
  final String email;
  final String whatsapp;
  final String area;
  final String about;
  final double rating;
  final int totalTasks;
  final int onTimePercent;

  const WorkerProfile({
    required this.name,
    required this.skill,
    required this.email,
    required this.whatsapp,
    required this.area,
    required this.about,
    required this.rating,
    required this.totalTasks,
    required this.onTimePercent,
  });

  String get firstName => name.split(' ').first;
}

class JobOffer {
  final String id;
  final String client;
  final String title;
  final String date;
  final String time;
  final String address;
  final int amount;

  const JobOffer({
    required this.id,
    required this.client,
    required this.title,
    required this.date,
    required this.time,
    required this.address,
    required this.amount,
  });
}

class WorkTask {
  final String id;
  final String client;
  final String title;
  final String location;
  final int amount;
  TaskStatus status;
  bool hasBefore;
  bool hasAfter;
  String note;

  WorkTask({
    required this.id,
    required this.client,
    required this.title,
    required this.location,
    required this.amount,
    this.status = TaskStatus.berjalan,
    this.hasBefore = false,
    this.hasAfter = false,
    this.note = '',
  });
}

class WalletTx {
  final String title;
  final String subtitle;
  final String time;

  /// positif = uang masuk, negatif = uang keluar
  final int amount;

  const WalletTx({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.time,
  });
}
