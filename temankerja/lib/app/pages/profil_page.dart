import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';
import 'package:inovasi_sumut/regar/data/repositories/worker_repository.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/common/kk_widgets.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  // Modal Sheet Modern untuk Mengubah Data Pekerjaan & Profil di Firestore
  void _showEditProfileSheet(
    BuildContext context, {
    required String uid,
    required String currentName,
    required String currentSkill,
    required String currentAbout,
    required String currentArea,
    required String currentWhatsapp,
  }) {
    final nameController = TextEditingController(text: currentName);
    final skillController = TextEditingController(text: currentSkill);
    final aboutController = TextEditingController(text: currentAbout);
    final areaController = TextEditingController(text: currentArea);
    final whatsappController = TextEditingController(text: currentWhatsapp);

    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
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
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Edit Profil & Keahlian',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: KkColors.text,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: KkColors.muted),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Field Nama Lengkap
                    _buildTextField(
                      controller: nameController,
                      label: 'Nama Lengkap',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 14),

                    // Field Keahlian
                    _buildTextField(
                      controller: skillController,
                      label: 'Keahlian / Profesi Utama',
                      hint: 'Contoh: Videografer, Editor, Desainer',
                      icon: Icons.work_outline,
                    ),
                    const SizedBox(height: 14),

                    // Field Tentang Saya
                    _buildTextField(
                      controller: aboutController,
                      label: 'Tentang Saya (Deskripsi Singkat)',
                      hint: 'Jasa Video, Foto dan Editing Profesional',
                      icon: Icons.description_outlined,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 14),

                    // Field Lokasi
                    _buildTextField(
                      controller: areaController,
                      label: 'Lokasi / Area Kerja',
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 14),

                    // Field WhatsApp
                    _buildTextField(
                      controller: whatsappController,
                      label: 'Nomor WhatsApp',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 24),

                    // Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KkColors.green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isSaving
                            ? null
                            : () async {
                                setModalState(() => isSaving = true);
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(uid)
                                      .set({
                                    'name': nameController.text.trim(),
                                    'skill': skillController.text.trim(),
                                    'about': aboutController.text.trim(),
                                    'area': areaController.text.trim(),
                                    'location': areaController.text.trim(),
                                    'whatsapp': whatsappController.text.trim(),
                                    'updatedAt': FieldValue.serverTimestamp(),
                                  }, SetOptions(merge: true));

                                  if (context.mounted) {
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Profil berhasil diperbarui!'),
                                        backgroundColor: KkColors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  setModalState(() => isSaving = false);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Gagal menyimpan data: $e'),
                                      ),
                                    );
                                  }
                                }
                              },
                        child: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Simpan Perubahan',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: KkColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: KkColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: KkColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: KkColors.green, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 48, color: KkColors.muted),
                SizedBox(height: 12),
                Text(
                  'Sesi Anda Telah Berakhir',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Silakan login kembali untuk melihat profil Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: KkColors.muted),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final String currentUid = user.uid;

    return SafeArea(
      child: ListenableBuilder(
        listenable: workerRepository,
        builder: (context, _) {
          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(currentUid)
                .snapshots(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: KkColors.green),
                );
              }

              final userData = userSnapshot.data?.data() ?? {};

              final String name = userData['name'] ?? user.displayName ?? 'Fajar Adhitya Manthey';
              final String firstName = name.isNotEmpty ? name.split(' ').first : 'Fajar';
              final String about = userData['about'] ?? userData['bio'] ?? 'Jasa Video Foto dan Editing';
              final String skill = userData['skill'] ?? userData['category'] ?? about;
              final double rating = (userData['rating'] as num?)?.toDouble() ?? 5.0;
              final String area = userData['location'] ?? userData['area'] ?? 'Medan Kota';
              final String email = userData['email'] ?? user.email ?? '-';
              final String whatsapp = userData['whatsapp'] ?? userData['phone'] ?? '087817615382';

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
                builder: (context, jobSnapshot) {
                  final jobDocs = jobSnapshot.data?.docs ?? [];

                  // 1. Pekerjaan Selesai
                  final int completedCount = jobDocs.where((doc) {
                    final data = doc.data();
                    final status = (data['status'] ?? '').toString().toLowerCase();
                    final progress = (data['progressStatus'] ?? '').toString().toLowerCase();
                    return status == 'completed' || status == 'done' || progress == 'completed';
                  }).length;

                  // 2. Lamaran Masuk
                  final int incomingOffersCount = jobDocs.where((doc) {
                    final data = doc.data();
                    final postedByUid = data['postedByUid']?.toString() ?? '';
                    final applicantUid = data['applicantUid']?.toString() ?? '';
                    final status = (data['status'] ?? '').toString().toLowerCase();

                    final bool isMyJob = postedByUid.isEmpty || postedByUid == currentUid;
                    final bool isPending = status == 'open' || status == 'pending' || status == 'applied';

                    return isMyJob && applicantUid.isNotEmpty && isPending;
                  }).length;

                  // 3. Lagi Dikerjakan
                  final int inProgressCount = jobDocs.where((doc) {
                    final data = doc.data();
                    final status = (data['status'] ?? '').toString().toLowerCase();
                    final progress = (data['progressStatus'] ?? '').toString().toLowerCase();

                    return status == 'accepted' || status == 'in_progress' || status == 'ongoing' || progress == 'in_progress';
                  }).length;

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                    children: [
                      KkHeader(notifCount: incomingOffersCount),
                      const SizedBox(height: 14),

                      // KARTU PROFIL UTAMA
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: KkColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: KkColors.greenSoft,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.verified, size: 14, color: KkColors.green),
                                      SizedBox(width: 4),
                                      Text(
                                        'Terverifikasi',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: KkColors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: KkColors.green,
                                    side: BorderSide(color: KkColors.green.withOpacity(0.3)),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () => _showEditProfileSheet(
                                    context,
                                    uid: currentUid,
                                    currentName: name,
                                    currentSkill: skill,
                                    currentAbout: about,
                                    currentArea: area,
                                    currentWhatsapp: whatsapp,
                                  ),
                                  icon: const Icon(Icons.edit_note_rounded, size: 18),
                                  label: const Text(
                                    'Edit Profil',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Stack(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: KkColors.greenSoft,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    firstName.isNotEmpty ? firstName.substring(0, 1).toUpperCase() : 'F',
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w900,
                                      color: KkColors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: KkColors.text,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              skill,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: KkColors.muted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.star_rounded, size: 18, color: KkColors.gold),
                                const SizedBox(width: 4),
                                Text(
                                  '$rating',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  ' • $completedCount Pekerjaan Selesai',
                                  style: const TextStyle(fontSize: 12, color: KkColors.muted, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_on, size: 14, color: KkColors.muted),
                                const SizedBox(width: 2),
                                Text(
                                  area,
                                  style: const TextStyle(fontSize: 12, color: KkColors.muted),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // STATISTIK AKTIVITAS REALTIME (3 GRID CARD MODERN)
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              value: '$completedCount',
                              label: 'Pekerjaan Selesai',
                              icon: Icons.task_alt_rounded,
                              bgColor: KkColors.greenSoft,
                              textColor: KkColors.green,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _StatCard(
                              value: '$incomingOffersCount',
                              label: 'Lamaran Masuk',
                              icon: Icons.mark_email_unread_rounded,
                              bgColor: KkColors.blueSoft,
                              textColor: KkColors.blue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _StatCard(
                              value: '$inProgressCount',
                              label: 'Lagi Dikerjakan',
                              icon: Icons.pending_actions_rounded,
                              bgColor: KkColors.goldSoft,
                              textColor: KkColors.goldText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // TENTANG SAYA
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: KkColors.border),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.format_quote_rounded, size: 16, color: KkColors.muted),
                                SizedBox(width: 6),
                                Text(
                                  'TENTANG SAYA',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: KkColors.muted,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '"$about"',
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 13,
                                color: KkColors.text,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // KEAHLIAN / SKILL PILLS
                      const KkSectionTitle(Icons.verified_outlined, 'Keahlian Utamanya'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final s in skill.split(','))
                            if (s.trim().isNotEmpty) KkPill(s.trim()),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // KREDENSIAL (ALAT & MOBILITAS)
                      Row(
                        children: [
                          Expanded(
                            child: _CredentialCard(
                              icon: Icons.construction_rounded,
                              label: 'Peralatan',
                              value: userData['equipment'] ?? 'Bawa Alat Sendiri',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _CredentialCard(
                              icon: Icons.directions_bike_rounded,
                              label: 'Mobilitas',
                              value: userData['mobility'] ?? 'Kendaraan Pribadi',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // DETAIL KONTAK
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: KkColors.border),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: Column(
                          children: [
                            _ContactRow(Icons.email_outlined, 'Email', email),
                            const Divider(height: 1, color: KkColors.border),
                            _ContactRow(Icons.phone_outlined, 'Nomor WhatsApp', whatsapp),
                            const Divider(height: 1, color: KkColors.border),
                            _ContactRow(Icons.place_outlined, 'Lokasi Utama', area),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // TOMBOL KELUAR AKUN
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            side: BorderSide(color: Colors.red.shade200),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                          },
                          icon: const Icon(Icons.logout_rounded, size: 18),
                          label: const Text(
                            'Keluar Akun',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color textColor;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: textColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _CredentialCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CredentialCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KkColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: KkColors.greenSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: KkColors.green),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: KkColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: KkColors.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: KkColors.muted),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: KkColors.muted),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: KkColors.text,
            ),
          ),
        ],
      ),
    );
  }
}