import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart' as private_svc;
import '../../services/psupbase_service.dart' as public_svc;

class ReportScree extends StatefulWidget {
  const ReportScree({super.key});

  @override
  State<ReportScree> createState() => _ReportScreeState();
}

class _ReportScreeState extends State<ReportScree> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _reports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        setState(() {
          _reports = [];
          _error = 'يرجى تسجيل الدخول لعرض بلاغاتك';
          _loading = false;
        });
        return;
      }

      final privateReports =
          await private_svc.SupabaseService().getUserReports();
      final publicReports =
          await public_svc.PSupabaseService().getUserReports();

      final combined = <Map<String, dynamic>>[
        ...privateReports.map((r) => {...r, '_source': 'reportc'}),
        ...publicReports.map((r) => {...r, '_source': 'preportc'}),
      ];

      combined.sort((a, b) {
        final ad =
            DateTime.tryParse(a['created_at']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bd =
            DateTime.tryParse(b['created_at']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bd.compareTo(ad);
      });

      setState(() {
        _reports = combined;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'فشل في جلب البلاغات: $e';
        _loading = false;
      });
    }
  }

  String _formatDate(String? iso) {
    if (iso == null) return '-';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حالة البلاغ'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadReports,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
              : _reports.isEmpty
              ? const Center(child: Text('لا توجد بلاغات حتى الآن'))
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _reports.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final r = _reports[index];
                  final id = (r['id'] ?? '').toString();
                  final type = (r['type'] ?? 'غير محدد').toString();
                  final status = (r['status'] ?? 'قيد المعالجة').toString();
                  final createdAt = _formatDate(r['created_at']?.toString());
                  final assigned = (r['assigned_technician'] ?? '').toString();
                  final src =
                      r['_source'] == 'preportc' ? 'بلاغ عام' : 'بلاغ خاص';

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade50,
                        child: const Icon(
                          Icons.receipt_long,
                          color: Colors.blue,
                        ),
                      ),
                      title: Text('رقم البلاغ: $id'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('نوع البلاغ: $type ($src)'),
                          Text('الحالة: $status'),
                          Text('التاريخ: $createdAt'),
                          if (assigned.isNotEmpty)
                            Text('الفني المعيّن: $assigned'),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
