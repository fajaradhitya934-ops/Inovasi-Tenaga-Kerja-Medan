import 'package:flutter/material.dart';
import '../../../fajar/core/constant/app_colors.dart';

class CariKerjaPage extends StatefulWidget {
  const CariKerjaPage({super.key});

  @override
  State<CariKerjaPage> createState() => _CariKerjaPageState();
}

class _CariKerjaPageState extends State<CariKerjaPage> {
  final TextEditingController _searchController = TextEditingController();

  // Data Dummy Lowongan Kerja
  final List<Map<String, String>> _jobList = const [
    {
      'title': 'Teknisi AC & Listrik',
      'company': 'Servis Mandiri Medan',
      'location': 'Medan Kota',
      'salary': 'Rp 150rb - 250rb / hari',
      'type': 'Harian',
      'category': 'Jasa',
    },
    {
      'title': 'Staf Kasir & Admin',
      'company': 'Toko Sembako Berkah',
      'location': 'Medan Helvetia',
      'salary': 'Rp 2.500.000 / bulan',
      'type': 'Full Time',
      'category': 'Ritel',
    },
    {
      'title': 'Driver Operasional',
      'company': 'CV Distribusi Utama',
      'location': 'Medan Amplas',
      'salary': 'Rp 3.000.000 / bulan',
      'type': 'Full Time',
      'category': 'Logistik',
    },
    {
      'title': 'Desainer Grafis Freelance',
      'company': 'Studio Kreatif Medan',
      'location': 'Medan Selayang',
      'salary': 'Rp 500rb / proyek',
      'type': 'Freelance',
      'category': 'Kreatif',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cari Pekerjaan',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar & Filter Button
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Cari posisi, skill, atau lokasi...',
                        hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
                        icon: Icon(Icons.search, color: AppColors.textMuted),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.medanGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.tune, color: Colors.white),
                    onPressed: () {
                      // Action Filter
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Section Info Total Lowongan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Baris 122 diperbaiki
              children: [
                Text(
                  '${_jobList.length} Lowongan Tersedia',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const Text(
                  'Urutkan: Terbaru',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Daftar Lowongan Pekerjaan
            Expanded(
              child: ListView.builder(
                itemCount: _jobList.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final job = _jobList[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Baris 162 diperbaiki
                          children: [
                            Expanded(
                              child: Text(
                                job['title']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                job['type']!,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job['company']!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              job['location']!,
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.payments_outlined, size: 14, color: AppColors.medanGreen),
                            const SizedBox(width: 4),
                            Text(
                              job['salary']!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.medanGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Lamar pekerjaan: ${job['title']}')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.medanGreen,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Lamar Sekarang',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}