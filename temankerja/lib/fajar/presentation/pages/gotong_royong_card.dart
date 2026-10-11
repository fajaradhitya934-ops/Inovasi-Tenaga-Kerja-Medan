import 'package:flutter/material.dart';

class GotongRoyongCard extends StatelessWidget {
  final String title;
  final String location;
  final double collectedAmount;
  final double targetAmount;
  final double physicalProgress; // 0.0 sampai 1.0 (0% - 100%)
  final String targetCompletionDate;
  final List<String> progressPhotos;
  final VoidCallback onTap;

  const GotongRoyongCard({
    super.key,
    required this.title,
    required this.location,
    required this.collectedAmount,
    required this.targetAmount,
    required this.physicalProgress,
    required this.targetCompletionDate,
    required this.progressPhotos,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double financialProgress =
        targetAmount > 0 ? (collectedAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge & Lokasi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                        'GOTONG ROYONG DESA',
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
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 2),
                    Text(
                      location,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Judul Proyek
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),

            // Target Selesai
            Row(
              children: [
                const Icon(Icons.event, size: 14, color: Colors.orange),
                const SizedBox(width: 4),
                Text(
                  'Target Selesai: $targetCompletionDate',
                  style: const TextStyle(fontSize: 12, color: Colors.orange),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 1. Progres Pendanaan (Transparansi Uang)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dana Terkumpul:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                Text(
                  'Rp ${_formatRupiah(collectedAmount)} / Rp ${_formatRupiah(targetAmount)}',
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
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: financialProgress,
                backgroundColor: Colors.grey.shade200,
                color: Colors.green,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 14),

            // 2. Progres Fisik Pembangunan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Progres Pembangunan:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                Text(
                  '${(physicalProgress * 100).toInt()}% Selesai',
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
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: physicalProgress,
                backgroundColor: Colors.grey.shade200,
                color: Colors.blueAccent,
                minHeight: 10,
              ),
            ),

            // 3. Galeri Foto Progres (Akses Lurah / Kades Upload Foto)
            if (progressPhotos.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Text(
                'Dokumentasi Progres Lapangan:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: progressPhotos.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(progressPhotos[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Tombol Aksi Warga
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.handshake, color: Colors.white, size: 18),
                label: const Text(
                  'Ikut Gotong Royong / Lihat Detail',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
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