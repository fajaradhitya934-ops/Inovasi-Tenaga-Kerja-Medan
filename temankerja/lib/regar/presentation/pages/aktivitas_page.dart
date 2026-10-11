import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';

class AktivitasPage extends StatelessWidget {
  const AktivitasPage({super.key});

  // Fungsi ACC Pelamar
  Future<void> _acceptApplicant(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('job_offers')
          .doc(docId)
          .update({'status': 'accepted'});

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pelamar berhasil diterima!'),
          backgroundColor: KkColors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menerima pelamar: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Fungsi Tolak Pelamar
  Future<void> _rejectApplicant(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('job_offers')
          .doc(docId)
          .update({
        'applicantUid': '',
        'status': 'rejected',
      });

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pelamar telah ditolak.'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menolak pelamar: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Modal Dialog untuk Melihat Profil Pelamar
  void _showUserProfileModal(BuildContext context, String uid) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 250,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final data = snapshot.data?.data() ?? {};
            final String name = data['name'] ?? data['displayName'] ?? 'Pekerja';
            final String email = data['email'] ?? '-';
            final String phone = data['phoneNumber'] ?? data['phone'] ?? '-';
            final String skills = data['skills'] ?? 'Belum mengisi keahlian';

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Profil Pelamar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 24),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: KkColors.green,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(email),
                  ),
                  const SizedBox(height: 8),
                  Text('Nomor Telepon/WA: $phone', style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 8),
                  Text('Keahlian: $skills', style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Silakan login terlebih dahulu')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktivitas & Lamaran Masuk'),
        backgroundColor: Colors.white,
        foregroundColor: KkColors.text,
        elevation: 0.5,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('job_offers')
            .where('postedByUid', isEqualTo: currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          // Filter hanya pekerjaan yang ada pelamarnya
          final appliedJobs = docs.where((doc) {
            final data = doc.data();
            final applicantUid = data['applicantUid'] as String?;
            return applicantUid != null && applicantUid.isNotEmpty;
          }).toList();

          if (appliedJobs.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada lamaran masuk di pekerjaan Anda.',
                style: TextStyle(color: KkColors.muted),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appliedJobs.length,
            itemBuilder: (context, index) {
              final doc = appliedJobs[index];
              final data = doc.data();
              final String jobTitle = data['title'] ?? 'Pekerjaan';
              final String applicantUid = data['applicantUid'] ?? '';
              final String status = data['status'] ?? 'applied';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              jobTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: status == 'accepted'
                                  ? Colors.green.shade50
                                  : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              status == 'accepted' ? 'Diterima' : 'Menunggu Konfirmasi',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: status == 'accepted'
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _showUserProfileModal(context, applicantUid),
                            icon: const Icon(Icons.account_circle, size: 18),
                            label: const Text('Lihat Profil Pelamar'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (status != 'accepted')
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _rejectApplicant(context, doc.id),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                ),
                                child: const Text('Tolak'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _acceptApplicant(context, doc.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: KkColors.green,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('ACC / Terima'),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}