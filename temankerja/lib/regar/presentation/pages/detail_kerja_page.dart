import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';
import 'package:inovasi_sumut/regar/data/models/job_model.dart';
import 'package:inovasi_sumut/regar/data/repositories/worker_repository.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/common/kk_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// Fungsi utama untuk memanggil Modal Bottom Sheet
void showDetailKerjaBottomSheet(BuildContext context, JobModel job) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _DetailKerjaModalContent(job: job),
  );
}

class _DetailKerjaModalContent extends StatefulWidget {
  final JobModel job;

  const _DetailKerjaModalContent({required this.job});

  @override
  State<_DetailKerjaModalContent> createState() =>
      _DetailKerjaModalContentState();
}

class _DetailKerjaModalContentState extends State<_DetailKerjaModalContent> {
  bool _sending = false;

  // Fungsi menyimpan rating & memperbarui average rating pekerja di Firestore
  Future<void> _submitJobRating({
    required String jobId,
    required String workerUid,
    required double rating,
    required String reviewText,
  }) async {
    final firestore = FirebaseFirestore.instance;

    // 1. Update status pekerjaan menjadi 'completed' dan simpan rating
    await firestore.collection('job_offers').doc(jobId).set({
      'status': 'completed',
      'progressStatus': 'completed',
      'ratingGiven': rating,
      'reviewText': reviewText,
      'completedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // 2. Ambil semua pekerjaan selesai milik pekerja ini untuk menghitung rata-rata baru
    final workerJobsSnapshot = await firestore
        .collection('job_offers')
        .where('acceptedWorkerUid', isEqualTo: workerUid)
        .where('status', isEqualTo: 'completed')
        .get();

    double totalStars = 0;
    int ratedJobsCount = 0;

    for (var doc in workerJobsSnapshot.docs) {
      final data = doc.data();
      if (data.containsKey('ratingGiven') && data['ratingGiven'] != null) {
        totalStars += (data['ratingGiven'] as num).toDouble();
        ratedJobsCount++;
      }
    }

    double newAverageRating = 5.0;
    if (ratedJobsCount > 0) {
      newAverageRating =
          double.parse((totalStars / ratedJobsCount).toStringAsFixed(1));
    }

    // 3. Update rating & total pekerjaan selesai di profil pekerja (`users/{workerUid}`)
    await firestore.collection('users').doc(workerUid).set({
      'rating': newAverageRating,
      'completedJobs': workerJobsSnapshot.docs.length,
      'totalReviews': ratedJobsCount,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Dialog Modal Interaktif Beri Rating Bintang (1 - 5)
  void _showRatingDialog({
    required String jobId,
    required String workerUid,
    required String workerName,
  }) {
    double selectedRating = 5.0;
    final reviewController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Column(
                children: [
                  const Icon(Icons.stars_rounded,
                      size: 48, color: KkColors.gold),
                  const SizedBox(height: 8),
                  Text(
                    'Beri Rating untuk $workerName',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Bagaimana hasil pekerjaan pekerja ini?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: KkColors.muted),
                  ),
                  const SizedBox(height: 16),

                  // Interactive 5 Star Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      return IconButton(
                        icon: Icon(
                          starValue <= selectedRating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 32,
                          color: KkColors.gold,
                        ),
                        onPressed: () {
                          setModalState(
                              () => selectedRating = starValue.toDouble());
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${selectedRating.toInt()} dari 5 Bintang',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: KkColors.green),
                  ),
                  const SizedBox(height: 16),

                  // Field Input Ulasan
                  TextField(
                    controller: reviewController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Tulis ulasan singkat (Opsional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
                  child: const Text('Batal',
                      style: TextStyle(color: KkColors.muted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KkColors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setModalState(() => isSubmitting = true);
                          try {
                            await _submitJobRating(
                              jobId: jobId,
                              workerUid: workerUid,
                              rating: selectedRating,
                              reviewText: reviewController.text.trim(),
                            );

                            if (context.mounted) {
                              Navigator.pop(ctx); // Tutup Dialog Rating
                              Navigator.pop(
                                  context); // Tutup BottomSheet Detail
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Pekerjaan selesai & rating berhasil dikirim!'),
                                  backgroundColor: KkColors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            setModalState(() => isSubmitting = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Gagal memberikan rating: $e')),
                              );
                            }
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Kirim Rating'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Fungsi meluncurkan WhatsApp
  Future<void> _launchWhatsApp(String phone, String jobTitle) async {
    if (phone.isEmpty) return;

    String formattedPhone = phone.trim().replaceAll(RegExp(r'\s+|-'), '');
    if (formattedPhone.startsWith('0')) {
      formattedPhone = '62${formattedPhone.substring(1)}';
    }

    final String waUrl =
        'https://wa.me/$formattedPhone?text=Halo,\%20saya\%20tertarik\%20dengan\%20lowongan\%20pekerjaan\%20"${Uri.encodeComponent(jobTitle)}"%20yang%20Anda%20posting%20di%20TemanKerja.';

    final uri = Uri.parse(waUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Tidak dapat membuka WhatsApp ($formattedPhone)')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka WhatsApp: $e')),
      );
    }
  }

  // Fungsi Melamar Kerja yang menyimpan langsung ke Firestore
  Future<void> _apply(String docId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final job = widget.job;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lamar pekerjaan ini?'),
        content: Text(
          'Lamaran untuk "${job.title}" akan dikirim ke ${job.company}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: KkColors.green),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Kirim Lamaran'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _sending = true);
    try {
      await FirebaseFirestore.instance
          .collection('job_offers')
          .doc(docId)
          .set({
        'applicantUid': currentUser.uid,
        'status': 'applied',
      }, SetOptions(merge: true));

      workerRepository.addApplication(job);

      if (!mounted) return;
      setState(() => _sending = false);

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lamaran "${job.title}" terkirim!'),
          backgroundColor: KkColors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim lamaran: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('job_offers')
          .doc(widget.job.id)
          .snapshots(),
      builder: (context, snapshot) {
        final Map<String, dynamic> firestoreData =
            (snapshot.hasData && snapshot.data!.exists)
                ? snapshot.data!.data()!
                : {};

        final String title = firestoreData['title'] ?? widget.job.title;
        final String company = firestoreData['company'] ??
            firestoreData['workerEmail'] ??
            widget.job.company;
        final String location = firestoreData['location'] ??
            firestoreData['district'] ??
            widget.job.location;
        final String category =
            firestoreData['category'] ?? widget.job.category;
        final double salary = (firestoreData['totalClientPay'] ??
                firestoreData['cleanSalary'] ??
                firestoreData['salary'] ??
                widget.job.salary)
            .toDouble();
        final String description =
            firestoreData['description'] ?? widget.job.description;
        final String phoneNumber =
            firestoreData['phoneNumber'] ?? widget.job.phoneNumber;
        final String acceptedPaymentType =
            firestoreData['acceptedPaymentType'] ??
                widget.job.acceptedPaymentType;
        final String postedByUid = firestoreData['postedByUid'] ?? '';
        final String applicantUid = firestoreData['applicantUid'] ?? '';
        final String acceptedWorkerUid =
            firestoreData['acceptedWorkerUid'] ?? applicantUid;
        final String status =
            (firestoreData['status'] ?? '').toString().toLowerCase();

        final bool requiresOwnTools =
            firestoreData['requiresOwnTools'] ?? false;
        final String mobilityRequirement =
            firestoreData['requiredMobility'] ??
                firestoreData['mobility'] ??
                'Bebas / Tidak Wajib Kendaraan';

        String paymentLabel = 'Hanya Tunai';
        Color paymentBg = Colors.grey.shade200;
        Color paymentFg = Colors.grey.shade700;

        if (acceptedPaymentType == 'qris') {
          paymentLabel = 'Escrow QRIS / Transfer';
          paymentBg = Colors.blue.shade50;
          paymentFg = Colors.blue.shade700;
        }

        final String formattedSalary = salary > 0
            ? 'Rp ${salary.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}'
            : 'Negosiasi';

        final bool isOwnJobByUid = currentUser != null &&
            postedByUid.isNotEmpty &&
            postedByUid == currentUser.uid;
        final bool isOwnJobByEmail = currentUser != null &&
            currentUser.email != null &&
            company.toLowerCase() == currentUser.email!.toLowerCase();
        final bool isOwnJob = isOwnJobByUid || isOwnJobByEmail;

        final bool isOngoing = status == 'accepted' ||
            status == 'in_progress' ||
            status == 'ongoing';
        final bool isCompleted = status == 'completed' || status == 'done';

        final bool isAppliedInFirestore =
            (currentUser != null && applicantUid == currentUser.uid);
        final bool isApplied =
            isAppliedInFirestore || workerRepository.isApplied(widget.job.id);

        return Container(
          decoration: const BoxDecoration(
            color: KkColors.bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.only(top: 12),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.75,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Column(
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        KkCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: KkColors.text,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.person_outline,
                                      size: 16, color: KkColors.muted),
                                  const SizedBox(width: 4),
                                  Text(
                                    company,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: KkColors.muted,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  KkPill(widget.job.type.label,
                                      bg: KkColors.blueSoft, fg: KkColors.blue),
                                  KkPill(category),
                                  KkPill(location,
                                      bg: KkColors.inner, fg: KkColors.muted),
                                  KkPill(
                                    paymentLabel,
                                    bg: paymentBg,
                                    fg: paymentFg,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        KkInfoBox(
                          label: 'Honor / Gaji',
                          value: formattedSalary,
                          valueColor: KkColors.green,
                        ),
                        const SizedBox(height: 12),

                        // Section Persyaratan Peralatan & Mobilitas
                        const KkSectionTitle(Icons.checklist_rounded,
                            'Persyaratan & Kualifikasi'),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: KkColors.border),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    requiresOwnTools
                                        ? Icons.build_circle_rounded
                                        : Icons.handyman_outlined,
                                    color: requiresOwnTools
                                        ? Colors.orange.shade800
                                        : Colors.blue.shade700,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Kebutuhan Peralatan',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: KkColors.muted),
                                        ),
                                        Text(
                                          requiresOwnTools
                                              ? 'Wajib Bawa Peralatan Sendiri'
                                              : 'Peralatan Disediakan Pemberi Kerja',
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 16),
                              Row(
                                children: [
                                  Icon(
                                    Icons.two_wheeler_rounded,
                                    color: Colors.green.shade700,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Kebutuhan Mobilitas / Kendaraan',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: KkColors.muted),
                                        ),
                                        Text(
                                          mobilityRequirement,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const KkSectionTitle(
                              Icons.description_outlined, 'Deskripsi Pekerjaan'),
                          Text(
                            description,
                            style: const TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: KkColors.text),
                          ),
                        ],
                        if (phoneNumber.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const KkSectionTitle(
                              Icons.contacts_outlined, 'Kontak Pemberi Kerja'),
                          ElevatedButton.icon(
                            onPressed: () =>
                                _launchWhatsApp(phoneNumber, title),
                            icon: const Icon(Icons.chat, color: Colors.white),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            label: Text(
                              'Hubungi Pemberi Kerja ($phoneNumber)',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                  // AREA TOMBOL AKSI BAWAH
                  SafeArea(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(top: BorderSide(color: KkColors.border)),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: isOwnJob && isOngoing
                            ? FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: KkColors.green,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => _showRatingDialog(
                                  jobId: widget.job.id,
                                  workerUid: acceptedWorkerUid,
                                  workerName: 'Pekerja Terpilih',
                                ),
                                icon: const Icon(Icons.star_rate_rounded,
                                    size: 20),
                                label: const Text(
                                  'Selesaikan & Beri Rating',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14),
                                ),
                              )
                            : FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: isCompleted
                                      ? Colors.grey.shade300
                                      : (isOwnJob
                                          ? Colors.grey.shade300
                                          : KkColors.gold),
                                  foregroundColor: isCompleted
                                      ? Colors.grey.shade600
                                      : (isOwnJob
                                          ? Colors.grey.shade600
                                          : KkColors.greenDark),
                                  disabledBackgroundColor: Colors.grey.shade300,
                                  disabledForegroundColor: Colors.grey.shade600,
                                ),
                                onPressed: (isOwnJob || isApplied || isCompleted || _sending)
                                    ? null
                                    : () => _apply(widget.job.id),
                                child: _sending
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: KkColors.greenDark,
                                        ),
                                      )
                                    : Text(
                                        isCompleted
                                            ? 'Pekerjaan Telah Selesai'
                                            : (isOwnJob
                                                ? 'Pekerjaan Anda Sendiri'
                                                : (isApplied
                                                    ? 'Sudah Dilamar'
                                                    : 'Lamar Sekarang')),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800),
                                      ),
                              ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}