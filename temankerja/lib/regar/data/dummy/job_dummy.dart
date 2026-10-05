import 'package:inovasi_sumut/regar/data/models/job_model.dart';

const List<JobModel> dummyJobs = [
  JobModel(
    id: 'job-001',
    title: 'Teknisi AC & Listrik',
    company: 'Servis Mandiri Medan',
    location: 'Medan Kota',
    salary: 'Rp 150rb - 250rb / hari',
    type: JobType.harian,
    category: 'Jasa',
    postedAgo: '2 jam lalu',
    description:
        'Dibutuhkan teknisi untuk perbaikan dan pemasangan AC serta instalasi listrik rumah tangga di area Medan Kota dan sekitarnya.',
    requirements: [
      'Berpengalaman minimal 1 tahun',
      'Membawa peralatan sendiri',
      'Memiliki kendaraan pribadi',
      'Jujur dan tepat waktu',
    ],
  ),
  JobModel(
    id: 'job-002',
    title: 'Staf Kasir & Admin',
    company: 'Toko Sembako Berkah',
    location: 'Medan Helvetia',
    salary: 'Rp 2.500.000 / bulan',
    type: JobType.fullTime,
    category: 'Ritel',
    postedAgo: '5 jam lalu',
    description:
        'Mengelola kasir, mencatat stok barang, dan membuat laporan penjualan harian toko.',
    requirements: [
      'Minimal lulusan SMA/SMK',
      'Menguasai Excel dasar',
      'Teliti dan komunikatif',
    ],
  ),
  JobModel(
    id: 'job-003',
    title: 'Driver Operasional',
    company: 'CV Distribusi Utama',
    location: 'Medan Amplas',
    salary: 'Rp 3.000.000 / bulan',
    type: JobType.fullTime,
    category: 'Logistik',
    postedAgo: '1 hari lalu',
    description:
        'Mengantar barang ke pelanggan dalam Kota Medan sesuai rute harian yang ditentukan.',
    requirements: [
      'Memiliki SIM A/B1 aktif',
      'Hafal jalan di Kota Medan',
      'Siap bekerja shift',
    ],
  ),
  JobModel(
    id: 'job-004',
    title: 'Desainer Grafis Freelance',
    company: 'Studio Kreatif Medan',
    location: 'Medan Selayang',
    salary: 'Rp 500rb / proyek',
    type: JobType.freelance,
    category: 'Kreatif',
    postedAgo: '1 hari lalu',
    description:
        'Membuat desain poster, banner, dan konten media sosial untuk klien UMKM.',
    requirements: [
      'Menguasai Canva / Photoshop / Figma',
      'Memiliki portofolio',
      'Mampu bekerja dengan tenggat waktu',
    ],
  ),
  JobModel(
    id: 'job-005',
    title: 'Tukang Cat Pagar & Dinding',
    company: 'Bapak Hendra',
    location: 'Medan Denai',
    salary: 'Rp 180rb / hari',
    type: JobType.harian,
    category: 'Jasa',
    postedAgo: '2 hari lalu',
    description:
        'Pengecatan pagar dan dinding luar rumah, pekerjaan sekitar 2 hari. Cat disediakan pemilik rumah.',
    requirements: [
      'Berpengalaman mengecat',
      'Membawa kuas dan roller sendiri',
    ],
  ),
  JobModel(
    id: 'job-006',
    title: 'Admin Media Sosial UMKM',
    company: 'Kedai Kopi Nusantara',
    location: 'Medan Petisah',
    salary: 'Rp 1.200.000 / bulan',
    type: JobType.proyek,
    category: 'Kreatif',
    postedAgo: '3 hari lalu',
    description:
        'Mengelola Instagram dan TikTok kedai, membuat jadwal konten, dan membalas pesan pelanggan.',
    requirements: [
      'Aktif di media sosial',
      'Bisa mengedit video sederhana',
      'Kreatif dan rajin',
    ],
  ),
];
