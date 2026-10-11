import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';

/// Kartu hijau di paling atas Beranda: sapaan + 3 angka kontribusi realtime.
class HeroStatsCard extends StatelessWidget {
  final String name;

  const HeroStatsCard({
    super.key,
    required this.name,
  });

  static String _angka(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
      b.write(s[i]);
    }
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [KkColors.green, Color(0xFF1F5E3A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0x33FFFFFF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Satu Keahlian, Satu Kesempatan, Satu Gerakan.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Halo, $name!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Pilih layanan yang Anda butuhkan hari ini.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Container Tampilan Realtime Stats
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0x26FFFFFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: (user != null)
                  ? FirebaseFirestore.instance
                      .collection('job_offers')
                      .snapshots()
                  : null,
              builder: (context, snapshot) {
                int kerjaSelesaiCount = 0;
                int lamaranMasukCount = 0;
                int pekerjaanSekarangCount = 0;

                if (user != null && snapshot.hasData) {
                  final docs = snapshot.data!.docs;

                  for (final doc in docs) {
                    final data = doc.data();
                    final postedByUid = data['postedByUid']?.toString() ?? '';
                    final applicantUid = data['applicantUid']?.toString() ?? '';
                    final workerId = data['workerId']?.toString() ?? '';
                    final acceptedWorkerUid =
                        data['acceptedWorkerUid']?.toString() ?? '';
                    final status =
                        (data['status'] ?? 'open').toString().toLowerCase();
                    final progressStatus = (data['progressStatus'] ?? '')
                        .toString()
                        .toLowerCase();

                    // 1. Kerja Selesai: Dokumen yang statusnya completed / done
                    final bool isCompleted = status == 'completed' ||
                        status == 'done' ||
                        progressStatus == 'completed';
                    final bool isMyJobAsWorkerOrOwner =
                        postedByUid == user.uid ||
                            workerId == user.uid ||
                            applicantUid == user.uid;

                    if (isCompleted && isMyJobAsWorkerOrOwner) {
                      kerjaSelesaiCount++;
                    }

                    // 2. Lamaran Masuk: Diposting oleh user, ada pelamar, dan status masih pending/open
                    final bool isMyJob = postedByUid == user.uid;
                    final bool hasApplicant = applicantUid.isNotEmpty;
                    final bool isPendingStatus = status == 'open' ||
                        status == 'applied' ||
                        status == 'pending';

                    if (isMyJob && hasApplicant && isPendingStatus) {
                      lamaranMasukCount++;
                    }

                    // 3. Pekerjaan Sekarang: Status in_progress atau accepted
                    final bool isInProgress = status == 'in_progress' ||
                        status == 'accepted' ||
                        progressStatus == 'in_progress';
                    final bool isWorkerInJob = workerId == user.uid ||
                        acceptedWorkerUid == user.uid ||
                        (applicantUid == user.uid && status == 'accepted');
                    final bool isOwnerInJob = postedByUid == user.uid;

                    if (isInProgress && (isWorkerInJob || isOwnerInJob)) {
                      pekerjaanSekarangCount++;
                    }
                  }
                }

                return Row(
                  children: [
                    Expanded(
                      child: _Stat(_angka(kerjaSelesaiCount), 'Kerja Selesai'),
                    ),
                    const _VDivider(),
                    Expanded(
                      child: _Stat(_angka(lamaranMasukCount), 'Lamaran Masuk'),
                    ),
                    const _VDivider(),
                    Expanded(
                      child: _Stat(
                        _angka(pekerjaanSekarangCount),
                        'Pekerjaan Aktif',
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}

class _VDivider extends StatelessWidget {
  const _VDivider();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 30, color: const Color(0x33FFFFFF));
}