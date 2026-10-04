import 'package:flutter/material.dart';

// Import relative path yang benar (mundur ke folder core)
import '/fajar/core/constant/app_colors.dart';

class OfferJobPage extends StatefulWidget {
  const OfferJobPage({Key? key}) : super(key: key);

  @override
  State<OfferJobPage> createState() => _OfferJobPageState();
}

class _OfferJobPageState extends State<OfferJobPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  final double _appFeePercent = 0.02; // Contoh 2% biaya aplikasi

  @override
  Widget build(BuildContext context) {
    double cleanSalary = double.tryParse(_priceController.text) ?? 0;
    double appFee = cleanSalary * _appFeePercent; // Jika 500rb -> 10rb
    double totalClientPay = cleanSalary + appFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tawarkan Keahlian / Kerja',
          style: TextStyle(color: AppColors.textDark, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: const BackButton(color: AppColors.textDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lengkapi Profil Pekerjaan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              
              // Input Judul Keahlian
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Pekerjaan / Keahlian',
                  hintText: 'Contoh: Perbaikan Instalasi Listrik Rumah',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Input Tarif Bersih Pekerja
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                onChanged: (val) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Upah Bersih Yang Ingin Diterima (Rp)',
                  hintText: '500000',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Rincian Kalkulasi Biaya Aplikasi
              if (cleanSalary > 0)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.medanYellow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderYellow),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Upah Bersih Pekerja:'),
                          Text(
                            'Rp ${cleanSalary.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Biaya Layanan Aplikasi (2%):'),
                          Text(
                            'Rp ${appFee.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Yang Dibayar Klien:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Rp ${totalClientPay.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppColors.medanGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),

              // Deskripsi Pekerjaan
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Detil Layanan',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Logic Simpan Penawaran Kerja
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.medanGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Publikasikan Penawaran',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}