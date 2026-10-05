import 'package:flutter/material.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';
import 'package:inovasi_sumut/regar/core/utils/formatter.dart';

class WalletCard extends StatelessWidget {
  final int balance;
  final bool hidden;
  final VoidCallback onToggle;
  final VoidCallback onHistory;
  final VoidCallback onWithdraw;

  const WalletCard({
    super.key,
    required this.balance,
    required this.hidden,
    required this.onToggle,
    required this.onHistory,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: KkColors.greenDark,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saldo Dompet Digital',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  hidden ? 'Rp ••••••' : rupiah(balance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: onToggle,
                icon: Icon(
                  hidden ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                  ),
                  onPressed: onHistory,
                  icon: const Icon(Icons.history, size: 18),
                  label: const Text('Riwayat'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: KkColors.gold,
                    foregroundColor: KkColors.greenDark,
                  ),
                  onPressed: onWithdraw,
                  icon: const Icon(Icons.qr_code_2, size: 18),
                  label: const Text('Tarik Saldo QRIS'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
