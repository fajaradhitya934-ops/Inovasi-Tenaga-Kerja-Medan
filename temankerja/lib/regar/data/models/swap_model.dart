import 'package:cloud_firestore/cloud_firestore.dart';

enum SwapStatus {
  open('Terbuka'),
  matched('Berjalan'),
  done('Selesai');

  final String label;
  const SwapStatus(this.label);

  static SwapStatus fromName(String? name) => SwapStatus.values.firstWhere(
        (s) => s.name == name,
        orElse: () => SwapStatus.open,
      );
}

class SwapModel {
  final String id;
  final String ownerUid;
  final String ownerName;
  final String location;
  final String offerSkill; // yang ditawarkan pemilik
  final String needSkill; // yang dibutuhkan pemilik
  final int hours;
  final String note;
  final SwapStatus status;
  final String partnerUid;
  final String partnerName;
  final List<String> doneBy;
  final DateTime? createdAt;

  const SwapModel({
    required this.id,
    required this.ownerUid,
    required this.ownerName,
    required this.location,
    required this.offerSkill,
    required this.needSkill,
    required this.hours,
    required this.note,
    required this.status,
    required this.partnerUid,
    required this.partnerName,
    required this.doneBy,
    required this.createdAt,
  });

  factory SwapModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data() ?? <String, dynamic>{};
    final ts = m['createdAt'];
    return SwapModel(
      id: doc.id,
      ownerUid: m['ownerUid'] as String? ?? '',
      ownerName: m['ownerName'] as String? ?? 'Pengguna',
      location: m['location'] as String? ?? '',
      offerSkill: m['offerSkill'] as String? ?? '',
      needSkill: m['needSkill'] as String? ?? '',
      hours: (m['hours'] as num?)?.toInt() ?? 1,
      note: m['note'] as String? ?? '',
      status: SwapStatus.fromName(m['status'] as String?),
      partnerUid: m['partnerUid'] as String? ?? '',
      partnerName: m['partnerName'] as String? ?? '',
      doneBy: List<String>.from(m['doneBy'] as List? ?? const []),
      createdAt: ts is Timestamp ? ts.toDate() : null,
    );
  }
}
