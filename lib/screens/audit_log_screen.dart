import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audit_provider.dart';
import '../providers/auth_provider.dart';
import '../models/audit_log.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  String? _selectedAction;
  String? _selectedEntityType;
  String? _selectedUserId;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuditProvider>().loadAuditLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuditProvider, AuthProvider>(
      builder: (context, auditProvider, authProvider, child) {
        if (!authProvider.hasPermission(Permission.viewAuditLog)) {
          return const Scaffold(
            body: Center(
              child: Text(
                'ليس لديك صلاحية لعرض سجل الأنشطة',
                style: TextStyle(fontSize: 18),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('سجل الأنشطة'),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterDialog,
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => auditProvider.loadAuditLogs(),
              ),
            ],
          ),
          body: auditProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildAuditLogsList(auditProvider),
        );
      },
    );
  }

  Widget _buildAuditLogsList(AuditProvider auditProvider) {
    final filteredLogs = auditProvider.filterLogs(
      action: _selectedAction,
      entityType: _selectedEntityType,
      userId: _selectedUserId,
      startDate: _startDate,
      endDate: _endDate,
    );

    if (filteredLogs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'لا توجد أنشطة مسجلة',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredLogs.length,
      itemBuilder: (context, index) {
        final log = filteredLogs[index];
        return AuditLogTile(log: log);
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصفية سجل الأنشطة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedAction,
                decoration: const InputDecoration(labelText: 'الإجراء'),
                items: AuditAction.values.map((action) {
                  return DropdownMenuItem(
                    value: action.value,
                    child: Text(action.displayName),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedAction = value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedEntityType,
                decoration: const InputDecoration(labelText: 'نوع الكيان'),
                items: EntityType.values.map((type) {
                  return DropdownMenuItem(
                    value: type.value,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedEntityType = value),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _startDate = date);
                        }
                      },
                      child: Text(_startDate != null
                          ? 'من: ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                          : 'تاريخ البداية'),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _endDate = date);
                        }
                      },
                      child: Text(_endDate != null
                          ? 'إلى: ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                          : 'تاريخ النهاية'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedAction = null;
                _selectedEntityType = null;
                _selectedUserId = null;
                _startDate = null;
                _endDate = null;
              });
              Navigator.pop(context);
            },
            child: const Text('إعادة تعيين'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('تطبيق'),
          ),
        ],
      ),
    );
  }
}

class AuditLogTile extends StatelessWidget {
  final AuditLog log;

  const AuditLogTile({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getActionColor(log.action),
          child: Icon(
            _getActionIcon(log.action),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          '${_getActionDisplayName(log.action)} ${_getEntityDisplayName(log.entityType)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المستخدم: ${log.userName}'),
            Text('التوقيت: ${_formatTimestamp(log.timestamp)}'),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (log.entityId != null)
                  Text('معرف الكيان: ${log.entityId}'),
                if (log.oldValues != null) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'القيم القديمة:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(log.oldValues!),
                ],
                if (log.newValues != null) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'القيم الجديدة:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(log.newValues!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'create':
        return Colors.green;
      case 'update':
        return Colors.blue;
      case 'delete':
        return Colors.red;
      case 'view':
        return Colors.grey;
      case 'login':
        return Colors.purple;
      case 'logout':
        return Colors.orange;
      case 'export':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'create':
        return Icons.add;
      case 'update':
        return Icons.edit;
      case 'delete':
        return Icons.delete;
      case 'view':
        return Icons.visibility;
      case 'login':
        return Icons.login;
      case 'logout':
        return Icons.logout;
      case 'export':
        return Icons.download;
      default:
        return Icons.info;
    }
  }

  String _getActionDisplayName(String action) {
    switch (action) {
      case 'create':
        return 'إنشاء';
      case 'update':
        return 'تعديل';
      case 'delete':
        return 'حذف';
      case 'view':
        return 'عرض';
      case 'login':
        return 'تسجيل دخول';
      case 'logout':
        return 'تسجيل خروج';
      case 'export':
        return 'تصدير';
      default:
        return action;
    }
  }

  String _getEntityDisplayName(String entityType) {
    switch (entityType) {
      case 'booking':
        return 'حجز';
      case 'customer':
        return 'عميل';
      case 'employee':
        return 'موظف';
      case 'payment':
        return 'دفعة';
      case 'lostItem':
        return 'مفقود';
      case 'user':
        return 'مستخدم';
      case 'system':
        return 'النظام';
      default:
        return entityType;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

