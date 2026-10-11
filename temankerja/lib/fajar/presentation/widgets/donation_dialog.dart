import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DonationDialog extends StatefulWidget {
  final String jobId;
  final String title;

  const DonationDialog({
    super.key,
    required this.jobId,
    required this.title,
  });

  @override
  State<DonationDialog> createState() => _DonationDialogState();
}

class _DonationDialogState extends State<DonationDialog> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String _selectedPaymentMethod = 'QRIS';
  bool _isSubmitting = false;

  final List<double> _quickAmounts = [10000, 25000, 50000, 100000];

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _processDonation() async {
    // Validasi ketersediaan jobId
    if (widget.jobId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal: ID Proyek tidak ditemukan.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final double? amount =
        double.tryParse(_amountController.text.replaceAll('.', ''));

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nominal donasi yang valid')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 1. Catat transaksi di sub-collection 'donations'
      await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.jobId)
          .collection('donations')
          .add({
        'donorName': _nameController.text.trim().isEmpty
            ? 'Hamba Allah'
            : _nameController.text.trim(),
        'amount': amount,
        'paymentMethod': _selectedPaymentMethod,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Update collectedAmount di dokumen proyek 'jobs'
      await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.jobId)
          .update({
        'collectedAmount': FieldValue.increment(amount),
      });

      if (!mounted) return;
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Terima kasih! Donasi sebesar Rp ${_formatRupiah(amount)} berhasil dikirim.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Gagal memproses donasi: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  static String _formatRupiah(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Donasi Gotong Royong',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            widget.title,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nama Donatur
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama Donatur (Opsional)',
                hintText: 'Biarkan kosong untuk Hamba Allah',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Nominal Donasi
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Nominal Donasi (Rp)',
                prefixText: 'Rp ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Pilihan Nominal Cepat
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _quickAmounts.map((val) {
                return ActionChip(
                  label: Text('Rp ${_formatRupiah(val)}'),
                  labelStyle: const TextStyle(fontSize: 11),
                  onPressed: () {
                    _amountController.text = val.toInt().toString();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Metode Pembayaran
            const Text(
              'Metode Pembayaran',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedPaymentMethod,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: [
                'QRIS',
                'Transfer Bank (BCA)',
                'Transfer Bank (BRI)',
                'E-Wallet (Gopay/OVO)'
              ]
                  .map((method) => DropdownMenuItem(
                        value: method,
                        child:
                            Text(method, style: const TextStyle(fontSize: 13)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPaymentMethod = value);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _processDonation,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Bayar Sekarang'),
        ),
      ],
    );
  }
}