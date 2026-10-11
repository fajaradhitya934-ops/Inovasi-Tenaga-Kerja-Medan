import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';
import 'package:inovasi_sumut/regar/core/utils/formatter.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/common/kk_widgets.dart';

class OfferCardRealtime extends StatelessWidget {
  final String offerId;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onDetailTap;

  const OfferCardRealtime({
    super.key,
    required this.offerId,
    this.onAccept,
    this.onReject,
    this.onDetailTap,
  });

  // 1. ACC Pelamar -> Set workerId, status 'accepted', & progressStatus 'in_progress'
  Future<void> _handleAcceptApplicant(
      BuildContext context, String docId, String applicantUid) async {
    try {
      await FirebaseFirestore.instance
          .collection('job_offers')
          .doc(docId)
          .update({
        'status': 'accepted',
        'progressStatus': 'in_progress',
        'workerId': applicantUid, // Penting agar muncul di Ongoing Card Pekerja
        'acceptedWorkerUid': applicantUid,
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tawaran/Lamaran diterima! Pekerjaan resmi berpindah ke On-Going.'),
          backgroundColor: KkColors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menerima: $e'),
          backgroundColor: KkColors.red,
        ),
      );
    }
  }

  // 2. Tolak Pelamar -> Reset applicantUid & kembalikan status ke 'open'
  Future<void> _handleRejectApplicant(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('job_offers')
          .doc(docId)
          .update({
        'applicantUid': '',
        'workerId': '',
        'status': 'open',
        'progressStatus': 'open',
      });

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permintaan/Tawaran telah ditolak.'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menolak: $e'),
          backgroundColor: KkColors.red,
        ),
      );
    }
  }

  // 3. Modal Bottom Sheet untuk Pekerja (Upload Before/After & Deskripsi)
  void _showWorkerUploadModal(
      BuildContext context, String docId, Map<String, dynamic> data) {
    final TextEditingController beforeUrlCtrl =
        TextEditingController(text: data['beforeImageUrl'] ?? '');
    final TextEditingController afterUrlCtrl =
        TextEditingController(text: data['afterImageUrl'] ?? '');
    final TextEditingController notesCtrl =
        TextEditingController(text: data['workNotes'] ?? data['note'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
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
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Upload Hasil & Progres Kerja',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Unggah foto sebelum/sesudah dan deskripsi hasil pengerjaan (opsional).',
                  style: TextStyle(fontSize: 12, color: KkColors.muted),
                ),
                const SizedBox(height: 16),
                const Text('Foto Before (Sebelum Dikerjakan)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: beforeUrlCtrl,
                  decoration: InputDecoration(
                    hintText: 'Masukkan URL foto before',
                    prefixIcon: const Icon(Icons.image_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Foto After (Setelah Dikerjakan)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: afterUrlCtrl,
                  decoration: InputDecoration(
                    hintText: 'Masukkan URL foto after',
                    prefixIcon: const Icon(Icons.add_a_photo_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Deskripsi Pengerjaan (Opsional)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: notesCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Catatan tambahan terkait pekerjaan...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: KkColors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      try {
                        await FirebaseFirestore.instance
                            .collection('job_offers')
                            .doc(docId)
                            .update({
                          'beforeImageUrl': beforeUrlCtrl.text.trim(),
                          'afterImageUrl': afterUrlCtrl.text.trim(),
                          'workNotes': notesCtrl.text.trim(),
                          'note': notesCtrl.text.trim(),
                          'status': 'pending_verification',
                          'progressStatus': 'waiting_verification',
                          'updatedAt': FieldValue.serverTimestamp(),
                        });

                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Hasil pengerjaan berhasil dikirim!'),
                            backgroundColor: KkColors.green,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal memperbarui progres: $e')),
                        );
                      }
                    },
                    child: const Text('Simpan & Kirim Progres',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 4. Bottom Sheet Progres Kerja untuk Pemberi Kerja / Klien
  void _showOwnerProgressBottomSheet(
      BuildContext context, String docId, Map<String, dynamic> data) {
    final String beforeUrl = data['beforeImageUrl'] ?? '';
    final String afterUrl = data['afterImageUrl'] ?? '';
    final String workNotes = data['workNotes'] ?? data['note'] ?? '';
    final String progressStatus = data['progressStatus'] ?? 'in_progress';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
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
                'Detail Progres & Hasil Pekerjaan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: progressStatus == 'waiting_verification' ||
                          progressStatus == 'completed_pending_review'
                      ? Colors.amber.shade50
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      progressStatus == 'waiting_verification' ||
                              progressStatus == 'completed_pending_review'
                          ? Icons.pending_actions
                          : Icons.engineering,
                      color: progressStatus == 'waiting_verification' ||
                              progressStatus == 'completed_pending_review'
                          ? Colors.amber.shade800
                          : Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        progressStatus == 'waiting_verification' ||
                                progressStatus == 'completed_pending_review'
                            ? 'Pekerja telah mengirimkan bukti kerja untuk diperiksa.'
                            : 'Pekerja sedang menyelesaikan tugas ini.',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Catatan / Deskripsi Pekerja:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              Text(
                workNotes.isEmpty ? 'Belum ada catatan deskripsi.' : workNotes,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              const Text('Foto Dokumentasi (Before & After):',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: beforeUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(beforeUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                      child: Text('Gagal Memuat Foto'))),
                            )
                          : const Center(
                              child: Text('Foto Before\nBelum ada',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey))),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: afterUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(afterUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                      child: Text('Gagal Memuat Foto'))),
                            )
                          : const Center(
                              child: Text('Foto After\nBelum ada',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey))),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: KkColors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Setujui Hasil & Selesaikan Pekerjaan',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('job_offers')
                        .doc(docId)
                        .update({
                      'status': 'completed',
                      'progressStatus': 'completed',
                      'updatedAt': FieldValue.serverTimestamp(),
                    });
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pekerjaan disetujui dan dinyatakan selesai!'),
                        backgroundColor: KkColors.green,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('job_offers')
          .doc(offerId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!.data()!;
        final currentUser = FirebaseAuth.instance.currentUser;

        final String title = data['title'] ?? data['jobTitle'] ?? 'Tanpa Judul';
        final String company = data['company'] ?? data['clientName'] ?? 'Pemberi Kerja';
        final String location = data['location'] ?? data['district'] ?? '-';
        final int salary = (data['salary'] as num?)?.toInt() ?? 0;
        final String type = data['type'] ?? 'Harian';
        final String status = (data['status'] ?? 'open').toString().toLowerCase();

        final String postType = (data['postType'] ?? '').toString().toLowerCase();
        final String postMode = (data['postMode'] ?? '').toString().toLowerCase();
        final String postedByUid = data['postedByUid'] ?? '';
        final String applicantUid = data['applicantUid'] ?? '';
        final String workerId = data['workerId'] ?? data['acceptedWorkerUid'] ?? '';

        final bool isWorkerOffer = postType == 'worker' ||
            postType == 'worker_profile' ||
            postMode == 'offer_service';

        // Pihak penerima ACC:
        // Jika Tawaran Jasa (worker) -> Pemilik Posting (postedByUid)
        // Jika Lowongan Kerja (job) -> Pemilik Posting (postedByUid)
        final bool canAcceptRequest = currentUser != null &&
            (postedByUid == currentUser.uid);

        final bool isApplicant = currentUser != null && (applicantUid == currentUser.uid);

        final bool isWorkerAssigned = currentUser != null &&
            (workerId == currentUser.uid ||
                (isWorkerOffer && postedByUid == currentUser.uid));

        final bool hasApplicant = applicantUid.isNotEmpty;

        final bool isOngoing = status == 'ongoing' ||
            status == 'accepted' ||
            status == 'in_progress' ||
            status == 'pending_verification';

        return KkCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Status Pekerjaan
              if (isOngoing) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.engineering, size: 16, color: Colors.blue),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Pekerjaan Berjalan (On-Going)',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (canAcceptRequest && hasApplicant) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_active, size: 16, color: Colors.amber),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          isWorkerOffer
                              ? 'Ada Klien Mengajak Bekerja!'
                              : 'Ada Pelamar Masuk!',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Ringkasan Pekerjaan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      type.toUpperCase(),
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(company, style: const TextStyle(fontSize: 13, color: KkColors.muted)),
              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(Icons.place_outlined, size: 14, color: KkColors.muted),
                  const SizedBox(width: 4),
                  Expanded(
                      child: Text(location,
                          style: const TextStyle(fontSize: 12, color: KkColors.muted),
                          maxLines: 1)),
                  const SizedBox(width: 8),
                  Text(rupiah(salary),
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: KkColors.green)),
                ],
              ),
              const SizedBox(height: 12),

              // Tombol-tombol Aksi Berdasarkan Peran & Status
              if (canAcceptRequest) ...[
                if (!isOngoing && hasApplicant) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red)),
                          onPressed: (onReject != null)
                              ? onReject
                              : () => _handleRejectApplicant(context, offerId),
                          child: const Text('Tolak'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: KkColors.green),
                          onPressed: (onAccept != null)
                              ? onAccept
                              : () => _handleAcceptApplicant(
                                  context, offerId, applicantUid),
                          child: const Text('ACC / Terima',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ] else if (isOngoing) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: KkColors.green),
                        foregroundColor: KkColors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      icon: const Icon(Icons.analytics_outlined, size: 18),
                      label: const Text('Lihat Progres Pekerjaan',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () =>
                          _showOwnerProgressBottomSheet(context, offerId, data),
                    ),
                  ),
                ],
              ] else if (isApplicant || isWorkerAssigned) ...[
                if (isOngoing) ...[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: KkColors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      icon: const Icon(Icons.upload_file_outlined, size: 18),
                      label: const Text('Upload Progres & Foto (Before/After)'),
                      onPressed: () => _showWorkerUploadModal(context, offerId, data),
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onDetailTap,
                      child: Text(hasApplicant
                          ? (isWorkerOffer ? 'Sudah Diajak' : 'Sudah Dilamar')
                          : 'Lihat Detail'),
                    ),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}