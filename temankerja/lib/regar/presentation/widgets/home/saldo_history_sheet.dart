import 'package:flutter/material.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';
import 'package:inovasi_sumut/regar/core/utils/formatter.dart';
import 'package:inovasi_sumut/regar/data/repositories/worker_repository.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/common/kk_widgets.dart';

Future<void> showSaldoHistorySheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: KkColors.bg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      builder: (ctx, scroll) => ListenableBuilder(
        listenable: workerRepository,
        builder: (_, __) {
          final txs = workerRepository.transactions;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.history, color: KkColors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Riwayat Mutasi Saldo\nSaldo saat ini: ${rupiah(workerRepository.balance)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: KkColors.text,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  controller: scroll,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: txs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final t = txs[i];
                    final masuk = t.amount >= 0;
                    return KkCard(
                      child: Row(
                        children: [
                          Icon(
                            masuk ? Icons.south_west : Icons.north_east,
                            size: 20,
                            color: masuk ? KkColors.green : KkColors.red,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  t.subtitle,
                                  style: const TextStyle(
                                      fontSize: 11, color: KkColors.muted),
                                ),
                                Text(
                                  t.time,
                                  style: const TextStyle(
                                      fontSize: 11, color: KkColors.muted),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${masuk ? '+' : ''}${rupiah(t.amount)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: masuk ? KkColors.green : KkColors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Tutup Riwayat'),
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
