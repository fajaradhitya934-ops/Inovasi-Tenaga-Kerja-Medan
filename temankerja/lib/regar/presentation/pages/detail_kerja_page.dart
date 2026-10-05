import 'package:flutter/material.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';
import 'package:inovasi_sumut/regar/data/models/job_model.dart';
import 'package:inovasi_sumut/regar/data/repositories/job_repository.dart';
import 'package:inovasi_sumut/regar/data/repositories/worker_repository.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/common/kk_widgets.dart';

class DetailKerjaPage extends StatefulWidget {
  final JobModel job;

  const DetailKerjaPage({super.key, required this.job});

  @override
  State<DetailKerjaPage> createState() => _DetailKerjaPageState();
}

class _DetailKerjaPageState extends State<DetailKerjaPage> {
  bool _sending = false;

  Future<void> _apply() async {
    final job = widget.job;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lamar pekerjaan ini?'),
        content: Text(
          'Lamaran untuk "${job.title}" akan dikirim ke ${job.company}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: KkColors.green),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Kirim Lamaran'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _sending = true);
    try {
      await jobRepository.applyToJob(job.id);
      workerRepository.addApplication(job);
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lamaran "${job.title}" terkirim')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim lamaran. Coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    return Scaffold(
      backgroundColor: KkColors.bg,
      appBar: AppBar(
        backgroundColor: KkColors.bg,
        elevation: 0,
        leading: const BackButton(color: KkColors.text),
        title: const Text(
          'Detail Lowongan',
          style: TextStyle(
            color: KkColors.text,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          KkCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: KkColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  job.company,
                  style: const TextStyle(fontSize: 13, color: KkColors.muted),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    KkPill(job.type.label,
                        bg: KkColors.blueSoft, fg: KkColors.blue),
                    KkPill(job.category),
                    KkPill(job.location,
                        bg: KkColors.inner, fg: KkColors.muted),
                    if (job.postedAgo.isNotEmpty)
                      KkPill(job.postedAgo,
                          bg: KkColors.inner, fg: KkColors.muted),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          KkInfoBox(
            label: 'Honor / Gaji',
            value: job.salary,
            valueColor: KkColors.green,
          ),
          if (job.description.isNotEmpty) ...[
            const KkSectionTitle(
                Icons.description_outlined, 'Deskripsi Pekerjaan'),
            Text(
              job.description,
              style: const TextStyle(
                  fontSize: 13, height: 1.5, color: KkColors.text),
            ),
          ],
          if (job.requirements.isNotEmpty) ...[
            const KkSectionTitle(Icons.checklist, 'Persyaratan'),
            for (final r in job.requirements)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.check_circle,
                          size: 16, color: KkColors.green),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        r,
                        style:
                            const TextStyle(fontSize: 13, color: KkColors.text),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: ListenableBuilder(
          listenable: workerRepository,
          builder: (context, _) {
            final applied = workerRepository.isApplied(job.id);
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: KkColors.border)),
              ),
              child: SizedBox(
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: KkColors.gold,
                    foregroundColor: KkColors.greenDark,
                    disabledBackgroundColor: KkColors.inner,
                  ),
                  onPressed: (applied || _sending) ? null : _apply,
                  child: _sending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: KkColors.greenDark,
                          ),
                        )
                      : Text(
                          applied ? 'Sudah Dilamar' : 'Lamar Sekarang',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
