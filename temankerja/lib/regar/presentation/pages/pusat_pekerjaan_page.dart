import 'package:flutter/material.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';
import 'package:inovasi_sumut/regar/data/repositories/worker_repository.dart';
import 'package:inovasi_sumut/regar/presentation/pages/detail_tugas_page.dart';
import 'package:inovasi_sumut/regar/presentation/pages/cari_kerja_page.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/common/kk_widgets.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/home/offer_card.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/tasks/task_card.dart';

class PusatPekerjaanPage extends StatefulWidget {
  const PusatPekerjaanPage({super.key});

  @override
  State<PusatPekerjaanPage> createState() => _PusatPekerjaanPageState();
}

class _PusatPekerjaanPageState extends State<PusatPekerjaanPage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: workerRepository,
        builder: (context, _) {
          final repo = workerRepository;
          final tabs = [
            'Tugas Aktif (${repo.activeTasks.length})',
            'Tawaran & Lamaran (${repo.offers.length + repo.applications.length})',
            'Riwayat Selesai (${repo.doneTasks.length})',
          ];
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              KkHeader(
                notifCount: repo.offers.length,
              ),
              const SizedBox(height: 16),
              const Text(
                'Pusat Pekerjaan & Tugas',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: KkColors.text,
                ),
              ),
              const Text(
                'Kelola tugas aktif, konfirmasi tawaran klien, dan pantau status lamaran Anda.',
                style: TextStyle(fontSize: 13, color: KkColors.muted),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: KkColors.gold,
                    foregroundColor: KkColors.greenDark,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CariKerjaPage()),
                  ),
                  icon: const Icon(Icons.travel_explore, size: 18),
                  label: const Text('Cari Lowongan'),
                ),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var i = 0; i < tabs.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(tabs[i]),
                          selected: _tab == i,
                          showCheckmark: false,
                          selectedColor: KkColors.green,
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: _tab == i ? KkColors.green : KkColors.border,
                          ),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _tab == i ? Colors.white : KkColors.text,
                          ),
                          onSelected: (_) => setState(() => _tab = i),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              ..._content(context),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _content(BuildContext context) {
    final repo = workerRepository;

    void openTask(task) => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailTugasPage(task: task)),
        );

    if (_tab == 0) {
      if (repo.activeTasks.isEmpty) return [_empty('Belum ada tugas aktif.')];
      return [
        for (final t in repo.activeTasks)
          TaskCard(task: t, onTap: () => openTask(t)),
      ];
    }

    if (_tab == 1) {
      if (repo.offers.isEmpty && repo.applications.isEmpty) {
        return [_empty('Belum ada tawaran atau lamaran.')];
      }
      return [
        for (final o in repo.offers)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OfferCard(
              offer: o,
              onReject: () => repo.rejectOffer(o),
              onAccept: () => repo.acceptOffer(o),
            ),
          ),
        for (final j in repo.applications)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: KkCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          j.title,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          j.company,
                          style: const TextStyle(
                              fontSize: 12, color: KkColors.muted),
                        ),
                      ],
                    ),
                  ),
                  const KkPill('Menunggu respons',
                      bg: KkColors.blueSoft, fg: KkColors.blue),
                ],
              ),
            ),
          ),
      ];
    }

    if (repo.doneTasks.isEmpty) return [_empty('Belum ada pekerjaan selesai.')];
    return [
      for (final t in repo.doneTasks)
        TaskCard(task: t, onTap: () => openTask(t)),
    ];
  }

  Widget _empty(String text) => KkCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(text, style: const TextStyle(color: KkColors.muted)),
          ),
        ),
      );
}
