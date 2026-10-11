import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';
import 'package:inovasi_sumut/regar/data/models/job_model.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/common/kk_widgets.dart';

class JobCard extends StatefulWidget {
  final JobModel job;
  final bool applied;
  final VoidCallback onTap;
  final bool isWorkerOffer;
  final String? actionButtonText;

  const JobCard({
    super.key,
    required this.job,
    required this.applied,
    required this.onTap,
    this.isWorkerOffer = false,
    this.actionButtonText,
  });

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  bool _isApplying = false;
  late bool _hasApplied;

  @override
  void initState() {
    super.initState();
    _hasApplied = widget.applied;
  }

  @override
  void didUpdateWidget(covariant JobCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.applied != widget.applied) {
      _hasApplied = widget.applied;
    }
  }

  /// Mengecek apakah postingan ini berjenis tawaran jasa (Pekerja Mandiri)
  bool get _checkIsWorkerOffer {
    final type = widget.job.postType.toLowerCase();
    return widget.isWorkerOffer ||
        type == 'worker' ||
        type == 'worker_profile' ||
        type == 'offer_service';
  }

  Future<void> _handleApplyOrInviteJob() async {
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

      // Update state lokal secara instan agar tombol langsung berubah
      setState(() {
        _hasApplied = true;
      });

      final String message = _checkIsWorkerOffer
          ? 'Berhasil mengajak pekerja!'
          : 'Berhasil melamar pekerjaan!';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: KkColors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memproses permintaan: $e'),
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

    // Pengecekan kepemilikan postingan
    final isOwnJob = currentUser != null &&
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

    // Penentuan teks label tombol otomatis berdasarkan state _hasApplied
    String defaultButtonLabel;
    if (isOwnJob) {
      defaultButtonLabel = 'Postingan Anda';
    } else if (_checkIsWorkerOffer) {
      defaultButtonLabel = _hasApplied ? 'Sudah Diajak' : 'Ajak Bekerja';
    } else {
      defaultButtonLabel = _hasApplied ? 'Sudah Dilamar' : 'Lamar Pekerjaan';
    }

    final String buttonLabel = widget.actionButtonText ?? defaultButtonLabel;

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
            Text(
              widget.job.company,
              style: const TextStyle(fontSize: 12, color: KkColors.muted),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _InfoItem(
                  icon: Icons.location_on_outlined,
                  text: widget.job.location,
                  color: KkColors.muted,
                ),
                _InfoItem(
                  icon: Icons.payments_outlined,
                  text: formattedSalary,
                  color: KkColors.green,
                  bold: true,
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
                    onPressed: (isOwnJob || _hasApplied || _isApplying)
                        ? null
                        : _handleApplyOrInviteJob,
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

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final bool bold;

  const _InfoItem({
    required this.icon,
    required this.text,
    required this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: bold ? FontWeight.w800 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}