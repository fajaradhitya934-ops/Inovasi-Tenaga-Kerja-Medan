import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/swap/swap_model.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/swap/swap_repository.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/swap/buat_barter_page.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/common/kk_widgets.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/swap/swap_card.dart';

/// Halaman Tukar Skill: Cari Barter + Barter Saya (realtime dari Firestore).
class TukarSkillPage extends StatefulWidget {
  const TukarSkillPage({super.key});

  @override
  State<TukarSkillPage> createState() => _TukarSkillPageState();
}

class _TukarSkillPageState extends State<TukarSkillPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);
  final TextEditingController _search = TextEditingController();

  String _query = '';
  List<String> _mySkills = [];
  String _myName = 'Pengguna';

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _loadMe();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadMe() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = snap.data() ?? <String, dynamic>{};

    final raw = data['skills'];
    final List<String> skills = raw is List
        ? raw.map((e) => e.toString()).toList()
        : (raw is String
            ? raw
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList()
            : <String>[]);

    final name = (data['name'] as String?)?.trim() ?? '';
    if (!mounted) return;
    setState(() {
      _mySkills = skills;
      _myName = name.isNotEmpty ? name : (user.displayName ?? 'Pengguna');
    });
  }

  /// Penawaran ini butuh keahlian yang kamu punya?
  bool _matches(SwapModel s) {
    final need = s.needSkill.toLowerCase().trim();
    if (need.isEmpty) return false;
    return _mySkills.any((k) {
      final m = k.toLowerCase().trim();
      return m.isNotEmpty && (need.contains(m) || m.contains(need));
    });
  }

  Future<void> _openCreate() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BuatBarterPage(mySkills: _mySkills, myName: _myName),
      ),
    );
    if (created == true && mounted) _tabs.animateTo(1);
  }

  Future<void> _request(SwapModel s) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ajukan pertukaran?'),
        content: Text(
          'Kamu memberi "${s.needSkill}" selama ${s.hours} jam kepada ${s.ownerName}, dan menerima "${s.offerSkill}" selama ${s.hours} jam.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: KkColors.green),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Ajukan'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      final success = await swapRepository.request(
        swapId: s.id,
        uid: _uid,
        name: _myName,
      );
      messenger.showSnackBar(SnackBar(
        content: Text(
          success
              ? 'Pertukaran disepakati! Cek tab Barter Saya'
              : 'Maaf, penawaran ini sudah diambil orang lain',
        ),
      ));
      if (success && mounted) _tabs.animateTo(1);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }

  Future<void> _done(SwapModel s) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final both = await swapRepository.markDone(swapId: s.id, uid: _uid);
      messenger.showSnackBar(SnackBar(
        content: Text(
          both
              ? 'Pertukaran selesai! +${SwapRepository.pointsPerSwap} Poin CP'
              : 'Konfirmasi terkirim, menunggu mitra',
        ),
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }

  Future<void> _cancel(SwapModel s) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan penawaran?'),
        content: const Text('Penawaran ini akan dihapus dari daftar.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Tidak'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: KkColors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await swapRepository.cancel(s.id);
      messenger.showSnackBar(
        const SnackBar(content: Text('Penawaran dibatalkan')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KkColors.bg,
      appBar: AppBar(
        backgroundColor: KkColors.bg,
        elevation: 0,
        leading: const BackButton(color: KkColors.text),
        title: const Text(
          'Tukar Skill',
          style: TextStyle(
            color: KkColors.text,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: TabBar(
          controller: _tabs,
          labelColor: KkColors.green,
          unselectedLabelColor: KkColors.muted,
          indicatorColor: KkColors.green,
          indicatorWeight: 3,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'Cari Barter'),
            Tab(text: 'Barter Saya'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: KkColors.gold,
        foregroundColor: KkColors.greenDark,
        onPressed: _openCreate,
        icon: const Icon(Icons.add),
        label: const Text('Buat Penawaran'),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [_buildOpenTab(), _buildMineTab()],
      ),
    );
  }

  // ---------------- Tab 1: Cari Barter ----------------
  Widget _buildOpenTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            children: [
              const KkCard(
                color: KkColors.purpleSoft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.published_with_changes_rounded,
                        color: KkColors.purple),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Barter keahlian tanpa uang',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Contoh: 2 jam desain poster, ditukar 2 jam servis laptop. Selesai dikonfirmasi dua pihak, kalian sama-sama dapat +15 Poin CP.',
                            style: TextStyle(
                              fontSize: 12,
                              color: KkColors.muted,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: KkColors.border),
                ),
                child: TextField(
                  controller: _search,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: const InputDecoration(
                    hintText: 'Cari keahlian (misal: desain, servis AC)',
                    hintStyle: TextStyle(fontSize: 13, color: KkColors.muted),
                    icon: Icon(Icons.search, color: KkColors.muted),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<SwapModel>>(
            stream: swapRepository.watchOpen(),
            builder: (context, snap) {
              if (snap.hasError) {
                return _message(
                  Icons.error_outline,
                  'Gagal memuat data:\n${snap.error}',
                );
              }
              if (!snap.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: KkColors.green),
                );
              }

              final q = _query.trim().toLowerCase();
              final items = snap.data!.where((s) {
                if (s.ownerUid == _uid) return false;
                if (q.isEmpty) return true;
                return s.offerSkill.toLowerCase().contains(q) ||
                    s.needSkill.toLowerCase().contains(q) ||
                    s.ownerName.toLowerCase().contains(q) ||
                    s.location.toLowerCase().contains(q);
              }).toList();

              // Yang cocok dengan keahlianmu di atas, lalu yang terbaru.
              items.sort((a, b) {
                final m = (_matches(b) ? 1 : 0) - (_matches(a) ? 1 : 0);
                if (m != 0) return m;
                final now = DateTime.now();
                return (b.createdAt ?? now).compareTo(a.createdAt ?? now);
              });

              if (items.isEmpty) {
                return _message(
                  Icons.swap_horiz_rounded,
                  'Belum ada penawaran barter.\nJadi yang pertama, tekan "Buat Penawaran".',
                );
              }

              final matchCount = items.where(_matches).length;
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                itemCount: items.length + 1,
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        '${items.length} penawaran • $matchCount cocok dengan keahlianmu',
                        style: const TextStyle(
                          fontSize: 12,
                          color: KkColors.muted,
                        ),
                      ),
                    );
                  }
                  final s = items[i - 1];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SwapCard(
                      swap: s,
                      myUid: _uid,
                      matchesMe: _matches(s),
                      onRequest: () => _request(s),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ---------------- Tab 2: Barter Saya ----------------
  Widget _buildMineTab() {
    return StreamBuilder<List<SwapModel>>(
      stream: swapRepository.watchMine(_uid),
      builder: (context, snap) {
        if (snap.hasError) {
          return _message(
            Icons.error_outline,
            'Gagal memuat data:\n${snap.error}',
          );
        }
        if (!snap.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: KkColors.green),
          );
        }

        final items = List<SwapModel>.of(snap.data!);
        if (items.isEmpty) {
          return _message(
            Icons.handshake_outlined,
            'Kamu belum punya barter.\nBuat penawaran atau ajukan tukar di tab Cari Barter.',
          );
        }

        // Berjalan dulu, lalu terbuka, lalu selesai.
        int rank(SwapStatus s) =>
            s == SwapStatus.matched ? 0 : (s == SwapStatus.open ? 1 : 2);
        items.sort((a, b) {
          final r = rank(a.status).compareTo(rank(b.status));
          if (r != 0) return r;
          final now = DateTime.now();
          return (b.createdAt ?? now).compareTo(a.createdAt ?? now);
        });

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final s = items[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SwapCard(
                swap: s,
                myUid: _uid,
                onDone: () => _done(s),
                onCancel: () => _cancel(s),
              ),
            );
          },
        );
      },
    );
  }

  Widget _message(IconData icon, String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: KkColors.muted),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: KkColors.muted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
