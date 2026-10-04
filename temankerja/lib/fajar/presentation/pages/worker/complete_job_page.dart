import 'package:flutter/material.dart';
import '/fajar/core/constant/app_colors.dart';

class CompleteJobPage extends StatefulWidget {
  const CompleteJobPage({Key? key}) : super(key: key);

  @override
  State<CompleteJobPage> createState() => _CompleteJobPageState();
}

class _CompleteJobPageState extends State<CompleteJobPage> {
  bool _isImageUploaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Penyelesaian Kerja', style: TextStyle(color: AppColors.textDark, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              onTap: () {
                setState(() {
                  _isImageUploaded = true; // Simulasi Upload
                });
              },
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                ),
                child: _isImageUploaded
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: AppColors.medanGreen, size: 48),
                          SizedBox(height: 8),
                          Text('Foto Hasil Kerja Terunggah!', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined, color: AppColors.textMuted, size: 40),
                          SizedBox(height: 8),
                          Text('Klik untuk ambil/unggah foto', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        ],
                      ),
              ),
            ),
            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isImageUploaded
                    ? () {
                        // Lanjut ke Halaman Generate QR
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.medanGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Lanjut Buat QR Tagihan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}