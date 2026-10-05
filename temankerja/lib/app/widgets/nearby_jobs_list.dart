import 'package:flutter/material.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';
import 'package:inovasi_sumut/regar/data/models/job_model.dart';
import 'package:inovasi_sumut/regar/data/repositories/job_repository.dart';
import 'package:inovasi_sumut/regar/data/repositories/worker_repository.dart';
import 'package:inovasi_sumut/regar/presentation/pages/detail_kerja_page.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/jobs/job_card.dart';

/// 3 lowongan teratas untuk ditampilkan di Beranda.
class NearbyJobsList extends StatefulWidget {
  const NearbyJobsList({super.key});

  @override
  State<NearbyJobsList> createState() => _NearbyJobsListState();
}

class _NearbyJobsListState extends State<NearbyJobsList> {
  late final Future<List<JobModel>> _future = jobRepository.getJobs();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<JobModel>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: CircularProgressIndicator(color: KkColors.green),
            ),
          );
        }
        final jobs = (snap.data ?? const <JobModel>[]).take(3).toList();
        return ListenableBuilder(
          listenable: workerRepository,
          builder: (context, _) => Column(
            children: [
              for (final j in jobs)
                JobCard(
                  job: j,
                  applied: workerRepository.isApplied(j.id),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DetailKerjaPage(job: j)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
