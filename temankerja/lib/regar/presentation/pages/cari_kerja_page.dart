import 'package:flutter/material.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';
import 'package:inovasi_sumut/regar/data/models/job_model.dart';
import 'package:inovasi_sumut/regar/data/repositories/job_repository.dart';
import 'package:inovasi_sumut/regar/data/repositories/worker_repository.dart';
import 'package:inovasi_sumut/regar/presentation/pages/detail_kerja_page.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/jobs/category_chips.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/jobs/job_card.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/jobs/job_search_bar.dart';

/// Daftar semua lowongan + pencarian + filter.
class CariKerjaPage extends StatefulWidget {
  const CariKerjaPage({super.key});

  @override
  State<CariKerjaPage> createState() => _CariKerjaPageState();
}

class _CariKerjaPageState extends State<CariKerjaPage> {
  static const String _semua = 'Semua';

  final TextEditingController _search = TextEditingController();

  List<JobModel> _jobs = [];
  String _category = _semua;
  JobType? _type;
  String _query = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final jobs = await jobRepository.getJobs();
      if (!mounted) return;
      setState(() {
        _jobs = jobs;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat lowongan. Coba lagi.';
        _loading = false;
      });
    }
  }

  List<String> get _categories => [
        _semua,
        ...{for (final j in _jobs) j.category},
      ];

  List<JobModel> get _filtered {
    final q = _query.trim().toLowerCase();
    return _jobs.where((j) {
      final okCategory = _category == _semua || j.category == _category;
      final okType = _type == null || j.type == _type;
      final okQuery = q.isEmpty ||
          j.title.toLowerCase().contains(q) ||
          j.company.toLowerCase().contains(q) ||
          j.location.toLowerCase().contains(q) ||
          j.category.toLowerCase().contains(q);
      return okCategory && okType && okQuery;
    }).toList();
  }

  void _openTypeFilter() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: KkColors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jenis Pekerjaan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: KkColors.text,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Semua'),
                    selected: _type == null,
                    selectedColor: KkColors.goldBg,
                    onSelected: (_) {
                      setState(() => _type = null);
                      Navigator.pop(ctx);
                    },
                  ),
                  for (final t in JobType.values)
                    ChoiceChip(
                      label: Text(t.label),
                      selected: _type == t,
                      selectedColor: KkColors.goldBg,
                      onSelected: (_) {
                        setState(() => _type = t);
                        Navigator.pop(ctx);
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
          'Cari Kerja',
          style: TextStyle(
            color: KkColors.text,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            JobSearchBar(
              controller: _search,
              onChanged: (v) => setState(() => _query = v),
              onFilterTap: _openTypeFilter,
              filterActive: _type != null,
            ),
            const SizedBox(height: 12),
            if (!_loading && _error == null) ...[
              CategoryChips(
                categories: _categories,
                selected: _category,
                onSelected: (c) => setState(() => _category = c),
              ),
              const SizedBox(height: 12),
              Text(
                'Ditemukan ${_filtered.length} lowongan',
                style: const TextStyle(fontSize: 12, color: KkColors.muted),
              ),
              const SizedBox(height: 8),
            ],
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: KkColors.green),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: KkColors.muted),
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: KkColors.muted)),
            const SizedBox(height: 12),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: KkColors.green),
              onPressed: _load,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }
    final items = _filtered;
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada lowongan yang cocok.\nCoba kata kunci atau filter lain.',
          textAlign: TextAlign.center,
          style: TextStyle(color: KkColors.muted),
        ),
      );
    }
    return RefreshIndicator(
      color: KkColors.green,
      onRefresh: _load,
      child: ListenableBuilder(
        listenable: workerRepository,
        builder: (context, _) => ListView.builder(
          itemCount: items.length,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, i) {
            final job = items[i];
            return JobCard(
              job: job,
              applied: workerRepository.isApplied(job.id),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailKerjaPage(job: job)),
              ),
            );
          },
        ),
      ),
    );
  }
}
