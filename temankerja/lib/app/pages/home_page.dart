import 'package:flutter/material.dart';
import 'package:inovasi_sumut/app/widgets/hero_stats_card.dart';
import 'package:inovasi_sumut/app/widgets/nearby_jobs_list.dart';
import 'package:inovasi_sumut/app/widgets/service_tile.dart';
import 'package:inovasi_sumut/fajar/presentation/pages/worker/offer_job_page.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';
import 'package:inovasi_sumut/regar/core/utils/formatter.dart';
import 'package:inovasi_sumut/regar/data/repositories/worker_repository.dart';
import 'package:inovasi_sumut/regar/presentation/pages/cari_kerja_page.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/common/kk_widgets.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/home/offer_card.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/home/ongoing_card.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/home/saldo_history_sheet.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/home/wallet_card.dart';

/// Satu-satunya Beranda aplikasi.
class HomePage extends StatelessWidget {
  final VoidCallback onGoActivity;

  const HomePage({super.key, required this.onGoActivity});

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _soon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature segera hadir')),
    );
  }

  Future<void> _withdraw(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    if (workerRepository.balance <= 0) {
      messenger.showSnackBar(const SnackBar(content: Text('Saldo kosong')));
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tarik Saldo via QRIS'),
        content: Text(
          'Tarik seluruh saldo ${rupiah(workerRepository.balance)} ke e-wallet / rekening bank?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: KkColors.green),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Tarik'),
          ),
        ],
      ),
    );
    if (ok == true && workerRepository.withdraw()) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Penarikan saldo diproses')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: workerRepository,
        builder: (context, _) {
          final repo = workerRepository;
          final active = repo.activeTasks;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              KkHeader(notifCount: repo.offers.length),
              const SizedBox(height: 14),
              HeroStatsCard(
                name: repo.profile.firstName,
                kerjaSelesai: repo.kerjaSelesai,
                proyekSosial: repo.socialProjects,
                poin: repo.points,
              ),
              const SizedBox(height: 14),
              WalletCard(
                balance: repo.balance,
                hidden: repo.hideBalance,
                onToggle: repo.toggleBalance,
                onHistory: () => showSaldoHistorySheet(context),
                onWithdraw: () => _withdraw(context),
              ),
              const KkSectionTitle(Icons.grid_view_rounded, 'Layanan Utama'),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ServiceTile(
                        icon: Icons.search_rounded,
                        title: 'Cari Kerja',
                        subtitle: 'Temukan lowongan & proyek lokal',
                        bg: KkColors.blueSoft,
                        fg: KkColors.blue,
                        onTap: () => _open(context, const CariKerjaPage()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ServiceTile(
                        icon: Icons.work_outline_rounded,
                        title: 'Tawarkan Kerja',
                        subtitle: 'Lengkapi profil & tawarkan skill',
                        bg: KkColors.greenSoft,
                        fg: KkColors.green,
                        onTap: () => _open(context, const OfferJobPage()),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ServiceTile(
                        icon: Icons.people_alt_outlined,
                        title: 'Gotong Royong',
                        subtitle: 'Proyek sosial & aksi masyarakat',
                        bg: KkColors.goldSoft,
                        fg: KkColors.goldText,
                        badge: 'Segera',
                        onTap: () => _soon(context, 'Gotong Royong'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ServiceTile(
                        icon: Icons.published_with_changes_rounded,
                        title: 'Tukar Skill',
                        subtitle: 'Barter keahlian tanpa uang',
                        bg: const Color(0xFFEADCF5),
                        fg: const Color(0xFF7B3FA0),
                        badge: 'Segera',
                        onTap: () => _soon(context, 'Tukar Skill'),
                      ),
                    ),
                  ],
                ),
              ),
              if (repo.offers.isNotEmpty) ...[
                KkSectionTitle(
                  Icons.mail_outline,
                  'Tawaran Kerja Masuk (${repo.offers.length})',
                ),
                for (final o in repo.offers)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: OfferCard(
                      offer: o,
                      onReject: () => repo.rejectOffer(o),
                      onAccept: () {
                        repo.acceptOffer(o);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Tawaran disetujui, cek tab Aktivitas'),
                          ),
                        );
                      },
                    ),
                  ),
              ],
              if (active.isNotEmpty) ...[
                const SizedBox(height: 6),
                OngoingCard(
                  count: active.length,
                  firstTitle: active.first.title,
                  onManage: onGoActivity,
                ),
              ],
              KkSectionTitle(
                Icons.auto_awesome,
                'Lowongan Terdekat',
                trailing: TextButton(
                  onPressed: () => _open(context, const CariKerjaPage()),
                  child: const Text('Lihat Semua'),
                ),
              ),
              const NearbyJobsList(),
            ],
          );
        },
      ),
    );
  }
}
