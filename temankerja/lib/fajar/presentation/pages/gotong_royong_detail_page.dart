import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inovasi_sumut/fajar/presentation/widgets/donation_dialog.dart';

class GotongRoyongDetailPage extends StatelessWidget {
  final Map<String, dynamic> initialData;
  final String? jobId;

  const GotongRoyongDetailPage({
    super.key,
    Map<String, dynamic>? data,
    this.jobId,
  }) : initialData = data ?? const {};

  static String _formatRupiah(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    // Ambil jobId dari parameter atau data initial, jika tidak ada fallback ke 'gotong_royong_1'
    final String activeJobId = (jobId != null && jobId!.isNotEmpty)
        ? jobId!
        : (initialData['id']?.toString().isNotEmpty == true
            ? initialData['id'].toString()
            : 'gotong_royong_1');

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: activeJobId.isNotEmpty
          ? FirebaseFirestore.instance
              .collection('jobs')
              .doc(activeJobId)
              .snapshots()
          : null,
      builder: (context, snapshot) {
        // Gunakan data realtime dari stream jika tersedia, jika tidak pakai initialData
        final Map<String, dynamic> data =
            (snapshot.hasData && snapshot.data?.data() != null)
                ? snapshot.data!.data()!
                : initialData;

        final String title = data['title'] ?? 'Proyek Gotong Royong';
        final String location = data['location'] ?? 'PB SELAYANG 1';
        final String description = data['description'] ??
            'Belum ada deskripsi detail untuk proyek gotong royong ini.';
        final double collectedAmount =
            (data['collectedAmount'] as num?)?.toDouble() ?? 0.0;
        final double targetAmount =
            (data['targetAmount'] as num?)?.toDouble() ?? 0.0;
        final double physicalProgress =
            (data['physicalProgress'] as num?)?.toDouble() ?? 0.0;

        final List<String> progressPhotos =
            List<String>.from(data['progressPhotos'] ?? [])
                .where((url) => url.trim().isNotEmpty)
                .toList();

        final double financialProgress = targetAmount > 0
            ? (collectedAmount / targetAmount).clamp(0.0, 1.0)
            : 0.0;

        String targetDate = 'Belum ditentukan';
        if (data['targetCompletionDate'] != null) {
          if (data['targetCompletionDate'] is Timestamp) {
            targetDate = (data['targetCompletionDate'] as Timestamp)
                .toDate()
                .toString()
                .split(' ')[0];
          } else {
            targetDate = data['targetCompletionDate'].toString().split(' ')[0];
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detail Gotong Royong'),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.diversity_3, size: 14, color: Colors.green),
                          SizedBox(width: 4),
                          Text(
                            'PROYEK DESA',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 2),
                        Text(
                          location,
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.event, size: 16, color: Colors.orange),
                    const SizedBox(width: 6),
                    Text(
                      'Target Selesai: $targetDate',
                      style: const TextStyle(
                          fontSize: 13, color: Colors.orange),
                    ),
                  ],
                ),
                const Divider(height: 32),
                const Text(
                  'Status Progres & Transparansi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Card(
                  color: Colors.green.shade50,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.green.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Transparansi Dana Terkumpul',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${(financialProgress * 100).toInt()}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: financialProgress,
                            backgroundColor: Colors.white,
                            color: Colors.green,
                            minHeight: 10,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rp ${_formatRupiah(collectedAmount)} dari target Rp ${_formatRupiah(targetAmount)}',
                          style: TextStyle(
                              color: Colors.green.shade900, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  color: Colors.blue.shade50,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.blue.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Progres Fisik Pembangunan',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${(physicalProgress * 100).toInt()}% Selesai',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: physicalProgress,
                            backgroundColor: Colors.white,
                            color: Colors.blueAccent,
                            minHeight: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Deskripsi Proyek',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Dokumentasi Lapangan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (progressPhotos.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Belum ada foto dokumentasi yang diunggah.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.3,
                    ),
                    itemCount: progressPhotos.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          progressPhotos[index],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image,
                                color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 30),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      if (activeJobId.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('ID Dokumen Proyek tidak valid'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      showDialog(
                        context: context,
                        builder: (_) => DonationDialog(
                          jobId: activeJobId,
                          title: title,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Donasi Dana'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Terima kasih telah mendaftar sebagai Sukarelawan!'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Ikut Tenaga / Skill'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}