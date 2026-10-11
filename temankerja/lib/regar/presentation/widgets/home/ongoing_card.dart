import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';
import 'package:inovasi_sumut/regar/presentation/pages/pusat_pekerjaan_page.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/common/kk_widgets.dart';

/// Widget Realtime yang mendengarkan perubahan daftar tugas berjalan dari Firestore
class OngoingCardRealtime extends StatelessWidget {
  final String userId;
  final VoidCallback? onManage; // Disesuaikan agar cocok dengan home_page.dart

  const OngoingCardRealtime({
    super.key,
    required this.userId,
    this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('job_offers').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final allDocs = snapshot.data!.docs;

        // Filter pekerjaan berjalan milik Klien maupun Pekerja
        final ongoingDocs = allDocs.where((doc) {
          final data = doc.data();
          final postedByUid = data['postedByUid']?.toString() ?? '';
          final workerId = data['workerId']?.toString() ?? '';
          final applicantUid = data['applicantUid']?.toString() ?? '';
          final acceptedWorkerUid = data['acceptedWorkerUid']?.toString() ?? '';

          final bool isRelatedUser = postedByUid == userId ||
              workerId == userId ||
              applicantUid == userId ||
              acceptedWorkerUid == userId;

          final status = (data['status'] ?? '').toString().toLowerCase();
          final progress = (data['progressStatus'] ?? '').toString().toLowerCase();

          final bool isOngoingStatus = status == 'accepted' ||
              status == 'taken' ||
              status == 'ongoing' ||
              status == 'in_progress' ||
              status == 'pending_verification' ||
              progress == 'in_progress' ||
              progress == 'waiting_verification';

          return isRelatedUser && isOngoingStatus;
        }).toList();

        if (ongoingDocs.isEmpty) {
          return const SizedBox.shrink(); // Sembunyikan jika tidak ada pekerjaan yang berjalan
        }

        final count = ongoingDocs.length;
        final firstTitle = ongoingDocs.first.data()['title'] ??
            ongoingDocs.first.data()['jobTitle'] ??
            'Pekerjaan Jasa';

        return OngoingCard(
          count: count,
          firstTitle: firstTitle.toString(),
          onManage: () {
            if (onManage != null) {
              onManage!();
            } else {
              // Pindah langsung ke PusatPekerjaanPage jika callback null
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PusatPekerjaanPage(),
                ),
              );
            }
          },
        );
      },
    );
  }
}

/// Widget Tampilan Murni (Stateless)
class OngoingCard extends StatelessWidget {
  final int count;
  final String? firstTitle;
  final VoidCallback onManage;

  const OngoingCard({
    super.key,
    required this.count,
    required this.firstTitle,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    return KkCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: KkColors.greenSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.handyman, color: KkColors.green, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count Pekerjaan Sedang Ditangani',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 13),
                ),
                const SizedBox(height: 4),
                const KkPill('Tugas Berjalan'),
                if (firstTitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    firstTitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: KkColors.muted),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: KkColors.green),
            onPressed: onManage,
            child: Text('Kelola ($count)'),
          ),
        ],
      ),
    );
  }
}