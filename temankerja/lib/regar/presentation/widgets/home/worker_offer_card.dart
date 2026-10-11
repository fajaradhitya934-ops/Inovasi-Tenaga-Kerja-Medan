import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';
import 'package:inovasi_sumut/regar/data/models/job_model.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/common/kk_widgets.dart';

class WorkerOfferCard extends StatefulWidget {
  final JobModel job;
  final bool applied;
  final VoidCallback onTap;

  const WorkerOfferCard({
    super.key,
    required this.job,
    required this.applied,
    required this.onTap,
  });

  @override
  State<WorkerOfferCard> createState() => _WorkerOfferCardState();
}

class _WorkerOfferCardState extends State<WorkerOfferCard> {
  bool _isApplying = false;

  Future<void> _handleInviteWorker(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() => _isApplying = true);

    try {
      await FirebaseFirestore.instance
          .collection('job_offers')
          .doc(widget.job.id)
          .update({
        'applicantUid': currentUser.uid,
        'status': 'applied',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil mengajak pekerja!'),
          backgroundColor: KkColors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memproses ajakan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isApplying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    final isOwnOffer = currentUser != null &&
        (widget.job.id == currentUser.uid ||
            widget.job.company.toLowerCase() ==
                currentUser.email?.toLowerCase());

    final String formattedSalary = widget.job.salary > 0
        ? 'Rp ${widget.job.salary.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}'
        : 'Negosiasi';

    String paymentLabel = 'Hanya Tunai';
    Color paymentBg = Colors.grey.shade100;
    Color paymentFg = Colors.grey.shade700;

    if (widget.job.acceptedPaymentType.toLowerCase() == 'qris') {
      paymentLabel = 'Escrow QRIS / Transfer';
      paymentBg = Colors.blue.shade50;
      paymentFg = Colors.blue.shade700;
    }

    String buttonLabel;
    if (isOwnOffer) {
      buttonLabel = 'Jasa Anda';
    } else if (widget.applied) {
      buttonLabel = 'Sudah Diajak';
    } else {
      buttonLabel = 'Ajak Bekerja';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: KkCard(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.job.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: KkColors.text,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                KkPill(
                  widget.job.type.label,
                  bg: KkColors.blueSoft,
                  fg: KkColors.blue,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: KkColors.muted),
                const SizedBox(width: 4),
                Text(
                  widget.job.company,
                  style: const TextStyle(fontSize: 12, color: KkColors.muted),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: KkColors.muted),
                    const SizedBox(width: 4),
                    Text(
                      widget.job.location,
                      style: const TextStyle(
                        fontSize: 11,
                        color: KkColors.muted,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.payments_outlined,
                        size: 14, color: KkColors.green),
                    const SizedBox(width: 4),
                    Text(
                      formattedSalary,
                      style: const TextStyle(
                        fontSize: 11,
                        color: KkColors.green,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: paymentBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    paymentLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: paymentFg,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: KkColors.text,
                      side: const BorderSide(color: KkColors.border),
                    ),
                    child: const Text('Lihat Detail'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: (isOwnOffer || widget.applied || _isApplying)
                        ? null
                        : () => _handleInviteWorker(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: KkColors.gold,
                      foregroundColor: KkColors.greenDark,
                      disabledBackgroundColor: Colors.grey.shade300,
                      disabledForegroundColor: Colors.grey.shade600,
                    ),
                    child: _isApplying
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: KkColors.greenDark,
                            ),
                          )
                        : Text(
                            buttonLabel,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}