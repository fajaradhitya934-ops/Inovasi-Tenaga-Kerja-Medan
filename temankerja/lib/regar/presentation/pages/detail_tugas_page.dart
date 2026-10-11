import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';
import 'package:inovasi_sumut/regar/core/utils/formatter.dart';
import 'package:inovasi_sumut/regar/data/models/worker_models.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/common/kk_widgets.dart';

class DetailTugasPage extends StatefulWidget {
  final WorkTask task;

  const DetailTugasPage({super.key, required this.task});

  @override
  State<DetailTugasPage> createState() => _DetailTugasPageState();
}

class _DetailTugasPageState extends State<DetailTugasPage> {
  late final TextEditingController _note = TextEditingController();
  bool _isLoading = false;

  String? _beforeBase64;
  String? _afterBase64;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  // Fungsi Unggah Foto (Base64)
  Future<void> _pickImage(bool isBefore) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50, // Kompresi agar ringan disimpan di Firestore
        maxWidth: 800,
      );

      if (pickedFile != null) {
        final Uint8List bytes = await pickedFile.readAsBytes();
        final String base64String = base64Encode(bytes);

        setState(() {
          if (isBefore) {
            _beforeBase64 = base64String;
          } else {
            _afterBase64 = base64String;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil gambar: $e')),
        );
      }
    }
  }

  // 1. PEKERJA: Mengirim Bukti Foto & Catatan ke Pemberi Kerja
  Future<void> _submitProofForVerification() async {
    if (_beforeBase64 == null && _afterBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unggah minimal 1 foto bukti (Before/After) sebelum mengirim.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updateData = <String, dynamic>{
        'status': 'pending_verification',
        'progressStatus': 'waiting_verification',
        'note': _note.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_beforeBase64 != null) {
        updateData['beforeImageBase64'] = _beforeBase64;
      }
      if (_afterBase64 != null) {
        updateData['afterImageBase64'] = _afterBase64;
      }

      await FirebaseFirestore.instance
          .collection('job_offers')
          .doc(widget.task.id)
          .update(updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bukti berhasil dikirim! Menunggu pemeriksaan dari pemberi kerja.'),
            backgroundColor: KkColors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim bukti: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 2. PEMBERI KERJA: Memeriksa & Menyetujui Pekerjaan
  Future<void> _approveTaskByClient() async {
    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('job_offers')
          .doc(widget.task.id)
          .update({
        'status': 'completed',
        'progressStatus': 'completed',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pekerjaan disetujui! Honor ${rupiah(widget.task.amount)} diteruskan ke pekerja.'),
            backgroundColor: KkColors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyetujui pekerjaan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 3. PEMBERI KERJA: Menolak Bukti (Meminta Perbaikan)
  Future<void> _rejectProofByClient() async {
    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('job_offers')
          .doc(widget.task.id)
          .update({
        'status': 'accepted',
        'progressStatus': 'in_progress',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bukti ditolak. Status pekerjaan dikembalikan ke Ongoing.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menolak bukti: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildPhotoTile({
    required String title,
    required String? base64Data,
    required bool locked,
    required VoidCallback onTap,
  }) {
    final bool hasData = base64Data != null && base64Data.isNotEmpty;

    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KkColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: locked ? null : onTap,
        child: hasData
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  base64Decode(base64Data),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    size: 36,
                    color: locked ? Colors.grey : KkColors.green,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: locked ? Colors.grey : KkColors.text,
                    ),
                  ),
                  if (!locked)
                    const Text(
                      'Ketuk untuk mengunggah foto',
                      style: TextStyle(fontSize: 11, color: KkColors.muted),
                    ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: KkColors.bg,
      appBar: AppBar(
        backgroundColor: KkColors.bg,
        elevation: 0,
        leading: const BackButton(color: KkColors.text),
        title: const Text(
          'Detail Tugas',
          style: TextStyle(
            color: KkColors.text,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('job_offers')
              .doc(widget.task.id)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: KkColors.green),
              );
            }

            final data = snapshot.data?.data() ?? {};

            final statusStr = data['status'] as String? ?? '';
            final progressStr = data['progressStatus'] as String? ?? '';
            final postedByUid = data['postedByUid'] as String? ?? '';

            // Sinkronkan gambar dari Firestore jika sudah tersimpan sebelumnya
            final firestoreBefore = data['beforeImageBase64'] as String?;
            final firestoreAfter = data['afterImageBase64'] as String?;

            final activeBefore = _beforeBase64 ?? firestoreBefore;
            final activeAfter = _afterBase64 ?? firestoreAfter;

            // Cek apakah user yang membuka halaman ini adalah Pemberi Kerja
            final bool isClient = currentUser != null && currentUser.uid == postedByUid;

            TaskStatus currentStatus = TaskStatus.berjalan;
            if (statusStr == 'completed' ||
                statusStr == 'done' ||
                progressStr == 'completed') {
              currentStatus = TaskStatus.selesai;
            } else if (statusStr == 'pending_verification' ||
                progressStr == 'waiting_verification') {
              currentStatus = TaskStatus.menungguVerifikasi;
            }

            final locked = currentStatus != TaskStatus.berjalan || isClient;
            final noteText = data['note'] ?? '';

            final rawAmount = data['salary'] ?? data['amount'] ?? widget.task.amount;
            final int amountInt = (rawAmount is num) ? rawAmount.toInt() : 0;

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                KkCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentStatus == TaskStatus.selesai
                            ? 'PEKERJAAN SELESAI'
                            : currentStatus == TaskStatus.menungguVerifikasi
                                ? 'MENUNGGU VERIFIKASI PEMBERI KERJA'
                                : 'PEKERJAAN SEDANG BERJALAN',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: currentStatus == TaskStatus.menungguVerifikasi
                              ? KkColors.gold
                              : KkColors.green,
                        ),
                      ),
                      Text(
                        data['title'] ?? data['jobTitle'] ?? widget.task.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      KkInfoBox(
                        label: 'Pemberi Kerja',
                        value: data['company'] ?? data['clientName'] ?? widget.task.client,
                      ),
                      const SizedBox(height: 8),
                      KkInfoBox(
                        label: 'Lokasi Penugasan',
                        value: data['location'] ?? widget.task.location,
                      ),
                      const SizedBox(height: 8),
                      KkInfoBox(
                        label: 'Honor Bersih (Escrow Safe-Pay)',
                        value: rupiah(amountInt),
                        valueColor: KkColors.green,
                        caption: 'Terjamin Aman di Escrow',
                      ),
                    ],
                  ),
                ),
                const KkSectionTitle(
                  Icons.photo_camera_outlined,
                  'Dokumentasi Bukti Kerja (Before & After)',
                ),
                const Text(
                  'Wajib foto kondisi sebelum & sesudah untuk verifikasi pencairan honor.',
                  style: TextStyle(fontSize: 12, color: KkColors.muted),
                ),
                const SizedBox(height: 12),

                // Unggah Foto Before
                _buildPhotoTile(
                  title: 'Foto Sebelum (Before)',
                  base64Data: activeBefore,
                  locked: locked,
                  onTap: () => _pickImage(true),
                ),
                const SizedBox(height: 10),

                // Unggah Foto After
                _buildPhotoTile(
                  title: 'Foto Sesudah (After)',
                  base64Data: activeAfter,
                  locked: locked,
                  onTap: () => _pickImage(false),
                ),
                const SizedBox(height: 14),

                // ==================== TAMPILAN SISI PEKERJA (BERJALAN) ====================
                if (currentStatus == TaskStatus.berjalan && !isClient) ...[
                  TextField(
                    controller: _note,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Catatan Pengerjaan untuk Pemberi Kerja',
                      hintText:
                          'Contoh: Pekerjaan sudah selesai dirapikan dan dibersihkan',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: KkColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: KkColors.gold,
                        foregroundColor: KkColors.greenDark,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: _isLoading ? null : _submitProofForVerification,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send, size: 18),
                      label: const Text('Kirim Bukti untuk Diverifikasi'),
                    ),
                  ),
                ],

                // ==================== TAMPILAN MENUNGGU VERIFIKASI ====================
                if (currentStatus == TaskStatus.menungguVerifikasi) ...[
                  if (noteText.toString().isNotEmpty)
                    KkCard(
                      child: Text(
                        'Catatan Pekerja: "$noteText"',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  const SizedBox(height: 10),

                  // BILA YANG MEMBUKA ADALAH PEMBERI KERJA -> TAMPILKAN TOMBOL ACC / TOLAK
                  if (isClient) ...[
                    const KkCard(
                      color: Color(0xFFFFF3D6),
                      child: Text(
                        'Pekerja telah mengirimkan bukti kerja. Silakan periksa foto dokumentasi di atas sebelum mengonfirmasi.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                            onPressed: _isLoading ? null : _rejectProofByClient,
                            child: const Text('Minta Perbaikan'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: KkColors.green,
                            ),
                            onPressed: _isLoading ? null : _approveTaskByClient,
                            child: const Text('ACC & Cairkan Honor'),
                          ),
                        ),
                      ],
                    ),
                  ]
                  // BILA YANG MEMBUKA ADALAH PEKERJA -> TAMPILKAN INFORMASI MENUNGGU
                  else ...[
                    const KkCard(
                      color: Color(0xFFFFF3D6),
                      child: Row(
                        children: [
                          Icon(Icons.hourglass_top, color: KkColors.gold),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Bukti kerja berhasil dikirim. Menunggu pemberi kerja memeriksa & mengonfirmasi hasil pekerjaan Anda.',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],

                // ==================== TAMPILAN SELESAI ====================
                if (currentStatus == TaskStatus.selesai)
                  KkCard(
                    color: KkColors.greenSoft,
                    child: Text(
                      'Pekerjaan telah diverifikasi dan selesai. Honor ${rupiah(amountInt)} diteruskan ke saldo dompet.',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: KkColors.green,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}