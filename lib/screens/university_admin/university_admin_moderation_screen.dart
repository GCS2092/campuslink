import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/university_admin_service.dart';
import '../../utils/app_colors.dart';

/// Écran de modération pour les administrateurs d'université
class UniversityAdminModerationScreen extends StatefulWidget {
  const UniversityAdminModerationScreen({super.key});

  @override
  State<UniversityAdminModerationScreen> createState() => _UniversityAdminModerationScreenState();
}

class _UniversityAdminModerationScreenState extends State<UniversityAdminModerationScreen> with SingleTickerProviderStateMixin {
  final UniversityAdminService _universityAdminService = UniversityAdminService();
  late TabController _tabController;

  List<Map<String, dynamic>> _reports = [];
  List<Map<String, dynamic>> _auditLogs = [];
  bool _isLoadingReports = true;
  bool _isLoadingAuditLogs = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReports();
    _loadAuditLogs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoadingReports = true);
    try {
      final reports = await _universityAdminService.getModerationReports();
      setState(() {
        _reports = reports;
        _isLoadingReports = false;
      });
    } catch (e) {
      debugPrint('Error loading reports: $e');
      setState(() {
        _reports = [];
        _isLoadingReports = false;
      });
    }
  }

  Future<void> _loadAuditLogs() async {
    setState(() => _isLoadingAuditLogs = true);
    try {
      final logs = await _universityAdminService.getAuditLogs();
      setState(() {
        _auditLogs = logs;
        _isLoadingAuditLogs = false;
      });
    } catch (e) {
      debugPrint('Error loading audit logs: $e');
      setState(() {
        _auditLogs = [];
        _isLoadingAuditLogs = false;
      });
    }
  }

  Future<void> _handleResolveReport(String reportId) async {
    try {
      final result = await _universityAdminService.resolveReport(reportId);
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rapport résolu'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadReports();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Erreur'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error resolving report: $e');
    }
  }

  Future<void> _handleRejectReport(String reportId) async {
    try {
      final result = await _universityAdminService.rejectReport(reportId);
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rapport rejeté'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadReports();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Erreur'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error rejecting report: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modération'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Rapports', icon: Icon(Icons.report)),
            Tab(text: 'Logs d\'Audit', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReportsTab(),
          _buildAuditLogsTab(),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    return _isLoadingReports
        ? const Center(child: CircularProgressIndicator())
        : _reports.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.report_outlined, size: 64, color: AppColors.textSecondary),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun rapport',
                      style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadReports,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reports.length,
                  itemBuilder: (context, index) {
                    final report = _reports[index];
                    return _ReportCard(
                      report: report,
                      onResolve: () => _handleResolveReport(report['id'].toString()),
                      onReject: () => _handleRejectReport(report['id'].toString()),
                    );
                  },
                ),
              );
  }

  Widget _buildAuditLogsTab() {
    return _isLoadingAuditLogs
        ? const Center(child: CircularProgressIndicator())
        : _auditLogs.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_outlined, size: 64, color: AppColors.textSecondary),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun log d\'audit',
                      style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadAuditLogs,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _auditLogs.length,
                  itemBuilder: (context, index) {
                    final log = _auditLogs[index];
                    return _AuditLogCard(log: log);
                  },
                ),
              );
  }
}

class _ReportCard extends StatelessWidget {
  final Map<String, dynamic> report;
  final VoidCallback onResolve;
  final VoidCallback onReject;

  const _ReportCard({
    required this.report,
    required this.onResolve,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final reason = report['reason'] ?? 'Sans raison';
    final status = report['status'] ?? 'pending';
    final createdAt = report['created_at'] != null
        ? DateTime.parse(report['created_at'])
        : DateTime.now();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    reason,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: status == 'resolved'
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status == 'resolved' ? 'Résolu' : 'En attente',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: status == 'resolved' ? AppColors.success : AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('dd MMM yyyy à HH:mm').format(createdAt),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            if (status == 'pending') ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Rejeter'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: onResolve,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Résoudre'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AuditLogCard extends StatelessWidget {
  final Map<String, dynamic> log;

  const _AuditLogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final action = log['action_type'] ?? 'action';
    final user = log['user'] ?? {};
    final username = user['username'] ?? 'Système';
    final createdAt = log['created_at'] != null
        ? DateTime.parse(log['created_at'])
        : DateTime.now();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    action,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd MMM yyyy à HH:mm').format(createdAt),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


