import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/swap/swap_repository.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/common/kk_widgets.dart';

class BuatBarterPage extends StatefulWidget {
  final List<String> mySkills;
  final String myName;

  const BuatBarterPage({
    super.key,
    required this.mySkills,
    required this.myName,
  });

  @override
  State<BuatBarterPage> createState() => _BuatBarterPageState();
}

class _BuatBarterPageState extends State<BuatBarterPage> {
  static const List<String> _populer = [
    'Desain grafis',
    'Servis laptop',
    'Servis AC',
    'Instalasi listrik',
    'Pasang CCTV',
    'Les privat',
    'Fotografi',
    'Tukang cat',
    'Admin media sosial',
    'Memasak',
  ];

  final TextEditingController _offer = TextEditingController();
  final TextEditingController _need = TextEditingController();
  final TextEditingController _note = TextEditingController();
  int _hours = 2;
  bool _saving = false;

  @override
  void dispose() {
    _offer.dispose();
    _need.dispose();
    _note.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, String hint) => InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: KkColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: KkColors.border),
        ),
      );

  Widget _chips(List<String> items, TextEditingController c) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final s in items)
          ActionChip(
            label: Text(s),
            backgroundColor: Colors.white,
            side: const BorderSide(color: KkColors.border),
            labelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: KkColors.text,
            ),
            onPressed: () => setState(() => c.text = s),
          ),
      ],
    );
  }

  Future<void> _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    final offer = _offer.text.trim();
    final need = _need.text.trim();

    if (offer.isEmpty || need.isEmpty) {
      messenger.showSnackBar(const SnackBar(
        content: Text('Isi keahlian yang ditawarkan dan yang dibutuhkan'),
      ));
      return;
    }
    if (offer.toLowerCase() == need.toLowerCase()) {
      messenger.showSnackBar(const SnackBar(
        content: Text('Keahlian yang ditawarkan dan dibutuhkan harus berbeda'),
      ));
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _saving = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final location = (snap.data()?['location'] as String?) ?? '';

      await swapRepository.create(
        uid: user.uid,
        name: widget.myName,
        location: location,
        offerSkill: offer,
        needSkill: need,
        hours: _hours,
        note: _note.text.trim(),
      );
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(
        content: Text('Penawaran barter dipublikasikan'),
      ));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
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
          'Buat Penawaran Barter',
          style: TextStyle(
            color: KkColors.text,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          const KkSectionTitle(
            Icons.volunteer_activism_outlined,
            'Keahlian yang Kamu Tawarkan',
          ),
          TextField(
            controller: _offer,
            textCapitalization: TextCapitalization.sentences,
            decoration: _dec('Yang kamu tawarkan', 'Contoh: Desain poster'),
          ),
          if (widget.mySkills.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Keahlian di profilmu:',
              style: TextStyle(fontSize: 11, color: KkColors.muted),
            ),
            const SizedBox(height: 6),
            _chips(widget.mySkills, _offer),
          ],
          const KkSectionTitle(
            Icons.handyman_outlined,
            'Keahlian yang Kamu Butuhkan',
          ),
          TextField(
            controller: _need,
            textCapitalization: TextCapitalization.sentences,
            decoration: _dec('Yang kamu butuhkan', 'Contoh: Servis laptop'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pilihan populer:',
            style: TextStyle(fontSize: 11, color: KkColors.muted),
          ),
          const SizedBox(height: 6),
          _chips(_populer, _need),
          const KkSectionTitle(Icons.schedule, 'Durasi Pertukaran'),
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: _hours > 1 ? () => setState(() => _hours--) : null,
                icon: const Icon(Icons.remove),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$_hours jam',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: KkColors.text,
                  ),
                ),
              ),
              IconButton.filledTonal(
                onPressed: _hours < 12 ? () => setState(() => _hours++) : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _note,
            maxLines: 3,
            decoration: _dec(
              'Catatan (opsional)',
              'Contoh: Bisa hari Sabtu, area Medan Baru',
            ),
          ),
          const SizedBox(height: 16),
          const KkCard(
            color: KkColors.purpleSoft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: KkColors.purple, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pertukaran adil: durasi sama untuk kedua pihak. Setelah kedua pihak menandai selesai, masing-masing mendapat +15 Poin CP.',
                    style: TextStyle(fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: KkColors.border)),
          ),
          child: SizedBox(
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: KkColors.gold,
                foregroundColor: KkColors.greenDark,
              ),
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: KkColors.greenDark,
                      ),
                    )
                  : const Text(
                      'Publikasikan Penawaran',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
