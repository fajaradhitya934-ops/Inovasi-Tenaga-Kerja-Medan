import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inovasi_sumut/app/widgets/hero_stats_card.dart';
import 'package:inovasi_sumut/app/widgets/nearby_jobs_list.dart';
import 'package:inovasi_sumut/app/widgets/service_tile.dart';
import 'package:inovasi_sumut/fajar/presentation/pages/gotong_royong_detail_page.dart';
import 'package:inovasi_sumut/fajar/presentation/pages/worker/offer_job_page.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';
import 'package:inovasi_sumut/regar/core/utils/formatter.dart';

// Page & Repositories
import 'package:inovasi_sumut/regar/data/models/job_model.dart';
import 'package:inovasi_sumut/regar/data/repositories/worker_repository.dart';
import 'package:inovasi_sumut/regar/presentation/pages/cari_kerja_page.dart';
import 'package:inovasi_sumut/regar/presentation/pages/detail_kerja_page.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/common/kk_widgets.dart';

import 'package:inovasi_sumut/regar/presentation/widgets/home/offer_card.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/home/ongoing_card.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/home/saldo_history_sheet.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/home/wallet_card.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/jobs/job_card.dart';

/// Satu-satunya Beranda utama aplikasi.
class HomePage extends StatelessWidget {
  final VoidCallback onGoActivity;

  const HomePage({super.key, required this.onGoActivity});

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _soon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature segera hadir')),
    );
  }

  static String _formatRupiah(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  Future<void> _withdraw(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final walletDoc = await FirebaseFirestore.instance
        .collection('wallets')
        .doc(user.uid)
        .get();

    final int balance = (walletDoc.data()?['balance'] as num?)?.toInt() ?? 0;

    if (balance <= 0) {
      messenger.showSnackBar(const SnackBar(content: Text('Saldo kosong')));
      return;
    }

    if (!context.mounted) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tarik Saldo via QRIS'),
        content: Text(
          'Tarik seluruh saldo ${rupiah(balance)} ke e-wallet / rekening bank?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: KkColors.green),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Tarik'),
          ),
        ],
      ),
    );

    if (ok == true) {
      try {
        await FirebaseFirestore.instance
            .collection('wallets')
            .doc(user.uid)
            .update({'balance': 0});

        await FirebaseFirestore.instance.collection('withdrawals').add({
          'uid': user.uid,
          'amount': balance,
          'status': 'pending',
          'paymentMethod': 'QRIS',
          'createdAt': FieldValue.serverTimestamp(),
        });

        messenger.showSnackBar(
          const SnackBar(content: Text('Penarikan saldo diproses')),
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text('Gagal menarik saldo: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return SafeArea(
      child: ListenableBuilder(
        listenable: workerRepository,
        builder: (context, _) {
          final repo = workerRepository;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              KkHeader(notifCount: repo.offers.length),
              const SizedBox(height: 14),

              // HeroStatsCard dengan Firestore Realtime
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: (user != null)
                    ? FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .snapshots()
                    : null,
                builder: (context, userSnapshot) {
                  final userData = userSnapshot.data?.data();
                  final String name = userData?['name'] ??
                      user?.displayName ??
                      repo.profile.firstName;

                  return HeroStatsCard(
                    name: name,
                  );
                },
              ),

              const SizedBox(height: 14),

              WalletCard(
                hidden: repo.hideBalance,
                onToggle: repo.toggleBalance,
                onHistory: () => showSaldoHistorySheet(context),
                onWithdraw: () => _withdraw(context),
              ),

              const KkSectionTitle(Icons.grid_view_rounded, 'Layanan Utama'),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ServiceTile(
                        icon: Icons.search_rounded,
                        title: 'Cari Kerja',
                        subtitle: 'Temukan lowongan & proyek lokal',
                        bg: KkColors.blueSoft,
                        fg: KkColors.blue,
                        onTap: () => _open(context, const CariKerjaPage()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ServiceTile(
                        icon: Icons.work_outline_rounded,
                        title: 'Tawarkan Kerja',
                        subtitle: 'Lengkapi profil & tawarkan skill',
                        bg: KkColors.greenSoft,
                        fg: KkColors.green,
                        onTap: () => _open(context, const OfferJobPage()),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('jobs')
                            .where('category', isEqualTo: 'Gotong Royong')
                            .limit(1)
                            .snapshots(),
                        builder: (context, snapshot) {
                          String targetJobId = 'gotong_royong_1';
                          Map<String, dynamic>? initialData;

                          if (snapshot.hasData &&
                              snapshot.data!.docs.isNotEmpty) {
                            final doc = snapshot.data!.docs.first;
                            targetJobId = doc.id;
                            initialData = doc.data();
                            initialData['id'] = doc.id;
                          }

                          return ServiceTile(
                            icon: Icons.people_alt_outlined,
                            title: 'Gotong Royong',
                            subtitle: 'Proyek sosial & aksi masyarakat',
                            bg: KkColors.goldSoft,
                            fg: KkColors.goldText,
                            onTap: () => _open(
                              context,
                              GotongRoyongDetailPage(
                                jobId: targetJobId,
                                data: initialData,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ServiceTile(
                        icon: Icons.published_with_changes_rounded,
                        title: 'Tukar Skill',
                        subtitle: 'Barter keahlian tanpa uang',
                        bg: const Color(0xFFEADCF5),
                        fg: const Color(0xFF7B3FA0),
                        badge: 'Segera',
                        onTap: () => _soon(context, 'Tukar Skill'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Section Realtime Lamaran Masuk (Hanya Tampil bagi PEMILIK POSTINGAN)
              if (user != null)
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('job_offers')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    }

                    final allDocs = snapshot.data?.docs ?? [];

                    final appliedJobs = allDocs.where((doc) {
                      final data = doc.data();
                      final postedByUid = data['postedByUid']?.toString() ?? '';
                      final applicantUid = data['applicantUid']?.toString() ?? '';
                      final status = (data['status'] ?? 'open').toString().toLowerCase();

                      final bool hasApplicant = applicantUid.isNotEmpty;
                      final bool isPendingStatus = status == 'open' ||
                          status == 'applied' ||
                          status == 'pending';

                      // Hanya ambil jika postingan ini dibuat oleh user yang sedang login di HP/Laptop ini
                      final bool isMyJob = postedByUid == user.uid;

                      return isMyJob && hasApplicant && isPendingStatus;
                    }).toList();

                    if (appliedJobs.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        KkSectionTitle(
                          Icons.mail_outline,
                          'Lamaran Masuk (${appliedJobs.length})',
                        ),
                        for (final doc in appliedJobs)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: OfferCardRealtime(
                              offerId: doc.id,
                              onAccept: () async {
                                final data = doc.data();
                                final applicantUid = data['applicantUid'] ?? '';
                                await doc.reference.update({
                                  'status': 'accepted',
                                  'progressStatus': 'in_progress',
                                  'workerId': applicantUid,
                                  'acceptedWorkerUid': applicantUid,
                                  'acceptedAt': FieldValue.serverTimestamp(),
                                });

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Lamaran berhasil diterima (ACC)!'),
                                      backgroundColor: KkColors.green,
                                    ),
                                  );
                                }
                              },
                              onReject: () async {
                                await doc.reference.update({
                                  'applicantUid': '',
                                  'workerId': '',
                                  'status': 'open',
                                  'progressStatus': 'open',
                                });

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Pelamar telah ditolak.'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                      ],
                    );
                  },
                ),

              const SizedBox(height: 10),

              // Section Realtime Pekerjaan Sedang Ditangani (Ongoing Card)
              if (user != null)
                OngoingCardRealtime(
                  userId: user.uid,
                  onManage: onGoActivity,
                ),

              const SizedBox(height: 14),

              // Section Gotong Royong & Proyek Desa
              const KkSectionTitle(
                Icons.diversity_3_rounded,
                'Gotong Royong & Proyek Desa',
              ),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('jobs')
                    .where('category', isEqualTo: 'Gotong Royong')
                    .limit(1)
                    .snapshots(),
                builder: (context, snapshot) {
                  String targetJobId = 'gotong_royong_1';
                  Map<String, dynamic> projectData = {
                    'title': 'Pembangunan Posko Desa',
                    'location': 'PB SELAYANG 1',
                    'collectedAmount': 0.0,
                    'targetAmount': 0.0,
                    'physicalProgress': 0.0,
                  };

                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    final doc = snapshot.data!.docs.first;
                    targetJobId = doc.id;
                    projectData = doc.data();
                    projectData['id'] = doc.id;
                  }

                  final String title =
                      projectData['title'] ?? 'Pembangunan Posko Desa';
                  final String location =
                      projectData['location'] ?? 'PB SELAYANG 1';
                  final double collectedAmount =
                      (projectData['collectedAmount'] as num?)?.toDouble() ?? 0.0;
                  final double targetAmount =
                      (projectData['targetAmount'] as num?)?.toDouble() ?? 0.0;
                  final double physicalProgress =
                      (projectData['physicalProgress'] as num?)?.toDouble() ?? 0.0;

                  final double financialProgress = targetAmount > 0
                      ? (collectedAmount / targetAmount).clamp(0.0, 1.0)
                      : 0.0;

                  return Card(
                    color: Colors.green.shade50,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.green.shade200),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _open(
                        context,
                        GotongRoyongDetailPage(
                          jobId: targetJobId,
                          data: projectData,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.green,
                                  child: Icon(Icons.diversity_3,
                                      size: 18, color: Colors.white),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on,
                                              size: 12, color: Colors.grey),
                                          const SizedBox(width: 2),
                                          Text(
                                            location,
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right,
                                    color: Colors.green),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Progress Dana Terkumpul
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Dana Terkumpul',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${(financialProgress * 100).toInt()}%',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: financialProgress,
                                backgroundColor: Colors.white,
                                color: Colors.green,
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rp ${_formatRupiah(collectedAmount)} dari target Rp ${_formatRupiah(targetAmount)}',
                              style: TextStyle(
                                color: Colors.green.shade800,
                                fontSize: 11,
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Progress Fisik
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Progres Fisik',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${(physicalProgress * 100).toInt()}%',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: physicalProgress,
                                backgroundColor: Colors.white,
                                color: Colors.blueAccent,
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),

              // Section Lowongan Kerja Biasa
              KkSectionTitle(
                Icons.auto_awesome,
                'Lowongan Terdekat',
                trailing: TextButton(
                  onPressed: () => _open(context, const CariKerjaPage()),
                  child: const Text('Lihat Semua'),
                ),
              ),
              const NearbyJobsList(),

              const SizedBox(height: 16),

              // WIDGET BOX PENAWARAN JASA DENGAN SEARCH & SCROLLABLE CONTAINER
              _WorkerOffersBox(
                onSeeAll: () => _open(context, const CariKerjaPage()),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Widget Box Khusus untuk Pekerja & Penawaran Jasa
class _WorkerOffersBox extends StatefulWidget {
  final VoidCallback onSeeAll;

  const _WorkerOffersBox({super.key, required this.onSeeAll});

  @override
  State<_WorkerOffersBox> createState() => _WorkerOffersBoxState();
}

class _WorkerOffersBoxState extends State<_WorkerOffersBox> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetail(BuildContext context, JobModel job) {
    showDetailKerjaBottomSheet(context, job);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KkColors.green.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.handyman_rounded, size: 20, color: KkColors.green),
                  SizedBox(width: 8),
                  Text(
                    'Pekerja Siap Kerja',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: KkColors.text,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: widget.onSeeAll,
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: KkColors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Input Search Bar
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: KkColors.border),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim().toLowerCase();
                });
              },
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Cari keahlian atau nama pekerja...',
                hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                prefixIcon: const Icon(Icons.search, size: 18, color: KkColors.muted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        child: const Icon(Icons.clear, size: 16, color: KkColors.muted),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // StreamBuilder Daftar Pekerja dengan Scroll Container
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('job_offers')
                .where('status', isEqualTo: 'open')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: KkColors.green),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              final filteredDocs = docs.where((doc) {
                final data = doc.data();
                final postType = (data['postType'] ?? '').toString().toLowerCase();
                final postMode = (data['postMode'] ?? '').toString().toLowerCase();
                final postedByUid = data['postedByUid']?.toString() ?? '';

                final bool isWorkerOffer = postType == 'worker' ||
                    postType == 'worker_profile' ||
                    postMode == 'offer_service';

                if (!isWorkerOffer) return false;
                if (user != null && postedByUid == user.uid) return false;

                if (_searchQuery.isEmpty) return true;

                final title = (data['title'] ?? '').toString().toLowerCase();
                final company = (data['company'] ?? '').toString().toLowerCase();
                final category = (data['category'] ?? '').toString().toLowerCase();
                final description = (data['description'] ?? '').toString().toLowerCase();

                return title.contains(_searchQuery) ||
                    company.contains(_searchQuery) ||
                    category.contains(_searchQuery) ||
                    description.contains(_searchQuery);
              }).toList();

              if (filteredDocs.isEmpty) {
                return Container(
                  height: 100,
                  alignment: Alignment.center,
                  child: Text(
                    _searchQuery.isNotEmpty
                        ? 'Pekerja "$_searchQuery" tidak ditemukan'
                        : 'Belum ada penawaran jasa pekerja lain.',
                    style: const TextStyle(fontSize: 12, color: KkColors.muted),
                  ),
                );
              }

              return SizedBox(
                height: 280,
                child: Scrollbar(
                  thumbVisibility: true,
                  radius: const Radius.circular(4),
                  child: ListView.builder(
                    itemCount: filteredDocs.length,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(right: 6),
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      final data = doc.data();
                      final job = JobModel.fromMap(doc.id, data);

                      final String applicantUid = data['applicantUid'] ?? '';
                      final bool isAppliedInFirestore =
                          user != null && applicantUid == user.uid;
                      final bool isApplied = isAppliedInFirestore ||
                          workerRepository.isApplied(job.id);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: JobCard(
                          job: job,
                          applied: isApplied,
                          isWorkerOffer: true,
                          onTap: () => _openDetail(context, job),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}