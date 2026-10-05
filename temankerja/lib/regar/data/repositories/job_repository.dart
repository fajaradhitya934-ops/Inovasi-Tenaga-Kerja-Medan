import 'package:inovasi_sumut/regar/data/dummy/job_dummy.dart';
import 'package:inovasi_sumut/regar/data/models/job_model.dart';

/// Semua halaman Cari Kerja mengambil data lewat kelas ini.
/// Saat Firebase siap, cukup buat FirebaseJobRepository yang meng-implement
/// kelas ini lalu ganti isi variabel [jobRepository] di bawah.
abstract class JobRepository {
  Future<List<JobModel>> getJobs();
  Future<Set<String>> getAppliedJobIds();
  Future<void> applyToJob(String jobId);
}

class DummyJobRepository implements JobRepository {
  final Set<String> _applied = {};

  @override
  Future<List<JobModel>> getJobs() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return dummyJobs;
  }

  @override
  Future<Set<String>> getAppliedJobIds() async => Set<String>.of(_applied);

  @override
  Future<void> applyToJob(String jobId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _applied.add(jobId);
  }
}

final JobRepository jobRepository = DummyJobRepository();
