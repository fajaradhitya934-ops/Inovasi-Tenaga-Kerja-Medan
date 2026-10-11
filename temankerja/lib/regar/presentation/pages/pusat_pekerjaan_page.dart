import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';
import 'package:inovasi_sumut/regar/data/models/worker_models.dart';
import 'package:inovasi_sumut/regar/presentation/pages/cari_kerja_page.dart';
import 'package:inovasi_sumut/regar/presentation/pages/detail_tugas_page.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/common/kk_widgets.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/home/offer_card.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/tasks/task_card.dart';

class PusatPekerjaanPage extends StatefulWidget {
  const PusatPekerjaanPage({super.key});

  @override
  State<PusatPekerjaanPage> createState() => _PusatPekerjaanPageState();
}

class _PusatPekerjaanPageState extends State<PusatPekerjaanPage> {
  int _tab = 0;
  int _activeSubTab = 0; // 0 = Saya Kerjakan, 1 = Saya Berikan

  // Converter dari Firestore DocumentSnapshot ke model WorkTask
  WorkTask _mapToWorkTask(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    TaskStatus status = TaskStatus.berjalan;
    final statusStr = (data['status'] ?? '').toString().toLowerCase();
    final progressStr = (data['progressStatus'] ?? '').toString().toLowerCase();

    if (statusStr == 'completed' ||
        statusStr == 'done' ||
        progressStr == 'completed') {
      status = TaskStatus.selesai;
    } else if (statusStr == 'pending_verification' ||
        progressStr == 'waiting_verification') {
      status = TaskStatus.menungguVerifikasi;
    } else {
      status = TaskStatus.berjalan;
    }

    final rawAmount = data['salary'] ?? data['amount'] ?? 0;
    final int amountValue = (rawAmount is num) ? rawAmount.toInt() : 0;

    return WorkTask(
      id: doc.id,
      title: data['title'] ?? data['jobTitle'] ?? 'Pekerjaan Jasa',
      client: data['company'] ?? data['clientName'] ?? 'Klien',
      location: data['location'] ?? 'Medan',
      amount: amountValue,
      status: status,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: KkColors.bg,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 48, color: KkColors.muted),
                SizedBox(height: 12),
                Text(
                  'Sesi Anda telah berakhir',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Silakan login kembali untuk mengelola pekerjaan Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: KkColors.muted),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final String currentUid = currentUser.uid;

    return SafeArea(
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        // Menggunakan Filter OR untuk menghindari pengambilan seluruh database
        stream: FirebaseFirestore.instance
            .collection('job_offers')
            .where(
              Filter.or(
                Filter('postedByUid', isEqualTo: currentUid),
                Filter('workerId', isEqualTo: currentUid),
                Filter('applicantUid', isEqualTo: currentUid),
                Filter('acceptedWorkerUid', isEqualTo: currentUid),
              ),
            )
            .snapshots(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];
          final bool isLoading = snapshot.connectionState == ConnectionState.waiting;

          // 1. TUGAS AKTIF / ONGOING
          final allActiveTasks = docs.where((doc) {
            final data = doc.data();
            final status = (data['status'] ?? '').toString().toLowerCase();
            final progress = (data['progressStatus'] ?? '').toString().toLowerCase();

            return status == 'accepted' ||
                status == 'taken' ||
                status == 'ongoing' ||
                status == 'in_progress' ||
                status == 'pending_verification' ||
                progress == 'in_progress' ||
                progress == 'waiting_verification';
          }).toList();

          final activeMyWork = allActiveTasks.where((doc) {
            final data = doc.data();
            final postedByUid = data['postedByUid']?.toString() ?? '';
            final workerId = (data['workerId'] ?? data['applicantUid'] ?? '').toString();

            return (workerId == currentUid || data['acceptedWorkerUid'] == currentUid) &&
                postedByUid != currentUid;
          }).toList();

          final activeMyHires = allActiveTasks.where((doc) {
            final data = doc.data();
            final postedByUid = data['postedByUid']?.toString() ?? '';
            return postedByUid == currentUid;
          }).toList();

          // 2. TAWARAN & LAMARAN MASUK
          final pendingOffers = docs.where((doc) {
            final data = doc.data();
            final status = (data['status'] ?? '').toString().toLowerCase();
            return status == 'open' || status == 'pending' || status == 'offered';
          }).toList();

          // 3. RIWAYAT SELESAI
          final completedTasks = docs.where((doc) {
            final data = doc.data();
            final status = (data['status'] ?? '').toString().toLowerCase();
            final progress = (data['progressStatus'] ?? '').toString().toLowerCase();

            return status == 'completed' ||
                status == 'done' ||
                status == 'finished' ||
                progress == 'completed';
          }).toList();

          final tabs = [
            'Tugas Aktif (${allActiveTasks.length})',
            'Tawaran & Lamaran (${pendingOffers.length})',
            'Riwayat Selesai (${completedTasks.length})',
          ];

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              KkHeader(
                notifCount: pendingOffers.length,
              ),
              const SizedBox(height: 16),
              const Text(
                'Pusat Pekerjaan & Tugas',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: KkColors.text,
                ),
              ),
              const Text(
                'Kelola tugas aktif, konfirmasi tawaran klien, dan pantau status lamaran Anda.',
                style: TextStyle(fontSize: 13, color: KkColors.muted),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: KkColors.gold,
                    foregroundColor: KkColors.greenDark,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CariKerjaPage()),
                  ),
                  icon: const Icon(Icons.travel_explore, size: 18),
                  label: const Text('Cari Lowongan'),
                ),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var i = 0; i < tabs.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(tabs[i]),
                          selected: _tab == i,
                          showCheckmark: false,
                          selectedColor: KkColors.green,
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: _tab == i ? KkColors.green : KkColors.border,
                          ),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _tab == i ? Colors.white : KkColors.text,
                          ),
                          onSelected: (_) => setState(() => _tab = i),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // SUB-TOGGLE UNTUK TAB TUGAS AKTIF
              if (_tab == 0) ...[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: KkColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _activeSubTab = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _activeSubTab == 0
                                  ? KkColors.green
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Center(
                              child: Text(
                                'Saya Kerjakan (${activeMyWork.length})',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _activeSubTab == 0
                                      ? Colors.white
                                      : KkColors.text,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _activeSubTab = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _activeSubTab == 1
                                  ? KkColors.green
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Center(
                              child: Text(
                                'Saya Berikan (${activeMyHires.length})',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _activeSubTab == 1
                                      ? Colors.white
                                      : KkColors.text,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              if (isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(color: KkColors.green),
                  ),
                )
              else
                ..._buildTabContent(
                  context,
                  activeMyWork: activeMyWork,
                  activeMyHires: activeMyHires,
                  pendingOffers: pendingOffers,
                  completedTasks: completedTasks,
                ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildTabContent(
    BuildContext context, {
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> activeMyWork,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> activeMyHires,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> pendingOffers,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> completedTasks,
  }) {
    void openTask(WorkTask task) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailTugasPage(task: task),
        ),
      );
    }

    if (_tab == 0) {
      final targetList = _activeSubTab == 0 ? activeMyWork : activeMyHires;

      if (targetList.isEmpty) {
        return [
          _empty(_activeSubTab == 0
              ? 'Belum ada pekerjaan yang sedang Anda kerjakan saat ini.'
              : 'Belum ada proyek aktif yang sedang dikerjakan orang lain.')
        ];
      }

      return targetList.map((doc) {
        final task = _mapToWorkTask(doc);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TaskCard(
            task: task,
            onTap: () => openTask(task),
          ),
        );
      }).toList();
    }

    if (_tab == 1) {
      if (pendingOffers.isEmpty) {
        return [_empty('Belum ada tawaran atau lamaran berjalan.')];
      }
      return pendingOffers.map((doc) {
        final task = _mapToWorkTask(doc);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: OfferCardRealtime(
            offerId: doc.id,
            onDetailTap: () => openTask(task),
          ),
        );
      }).toList();
    }

    if (completedTasks.isEmpty) {
      return [_empty('Belum ada riwayat pekerjaan selesai.')];
    }
    return completedTasks.map((doc) {
      final task = _mapToWorkTask(doc);
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TaskCard(
          task: task,
          onTap: () => openTask(task),
        ),
      );
    }).toList();
  }

  Widget _empty(String text) => KkCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(text, style: const TextStyle(color: KkColors.muted)),
          ),
        ),
      );
}