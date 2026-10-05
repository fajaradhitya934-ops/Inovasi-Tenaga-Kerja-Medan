import 'package:inovasi_sumut/regar/data/models/worker_models.dart';

const WorkerProfile dummyProfile = WorkerProfile(
  name: 'Budi Santoso',
  skill: 'Tukang Listrik, CCTV & AC',
  email: 'budi.santoso@medantalenta.id',
  whatsapp: '081260112233',
  area: 'Medan Baru',
  about:
      'Warga Kota Medan yang siap membantu pekerjaan listrik, pemasangan CCTV, dan servis AC, serta aktif di proyek gotong royong lingkungan.',
  rating: 4.8,
  totalTasks: 37,
  onTimePercent: 100,
);

const List<JobOffer> dummyOffers = [
  JobOffer(
    id: 'of-1',
    client: 'Siti Aminah',
    title: 'Pemasangan CCTV Rumah',
    amount: 120000,
    date: '2026-10-06',
    time: '09:00 WIB',
    address: 'Jl. Merdeka No. 12, Medan Baru',
  ),
];

/// Fungsi (bukan const) karena WorkTask bisa berubah statusnya.
List<WorkTask> buildDummyTasks() => [
      WorkTask(
        id: 't-1',
        client: 'Dewi Lestari',
        title: 'Perbaikan Instalasi Listrik',
        location: 'Medan Helvetia',
        amount: 85000,
        status: TaskStatus.menungguVerifikasi,
        hasBefore: true,
        hasAfter: true,
        note: 'Pekerjaan telah selesai dikerjakan sesuai permintaan.',
      ),
      WorkTask(
        id: 't-2',
        client: 'Hendra Ginting',
        title: 'Pasang Lampu & Stop Kontak',
        location: 'Medan Denai',
        amount: 150000,
      ),
    ];

List<WalletTx> buildDummyTxs() => const [
      WalletTx(
        title: 'Honor: Servis AC Kantor',
        subtitle: 'Pelepasan dana dari CV Maju Jaya',
        amount: 200000,
        time: '04/10/2026 11.22 WIB',
      ),
      WalletTx(
        title: 'Pencairan Saldo QRIS',
        subtitle: 'Transfer instan ke Gopay / Rek Bank',
        amount: -325000,
        time: '04/10/2026 10.34 WIB',
      ),
    ];
