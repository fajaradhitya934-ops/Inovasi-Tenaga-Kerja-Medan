import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/swap/swap_model.dart';

/// Semua urusan Firestore untuk fitur Tukar Skill ada di sini.
class SwapRepository {
  static const int pointsPerSwap = 15;

  FirebaseFirestore get _db => FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('skill_swaps');

  static int _byNewest(SwapModel a, SwapModel b) {
    final now = DateTime.now();
    return (b.createdAt ?? now).compareTo(a.createdAt ?? now);
  }

  /// Penawaran yang masih terbuka (realtime).
  Stream<List<SwapModel>> watchOpen() {
    return _col.where('status', isEqualTo: 'open').snapshots().map((snap) {
      final list = snap.docs.map(SwapModel.fromDoc).toList();
      list.sort(_byNewest);
      return list;
    });
  }

  /// Semua pertukaran yang melibatkan [uid] (sebagai pemilik atau mitra).
  Stream<List<SwapModel>> watchMine(String uid) {
    return _col
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(SwapModel.fromDoc).toList();
      list.sort(_byNewest);
      return list;
    });
  }

  Future<void> create({
    required String uid,
    required String name,
    required String location,
    required String offerSkill,
    required String needSkill,
    required int hours,
    String note = '',
  }) async {
    await _col.add({
      'ownerUid': uid,
      'ownerName': name,
      'location': location,
      'offerSkill': offerSkill,
      'needSkill': needSkill,
      'hours': hours,
      'note': note,
      'status': 'open',
      'participants': [uid],
      'partnerUid': '',
      'partnerName': '',
      'doneBy': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Mitra mengambil penawaran. false kalau sudah diambil orang lain.
  Future<bool> request({
    required String swapId,
    required String uid,
    required String name,
  }) {
    final ref = _col.doc(swapId);
    return _db.runTransaction<bool>((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data();
      if (data == null) return false;
      if (data['status'] != 'open') return false;
      if (data['ownerUid'] == uid) return false;
      tx.update(ref, {
        'status': 'matched',
        'partnerUid': uid,
        'partnerName': name,
        'participants': FieldValue.arrayUnion([uid]),
        'matchedAt': FieldValue.serverTimestamp(),
      });
      return true;
    });
  }

  /// true kalau pertukaran jadi selesai (kedua pihak sudah konfirmasi).
  Future<bool> markDone({required String swapId, required String uid}) {
    final ref = _col.doc(swapId);
    return _db.runTransaction<bool>((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data();
      if (data == null || data['status'] != 'matched') return false;

      final done = List<String>.from(data['doneBy'] as List? ?? const []);
      if (!done.contains(uid)) done.add(uid);

      final owner = data['ownerUid'] as String? ?? '';
      final partner = data['partnerUid'] as String? ?? '';
      final both = done.contains(owner) && done.contains(partner);

      final update = <String, dynamic>{'doneBy': done};
      if (both) {
        update['status'] = 'done';
        update['completedAt'] = FieldValue.serverTimestamp();
      }
      tx.update(ref, update);

      if (both) {
        for (final u in [owner, partner]) {
          tx.set(
            _db.collection('users').doc(u),
            {'cpPoints': FieldValue.increment(pointsPerSwap)},
            SetOptions(merge: true),
          );
        }
      }
      return both;
    });
  }

  Future<void> cancel(String swapId) => _col.doc(swapId).delete();
}

final SwapRepository swapRepository = SwapRepository();
