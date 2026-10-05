import 'package:flutter/material.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/common/kk_widgets.dart';

class OngoingCard extends StatelessWidget {
  final int count;
  final String? firstTitle;
  final VoidCallback onManage;

  const OngoingCard({
    super.key,
    required this.count,
    required this.firstTitle,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    return KkCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: KkColors.greenSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.handyman, color: KkColors.green, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count Pekerjaan Sedang Ditangani',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 13),
                ),
                const SizedBox(height: 4),
                const KkPill('Tugas Berjalan'),
                if (firstTitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    firstTitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: KkColors.muted),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: KkColors.green),
            onPressed: onManage,
            child: Text('Kelola ($count)'),
          ),
        ],
      ),
    );
  }
}
