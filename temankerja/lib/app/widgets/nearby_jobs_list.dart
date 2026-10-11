import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';
import 'package:inovasi_sumut/regar/data/models/job_model.dart';
import 'package:inovasi_sumut/regar/data/repositories/worker_repository.dart';
import 'package:inovasi_sumut/regar/presentation/pages/detail_kerja_page.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/jobs/job_card.dart';

class NearbyJobsList extends StatelessWidget {
  const NearbyJobsList({super.key});

  JobType _parseJobType(String? typeStr) {
    if (typeStr == null || typeStr.isEmpty) return JobType.values.first;
    return JobType.values.firstWhere(
      (e) => e.name.toLowerCase() == typeStr.toLowerCase(),
      orElse: () => JobType.values.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('job_offers')
          .where('status', isEqualTo: 'open')
          .where('expiredAt', isGreaterThan: DateTime.now())
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: CircularProgressIndicator(color: KkColors.green),
            ),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Gagal memuat lowongan: ${snapshot.error}'),
          );
        }

        final docs = (snapshot.data?.docs ?? []).where((doc) {
          final data = doc.data();
          final category = (data['category'] ?? '').toString().toLowerCase();

          // Identifikasi pembuat postingan
          final creatorId = data['postedByUid'] ??
              data['createdBy'] ??
              data['userId'] ??
              '';

          final companyName = (data['company'] ?? data['workerEmail'] ?? '')
              .toString()
              .toLowerCase();
          final currentUserName = (currentUser?.displayName ?? '').toLowerCase();
          final currentUserEmail = (currentUser?.email ?? '').toLowerCase();

          final isOwnJobByUid = currentUser != null &&
              currentUser.uid.isNotEmpty &&
              creatorId == currentUser.uid;
          final isOwnJobByName = currentUserName.isNotEmpty &&
              companyName.isNotEmpty &&
              companyName == currentUserName;
          final isOwnJobByEmail = currentUserEmail.isNotEmpty &&
              companyName.isNotEmpty &&
              companyName == currentUserEmail;

          // Cek kategori Gotong Royong
          final isGotongRoyongCategory = category.contains('gotong') ||
              category.contains('sosial') ||
              category.contains('bakti');

          // Deteksi tipe postingan: tawaran jasa pekerja vs lowongan pemberi kerja
          final String rawType = (data['postType'] ?? data['type'] ?? '')
              .toString()
              .toLowerCase();
          final bool isWorkerProfile = rawType == 'worker_profile' ||
              rawType == 'jasa' ||
              rawType == 'tawaran_jasa';

          // FILTER: Hanya Lowongan Pemberi Kerja, Bukan Buatan Sendiri, Bukan Jasa
          return !isGotongRoyongCategory &&
              !isOwnJobByUid &&
              !isOwnJobByName &&
              !isOwnJobByEmail &&
              !isWorkerProfile;
        }).toList();

        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Belum ada lowongan terdekat dari pengguna lain',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return ListenableBuilder(
          listenable: workerRepository,
          builder: (context, _) => Column(
            children: docs.map<Widget>((doc) {
              final data = doc.data();
              final category = data['category'] ?? 'Umum';

              final String rawType = (data['postType'] ?? data['type'] ?? '')
                  .toString()
                  .toLowerCase();
              final bool isWorkerOffer = rawType == 'worker_profile' ||
                  rawType == 'jasa' ||
                  rawType == 'tawaran_jasa';

              final job = JobModel(
                id: doc.id,
                title: data['title'] ?? 'Tanpa Judul',
                company: data['company'] ?? data['workerEmail'] ?? 'Pekerja Profesional',
                category: category,
                type: _parseJobType(data['type'] as String?),
                description: data['description'] ?? '',
                salary: (data['cleanSalary'] ?? data['salary'] as num?)?.toDouble() ?? 0.0,
                location: data['location'] ?? 'Medan',
                isSkillExchangeable: data['isSkillExchangeable'] ?? false,
              );

              final String applicantUid = data['applicantUid'] ?? '';
              final bool isAppliedInFirestore =
                  (currentUser != null && applicantUid == currentUser.uid);
              final bool isApplied =
                  isAppliedInFirestore || workerRepository.isApplied(job.id);

              return JobCard(
                job: job,
                applied: isApplied,
                isWorkerOffer: isWorkerOffer,
                actionButtonText: isWorkerOffer
                    ? (isApplied ? 'Sudah Diajak' : 'Ajak Bekerja')
                    : (isApplied ? 'Sudah Dilamar' : 'Lamar Pekerjaan'),
                onTap: () => showDetailKerjaBottomSheet(context, job),
              );
            }).toList().cast<Widget>(),
          ),
        );
      },
    );
  }
}