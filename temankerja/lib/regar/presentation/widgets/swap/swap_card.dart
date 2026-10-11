import 'package:flutter/material.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';
import 'package:inovasi_sumut/regar/data/models/swap_model.dart';
import 'package:inovasi_sumut/regar/data/repositories/swap_repository.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/common/kk_widgets.dart';

class SwapCard extends StatelessWidget {
  final SwapModel swap;
  final String myUid;
  final bool matchesMe;
  final VoidCallback? onRequest;
  final VoidCallback? onDone;
  final VoidCallback? onCancel;

  const SwapCard({
    super.key,
    required this.swap,
    required this.myUid,
    this.matchesMe = false,
    this.onRequest,
    this.onDone,
    this.onCancel,
  });

  bool get _isOwner => swap.ownerUid == myUid;

  @override
  Widget build(BuildContext context) {
    final initial =
        swap.ownerName.isNotEmpty ? swap.ownerName[0].toUpperCase() : '?';
    final partnerLabel = _isOwner
        ? (swap.partnerName.isEmpty ? '' : 'Mitra: ${swap.partnerName}')
        : 'Pemilik: ${swap.ownerName}';

    return KkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: KkColors.purpleSoft,
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: KkColors.purple,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isOwner ? 'Penawaran Saya' : swap.ownerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    if (swap.location.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.place_outlined,
                              size: 12, color: KkColors.muted),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              swap.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: KkColors.muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _statusPill(),
            ],
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _SkillBox(
                    label: 'MENAWARKAN',
                    value: swap.offerSkill,
                    bg: KkColors.greenSoft,
                    fg: KkColors.green,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: KkColors.purpleSoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.swap_horiz_rounded,
                        size: 20,
                        color: KkColors.purple,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _SkillBox(
                    label: 'MEMBUTUHKAN',
                    value: swap.needSkill,
                    bg: KkColors.goldBg,
                    fg: KkColors.goldText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              KkPill(
                '${swap.hours} jam',
                bg: KkColors.purpleSoft,
                fg: KkColors.purple,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Pertukaran 1:1, durasi sama untuk kedua pihak',
                  style: TextStyle(fontSize: 11, color: KkColors.muted),
                ),
              ),
            ],
          ),
          if (swap.note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '"${swap.note}"',
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: KkColors.text,
              ),
            ),
          ],
          if (partnerLabel.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.handshake_outlined,
                    size: 14, color: KkColors.green),
                const SizedBox(width: 4),
                Text(
                  partnerLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: KkColors.green,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          _actions(),
        ],
      ),
    );
  }

  Widget _statusPill() {
    if (swap.status == SwapStatus.open && matchesMe && !_isOwner) {
      return const KkPill(
        'Cocok denganmu',
        bg: KkColors.greenSoft,
        fg: KkColors.green,
      );
    }
    switch (swap.status) {
      case SwapStatus.open:
        return const KkPill('Terbuka',
            bg: KkColors.goldSoft, fg: KkColors.goldText);
      case SwapStatus.matched:
        return const KkPill('Berjalan',
            bg: KkColors.blueSoft, fg: KkColors.blue);
      case SwapStatus.done:
        return const KkPill('Selesai',
            bg: KkColors.greenSoft, fg: KkColors.green);
    }
  }

  Widget _actions() {
    switch (swap.status) {
      case SwapStatus.open:
        if (_isOwner) {
          return SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: KkColors.red,
                side: const BorderSide(color: KkColors.red),
              ),
              onPressed: onCancel,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Batalkan Penawaran'),
            ),
          );
        }
        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: KkColors.gold,
              foregroundColor: KkColors.greenDark,
            ),
            onPressed: onRequest,
            icon: const Icon(Icons.swap_horiz_rounded, size: 18),
            label: const Text('Ajukan Tukar'),
          ),
        );
      case SwapStatus.matched:
        final alreadyDone = swap.doneBy.contains(myUid);
        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: KkColors.green,
              disabledBackgroundColor: KkColors.inner,
            ),
            onPressed: alreadyDone ? null : onDone,
            icon: const Icon(Icons.check, size: 18),
            label: Text(
              alreadyDone ? 'Menunggu konfirmasi mitra' : 'Tandai Selesai',
            ),
          ),
        );
      case SwapStatus.done:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: KkColors.greenSoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Selesai • +${SwapRepository.pointsPerSwap} Poin CP didapat',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: KkColors.green,
              fontSize: 12,
            ),
          ),
        );
    }
  }
}

class _SkillBox extends StatelessWidget {
  final String label;
  final String value;
  final Color bg;
  final Color fg;

  const _SkillBox({
    required this.label,
    required this.value,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: KkColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
