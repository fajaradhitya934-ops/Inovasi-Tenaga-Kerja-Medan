import 'package:flutter/foundation.dart';
import 'package:inovasi_sumut/regar/core/utils/formatter.dart';
import 'package:inovasi_sumut/regar/data/dummy/worker_dummy.dart';
import 'package:inovasi_sumut/regar/data/models/job_model.dart';
import 'package:inovasi_sumut/regar/data/models/worker_models.dart';

/// Pusat data pengguna (saldo, tawaran, tugas, lamaran, poin kontribusi).
/// Sekarang masih data contoh di memori. Saat Firebase siap, isi method-method
/// di bawah diganti panggilan Firestore, halaman tidak perlu diubah.
class WorkerRepository extends ChangeNotifier {
  final WorkerProfile profile = dummyProfile;

  int _balance = 325000;
  bool _hideBalance = false;
  int _points = 2450;
  int _socialProjects = 12;

  final List<JobOffer> _offers = List<JobOffer>.of(dummyOffers);
  final List<WorkTask> _tasks = buildDummyTasks();
  final List<WalletTx> _txs = buildDummyTxs();
  final List<JobModel> _applications = [];

  int get balance => _balance;
  bool get hideBalance => _hideBalance;
  int get points => _points;
  int get socialProjects => _socialProjects;

  /// Angka awal profil + tugas yang selesai selama aplikasi dipakai.
  int get kerjaSelesai => profile.totalTasks + doneTasks.length;

  List<JobOffer> get offers => List.unmodifiable(_offers);
  List<WorkTask> get tasks => List.unmodifiable(_tasks);
  List<WorkTask> get activeTasks =>
      _tasks.where((t) => t.status != TaskStatus.selesai).toList();
  List<WorkTask> get doneTasks =>
      _tasks.where((t) => t.status == TaskStatus.selesai).toList();
  List<WalletTx> get transactions => List.unmodifiable(_txs);
  List<JobModel> get applications => List.unmodifiable(_applications);

  bool isApplied(String jobId) => _applications.any((j) => j.id == jobId);

  void toggleBalance() {
    _hideBalance = !_hideBalance;
    notifyListeners();
  }

  // ---- poin kontribusi (dipakai juga oleh fitur Gotong Royong nanti) ----
  void addPoints(int value, {bool newSocialProject = false}) {
    _points += value;
    if (newSocialProject) _socialProjects += 1;
    notifyListeners();
  }

  // ---- tawaran ----
  void acceptOffer(JobOffer o) {
    _offers.removeWhere((x) => x.id == o.id);
    _tasks.insert(
      0,
      WorkTask(
        id: 't-${DateTime.now().millisecondsSinceEpoch}',
        client: o.client,
        title: o.title,
        location: o.address,
        amount: o.amount,
      ),
    );
    notifyListeners();
  }

  void rejectOffer(JobOffer o) {
    _offers.removeWhere((x) => x.id == o.id);
    notifyListeners();
  }

  // ---- lamaran ----
  void addApplication(JobModel job) {
    if (isApplied(job.id)) return;
    _applications.insert(0, job);
    notifyListeners();
  }

  // ---- bukti kerja ----
  void markBefore(WorkTask t) {
    t.hasBefore = true;
    notifyListeners();
  }

  void markAfter(WorkTask t) {
    t.hasAfter = true;
    notifyListeners();
  }

  void useDemoPhotos(WorkTask t) {
    t.hasBefore = true;
    t.hasAfter = true;
    notifyListeners();
  }

  /// false kalau foto sesudah belum ada.
  bool submitProof(WorkTask t, String note) {
    if (!t.hasAfter) return false;
    t.note = note;
    t.status = TaskStatus.menungguVerifikasi;
    notifyListeners();
    return true;
  }

  /// Simulasi: klien menyetujui hasil kerja, honor cair ke saldo + poin.
  /// Nanti diganti aksi dari sisi pemberi kerja.
  void simulateClientApprove(WorkTask t) {
    t.status = TaskStatus.selesai;
    _balance += t.amount;
    _points += 10;
    _txs.insert(
      0,
      WalletTx(
        title: 'Honor: ${t.title}',
        subtitle: 'Pelepasan dana dari ${t.client}',
        amount: t.amount,
        time: nowLabel(),
      ),
    );
    notifyListeners();
  }

  bool withdraw() {
    if (_balance <= 0) return false;
    _txs.insert(
      0,
      WalletTx(
        title: 'Pencairan Saldo QRIS',
        subtitle: 'Transfer instan ke Gopay / Rek Bank',
        amount: -_balance,
        time: nowLabel(),
      ),
    );
    _balance = 0;
    notifyListeners();
    return true;
  }
}

final WorkerRepository workerRepository = WorkerRepository();
