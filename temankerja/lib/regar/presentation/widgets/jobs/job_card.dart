import 'package:flutter/material.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';
import 'package:inovasi_sumut/regar/data/models/job_model.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/common/kk_widgets.dart';

class JobCard extends StatelessWidget {
  final JobModel job;
  final bool applied;
  final VoidCallback onTap;

  const JobCard({
    super.key,
    required this.job,
    required this.applied,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: KkCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: KkColors.text,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                KkPill(job.type.label,
                    bg: KkColors.blueSoft, fg: KkColors.blue),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              job.company,
              style: const TextStyle(fontSize: 12, color: KkColors.muted),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                _InfoItem(
                  icon: Icons.location_on_outlined,
                  text: job.location,
                  color: KkColors.muted,
                ),
                _InfoItem(
                  icon: Icons.payments_outlined,
                  text: job.salary,
                  color: KkColors.green,
                  bold: true,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: KkColors.text,
                      side: const BorderSide(color: KkColors.border),
                    ),
                    child: const Text('Lihat Detail'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: applied ? null : onTap,
                    style: FilledButton.styleFrom(
                      backgroundColor: KkColors.gold,
                      foregroundColor: KkColors.greenDark,
                      disabledBackgroundColor: KkColors.inner,
                    ),
                    child: Text(applied ? 'Sudah Dilamar' : 'Lamar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final bool bold;

  const _InfoItem({
    required this.icon,
    required this.text,
    required this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: bold ? FontWeight.w800 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
