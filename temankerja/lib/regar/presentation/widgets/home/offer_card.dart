import 'package:flutter/material.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';
import 'package:inovasi_sumut/regar/core/utils/formatter.dart';
import 'package:inovasi_sumut/regar/data/models/worker_models.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/common/kk_widgets.dart';

class OfferCard extends StatelessWidget {
  final JobOffer offer;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const OfferCard({
    super.key,
    required this.offer,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return KkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const KkPill('TAWARAN KHUSUS',
                  bg: KkColors.goldSoft, fg: KkColors.goldText),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Klien: ${offer.client}',
                  style: const TextStyle(fontSize: 12, color: KkColors.muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tawaran: ${rupiah(offer.amount)}',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: KkColors.green,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            offer.title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.schedule, size: 14, color: KkColors.muted),
              const SizedBox(width: 4),
              Text(
                '${offer.date} • Pukul ${offer.time}',
                style: const TextStyle(fontSize: 12, color: KkColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(Icons.place_outlined, size: 14, color: KkColors.muted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  offer.address,
                  style: const TextStyle(fontSize: 12, color: KkColors.muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Row(
            children: [
              Icon(Icons.verified_user_outlined,
                  size: 14, color: KkColors.green),
              SizedBox(width: 4),
              Text(
                'Dana Escrow QRIS Terjamin',
                style: TextStyle(fontSize: 12, color: KkColors.green),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: KkColors.red),
                  onPressed: onReject,
                  child: const Text('Tolak'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: KkColors.gold,
                    foregroundColor: KkColors.greenDark,
                  ),
                  onPressed: onAccept,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Setujui Tawaran'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
