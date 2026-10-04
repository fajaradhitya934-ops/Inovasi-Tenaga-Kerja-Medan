import 'package:flutter/material.dart';
import '/fajar/core/constant/app_colors.dart';

class PaymentQRPage extends StatelessWidget {
  final double workerSalary;
  final double appCost;

  const PaymentQRPage({
    Key? key,
    this.workerSalary = 500000,
    this.appCost = 10000,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double totalPayment = workerSalary + appCost; // 510.000

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Tagihan Pembayaran', style: TextStyle(color: AppColors.textDark, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              'Tunjukkan QR ini ke Pemesan/Klien',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Container QR Code Placeholder
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade200, blurRadius: 8, spreadRadius: 2),
                ],
              ),
              child: Column(
                children: [
                  // Gambar Placeholder QR Code
                  Container(
                    width: 200,
                    height: 200,
                    color: Colors.black12,
                    child: const Icon(Icons.qr_code_2, size: 160, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Total Tagihan: Rp ${totalPayment.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.medanGreen),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Card Penjelasan Penahanan Dana (Escrow)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sesuai sistem, dana Rp ${totalPayment.toStringAsFixed(0)} akan masuk ke penampungan aplikasi dahulu. Setelah dikonfirmasi klien, Rp ${workerSalary.toStringAsFixed(0)} langsung cair ke dompet Anda.',
                      style: const TextStyle(fontSize: 11, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    
  }
}