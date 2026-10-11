import 'package:inovasi_sumut/regar/data/models/job_model.dart';

List<JobModel> dummyJobs = [
  const JobModel(
    id: 'job-001',
    title: 'Teknisi AC & Listrik',
    company: 'Servis Mandiri Medan',
    location: 'Medan Kota',
    salary: 200000.0, // Diubah ke double
    type: JobType.harian,
    category: 'Jasa',
    postedAgo: '2 jam lalu',
    isSkillExchangeable: true,
    description:
        'Dibutuhkan teknisi untuk perbaikan dan pemasangan AC serta instalasi listrik rumah tangga di area Medan Kota dan sekitarnya.',
    requirements: [
      'Berpengalaman minimal 1 tahun',
      'Membawa peralatan sendiri',
      'Memiliki kendaraan pribadi',
      'Jujur dan tepat waktu',
    ],
  ),
  const JobModel(
    id: 'job-002',
    title: 'Staf Kasir & Admin',
    company: 'Toko Sembako Berkah',
    location: 'Medan Helvetia',
    salary: 2500000.0, // Diubah ke double
    type: JobType.fullTime,
    category: 'Ritel',
    postedAgo: '5 jam lalu',
    isSkillExchangeable: false,
    description:
        'Mengelola kasir, mencatat stok barang, dan membuat laporan penjualan harian toko.',
    requirements: [
      'Minimal lulusan SMA/SMK',
      'Menguasai Excel dasar',
      'Teliti dan komunikatif',
    ],
  ),
  const JobModel(
    id: 'job-003',
    title: 'Desainer Grafis Freelance',
    company: 'Studio Kreatif Medan',
    location: 'Medan Selayang',
    salary: 500000.0, // Diubah ke double
    type: JobType.freelance,
    category: 'Kreatif',
    postedAgo: '1 hari lalu',
    isSkillExchangeable: true,
    description:
        'Membuat desain poster, banner, dan konten media sosial untuk klien UMKM.',
    requirements: [
      'Menguasai Canva / Photoshop / Figma',
      'Memiliki portofolio',
      'Mampu bekerja dengan tenggat waktu',
    ],
  ),
];