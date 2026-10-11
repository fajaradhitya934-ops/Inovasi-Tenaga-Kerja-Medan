import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '/fajar/core/constant/app_colors.dart';
import 'payment_qr_page.dart';

class CompleteJobPage extends StatefulWidget {
  final String jobId;
  final String title;
  final double amount;
  final String? workerOfferId; // ID Penawaran Pekerja jika ada

  const CompleteJobPage({
    super.key,
    this.jobId = 'JOB-12345',
    this.title = 'Perbaikan Instalasi Listrik',
    this.amount = 120000,
    this.workerOfferId,
  });

  @override
  State<CompleteJobPage> createState() => _CompleteJobPageState();
}

class _CompleteJobPageState extends State<CompleteJobPage> {
  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  // Fungsi Pilih Foto (Kamera / Galeri)
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Bottom Sheet Pilihan Sumber Foto
  void _showPickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera, color: AppColors.medanGreen),
                title: const Text('Ambil Foto dari Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.medanGreen),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Fungsi Unggah ke Firebase Storage & Update Firestore Batch
  Future<void> _submitJobProof() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      // 1. Unggah Foto Bukti Kerja ke Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('job_proofs')
          .child('${widget.jobId}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putFile(_selectedImage!);
      _uploadedImageUrl = await storageRef.getDownloadURL();

      // Gunakan WriteBatch agar semua update Firestore diproses atomik
      final batch = FirebaseFirestore.instance.batch();

      // 2. Update Status Pekerjaan Aktif
      final activeJobRef = FirebaseFirestore.instance
          .collection('active_jobs')
          .doc(widget.jobId);

      batch.set(
        activeJobRef,
        {
          'status': 'completed_pending_payment',
          'proofImageUrl': _uploadedImageUrl,
          'completedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // 3. Kembalikan status penawaran pekerja agar 'active' (muncul kembali tanpa buat baru)
      final offerId = widget.workerOfferId ?? currentUser?.uid;
      if (offerId != null) {
        final workerOfferRef = FirebaseFirestore.instance
            .collection('job_offers')
            .doc(offerId);

        batch.set(
          workerOfferRef,
          {
            'status': 'active',
            'isBusy': false,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      // 4. Update status lowongan pemesan menjadi 'completed' (tetap hilang dari publik)
      final jobRef = FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.jobId);

      batch.set(
        jobRef,
        {
          'status': 'completed',
          'completedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // Eksekusi seluruh batch
      await batch.commit();

      if (!mounted) return;

      // 5. Pindah ke Halaman QR Tagihan Pembayaran
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentQrPage(
            jobId: widget.jobId,
            title: widget.title,
            amount: widget.amount,
            proofUrl: _uploadedImageUrl ?? '',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyelesaikan pekerjaan: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Verifikasi Penyelesaian Kerja',
          style: TextStyle(color: AppColors.textDark, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tagihan: Rp ${_formatRupiah(widget.amount)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.medanGreen,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Upload Bukti Foto Hasil Kerja',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ambil atau unggah foto hasil pekerjaan yang telah selesai sebagai syarat verifikasi oleh pemesan.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),

            // Box Area Upload Gambar
            GestureDetector(
              onTap: _isUploading ? null : _showPickerBottomSheet,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined, color: AppColors.textMuted, size: 40),
                          SizedBox(height: 8),
                          Text(
                            'Klik untuk ambil/unggah foto',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
              ),
            ),

            const Spacer(),

            // Tombol Lanjut Buat QR Tagihan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_selectedImage != null && !_isUploading)
                    ? _submitJobProof
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.medanGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Lanjut Buat QR Tagihan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRupiah(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}