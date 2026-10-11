import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';
import 'package:inovasi_sumut/regar/data/models/job_model.dart';
import 'package:inovasi_sumut/regar/data/repositories/worker_repository.dart';
import 'package:inovasi_sumut/regar/presentation/pages/detail_kerja_page.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/jobs/category_chips.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/jobs/job_card.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/jobs/job_search_bar.dart';

class CariKerjaPage extends StatefulWidget {
  const CariKerjaPage({super.key});

  @override
  State<CariKerjaPage> createState() => _CariKerjaPageState();
}

class _CariKerjaPageState extends State<CariKerjaPage> {
  static const String _semua = 'Semua';

  final TextEditingController _search = TextEditingController();

  String _category = _semua;
  JobType? _type;
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: KkColors.bg,
        appBar: AppBar(
          backgroundColor: KkColors.bg,
          elevation: 0,
          leading: const BackButton(color: KkColors.text),
          title: const Text(
            'Cari Kerja & Layanan',
            style: TextStyle(
              color: KkColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          bottom: const TabBar(
            labelColor: KkColors.green,
            unselectedLabelColor: KkColors.muted,
            indicatorColor: KkColors.green,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: [
              Tab(text: 'Lowongan Kerja'),
              Tab(text: 'Tawaran Jasa'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: JobSearchBar(
                controller: _search,
                onChanged: (v) => setState(() => _query = v),
                onFilterTap: _openTypeFilter,
                filterActive: _type != null,
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Lowongan Kerja: Mencari Pekerjaan yang Dibuka Klien ('job')
                  _buildJobList(targetPostType: 'job'),
                  // Tawaran Jasa: Mencari Pekerja Mandiri untuk Diajak Bekerja ('worker')
                  _buildJobList(targetPostType: 'worker'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobList({required String targetPostType}) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('job_offers')
          .where('status', isEqualTo: 'open')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Gagal memuat data: ${snapshot.error}',
              style: const TextStyle(color: KkColors.muted),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: KkColors.green),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        final filteredDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final postType = (data['postType'] ?? '').toString().toLowerCase();
          final postMode = (data['postMode'] ?? '').toString().toLowerCase();

          if (targetPostType == 'job') {
            return postType == 'job' ||
                postType == 'job_vacancy' ||
                postMode == 'hire_worker';
          } else {
            return postType == 'worker' ||
                postType == 'worker_profile' ||
                postMode == 'offer_service';
          }
        }).toList();

        final allJobsWithDoc = filteredDocs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;

          final companyName =
              data['company'] ?? data['workerEmail'] ?? 'Pekerja Profesional';
          final postedByUid = data['postedByUid'] ?? '';

          final userEmail = currentUser?.email;

          final bool isOwnJobByUid = currentUser != null &&
              postedByUid.isNotEmpty &&
              postedByUid == currentUser.uid;
          final bool isOwnJobByEmail = userEmail != null &&
              companyName.toString().toLowerCase() == userEmail.toLowerCase();

          final bool isOwnJob = isOwnJobByUid || isOwnJobByEmail;

          final initialJob = JobModel.fromMap(doc.id, data);

          final job = JobModel(
            id: initialJob.id,
            title: initialJob.title,
            company: (isOwnJob && userEmail != null)
                ? userEmail
                : initialJob.company,
            location: initialJob.location,
            category: initialJob.category,
            salary: initialJob.salary,
            description: initialJob.description,
            type: initialJob.type,
            isSkillExchangeable: initialJob.isSkillExchangeable,
            requirements: initialJob.requirements,
            postedAgo: initialJob.postedAgo,
            phoneNumber: initialJob.phoneNumber,
            acceptedPaymentType: initialJob.acceptedPaymentType,
            postType: data['postType'] ?? targetPostType,
          );

          final String applicantUid = data['applicantUid'] ?? '';
          final bool isAppliedInFirestore =
              (currentUser != null && applicantUid == currentUser.uid);

          return {
            'job': job,
            'isAppliedInFirestore': isAppliedInFirestore,
            'isOwnJob': isOwnJob,
          };
        }).toList();

        final categories = [
          _semua,
          ...{
            for (final item in allJobsWithDoc)
              (item['job'] as JobModel).category
          },
        ];

        final q = _query.trim().toLowerCase();
        final filteredItems = allJobsWithDoc.where((item) {
          final job = item['job'] as JobModel;
          final okCategory =
              _category == _semua || job.category == _category;
          final okType = _type == null || job.type == _type;
          final okQuery = q.isEmpty ||
              job.title.toLowerCase().contains(q) ||
              job.company.toLowerCase().contains(q) ||
              job.location.toLowerCase().contains(q) ||
              job.category.toLowerCase().contains(q);
          return okCategory && okType && okQuery;
        }).toList();

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              CategoryChips(
                categories: categories,
                selected: _category,
                onSelected: (c) => setState(() => _category = c),
              ),
              const SizedBox(height: 12),
              Text(
                'Ditemukan ${filteredItems.length} ${targetPostType == 'job' ? 'lowongan' : 'tawaran jasa'}',
                style: const TextStyle(fontSize: 12, color: KkColors.muted),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filteredItems.isEmpty
                    ? Center(
                        child: Text(
                          targetPostType == 'job'
                              ? 'Tidak ada lowongan kerja yang cocok.\nCoba kata kunci atau filter lain.'
                              : 'Tidak ada tawaran jasa yang cocok.\nCoba kata kunci atau filter lain.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: KkColors.muted),
                        ),
                      )
                    : ListenableBuilder(
                        listenable: workerRepository,
                        builder: (context, _) => ListView.builder(
                          itemCount: filteredItems.length,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, i) {
                            final job = filteredItems[i]['job'] as JobModel;
                            final bool isAppliedInFirestore = filteredItems[i]
                                ['isAppliedInFirestore'] as bool;

                            final bool isApplied = isAppliedInFirestore ||
                                workerRepository.isApplied(job.id);

                            return JobCard(
                              job: job,
                              applied: isApplied,
                              isWorkerOffer: targetPostType == 'worker',
                              onTap: () {
                                showDetailKerjaBottomSheet(context, job);
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}