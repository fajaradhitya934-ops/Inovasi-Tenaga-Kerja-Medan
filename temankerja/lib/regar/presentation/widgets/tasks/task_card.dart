import 'package:flutter/material.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';
import 'package:inovasi_sumut/regar/core/utils/formatter.dart';
import 'package:inovasi_sumut/regar/data/models/worker_models.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/common/kk_widgets.dart';

class TaskCard extends StatelessWidget {
  final WorkTask task;
  final VoidCallback onTap;

  const TaskCard({super.key, required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (task.status) {
      TaskStatus.berjalan => (
          'Sedang dikerjakan',
          KkColors.goldSoft,
          KkColors.goldText
        ),
      TaskStatus.menungguVerifikasi => (
          'Menunggu verifikasi',
          KkColors.blueSoft,
          KkColors.blue
        ),
      TaskStatus.selesai => ('Selesai', KkColors.greenSoft, KkColors.green),
    };
    final heading = task.status == TaskStatus.selesai
        ? 'PEKERJAAN SELESAI'
        : 'PEKERJAAN SEDANG BERJALAN';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: KkCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: KkColors.greenSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.handyman,
                      color: KkColors.green, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        heading,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: KkColors.green,
                        ),
                      ),
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: KkColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: KkColors.muted),
              ],
            ),
            const SizedBox(height: 8),
            KkPill(label, bg: bg, fg: fg),
            const SizedBox(height: 10),
            KkInfoBox(label: 'Pemberi Kerja', value: task.client),
            const SizedBox(height: 8),
            KkInfoBox(label: 'Lokasi Penugasan', value: task.location),
            const SizedBox(height: 8),
            KkInfoBox(
              label: 'Honor Bersih (Escrow Safe-Pay)',
              value: rupiah(task.amount),
              valueColor: KkColors.green,
              caption: 'Terjamin Aman di Escrow',
            ),
          ],
        ),
      ),
    );
  }
}
