import 'package:flutter/material.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';
import 'package:inovasi_sumut/regar/data/repositories/worker_repository.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/common/kk_widgets.dart';

/// Satu profil untuk semua fungsi (cari kerja, tawarkan kerja, gotong royong).
class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: workerRepository,
        builder: (context, _) {
          final repo = workerRepository;
          final p = repo.profile;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              KkHeader(notifCount: repo.offers.length),
              const SizedBox(height: 16),
              KkCard(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: KkColors.greenSoft,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        p.firstName.substring(0, 1),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: KkColors.green,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      p.name,
                      style: const TextStyle(
                          fontSize: 19, fontWeight: FontWeight.w800),
                    ),
                    Text(p.skill,
                        style: const TextStyle(color: KkColors.muted)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, size: 16, color: KkColors.gold),
                        const SizedBox(width: 4),
                        Text(
                          '${p.rating} • ${repo.kerjaSelesai} pekerjaan selesai',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.place_outlined,
                            size: 14, color: KkColors.muted),
                        const SizedBox(width: 2),
                        Text(
                          p.area,
                          style: const TextStyle(
                              fontSize: 12, color: KkColors.muted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _Stat('${repo.kerjaSelesai}', 'Kerja Selesai')),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _Stat('${repo.socialProjects}', 'Proyek Sosial')),
                  const SizedBox(width: 8),
                  Expanded(child: _Stat('${repo.points}', 'Poin CP')),
                ],
              ),
              const SizedBox(height: 12),
              KkCard(
                color: KkColors.inner,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TENTANG SAYA:',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: KkColors.muted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '"${p.about}"',
                      style: const TextStyle(
                          fontStyle: FontStyle.italic, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const KkSectionTitle(Icons.verified_outlined, 'Keahlian'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in p.skill.split(',')) KkPill(s.trim()),
                ],
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Expanded(
                    child: _Credential(
                      icon: Icons.build_outlined,
                      label: 'Peralatan',
                      value: 'Bawa Alat Sendiri',
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _Credential(
                      icon: Icons.two_wheeler_outlined,
                      label: 'Mobilitas',
                      value: 'Kendaraan Pribadi',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              KkCard(
                child: Column(
                  children: [
                    _ContactRow(Icons.email_outlined, 'Email', p.email),
                    const Divider(color: KkColors.border),
                    _ContactRow(
                        Icons.phone_outlined, 'Nomor WhatsApp', p.whatsapp),
                    const Divider(color: KkColors.border),
                    _ContactRow(Icons.place_outlined, 'Lokasi', p.area),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return KkCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: KkColors.green,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: KkColors.muted),
          ),
        ],
      ),
    );
  }
}

class _Credential extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Credential({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return KkCard(
      child: Row(
        children: [
          Icon(icon, size: 20, color: KkColors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        const TextStyle(fontSize: 10, color: KkColors.muted)),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: KkColors.greenSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: KkColors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        const TextStyle(fontSize: 11, color: KkColors.muted)),
                Text(value,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
